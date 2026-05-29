"
An external type represents the type of external objects.

Instance variables:
	compiledSpec	<WordArray>		Compiled specification of the external type
	referentClass	<Behavior | nil>	Class type of argument required
	referencedType	<ExternalType>	Associated (non)pointer type with the receiver
	byteAlignment	<Integer | nil>		The desired alignment for a field of the external type within a structure.  If nil it has yet to be computed.

Compiled Spec:
The compiled spec defines the type in terms which are understood by the VM. Each word is defined as:
	bits 0...15 	- byte size of the entity
	bit 16		- structure flag (FFIFlagStructure)
				  This flag is set if the following words define a structure
	bit 17		- pointer flag (FFIFlagPointer)
				  This flag is set if the entity represents a pointer to another object
	bit 18		- atomic flag (FFIFlagAtomic)
				  This flag is set if the entity represents an atomic type.
				  If the flag is set the atomic type bits are valid.
	bits 19...23	- unused
	bits 24...27	- atomic type (FFITypeVoid ... FFITypeDoubleFloat)
	bits 28...30	- unused
	bit 31		- variadic arg flag FFIFlagVariadic
				  This flag is set for a variadic argument, and is automatically applied to all arguments following a '...' punctuator

Note that all combinations of the flags FFIFlagPointer, FFIFlagAtomic, and FFIFlagStructure are invalid, EXCEPT from the following:

	FFIFlagPointer + FFIFlagAtomic:
		This defines a pointer to an atomic type (e.g., 'char*', 'int*').
		The actual atomic type is represented in the atomic type bits.

	FFIFlagPointer + FFIFlagStructure:
		This defines a structure which is a typedef of a pointer type as in
			typedef void* VoidPointer;
			typedef Pixmap* PixmapPtr;
		It requires a byte size of four or eight (e.g. a 32-bit or 64-bit pointer) to work correctly.

[Note: Other combinations may be allowed in the future]

"
Class {
	#name : 'ExternalType',
	#superclass : 'Object',
	#instVars : [
		'compiledSpec',
		'referentClass',
		'referencedType',
		'pointerSize'
	],
	#classVars : [
		'AtomicSelectors',
		'AtomicTypeNames',
		'AtomicTypes',
		'StructTypes'
	],
	#pools : [
		'FFIConstants'
	],
	#category : 'FFI-Kernel',
	#package : 'FFI',
	#tag : 'Kernel'
}

