"
A MethodSpec describes a CompiledMethod. It includes enough detail for a real CompiledMethod to be created from it. But it is not a CompiledMethod:
- It can't be run. Can't be added to a class.
- There can be several MethodSpecs for different versions of a method in memory.
- It is a regular object. Doesn't include any detail specific to Cuis ObjectMemory or VM (Spur). Doesn't refer to globals.
- It is easy to serialize and deserialize. Nothing special to take care of.
"
Class {
	#name : 'MethodSpec',
	#superclass : 'CodeElementSpec',
	#instVars : [
		'classSpec',
		'isClassSide',
		'selector',
		'headerSignFlag',
		'header',
		'literals',
		'pragmas',
		'bytecodes'
	],
	#category : 'DynamicCuisLibraries-Code Model',
	#package : 'DynamicCuisLibraries',
	#tag : 'Code Model'
}

{ #category : 'services' }
MethodSpec class >> classesAssumedToExist [
	"
	MethodSpec classesAssumedToExist collect: [ :clsName | Smalltalk at: clsName ]
	"
	^#(
	ProtoObject
		Object
			UndefinedObject
			Boolean
				True
				False
			Magnitude
				DateAndTime
				Duration
				LookupKey
					Association
				Number
					Float
						BoxedFloat64
						SmallFloat64
					Fraction
					Integer
						LargePositiveInteger
							LargeNegativeInteger
						SmallInteger
			Character
			Collection
				Set
					Dictionary
						IdentityDictionary
							SystemDictionary
						MethodDictionary
				WeakSet
				SequenceableCollection
					ArrayedCollection
						Array
						ByteArray
							CompiledMethod
						FloatArray
							Float32Array
							Float64Array
					CharacterSequence
						String
							Symbol
						UnicodeString
							UnicodeSymbol
					LinkedList
						Semaphore
					OrderedCollection
			Behavior
				ClassDescription
					Class
					Metaclass
			BlockClosure
			Link
				Process
				ProcessorScheduler
			Stream
				DataStream
					ReferenceStream
				PositionableStream
					ReadStream
					WriteStream
						ReadWriteStream
							UniFileStream
				StdIOReadStream
				StdIOWriteStream
			UniStreamReadAdaptor
				ByteStringReadAdaptor
				BytesReadAdaptor
				UnicodeReadAdaptor
			FileSystemEntry
				DirectoryEntry
				FileEntry
			FileIOAccessor
			ClassSpec
			MethodSpec
			LiteralVariableSpec
		)
]

