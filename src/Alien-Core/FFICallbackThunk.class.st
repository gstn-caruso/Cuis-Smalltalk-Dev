"
An instance of FFICallbackThunk is a reference to a machine-code thunk/trampoline that calls-back into the VM.  The reference can be passed to C code which can use it as a function pointer through which to call-back into Smalltalk.  The machine-code thunk/trampoline is different for each instance, hence its address is a unique key that can be used to associate the Smalltalk side of the call-back (e.g. a block) with the thunk.  Since thunks must be executable and most OSs do not provide default execute permission on memory returned by malloc we do not use malloc directly.  Instead we rely on a primitive to provide memory that is guaranteed to be executable.  The FFICallbackThunk class>>allocateExecutablePage primitive answers an Alien that references an executable piece of memory that is some (possiby unitary) multiple of the pagesize.  Class-side code then parcels out pieces of a page to individual thunks.  These pieces are recycled when thunks are reclaimed.  Since the first byte of a thunk is non-zero we can use it as a flag indicating if the piece is in use or not.

See Callback for the higher-level construct that represents a Smalltalk block to be run in response to a callback.  Callbacks wrap instances of FFICallbackThunk and VMCallbackContext[32|64] instances that describe the stack layout and register contents for receiving callback arguments.

Class Variables
AccessProtect <Semaphore> critical section for ExecutablePages (de)allocation
AllocatedThunks <AlienWeakTable of <FFICallbackThunk -> Integer>> - weak collection of thunks, used to return thunk storage to the executable page pool.
ExecutablePages <Set of: Alien "executable page"> - collection of pages with execute permissions used to provide executable thunks
"
Class {
	#name : 'FFICallbackThunk',
	#superclass : 'Alien',
	#classVars : [
		'AccessProtect',
		'AllocatedThunks',
		'ExecutablePages'
	],
	#classInstVars : [
		'initializer'
	],
	#category : 'Alien-Core',
	#package : 'Alien',
	#tag : 'Core'
}

