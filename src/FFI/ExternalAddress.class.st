"
An ExternalAddress is an opaque handle to objects outside Smalltalk memory (e.g., a pointer).
"
Class {
	#name : 'ExternalAddress',
	#superclass : 'ByteArray',
	#classInstVars : [
		'wordSize'
	],
	#category : 'FFI-Kernel',
	#package : 'FFI',
	#tag : 'Kernel'
}

{ #category : 'instance creation' }
ExternalAddress class >> allocate: byteSize [
	"Primitive. Allocate an object on the external heap."
	<primitive: #primitiveFFIAllocate module: #SqueakFFIPrims error: ec>
	^self primitiveFailed
]

{ #category : 'instance creation' }
ExternalAddress class >> fromInteger: address [
	"Create an instance. address must be a non-negative integer.
	 Use a ByteArray to be able to send #integerAt:put:size:signed: and have it operate
	 on the pointer bytes and not on the (as yet undefined!) pointed to memory.
	Primitive integerAt:put:size:signed: will use the appropriate endianess for this platform.
	See also ExternalAddress >> #asInteger"
	"
	(ExternalAddress fromInteger: 12345678) asInteger
	"
	<primitive: #primitiveExternalAddressFromInteger module: #SqueakFFIPrims>
	| pointerBytes |
	pointerBytes := ByteArray new: wordSize.
	pointerBytes integerAt: 1 put: address size: wordSize signed: false.
	ExternalAddress adoptInstance: pointerBytes.
	^pointerBytes
]

{ #category : 'instance creation' }
ExternalAddress class >> gcallocate: byteSize [
	"Primitive. Allocate an object on the external heap.
	The external memory will be freed when i am garbage collected.
	BEWARE: there should be no copy of self, nor any pointer to a sub part..."
	
	| externalAddress |
	externalAddress := self allocate: byteSize.
	self finalizationRegistry add: externalAddress.
	^externalAddress
]

{ #category : 'class initialization' }
ExternalAddress class >> initialize [
	wordSize := Smalltalk wordSize
]

{ #category : 'instance creation' }
ExternalAddress class >> loadSymbol: moduleSymbol module: module  [
	<primitive: #primitiveLoadSymbolFromModule module: #SqueakFFIPrims error: ec>
	^ self primitiveFailed
]

{ #category : 'instance creation' }
ExternalAddress class >> new: n [
	"Only create ExternalAddresses of the right size."
	^n = wordSize
		ifTrue: [super new: n]
		ifFalse: [self shouldNotImplement]
]

{ #category : 'instance creation' }
ExternalAddress class >> numElements [
	"External addresses are either four or eight bytes long."
	^ wordSize
]

{ #category : 'class initialization' }
ExternalAddress class >> startUp: resuming [
	"If starting the image afresh all external addresses should be zero.
	 In addition, if the word size has changed then external addresses shoiuld be resized.
	 The two steps are combined for efficiency."
	resuming ifTrue:
		[| instances |
		 instances := self allInstances.
		 wordSize ~= Smalltalk wordSize
			ifTrue: "Implement nulling by becomming all existing instances to new (and hence null) pointers of the right size."
				[wordSize := Smalltalk wordSize.
				 instances elementsForwardIdentityTo: (instances collect: [:ea| self basicNew: wordSize])]
			ifFalse:
				[instances do: [:addr| addr beNull]]]
]

{ #category : 'accessing' }
ExternalAddress class >> wordSize [
	^wordSize
]

{ #category : 'arithmetic' }
ExternalAddress >> + offset [
	"Answer an address that is offset by the given number of bytes."

	^ExternalAddress fromInteger: self asInteger + offset
]

{ #category : 'private' }
ExternalAddress >> asByteArrayPointer [
	"Only kept for compatibility.
	Prefer #asByteArrayWithPointer"

	^self asByteArrayWithPointer
]

{ #category : 'private' }
ExternalAddress >> asByteArrayWithPointer [
	"Answer a ByteArray containing a copy of the pointer in the receiver.
	Useful when we specifically need an instance of ByteArray and not an instance of ExternalAddress.
	For example, to use data access primitive in SqueakFFIPrims, such as:
		primitiveFFIIntegerAt
		primitiveFFIIntegerAtPut,
	but have them operate on pointer data, and not on actual data pointed by it.
	See #asExternalAddress"

	| sz |
	^(ByteArray basicNew: (sz := self size))
		replaceFrom: 1 to: sz with: self startingAt: 1.
]

{ #category : 'private' }
ExternalAddress >> asExternalAddress [
	"Answer an instance of ExternalAddress, with my contents, assuming they form a pointer.
	See inheritance.
	See #asByteArrayWithPointer"

	^self
]

{ #category : 'converting' }
ExternalAddress >> asInteger [
	"Convert address to integer.
	 Convert to a ByteArray in order to access the pointer bytes instead of the bytes pointed to!
	Primitive integerAt:size:signed: will use the appropriate endianess for this platform.
	See also ExternalAddress class >> #fromInteger:"
	<primitive: #primitiveExternalAddressAsInteger module: #SqueakFFIPrims>
	| clone |
	clone := self shallowCopy.
	ByteArray adoptInstance: clone.
	^clone integerAt: 1 size: self size signed: false
]

{ #category : 'initialize-release' }
ExternalAddress >> beNull [
	"Make the receiver a NULL pointer"
	self atAllPut: 0.
]

{ #category : 'initialize-release' }
ExternalAddress >> finalize [
	"I am an executor (a copy) of an ExternalAddress that was just garbage collected.
	I must finalize. my mission is to free memory"
	self isNull ifTrue: [^self].
	self free
]

{ #category : 'initialize-release' }
ExternalAddress >> free [
	self isNull ifFalse: [
		self primFree.
		self isNull ifTrue: [
			"A possible error is explicitly freeing something that was allocated via #gcallocate:.
			To avoid the double free hazzard, ensure I'm not finalized."
			self class finalizationRegistry remove: self ifAbsent: nil ]].
]

{ #category : 'testing' }
ExternalAddress >> is: aSymbol [
	^#ExternalAddress = aSymbol or: [ super is: aSymbol ]
]

{ #category : 'testing' }
ExternalAddress >> isNull [
	"Answer true if I am a null pointer"
	1 to: self size do:[:i| (self at: i) = 0 ifFalse:[^false]].
	^true
]

{ #category : 'initialize-release' }
ExternalAddress >> primFree [
	"Primitive. Free the object pointed to on the external heap.
	Dangerous - may break your system if the receiver hasn't been
	allocated by ExternalAddress class>>allocate:. No checks are done."
	<primitive: #primitiveFFIFree module: #SqueakFFIPrims>
	^self primitiveFailed
]

{ #category : 'printing' }
ExternalAddress >> printOn: aStream [
	"print this as a hex address ('@ 16rFFFFFFFF') to distinguish it from ByteArrays"

	aStream nextPutAll: '@ '; nextPutAll: self asInteger hex8
]