{ #category : 'instance creation' }
MethodSpec class >> for: aCompiledMethod addClassesTo: anOrderedDictionaryOfClasses [
	"aCompiledMethod is a regular method that exists in the system
	"
	"
	| methods sortedClassSpecs |
	methods := OrderedCollection new.
	sortedClassSpecs := OrderedDictionary new.
	methods add: (MethodSpec for: AdditionalMethodState >> #selector addClassesTo: sortedClassSpecs).
	methods add: (MethodSpec for: Object>>#copyFrom: addClassesTo: sortedClassSpecs).
	methods add: (MethodSpec for: Object class >> #howToModifyPrimitives addClassesTo: sortedClassSpecs).
	methods add: (MethodSpec for: MethodSpec >> #testMethod addClassesTo: sortedClassSpecs).
	{methods. sortedClassSpecs}
	"

	| selector itsClass |
	"Note: We are currently ignoring any non pragma, non #libraryName property"
	self assert: (aCompiledMethod properties properties keys allSatisfy: [ :b | b = #libraryName ]).
	selector := aCompiledMethod selector.
	"Remove prefixes such as 'noclash_', 'noclash003_', noclashMySpecialName_', etc "
	(selector beginsWith: 'noclash') ifTrue: [
		selector := (selector copyFrom: (selector indexOf: $_ )+1 to: selector size) asSymbol ].
	itsClass := aCompiledMethod methodClass.
	^self basicNew
		classSpec: (ClassSpec for: itsClass theNonMetaClass addClassesTo: anOrderedDictionaryOfClasses)
		isClassSide: itsClass isMeta
		selector: selector
		headerSignFlag: aCompiledMethod signFlag
		header: aCompiledMethod headerWithoutSignFlag
		literals: (self literalSpecsFor: aCompiledMethod)
		pragmas: (self pragmaSpecsFor: aCompiledMethod)
		bytecodes: aCompiledMethod bytecodes.
]

{ #category : 'instance creation' }
MethodSpec class >> literalSpecsFor: aCompiledMethod [
	"Answer an Array with the regular literals. I.e. not including the last two, #penultimateLiteral and the #methodClassAssociation.
	Convert variable bindings (shared Associations in globals, class pool or shared pools) into LiteralVariableSpec"

	| answer s |
	s := aCompiledMethod numLiterals-2.
	s = 0 ifTrue: [ ^nil ].
	answer := Array new: s.
	1 to: answer size do: [ :i | | lit |
		lit := aCompiledMethod literalAt: i.
		(aCompiledMethod isNamedPrimitive and: [i=1]) ifTrue: [
			"The VM stores information about named primitive runs in the last two entries.
			Clear them.
			See #isLinkedNamedPrimitive.
			For additional details, In VMMaker package check references to 
				ExternalCallLiteralFlagsIndex
				ExternalCallLiteralTargetFunctionIndex
			(Apparently -1 means failure, most likely named primitive not found)"
			lit := {lit first. lit second. 0. 0} ].
		(lit isVariableBinding and: [(aCompiledMethod methodClass bindingOf: lit key) == lit]) ifTrue: [
			lit := LiteralVariableSpec variableName: lit key ].
		(MethodSpec classesAssumedToExist includes: lit class name) ifFalse: [
			"self halt:" ('What to do with ', lit class printString) print ].
		answer at: i put: lit ].
	^answer
	
	"
	preguntar isLiteral
	Cualquier imagen minima debera incluir todas las clases que #isLiteral
	Lo que no sea isLiteral o un binding que anda, sera un StreamedLiteralSpec o LiteralObjectSpec o LiteralButNotLiteralObjectSpec...
	O no soportarlo. No sabemos que les puede pasar a esos bichos. si la clase va a estar del otro lado, etc...
	"
"
Posibles candidatas. O fallar.
SHRange
CursorWithMask
Color
TranslucentColor
TextBackgroundColor
Text + RunArray, NotRunArray, atributos... mhhhhhh
"
]

{ #category : 'instance creation' }
MethodSpec class >> pragmaSpecsFor: aCompiledMethod [
	"Answer an Array with the information of Pragmas."

	| ps |
	ps := aCompiledMethod pragmas.
	ps size = 0 ifTrue: [ ^nil ].
	^aCompiledMethod pragmas collect: [ :p | Array with: p keyword withAll: p arguments ]
]

{ #category : 'private' }
MethodSpec >> at: index [
	"Compatibility with CompiledMethod"
	^bytecodes at: index
]

{ #category : 'private' }
MethodSpec >> at: index put: value [
	"Compatibility with CompiledMethod"
	^bytecodes at: index put: value
]

{ #category : 'accessing' }
MethodSpec >> bytecodes [
	^bytecodes
]

{ #category : 'accessing' }
MethodSpec >> bytecodes: aByteArray [
	bytecodes := aByteArray
]

{ #category : 'accessing' }
MethodSpec >> classSpec [
	^classSpec
]

{ #category : 'private' }
MethodSpec >> classSpec: aClassSpec isClassSide: aBoolean selector: aSymbol headerSignFlag: anotherBoolean header: aNumber literals: arrayOfLiterals pragmas: arrayOfPragmas bytecodes: aByteArray [

	classSpec := aClassSpec.
	isClassSide := aBoolean.
	selector := aSymbol.
	headerSignFlag := anotherBoolean.
	header := aNumber.
	literals := arrayOfLiterals.
	pragmas := arrayOfPragmas.
	bytecodes := aByteArray.
]

{ #category : 'copying' }
MethodSpec >> copyWithBytecodes: newBytecodes [
	"Assume that newBytecodes are regular bytecodes,
	meaning the answer will not include a primitive call.
	The new bytecodes are in the same bytecode set as the current ones.
	Remove the primitive bit from the header if present. Answer will not be a primitive call."
	
	| answer |
	answer := self copy.
	answer noPrimitive.
	answer bytecodes: newBytecodes.
	^answer
]

{ #category : 'accessing' }
MethodSpec >> encoderClass [
	"Answer the encoder class that encoded the bytecodes in this method.
	 The sign flag bit is used by the VM to select a bytecode set.  This formulation
	 may seem odd but this has to be fast, so no property probe unless needed.
	The fact that a positive header means byecodes are in the V3PlusClosures set,
	and negative header means bytecodes in the SistaV1 set is hardcoded in the
	OpenSmalltalk VMs as of August 2025."
	
	^ headerSignFlag
		ifFalse: 
			[EncoderForV3PlusClosures]
		ifTrue:
			[EncoderForSistaV1]
]

{ #category : 'compatibility with CompiledMethod' }
MethodSpec >> endPC [
	"Compatibility with CompiledMethod"
	^bytecodes size
]

{ #category : 'compatibility with CompiledMethod' }
MethodSpec >> flushCache [
	"NOP here"
]

{ #category : 'accessing' }
MethodSpec >> header [
	| answer |
	answer := header.
	headerSignFlag ifTrue: [
		answer := answer + SmallInteger minVal ].
	^answer
]

{ #category : 'compatibility with CompiledMethod' }
MethodSpec >> initialPC [
	"Compatibility with CompiledMethod"
	^1
]

{ #category : 'accessing' }
MethodSpec >> isClassSide [
	^isClassSide
]

{ #category : 'compatibility with CompiledMethod' }
MethodSpec >> isReturnField [
	"Answer whether the receiver is a quick return of an instance variable."
	^ self primitive between: 264 and: 519
]

{ #category : 'accessing' }
MethodSpec >> literals [
	"Regular literals.
	CompiledMethods have two special last literals, that are not included here.
	They hold #selector, maybe Pragmas or method properties (Associations),
	and #methodClass binding."

	^literals ifNil: [ #() ]
]

{ #category : 'materialization' }
MethodSpec >> materializeAndInstall [
	| theClass method |
	theClass := Smalltalk at: classSpec name.
	isClassSide ifTrue: [ theClass := theClass class ].
	method := self materializeIn: theClass.
	theClass addSelectorSilently: selector withMethod: method.
	^method
]

{ #category : 'materialization' }
MethodSpec >> materializeIn: aClass [
"
Currently:
	methodTrailer is zeros (No source code pointer)
	Pragmas are supported. Any other method property is not.
classSpec isClassSide selector 
header literals pragmas bytecodes
"
	| bytesCount method j |
	bytesCount := bytecodes size.
	method := CompiledMethod
		createMethod: bytesCount trailer: #(0 0 0 0) header: self header.
	1 to: self literals size do: [ :i | | lit varName |
		lit := literals at: i.
		(lit is: #LiteralVariableSpec) ifTrue: [
			varName := lit variableName.
			lit := aClass bindingOf: varName.
			"Create as global if needed."
			lit isNil ifTrue: [
				Smalltalk at: varName put: nil.
				lit := Smalltalk bindingOf: varName]].
		method literalAt: i put: lit].
	method penultimateLiteral: selector.
	self pragmaSpecs do: [ :pragmaData |
		method addPragma: (Pragma
			for: method
			selector: pragmaData first 
			arguments: (pragmaData copyFrom: 2 to: pragmaData size)) ].
	method methodClass: aClass.
	j := 1.
	method initialPC to: method endPC do: [ :i |
		method at: i put: (bytecodes at: j).
		j := j + 1 ].
	^method
]

{ #category : 'accessing' }
MethodSpec >> noPrimitive [
	"Take down the primitive flag if present."
	
	header := header bitAt: 17 put: 0.
]

{ #category : 'accessing' }
MethodSpec >> pragmaSpecs [
	^pragmas ifNil: [ #() ]
]

{ #category : 'compatibility with CompiledMethod' }
MethodSpec >> primitive [
	"Answer the primitive index associated with the receiver.
	Zero indicates that this is not a primitive method."

	^(header anyMask: 65536) "Is the hasPrimitive? flag set?"
		ifTrue: [(self at: 2) + ((self at: 3) bitShift: 8)]
		ifFalse: [0].
]

{ #category : 'printing' }
MethodSpec >> printOn: aStream [

	aStream
		nextPutAll: 'MethodSpec:';
		nextPutAll: classSpec name;
		nextPutAll: (isClassSide ifTrue: [ ' class'] ifFalse: ['']);
		nextPutAll: '>>';
		print: selector
]

{ #category : 'compatibility with CompiledMethod' }
MethodSpec >> returnField [
	"Answer the index of the instance variable returned by a quick return 
	method."
	| prim |
	prim := self primitive.
	prim < 264
		ifTrue: [self error: 'only meaningful for quick-return']
		ifFalse: [^ prim - 264]
]

{ #category : 'accessing' }
MethodSpec >> selector [
	^selector
]

{ #category : 'accessing' }
MethodSpec >> selector: aSymbol [
	selector := aSymbol.
]

{ #category : 'accessing' }
MethodSpec >> spurNumLiterals [
	"Answer the number of literals used by the receiver.
	See #numLiterals"

	^ header bitAnd: 16r7FFF
]