{ #category : 'executable page management' }
FFICallbackThunk class >> allocateExecutablePage "^<Alien>" [
	"Answer an Alien around a piece of (probably malloced) memory, of some multiple
	 of the pagesize, that has execute permissions set.  This memory can be parcelled
	 out to individual FFICallbackThunks to hold their thunk/trampoline machine code."
	<primitive: 'primAllocateExecutablePage' module: 'IA32ABI' error: errorCode>
	^self primitiveFailed
]

{ #category : 'instance creation' }
FFICallbackThunk class >> dataSize [
	^48 "see FFICallbackThunk initialize & initializeStdcall:; must be big enough for the largest thunk created."
]

{ #category : 'class initialization' }
FFICallbackThunk class >> ensureNotifiedAtStartup [
	"FFICallbackThunk needs to be notified at system startup to clear the ExecutablePages table."
	self ~~ FFICallbackThunk ifTrue: [^self].
	(Smalltalk classNamed: #SessionManager)
		ifNotNil: [:sessionManagerClass|
			sessionManagerClass default
				registerSystemClassNamed: self name
				atPriority: 60]
		ifNil:
			[Alien ensureNotifiedAtStartup.
			Smalltalk addToStartUpList: self after: Alien]
]

{ #category : 'finalization' }
FFICallbackThunk class >> finalize: address [
	self freeBlockInExecutablePage: address
]

{ #category : 'executable page management' }
FFICallbackThunk class >> freeBlockInExecutablePage: address [
	ExecutablePages do:
		[:alienPage| | alienAddress |
		alienAddress := alienPage address.
		(address >= alienAddress
		 and: [alienAddress + alienPage dataSize >= address]) ifTrue:
			[^alienPage replaceFrom: address - alienAddress + 1 to:address - alienAddress + 4 with: #[0 0 0 0] startingAt: 1]]
			
]

{ #category : 'class initialization' }
FFICallbackThunk class >> initialize [
	"FFICallbackThunk initialize"
	AccessProtect := Semaphore forMutualExclusion.
	AllocatedThunks := FinalizationRegistry new.
	ExecutablePages := Set new.
	self ensureNotifiedAtStartup
]

{ #category : 'instance creation' }
FFICallbackThunk class >> initializerForPlatform [
	"Answer the relevant initialize method for a C calling convention thunk on the current platform."
	^Callback abi caseOf: {
	['ARM32']		->	[#initializeARM32].
	['ARMv8']		->	[#initializeARMv8].
	['IA32']			->	[#initializeX86].
	['X64']			->	[#initializeX64].
	['X64Win64']	->	[#initializeX64Win64].
	['RiscV64']		-> [#initializeRiscV64]
	}
]

{ #category : 'instance creation' }
FFICallbackThunk class >> newCCall [
	"Answer a new instance for the C calling-convention."
	^self privateFinalizingNew perform: (initializer ifNil: [initializer := self initializerForPlatform])
]

{ #category : 'instance creation' }
FFICallbackThunk class >> newStdCall: argBytes [
	"Answer a new instance for Windows' StdCall (Pascal) convention, given the
	 size of the arguments in bytes (bytes to cut-back from the stack on return)."
	^self privateFinalizingNew initializeStdcall: argBytes
]

{ #category : 'instance creation' }
FFICallbackThunk class >> privateFinalizingNew [
	"Answer a new instance that will free its page when garbage collected."
	| address answer |
	address := self unusedBlockInExecutablePage.
	answer := self forPointer: address.
	answer toFinalizeSend: #finalize: to: self with: address.
	^answer
]

{ #category : 'class initialization' }
FFICallbackThunk class >> startUp: inANewImageSession [
	"Any thunks in the finalization registry at the time the image comes up in a
	 new session MUST NOT be finalized and should immediately be discarded.
	 Their thunk pointers are no longer valid."

	inANewImageSession ifTrue:
		[AllocatedThunks removeAll.
		ExecutablePages := Set new.
		initializer := nil]
]

{ #category : 'executable page management' }
FFICallbackThunk class >> unusedBlockInExecutablePage [
	"Callback thunks must be executable. This is achieved by allocating one or more executable pages
	 of memory via the allocateExecutablePage, and allocating dataSize sized chunks from them, marking
	 each used chunk with 4 non-zero bytes. We use 'used' as the used marker, until a callback thunk
	 overwrites the chunk with its own machine code, which, at least so far, does not begin with 4 0's.

	 An added complication is that on platforms such as Apple Silicon memory cannot be both executable
	 and writable at the same time.  On these platforms to write to executable memory the memory must
	 be flipped from executability, written to, and then flipped back into executablity (and currently Apple
	 Silicon appears to have no way to do this in a thread-safe manner with more than one thread !!). To
	 achieve this a hook exists in the Alien>>replaceFrom:to:with:startingAt: primAlienReplace primitive
	 that checks for the target being on an executable page, and performs the flips around the write.

	 Note that with e.g. a 4k page size and 40 byte callback thunks an application would have to create
	 over a hundred callbacks before it needed more than one page of executable memory."
	^AccessProtect critical:
		[ExecutablePages do:
			[:alien|
			1 to: alien dataSize - self dataSize by: self dataSize do:
				[:i|
				(alien unsignedLongAt: i) = 0 ifTrue:
					[alien replaceFrom: i to: i + 3 with: 'used' startingAt: 1.
					 ^alien address + i - 1]]].
		 (ExecutablePages add: self allocateExecutablePage)
			replaceFrom: 1 to: 4 with: 'used' startingAt: 1;
			address]
]

{ #category : 'accessing' }
FFICallbackThunk >> address [
	"Thunks are hacked - again they need to be indirect objects with a 0 size field."
	^self addressField
]

{ #category : 'finalization' }
FFICallbackThunk >> finalizationRegistry [
	^AllocatedThunks
]

{ #category : 'memory management' }
FFICallbackThunk >> free [
	"Recycle the memory in the executable page containing the receiver's thunk.
	 Since the receiver is a derived pointer to a block in an executable page this
	 requires returning the block to the free pool."
	AllocatedThunks remove: self.
	AccessProtect critical:
		[| address |
		address := self addressField.
		address ~= 0 ifTrue:
			[self addressFieldPut: 0.
			 self class freeBlockInExecutablePage: address]]
]

{ #category : 'private-instance initalization' }
FFICallbackThunk >> initializeARM32 [
	"Initialize the receiver with a __ccall thunk.  The thunk calls thunkEntry in the Alien/IA32ABI plugin,
	 whose source is in platforms/Cross/plugins/IA32ABI/arm32abicc.c.  thunkEntry is the entry point
	 for Callbacks. The objective of the thunk is to call thunkEntry with all arguments to the call of the
	 thunk (registers and stack) as well as a pointer to the thunk itself.  thunkEntry is as follows:
	
		long long
		thunkEntry(long r0, long r1, long r2, long r3,
		            double d0, double d1, double d2, double d3,
		            double d4, double d5, double d6, double d7,
		            void *thunkpPlus16, sqIntptr_t *stackp)

	thunkEntry then collects the various arguments (thunk, integer register arguments, floating-point
	register arguments, stack pointer) in a VMCallbackContext and invokes the callback via invokeCallbackContext:."

	"0x0 <thunk+0>:		mov     r12, sp			; 0xe1a0c00d
 	 0x4 <thunk+4>:		sub     sp, sp, #16		; 0xe24dd010
 	 0x8 <thunk+8>:		str     pc, [sp, #0]		; 0xe58df000 N.B. passes thunk+16; thunkEntry compensates
 	 0xc <thunk+12>:		str     r12, [sp,#4]		; 0xe58dc004
 	 0x10 <thunk+16>:	str     lr, [sp, #12]		; 0xe58de00c
 	 0x14 <thunk+20>:	ldr     r12, [pc, #8]		; 0xe59fc008
 	 0x18 <thunk+24>:	blx     r12				; 0xe12fff3c
 	 0x1c <thunk+28>:	add     sp, sp, #12		; 0xe28dd00c
 	 0x20 <thunk+32>:	ldr     pc, [sp], #4!		; 0xe49df004 ; pop     {pc}
 	 0x24 <thunk+36>:     .word thunkEntry"
	self
		unsignedLongAt:   1 put: 16rE1A0C00D;
		unsignedLongAt:   5 put: 16rE24DD010;
		unsignedLongAt:   9 put: 16rE58DF000;
		unsignedLongAt: 13 put: 16rE58DC004;
		unsignedLongAt: 17 put: 16rE58DE00C;
		unsignedLongAt: 21 put: 16rE59FC008;
		unsignedLongAt: 25 put: 16rE12FFF3C;
		unsignedLongAt: 29 put: 16rE28DD00C;
		unsignedLongAt: 33 put: 16rE49DF004;
		unsignedLongAt: 37 put: self primThunkEntryAddress

	"self newCCall"
]

{ #category : 'private-instance initalization' }
FFICallbackThunk >> initializeARMv8 [
	"Initialize the receiver with a __ccall thunk.  The thunk calls thunkEntry in the Alien/IA32ABI plugin,
	 whose source is in platforms/Cross/plugins/IA32ABI/arm64abicc.c.  thunkEntry is the entry point
	 for Callbacks. The objective of the thunk is to call thunkEntry with all arguments to the call of the
	 thunk (registers and stack) as well as a pointer to the thunk itself.  thunkEntry is as follows:
	
		long long
		thunkEntry(long x0, long x1, long x2, long x3,
				       long x4, long x5, long x6, long x7,
				       double d0, double d1, double d2, double d3,
				       double d4, double d5, double d6, double d7,
				       void *thunkpPlus20, sqIntptr_t *stackp)

	thunkEntry then collects the various arguments (thunk, integer register arguments, floating-point
	register arguments, stack pointer) in a VMCallbackContext and invokes the callback via invokeCallbackContext:."

	| bytes |
	bytes := #["0		mov	x16, sp"			16rF0 16r03 16r00 16r91
				"4		sub	sp, sp, #0x20"			16rFF 16r83 16r00 16rD1
				"8		stp	x16, x30, [sp, #0x8]"	16rF0 16rFB 16r00 16rA9
				"c		bl		0x10"				16r01 16r00 16r00 16r94
				"10		str		x30, [sp]"			16rFE 16r03 16r00 16rF9
				"14		ldr		x16, #0x14"		16rB0 16r00 16r00 16r58
				"18		blr		x16	"				16r00 16r02 16r3F 16rD6
				 "1C	ldr		x30, [sp, #0x16]"	16rFE 16r0B 16r40 16rF9
				 "20	add		sp, sp, #0x20"		16rFF 16r83 16r00 16r91
				 "24	ret"							16rC0 16r03 16r5F 16rD6
													0 0 0 0 0 0 0 0] copy.
	bytes unsignedLongLongAt: 41 put: self primThunkEntryAddress.
	self replaceFrom: 1 to: 48 with: bytes startingAt: 1

	"self newCCall"
]

{ #category : 'private-instance initalization' }
FFICallbackThunk >> initializeRiscV64 [
	"Initialize the receiver with a __ccall thunk.  The thunk calls thunkEntry in the Alien/IA32ABI plugin,
	 whose source is in platforms/Cross/plugins/IA32ABI/riscv64abicc.c.  thunkEntry is the entry point
	 for Callbacks. The objective of the thunk is to call thunkEntry with all arguments to the call of the
	 thunk (registers and stack) as well as a pointer to the thunk itself.  thunkEntry is as follows:
	
		long long
		thunkEntry(long x0, long x1, long x2, long x3,
				       long x4, long x5, long x6, long x7,
				       double d0, double d1, double d2, double d3,
				       double d4, double d5, double d6, double d7,
				       void *thunkpPlus20, sqIntptr_t *stackp)

	thunkEntry then collects the various arguments 
	(thunk, integer register arguments, floating-point register arguments, stack pointer) 
	in a VMCallbackContext and invokes the callback via invokeCallbackContext:."
"
  0 :	00000297        auipc	t0,0x0    Current PC = self codeAddress (start)
  4 :	1101               	addi	sp,sp,-32   reserve 4 stack slots (1 for alignment)
  6 :	e806                sd		ra,16(sp)	push Return Address
  8 :	e40a                sd		sp,8(sp)	push current Stack Pointer
  c :	e016                sd		t0,0(sp)	push self codeAddress
  c :	02828313        t1,	t0,0x28	start+0x28 is address of &entryThunk
 10:	00033383        ld		t2,0(t1)	get &entryThunk in register
 14 :	9382               	jalr		t2			Call entryThunk()
 16 :	60c2                	ld		ra,16(sp)	Restore saved Return Address
 18 :	6105               	addi	sp,sp,32	Restore Stack Pointer
 20 :	8082               	ret					Return to Mamma
 22 :	0001               	noop				--keep prefetch happy-- 
 24 : 0001				noop
 ... 
 28:   <@entryThunk>
" 
	  "NB: upper & lower instructions swapped"
	self unsignedLongLongAt:  1 put: 16rE806110100000297.  "16r0"
	self unsignedLongLongAt:  9 put: 16r02828313E40AE016.  "16r8"
	self unsignedLongLongAt: 17 put: 16r60C2938200033383. "16r10"
	self unsignedLongLongAt: 25 put: 16r0001000180826105. "16r18"
	self unsignedLongLongAt: 33 put: 16r0001000100010001. 
	self unsignedLongLongAt: 41 put: self primThunkEntryAddress.

	self

	"self newCCall"
]

{ #category : 'private-instance initalization' }
FFICallbackThunk >> initializeStdcall: bytes [
	"Initialize the receiver with a __stdcall thunk with bytes argument bytes."
	Callback abi caseOf: {
	['IA32']		->	[self initializeX86Stdcall: bytes] }
]

{ #category : 'private-instance initalization' }
FFICallbackThunk >> initializeX64 [
	"Initialize the receiver with a __ccall thunk.  The thunk calls thunkEntry in the Alien/IA32ABI plugin,
	 whose source is in platforms/Cross/plugins/IA32ABI/x64sysvabicc.c.  thunkEntry is the entry point
	 for Callbacks. The objective of the thunk is to call thunkEntry with all arguments to the call of the
	 thunk (registers and stack) as well as a pointer to the thunk itself.  thunkEntry is as follows:

		long
		thunkEntry(long a0, long a1, long a2, long a3, long a4, long a5,
		            double d0, double d1, double d2, double d3,
		            double d4, double d5, double d6, double d7,
		            void *thunkp, sqIntptr_t *stackp)

	thunkEntry then collects the various arguments (thunk, integer register arguments, floating-point
	register arguments, stack pointer) in a VMCallbackContext and invokes the callback via invokeCallbackContext:."

	"thunk+0x0:	pushq  %rsp							54
	 thunk+0x1:	pushq  %rsp							54
	 thunk+0x4:	movabsq $thunk, %rax					48 b8 b0..b7 eight bytes of thunk address a.k.a. addressField
	 thunk+0xc:	pushq  %rax							50
	 thunk+0xd:	movabsq $thunkEntry, %rax			48 b8 b0..b7 eight bytes of the thunkEntry address
	 thunk+0x17:	callq  *%rax							ff d0
	 thunk+0x19:	addq   $0x18, %rsp					48 83 c4 18
	 thunk+0x1d:	retq									c3
	 thunk+0x1e:	nop										90
	 thunk+0x1f:	nop										90"
	self
		unsignedLongAt:		  1 put: 16rB8485454;
		unsignedLongLongAt:	  5 put: self addressField;
		unsignedLongAt:		13 put: 16r00B84850; "00 is the first byte of the 64-bit constant the movabsq/0x48 opcode moves"
		unsignedLongLongAt:	16 put: self primThunkEntryAddress;
		unsignedByteAt:		24 put: 16rFF;
		unsignedLongAt:		25 put: 16rC48348D0;
		unsignedLongAt:		29 put: 16r9090C318

	"self newCCall"
]

{ #category : 'private-instance initalization' }
FFICallbackThunk >> initializeX64Win64 [
	"Initialize the receiver with a __ccall thunk.  The thunk calls thunkEntry in the Alien/IA32ABI plugin,
	 whose source is in platforms/Cross/plugins/IA32ABI/x64win64abicc.c.  thunkEntry is the entry point
	 for Callbacks. The objective of the thunk is to call thunkEntry with all arguments to the call of the
	 thunk (registers and stack) as well as a pointer to the thunk itself.  thunkEntry is as follows:

		long long
		thunkEntry(long long rcx, long long rdx,
		      		long long r8, long long r9,
					void *thunkp, sqIntptr_t *stackp)

	thunkEntry then collects the various arguments (thunk, integer register arguments, stack pointer)
	in a VMCallbackContext and invokes the callback via invokeCallbackContext:."

	"thunk+0x0:	pushq  %rsp							54
	 thunk+0x1:	pushq  %rsp							54
	 thunk+0x4:	movabsq $thunk, %rax					48 b8 b0..b7 eight bytes of thunk address a.k.a. addressField
	 thunk+0xc:	pushq  %rax							50
	 thunk+0xd:	subq   $0x20, %rsp						48 83 c4 e0 (this is addq -20 since the immediate is signed extended)
	 thunk+0x11:	movabsq $thunkEntry, %rax			48 b8 b0..b7 eight bytes of the thunkEntry address
	 thunk+0x1b:	callq  *%rax							ff d0
	 thunk+0x1d:	addq   $0x38, %rsp					48 83 c4 38
	 thunk+0x21:	retq									c3
	 thunk+0x22:	nop										90
	 thunk+0x23:	nop										90"
	self
		unsignedLongAt:		  1 put: 16rB8485454;
		unsignedLongLongAt:	  5 put: self addressField;
		unsignedLongAt:		13 put: 16rC4834850; 
		unsignedLongAt:		17 put: 16r00B848E0; "00 is the first byte of the 64-bit constant the movabsq/0x48 opcode moves"
		unsignedLongLongAt:	20 put: self primThunkEntryAddress;
		unsignedByteAt:		28 put: 16rFF;
		unsignedLongAt:		29 put: 16rC48348D0;
		unsignedLongAt:		33 put: 16r9090C338

	"self newCCall"
]

{ #category : 'private-instance initalization' }
FFICallbackThunk >> initializeX86 [
	"Initialize the receiver with a __ccall thunk.  The thunk calls thunkEntry in the Alien/IA32ABI plugin,
	 whose source is in platforms/Cross/plugins/IA32ABI/x64win64abicc.c.  thunkEntry is the entry point
	 for Callbacks. The objective of the thunk is to call thunkEntry with all arguments to the call of the
	 thunk (registers and stack) as well as a pointer to the thunk itself.  thunkEntry is as follows:

		long
		thunkEntry(void *thunkp, sqIntptr_t *stackp)

	thunkEntry then collects the various arguments (thunk, stack pointer) in a VMCallbackContext and
	invokes the callback via invokeCallbackContext:."

	"thunk:		push   %esp				0x54							0xa1905454
	 thunk+01:	push   %esp				0x54
	 thunk+02:	nop   						0x90
	 thunk+03:	mov    $thunkEntry,%eax	0xb8 0x00 0x00 0x00 0x00	0x00000000 - entry
	 thunk+08:	nop   						0x90							0x68909090
	 thunk+09:	nop   						0x90
	 thunk+10:	nop   						0x90
	 thunk+11:	push   $thunk				0x68 0x00 0x00 0x00 0x00	0x00000000 - thunk
	 thunk+16:	call   *%eax					0xff 0xd0						0xc483d0ff
	 thunk+18:	add    $0xC,%esp			0x83 0xc4 0x0C				0x9090c30C
	 thunk+21:	ret							0xc3
	 thunk+22:	nop							0x90
	 thunk+23:	nop							0x90"
	self
		unsignedLongAt:  1 put: 16rB8905454;
		unsignedLongAt:  5 put: self primThunkEntryAddress;
		unsignedLongAt:  9 put: 16r68909090;
		unsignedLongAt: 13 put: self addressField;
		unsignedLongAt: 17 put: 16rC483D0FF;
		unsignedLongAt: 21 put: 16r9090C30C
]

{ #category : 'private-instance initalization' }
FFICallbackThunk >> initializeX86Stdcall: bytes [
	"Initialize the receiver with a __stdcall thunk with bytes argument bytes. (See initializeX86 fort more info)"
	"thunk:		push   %esp				0x54							0xa1905454
	 thunk+01:	push   %esp				0x54
	 thunk+02:	nop   						0x90
	 thunk+03:	mov    $thunkEntry,%eax	0xb8 0x00 0x00 0x00 0x00	0x00000000 - entry
	 thunk+08:	nop   						0x90							0x68909090
	 thunk+09:	nop   						0x90
	 thunk+10:	nop   						0x90
	 thunk+11:	push   $thunk				0x68 0x00 0x00 0x00 0x00	0x00000000 - thunk
	 thunk+16:	call   *%eax					0xff 0xd0						0xc483d0ff
	 thunk+18:	add    $0xC,%esp			0x83 0xc4 0x0C				0xBYTSc20C
	 thunk+21:	ret    $bytes				0xc2 0xBY 0xTS"

	self
		unsignedLongAt:  1 put: 16rB8905454;
		unsignedLongAt:  5 put: self primThunkEntryAddress;
		unsignedLongAt:  9 put: 16r68909090;
		unsignedLongAt: 13 put: self addressField;
		unsignedLongAt:  17 put: 16rC483D0FF;
		unsignedShortAt: 21 put: 16rC20C;
		unsignedShortAt: 23 put: bytes
]

{ #category : 'primitives-memory management' }
FFICallbackThunk >> primFree [
	self shouldNotImplement
]

{ #category : 'private-primitives' }
FFICallbackThunk >> primThunkEntryAddress "^<Integer>" [
	"Answer the address of the entry-point for thunk callbacks:
		x86: long thunkEntry(void *thunkp, long *stackp);
		x64: long thunkEntry(long a, long b, long c, long d, long, e, long f,
								double d0, double d1, double d2, double d3,
								double d4, double d5, double d6, double d7,
								void *thunkp, long *stackp);
		ARM: long thunkEntry(long a, long b, long c, long d,
								double d0, double d1, double d2, double d3,
								double d4, double d5, double d6, double d7,
								void *thunkp, long *stackp);
	 etc.
	 This is the function a callback thunk/trampoline should call to initiate a callback."
	<primitive: 'primThunkEntryAddress' module: 'IA32ABI' error: errorCode>
	^self primitiveFailed
]

{ #category : 'accessing' }
FFICallbackThunk >> thunk [
	"For polymorphism and coercion with Callback>>thunk, which answers an instance of me.
	 Instead of answering an error if a client sends thunk to a Callback's thunk, just answer self."
	^self
]