{ #category : 'private' }
ExternalType class >> atomicTypeNamed: aString [
	| n oldTypeNames newTypeNames |
	n := aString.
	n = 'size_t' ifTrue: [
		n := Smalltalk wordSize = 8 ifTrue: [ 'uint64' ] ifFalse: [ 'uint32' ]].
	n = 'uint3264' ifTrue: [
		n := Smalltalk wordSize = 8 ifTrue: [ 'uint64' ] ifFalse: [ 'uint32' ]].
	n = 'int3264' ifTrue: [
		n := Smalltalk wordSize = 8 ifTrue: [ 'int64' ] ifFalse: [ 'int32' ]].
	oldTypeNames := #(byte sbyte ushort short ulong long ulonglong longlong).
	newTypeNames := #(uint8 int8 uint16 int16 uint32 int32 uint64 int64).
	(oldTypeNames statePointsTo: n asSymbol) ifTrue: [
		n := (newTypeNames at: (oldTypeNames indexOf: n asSymbol)) asString ].
	^AtomicTypes at: n ifAbsent:[nil]
]

{ #category : 'type constants' }
ExternalType class >> bool [
	^AtomicTypes at: 'bool'
]

{ #category : 'old type constants' }
ExternalType class >> byte [
	"byte defaults to unsigned byte"
	^self uint8
]

{ #category : 'type constants' }
ExternalType class >> char [
	"char defaults to unsigned char"
	^self unsignedChar
]

{ #category : 'housekeeping' }
ExternalType class >> cleanupUnusedTypes [
	"ExternalType cleanupUnusedTypes"
	| value |
	StructTypes keys do:[:key|
		value := StructTypes at: key.
		value == nil ifTrue:[StructTypes removeKey: key ifAbsent:[]]].
]

{ #category : 'type constants' }
ExternalType class >> double [
	^AtomicTypes at: 'double'
]

{ #category : 'type constants' }
ExternalType class >> float [
	^AtomicTypes at: 'float'
]

{ #category : 'private' }
ExternalType class >> forceTypeNamed: aString [
	^self newTypeNamed: aString force: true
]

{ #category : 'class initialization' }
ExternalType class >> initialize [
	"
	AtomicTypes := nil.
	ExternalType initialize
	"
	self initializeFFIConstants.
	self initializeDefaultTypes.
]

{ #category : 'class initialization' }
ExternalType class >> initializeAtomicTypes [
	"ExternalType initialize"
	| atomicType byteSize type typeName |
	#(
		"name			atomic id				byte size"
		('void' 			0 				0)
		('bool' 			1 				1)
		('uint8' 			2 				1)
		('int8' 			3 				1)
		('uint16' 			4 				2)
		('int16' 			5 				2)
		('uint32' 			6 				4)
		('int32' 			7 				4)
		('uint64' 			8 				8)
		('int64' 			9 				8)
		('char' 			10 				1)
		('schar' 			11 				1)
		('float' 			12 				4)
		('double' 			13 				8)
	) do: [ :typeSpec | | compiled |
		typeName := typeSpec first.
		atomicType := typeSpec second.
		byteSize := typeSpec third.
		compiled := WordArray with: ((byteSize bitOr: FFIFlagAtomic) bitOr:
				(atomicType bitShift: FFIAtomicTypeShift)).
		type := (AtomicTypes at: typeName).
		type compiledSpec: compiled.
		compiled := WordArray with: ((self pointerSpec bitOr: FFIFlagAtomic) bitOr:
				(atomicType bitShift: FFIAtomicTypeShift)).
		type asPointerType compiledSpec: compiled.
	].
]

{ #category : 'class initialization' }
ExternalType class >> initializeDefaultTypes [
	"ExternalType initialize"
	| type pointerType |
	AtomicTypes = nil ifTrue:[
		"Create new atomic types and setup the dictionaries"
		AtomicTypes := Dictionary new.
		StructTypes := WeakValueDictionary new.
		AtomicTypeNames valuesDo:[:k|
			type := self basicNew.
			pointerType := self basicNew.
			AtomicTypes at: k put: type.
			type setReferencedType: pointerType.
			pointerType setReferencedType: type.
		].
	].
	self initializeAtomicTypes.
	self initializeStructureTypes.
	"AtomicTypes := nil"
]

{ #category : 'class initialization' }
ExternalType class >> initializeFFIConstants [
	"ExternalType initialize"
	FFIConstants initialize. "ensure proper initialization"
	AtomicTypeNames := IdentityDictionary new.
	AtomicSelectors := IdentityDictionary new.
	AtomicTypeNames
		at: FFITypeVoid put: 'void';
		at: FFITypeBool put: 'bool';
		at: FFITypeUint8 put: 'uint8';
		at: FFITypeInt8 put: 'int8';
		at: FFITypeUint16 put: 'uint16';
		at: FFITypeInt16 put: 'int16';
		at: FFITypeUint32 put: 'uint32';
		at: FFITypeInt32 put: 'int32';
		at: FFITypeUint64 put: 'uint64';
		at: FFITypeInt64 put: 'int64';
		at: FFITypeUnsignedChar put: 'char';
		at: FFITypeSignedChar put: 'schar';
		at: FFITypeSingleFloat put: 'float';
		at: FFITypeDoubleFloat put: 'double';
	yourself.

	AtomicSelectors
		at: FFITypeVoid put: #voidAt:;
		at: FFITypeBool put: #booleanAt:;
		at: FFITypeUint8 put: #uint8At:;
		at: FFITypeInt8 put: #int8At:;
		at: FFITypeUint16 put: #uint16At:;
		at: FFITypeInt16 put: #int16At:;
		at: FFITypeUint32 put: #uint32At:;
		at: FFITypeInt32 put: #int32At:;
		at: FFITypeUint64 put: #uint64At:;
		at: FFITypeInt64 put: #int64At:;
		at: FFITypeUnsignedChar put: #unsignedCharAt:;
		at: FFITypeSignedChar put: #signedCharAt:;
		at: FFITypeSingleFloat put: #floatAt:;
		at: FFITypeDoubleFloat put: #doubleAt:;
	yourself
]

{ #category : 'class initialization' }
ExternalType class >> initializeStructureTypes [
	"ExternalType initialize"
	| referentClass pointerType |
	self cleanupUnusedTypes.
	StructTypes keysAndValuesDo:[:referentName :type|
		referentClass := (Smalltalk at: referentName ifAbsent:[nil]).
		(referentClass isBehavior and:[
			referentClass includesBehavior: ExternalStructure])
				ifFalse:[referentClass := nil].
		type compiledSpec: 
			(WordArray with: self structureSpec).
		type newReferentClass: referentClass.
		pointerType := type asPointerType.
		pointerType compiledSpec: 
			(WordArray with: self pointerSpec).
		pointerType newReferentClass: referentClass.
	].
]

{ #category : 'type constants' }
ExternalType class >> int16 [
	^AtomicTypes at: 'int16'
]

{ #category : 'type constants' }
ExternalType class >> int32 [
	^AtomicTypes at: 'int32'
]

{ #category : 'type constants' }
ExternalType class >> int3264 [
	"32 or 64 bits, depending on the platform"
	^Smalltalk wordSize = 8
		ifTrue: [ self int64 ]
		ifFalse: [ self int32 ].
]

{ #category : 'type constants' }
ExternalType class >> int64 [
	^AtomicTypes at: 'int64'
]

{ #category : 'type constants' }
ExternalType class >> int8 [
	^AtomicTypes at: 'int8'
]

{ #category : 'old type constants' }
ExternalType class >> long [
	^self int32
]

{ #category : 'instance creation' }
ExternalType class >> new [
	"Use either the type constants or #externalType for creating external types"
	^self shouldNotImplement
]

{ #category : 'private' }
ExternalType class >> newTypeNamed: aString force: aBool [
	| sym type referentClass pointerType |
	sym := aString asSymbol.
	type := StructTypes at: aString ifAbsent:[nil].
	type == nil ifFalse:[^type].
	referentClass := Smalltalk at: sym ifAbsent:[nil].
	(referentClass isBehavior and:[referentClass includesBehavior: ExternalStructure])
		ifFalse:[referentClass := nil].
	"If we don't have a referent class and are not forced to create a type get out"
	(referentClass == nil and:[aBool not]) ifTrue:[^nil].
	type := self basicNew compiledSpec: 
		(WordArray with: self structureSpec).
	pointerType := self basicNew compiledSpec: 
		(WordArray with: self pointerSpec).
	type setReferencedType: pointerType.
	pointerType setReferencedType: type.
	type newReferentClass: referentClass.
	pointerType newReferentClass: referentClass.
	StructTypes at: sym put: type.
	^type
]

{ #category : 'housekeeping' }
ExternalType class >> noticeModificationOf: aClass [
	"A subclass of ExternalStructure has been redefined.
	Clean out any obsolete references to its type."
	| type |
	aClass isBehavior ifFalse:[^nil]. "how could this happen?"
	aClass withAllSubclassesDo:[:cls|
		type := StructTypes at: cls name ifAbsent:[nil].
		type == nil ifFalse:[
			type newReferentClass: cls.
			type asPointerType newReferentClass: cls].
	].
]

{ #category : 'housekeeping' }
ExternalType class >> noticeRemovalOf: aClass [
	"A subclass of ExternalStructure is being removed.
	Clean out any obsolete references to its type."
	| type |
	type := StructTypes at: aClass name ifAbsent:[nil].
	type == nil ifFalse:[
		type newReferentClass: nil.
		type asPointerType newReferentClass: nil].

]

{ #category : 'housekeeping' }
ExternalType class >> noticeRenamingOf: aClass from: oldName to: newName [
	"An ExternalStructure has been renamed from oldName to newName.
	Keep our type names in sync."
	| type |
	type := StructTypes at: oldName ifAbsent:[nil].
	type == nil ifFalse:[StructTypes at: newName put: type].
	StructTypes removeKey: oldName ifAbsent:[].
]

{ #category : 'private' }
ExternalType class >> pointerSpec [
	^(Smalltalk wordSize bitOr: FFIFlagPointer)
]

{ #category : 'query' }
ExternalType class >> primitiveAlignmentOf: atomicTypeCode [
	"Answer the platform C compiler's alignment in a structure of an element of the
	 C type corresponding to atomicTypeCode, where atomicTypeCode is in the range
	 FFITypeUint8 (2) to FFITypeDoubleFloat (13), or is FFIFlagStructure (65536)."
	<primitive: #primitiveStructureElementAlignment module: #SqueakFFIPrims>
	self primitiveFailed

	"(FFITypeUint8 to: FFITypeDoubleFloat), {FFIFlagStructure} collect: [:n| self primitiveAlignmentOf: n]"
]

{ #category : 'query' }
ExternalType class >> primitiveCDataModel [
	"Answer the name for the platform C compiler's data model, ILP32, LP64, et al."
	<primitive: #primitiveCDataModel module: #SqueakFFIPrims error: ec>
	self primitiveFailed

	"self primitiveCDataModel"
]

{ #category : 'query' }
ExternalType class >> primitiveSizesInto: aByteArrayOfSizeNine [
	"Answer the platform C compiler's sizes for char, short, int, long, long long, wchar_t, float, double, void *."
	<primitive: #primitiveCDataModel module: #SqueakFFIPrims error: ec>
	self primitiveFailed

	"(#(char short int long #'long long' wchar_t float double #'void *')
		with: (self primitiveSizesInto: (ByteArray new: 9))
		collect: [:n :s| {n. s}]) flatten"
]

{ #category : 'old type constants' }
ExternalType class >> sbyte [
	^self int8
]

{ #category : 'type constants' }
ExternalType class >> schar [
	^self signedChar
]

{ #category : 'old type constants' }
ExternalType class >> short [
	^self int16
]

{ #category : 'old type constants' }
ExternalType class >> signedByte [
	^self int8
]

{ #category : 'type constants' }
ExternalType class >> signedChar [
	^AtomicTypes at: 'schar'
]

{ #category : 'old type constants' }
ExternalType class >> signedLong [
	^self int32
]

{ #category : 'old type constants' }
ExternalType class >> signedLongLong [
	^self int64
]

{ #category : 'old type constants' }
ExternalType class >> signedShort [
	^self int16
]

{ #category : 'type constants' }
ExternalType class >> string [
	^(AtomicTypes at: 'char') asPointerType
]

{ #category : 'private' }
ExternalType class >> structTypeNamed: aSymbol [
	aSymbol == nil ifTrue:[^nil].
	^self newTypeNamed: aSymbol force: false
]

{ #category : 'private' }
ExternalType class >> structureSpec [
	^FFIFlagStructure
]

{ #category : 'type constants' }
ExternalType class >> uint16 [
	^AtomicTypes at: 'uint16'
]

{ #category : 'type constants' }
ExternalType class >> uint32 [
	^AtomicTypes at: 'uint32'
]

{ #category : 'type constants' }
ExternalType class >> uint64 [
	^AtomicTypes at: 'uint64'
]

{ #category : 'type constants' }
ExternalType class >> uint8 [
	^AtomicTypes at: 'uint8'
]

{ #category : 'old type constants' }
ExternalType class >> ulong [
	^self uint32
]

{ #category : 'old type constants' }
ExternalType class >> unsignedByte [
	^self uint8
]

{ #category : 'type constants' }
ExternalType class >> unsignedChar [
	^AtomicTypes at: 'char'
]

{ #category : 'old type constants' }
ExternalType class >> unsignedLong [
	^self uint32
]

{ #category : 'old type constants' }
ExternalType class >> unsignedLongLong [
	^self uint64
]

{ #category : 'old type constants' }
ExternalType class >> unsignedShort [
	^self uint16
]

{ #category : 'old type constants' }
ExternalType class >> ushort [
	^self uint16
]

{ #category : 'type constants' }
ExternalType class >> void [
	^AtomicTypes at: 'void'
]

{ #category : 'converting' }
ExternalType >> asNonPointerType [
	"convert the receiver into a non pointer type"
	self isPointerType
		ifTrue:[^referencedType]
		ifFalse:[^self]
]

{ #category : 'converting' }
ExternalType >> asPointerType [
	"convert the receiver into a pointer type"
	self isPointerType
		ifTrue:[^self]
		ifFalse:[^referencedType]
]

{ #category : 'converting' }
ExternalType >> asPointerType: aPointerSize [
	"convert the receiver into a pointer type"
	| type |
	type := self asPointerType.
	^type pointerSize = aPointerSize
		ifTrue: [type]
		ifFalse:
			[type copy pointerSize: aPointerSize; yourself]
]

{ #category : 'accessing' }
ExternalType >> atomicType [
	^(self headerWord bitAnd: FFIAtomicTypeMask) >> FFIAtomicTypeShift
]

{ #category : 'accessing' }
ExternalType >> byteSize [
	"Return the size in bytes of this type"
	^self headerWord bitAnd: FFIStructSizeMask
]

{ #category : 'accessing' }
ExternalType >> compiledSpec [
	"Return the compiled spec of the receiver"
	^compiledSpec
]

{ #category : 'private' }
ExternalType >> compiledSpec: aWordArray [
	compiledSpec := aWordArray.
]

{ #category : 'private' }
ExternalType >> embeddedSpecWithSize: typeSize [
	"Return a compiled spec for embedding in a new compiled spec."
	| spec header |
	spec := self compiledSpec copy.
	header := spec at: 1.
	header := (header bitAnd: FFIStructSizeMask bitInvert32) bitOr: typeSize.
	spec at: 1 put: header.
	(self isStructureType and:[self isPointerType not])
		ifTrue:[spec := spec copyWith: self class structureSpec].
	^spec
]

{ #category : 'private' }
ExternalType >> externalTypeName [
	^'ExternalType ', (AtomicTypeNames at: self atomicType), ' asPointerType'
]

{ #category : 'private' }
ExternalType >> headerWord [
	"Return the compiled header word"
	^compiledSpec at: 1
]

{ #category : 'testing' }
ExternalType >> isAtomic [
	"Return true if the receiver describes a built-in type"
	^self headerWord anyMask: FFIFlagAtomic
]

{ #category : 'testing' }
ExternalType >> isIntegerType [
	"Return true if the receiver is a built-in integer type"
	| type |
	type := self atomicType.
	^type > FFITypeBool and:[type <= FFITypeInt64]
]

{ #category : 'testing' }
ExternalType >> isPointerType [
	"Return true if the receiver represents a pointer type"
	^self isStructureType not and:[self headerWord anyMask: FFIFlagPointer]
]

{ #category : 'testing' }
ExternalType >> isPunctuator [
	^false
]

{ #category : 'testing' }
ExternalType >> isSigned [
	"Return true if the receiver is a signed type.
	Note: Only useful for integer types."
	^self atomicType anyMask: 1
]

{ #category : 'testing' }
ExternalType >> isStructureType [
	"Return true if the receiver represents a structure type"
	^self headerWord anyMask: FFIFlagStructure
]

{ #category : 'testing' }
ExternalType >> isUnsigned [
	"Return true if the receiver is an unsigned type.
	Note: Only useful for integer types."
	^self isSigned not
]

{ #category : 'testing' }
ExternalType >> isVoid [
	"Return true if the receiver describes a plain 'void' type"
	^self isAtomic and:[self atomicType = 0]
]

{ #category : 'private' }
ExternalType >> newReferentClass: aClass [
	"The class I'm referencing has changed. Update my spec."
	referentClass := aClass.
	self isPointerType ifTrue:[^self]. "for pointers only the referentClass changed"
	referentClass == nil ifTrue:[
		"my class has been removed - make me 'struct { void }'"
		compiledSpec := WordArray with: (FFIFlagStructure).
	] ifFalse:[
		"my class has been changed - update my compiledSpec"
		compiledSpec := referentClass compiledSpec.
	].
]

{ #category : 'accessing' }
ExternalType >> pointerSize [
	"Answer the pointer size of the receiver, if specified."
	^pointerSize
]

{ #category : 'private' }
ExternalType >> pointerSize: anInteger [
	| spec |
	pointerSize := anInteger.
	(((spec := compiledSpec at: 1) anyMask: FFIFlagPointer)
	 and: [(spec bitAnd: FFIStructSizeMask) ~= anInteger]) ifTrue:
		[compiledSpec := compiledSpec shallowCopy.
		 compiledSpec at: 1 put: (spec bitClear: FFIStructSizeMask) + anInteger]
]

{ #category : 'printing' }
ExternalType >> printAtomicType: spec on: aStream [
	self assert: (spec anyMask: FFIFlagAtomic).
	aStream nextPutAll: (#(	'void' 'unsigned char' 'unsigned char' 'signed char'
							'uint16' 'int16'
							'uint32' 'int32'
							'uint64' 'int64'
							'char' 'signed char'
							'float' 'double') at:
						((spec bitAnd: FFIAtomicTypeMask) bitShift: FFIAtomicTypeShift negated) + 1).
	aStream space.
	(spec anyMask: FFIFlagPointer) ifTrue:
		[aStream nextPut: $*]
]

{ #category : 'printing' }
ExternalType >> printOn: aStream [
	referentClass == nil
		ifTrue:[aStream nextPutAll: (AtomicTypeNames at: self atomicType)]
		ifFalse:[aStream nextPutAll: referentClass name].
	self isPointerType ifTrue:[aStream nextPut: $*].
]

{ #category : 'printing' }
ExternalType >> printStructureFieldStartingAt: initialSpecIndex withName: name inClass: structureClass on: aStream indent: indent [
	"Print the structure's field starting at initialSpecIndex and answer the index in compiledSpec of the subsequent type."
	| spec subStructureClassBinding |
	aStream tab: indent.
	spec := compiledSpec at: initialSpecIndex.
	(spec anyMask: FFIFlagAtomic) ifTrue:
		[self printAtomicType: spec on: aStream.
		 aStream nextPutAll: (name ifNotNil: [name] ifNil: ['foo']).
		 ^initialSpecIndex + 1].
	 subStructureClassBinding := (structureClass >> name) literals detect:
									[:l| l isVariableBinding and: [l value inheritsFrom: ExternalStructure]].
	(spec bitClear: FFIStructSizeMask) = FFIFlagStructure ifTrue:
		[| next |
		 next := initialSpecIndex + 1.
		 aStream
			nextPutAll: subStructureClassBinding value compositeName;
			nextPutAll: ' {'.
		 subStructureClassBinding value fields withIndexDo:
			[:tuple :i|
			aStream newLine.
			next := self printStructureFieldStartingAt: next
						withName: tuple first
						inClass: subStructureClassBinding value
						on: aStream
						indent: indent + 1.
			aStream nextPut: $;].
		 aStream newLine; tab: indent; nextPut: $}.
		 name ifNotNil: [aStream space; nextPutAll: name].
		 self assert: (next - 1 = compiledSpec size or: [(compiledSpec at: next) = FFIFlagStructure]).
		 ^next <= compiledSpec size ifTrue: [next + 1] ifFalse: [next]].
	self assert: (spec anyMask: FFIFlagPointer).


self halt.
	(subStructureClassBinding value isKindOf: ExternalUnion)
			ifTrue: [aStream nextPutAll: 'union ']
			ifFalse: [aStream nextPutAll: 'struct '].
"	aStream nextPutAll: subStructureClassBinding value compositeName."




	aStream nextPutAll: subStructureClassBinding value name; nextPutAll: ' *'; nextPutAll: name.
	^initialSpecIndex + 1
]

{ #category : 'printing' }
ExternalType >> printTypedefOn: s [
	s nextPutAll: 'typedef '.
	(referentClass notNil
	 and: [(compiledSpec first bitClear: FFIStructSizeMask) = FFIFlagStructure])
		ifTrue:
			[| next |
			 next := 2.
			 s
				nextPutAll: referentClass compositeName;
				nextPutAll: ' {'.
			 referentClass fields withIndexDo:
				[:tuple :i|
				s newLine.
				next := self printStructureFieldStartingAt: next
							withName: tuple first
							inClass: referentClass
							on: s
							indent: 1.
				s nextPut: $;].
			 s newLine; nextPutAll: '} '.
			 self assert: (next - 1 = compiledSpec size or: [(compiledSpec at: next) = FFIFlagStructure])]
		ifFalse:
			[self printAtomicType: compiledSpec first on: s].
	s nextPutAll: (referentClass ifNotNil: [referentClass name] ifNil: ['foo'])
]

{ #category : 'private' }
ExternalType >> readFieldAt: byteOffset [
	"Answer a string defining the accessor to an entity of the receiver type starting at the given byte offset. 
	 Private. Used for field definition only."
	^String streamContents:
		[:s|
		self isPointerType
			ifTrue:
				[| accessor |
				 accessor := self pointerSize caseOf: {
								[nil]	->	[#pointerAt:].
								[4]	->	[#pointer32At:].
								[8]	->	[#pointer64At:] }.
				 referentClass
					ifNil:
						[s	nextPutAll: '^ExternalData fromHandle: (handle ';
							nextPutAll: accessor;
							space; print: byteOffset;
							nextPutAll: ') type: ExternalType ';
							nextPutAll: (AtomicTypeNames at: self atomicType);
							nextPutAll: ' asPointerType']
					ifNotNil:
						[s	nextPut: $^;
							print: referentClass;
							nextPutAll: ' fromHandle: (handle ';
							nextPutAll: accessor;
							space; print: byteOffset;
							nextPut: $)]]
			ifFalse:
				[self isAtomic
					ifTrue:
						[s	nextPutAll:'^handle ';
							nextPutAll: (AtomicSelectors at: self atomicType);
							space; print: byteOffset]
					ifFalse:
						[s	nextPut: $^;
				print: referentClass;
				nextPutAll:' fromHandle: (handle structAt: ';
				print: byteOffset;
				nextPutAll:' length: ';
				print: self byteSize;
				nextPut: $)]]]
]

{ #category : 'accessing' }
ExternalType >> referentClass [
	"Return the class specifying the receiver"
	^referentClass
]

{ #category : 'private' }
ExternalType >> setReferencedType: aType [
	referencedType := aType
]

{ #category : 'printing' }
ExternalType >> storeOn: aStream [
	referentClass == nil
		ifTrue:[aStream nextPutAll: ExternalType name; space; nextPutAll: (AtomicTypeNames at: self atomicType)]
		ifFalse:[aStream nextPut: $(; nextPutAll: ExternalType name; space; nextPutAll: #structTypeNamed:; space;  store: referentClass name; nextPut: $)].
	self isPointerType ifTrue: [aStream space; nextPutAll: #asPointer].
]

{ #category : 'printing' }
ExternalType >> typedef [
	^String streamContents: [:s| self printTypedefOn: s]
]

{ #category : 'private' }
ExternalType >> writeFieldAt: byteOffset with: valueName [
	"Answer a string defining the accessor to an entity of the receiver type starting at the given byte offset. 
	 Private. Used for field definition only."

	^String streamContents:
		[:s|
		self isPointerType
			ifTrue:
				[| accessor |
				accessor := self pointerSize caseOf: {
								[nil]	->	[#pointerAt:].
								[4]	->	[#pointer32At:].
								[8]	->	[#pointer64At:] }.
				s	nextPutAll:'handle ';
					nextPutAll: accessor;
					space; print: byteOffset;
					nextPutAll:' put: ';
					nextPutAll: valueName;
					nextPutAll:' getHandle']
			ifFalse:
				[self isAtomic
					ifTrue:
						[s	nextPutAll:'handle ';
							nextPutAll: (AtomicSelectors at: self atomicType);
							space; print: byteOffset;
							nextPutAll:' put: ';
							nextPutAll: valueName]
					ifFalse:
						[s	nextPutAll:'handle structAt: ';
							print: byteOffset;
							nextPutAll:' put: ';
							nextPutAll: valueName;
							nextPutAll:' getHandle';
							nextPutAll:' length: ';
							print: self byteSize]]]
]
