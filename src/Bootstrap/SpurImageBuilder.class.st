"
My sub instances can build new image files, in one of the Spur format variants, from a set of Foreign Objects.
"
Class {
	#name : 'SpurImageBuilder',
	#superclass : 'ImageBuilder',
	#instVars : [
		'classTableRoots',
		'lastClassIndex'
	],
	#category : 'Bootstrap-Smalltalk Image Builders',
	#package : 'Bootstrap',
	#tag : 'Smalltalk Image Builders'
}

{ #category : 'foreign objects' }
SpurImageBuilder >> addClassAndMetaclassSpec: aClassSpec classIndexOrNil: classIndexOrNil [
	"Add ForeignObjects both for class and metaclass to the list.
	But only add the one for the class to the foreignObjects dictionary, because they share the spec.
	classIndexOrNil if specified is used for the class."

	| classForeignObject metaclassForeignObject |
	classForeignObject := self addClassFor: aClassSpec classIndexOrNil: classIndexOrNil.
	metaclassForeignObject := self addMetaclassFor: aClassSpec.
	classForeignObject metaclassForeignObject: metaclassForeignObject.
	metaclassForeignObject thisClassForeignObject: classForeignObject.
"MethodDictionaries will only be added after adding all methods, as they need to be created large enough,
meaning we don't yet know the size they will have, and the memory space they will use.
Perhaps create the object but don't add it to the list yet... Or devise some way to hold the method specs and fo until we start serializing.
WARNING: this means once we start serializing we can no longer add methods.
The #addMethod: or whatever protocol must check that we haven't given oop and size to the method dict fo, or else..."
	"
	classForeignObject methodDictForeignObject: self addForeignObjectForMethodDictionary.
	metaclassForeignObject methodDictForeignObject: self addForeignObjectForMethodDictionary.
	"
	^classForeignObject

]

{ #category : 'foreign objects' }
SpurImageBuilder >> addClassFor: aClassSpec classIndexOrNil: classIndexOrNil [

	| classForeignObject classPool classPoolForeignObject classPoolArray classPoolArrayForeignObject |
	classForeignObject := self addClassSpec: aClassSpec class: ClassForeignObject classIndexOrNil: classIndexOrNil.
	classForeignObject nameForeignObject: (self findOrAddLiteral: aClassSpec name).
	classForeignObject instanceVariablesForeignObject: (self findOrAddLiteral: aClassSpec instVarNames).

	"This assumes quite a few things about Dictionary in the image we're about to create.
	Including that the #hash answered by Symbols should equal that of the mother image.
	We did better for IdentityDictionary, and in particular for the Smalltalk SystemDictionary.
	See #foreignIdentityHash.
	Consider doing something similar same for all Dictionaries...
		but how can we now what #hash will do in the new image?
	Other similar assumptions in #addSmalltalk #addMethodDictionaryFor: etc...
	For instance CompiledMethodForeignObject implements #identityHash,
	for the benefit of #addMethodDictionaryFor:"
	classPool := Dictionary new.
	aClassSpec classVarNames do: [ :cVarName |
		self findOrAddLiteral: cVarName.
		"Should we use ReadOnlyVariableBinding ? What's the point?"
		classPool at: cVarName put: nil ].
	"Create a ForeignObject for the class pool dictionary"
	classPoolForeignObject := self createForeignObjectFor: classPool.
	"Now replace the array inside with a ForeignObject for it"
	classPoolArray := classPool array.
	classPoolArrayForeignObject := self createForeignObjectFor: classPoolArray.
	classPool instVarNamed: 'array' put: classPoolArrayForeignObject.
	"Replace all associations with ForeignObjects too"
	classPoolArray withIndexDo: [ :association :index |
		association notNil ifTrue: [
			classPoolArray at: index put: (self createForeignObjectFor: association) ]].
	"Now give it to the class foreign object"
	classForeignObject classPoolForeignObject: classPoolForeignObject.

	"ClassSpec holds 'poolDictionaryNames', but it is currently unused. implement!"
	classForeignObject sharedPoolsForeignObject: (self findForeignObjectFor: nil).

	^classForeignObject
]

{ #category : 'foreign objects' }
SpurImageBuilder >> addClassSpec: aClassSpec class: aForeignObjectClass classIndexOrNil: classIndexOrNil [
	"Both for class and metaclass:
		aForeignObjectClass may be ClassForeignObject or MetaclassForeignObject"

	| hashAndClassIndex behaviorForeignObject rootsIdx pageIdx pageForeignObject page |
	hashAndClassIndex := classIndexOrNil ifNil: [self newClassIndex].
	rootsIdx := (hashAndClassIndex >> 10) + 1.
	pageIdx := (hashAndClassIndex bitAnd: (1 << 10 - 1)) + 1.
	pageForeignObject := classTableRoots at: rootsIdx.
	pageForeignObject isNil ifTrue: [
		pageForeignObject := self createForeignObjectFor: (Array new: 1024) hash: 0 class: SpurPseudoArrayForeignObject.
		classTableRoots at: rootsIdx put: pageForeignObject ].
	page := pageForeignObject representedObject.
	self assert: (page at: pageIdx) == nil.
	behaviorForeignObject := self createForeignObjectFor: aClassSpec hash: hashAndClassIndex class: aForeignObjectClass.
	page at: pageIdx put: behaviorForeignObject.
	^behaviorForeignObject
]

{ #category : 'foreign objects' }
SpurImageBuilder >> addClassTable [
	"Add the ForeignObjects for:
		ClassTable+HiddenRoots
		FirstPateOfClassTable.
	See class comment at VMMaker SpurMemoryManager wrt 'hiddenRootsObj'. Also see #classTableRootSlots + #hiddenRootSlots."
	
	"Spur uses a maximum of 2ˆ12=4096 pages of 2ˆ10=1024 classes each.
	The classTablePages array and the first page array are always present.
	The rest of the pages are created on demand.
	Class index (that equals class identityHash) are usually small numbers, and few pages are actually needed."
	
	"These don't really need to be added to the foreignObjects dictionary,
	but doing it doesn't hurt, and lets us use #addForeignObjectFor: instead of adding extra code."

	| firstPageOfClassTable |
	classTableRoots := Array new: (2 raisedTo: 12) + 8 "#classTableRootSlots + #hiddenRootSlots".
	self createForeignObjectFor: classTableRoots hash: 0 class: SpurPseudoArrayForeignObject.
	"Spur reserves the first class index page immediately after the hiddenRoots, for #addForeignObjectsForVmKnownClasses"
	firstPageOfClassTable := Array new: 1024.
	classTableRoots at: 1 put: (self createForeignObjectFor: firstPageOfClassTable hash: 0 class: SpurPseudoArrayForeignObject).
	"Add the second page too. Any other classes other than #addForeignObjectsForVmKnownClasses start here."
	firstPageOfClassTable := Array new: 1024.
	classTableRoots at: 2 put: (self createForeignObjectFor: firstPageOfClassTable hash: 0 class: SpurPseudoArrayForeignObject).
]

{ #category : 'foreign objects' }
SpurImageBuilder >> addFreeLists [
	self subclassResponsibility
]

{ #category : 'foreign objects' }
SpurImageBuilder >> addMetaclassFor: aClassSpec [

	| metaclassForeignObject |
	metaclassForeignObject := self addClassSpec: aClassSpec class: MetaclassForeignObject classIndexOrNil: nil.
	metaclassForeignObject instanceVariablesForeignObject: (self findOrAddLiteral: aClassSpec classInstVarNames).
	^metaclassForeignObject
]

{ #category : 'foreign objects' }
SpurImageBuilder >> addMethodDictionaryFor: aClassOrMetaclassForeignObject [
	"Create a ForeignObject for a new MethodDictionary to be created.
	Also create required ForeignObjects for its parts, i.e. the 'array' instance variable.
	Don't add the objects created to the foreignObjects dictionary, as nobody else should reference them!"

	| methodForeignObjects methodDictionaryForeignObject methodDictionaryToAdd methodArrayForeignObject |
	methodForeignObjects := aClassOrMetaclassForeignObject methodForeignObjects.

	"This assumes that the representation of MethodDictionaries will be the same as in the image we are running in.
	Also, ForeignObjects for selectors must answer the same #identityHash as the to-be-created Symbol.
	So we can simply use a MethodDictionary.
	These assumptions may change in the future, and a more sophisticated strategy to build MethodDictionaries may be needed.
	This should actually take into account the source code from which the MethodDictionary class will be created..."
	methodDictionaryToAdd := MethodDictionary newWithRoomForMoreThan: methodForeignObjects size.
	methodForeignObjects do: [ :each |
		methodDictionaryToAdd
			at: (self findForeignObjectFor: each representedObject selector)
			put: each ].

	"Give it to the argument Class or Metaclass."
	methodDictionaryForeignObject := self createForeignObjectFor: methodDictionaryToAdd.
	aClassOrMetaclassForeignObject methodDictForeignObject: methodDictionaryForeignObject.

	"The only additional ForeignObject is for the 'array' instance variable."	
	methodArrayForeignObject := self createForeignObjectFor: methodDictionaryToAdd methodArray.
	methodDictionaryToAdd instVarNamed: 'array' put: methodArrayForeignObject.

	^methodDictionaryForeignObject.
]

{ #category : 'image building' }
SpurImageBuilder >> addSpurHiddenObjectsIfRequired [

	"Create and add a SpurFreeListsForeignObject, to properly allocate the FreeLists object needed in Spur images."
	self addFreeLists.

	"Class Table and Hidden Roots. First page of the Class Table."
	self addClassTable.
]

{ #category : 'image building' }
SpurImageBuilder >> addVmKnownClasses [
	"Some classes are known by the VM.
	- They have specific classIndex and identityHash
	- They are stored in the first page of the class table
	Add ForeignObjects both for class and metaclass to the list.
	But only add the one for the class to the foreignObjects dictionary, because they share the spec."
	"This first implementation uses the fact that these classes already exist in the image we are running.
	It would be better to build them from scratch, using alternative class protocol in ClassSpec,
	most likely by compiling a source code file."

	"Note: SmallFloat64 will never be instantiated in Spur32!"

	| vmKnownClassNames |
	vmKnownClassNames := #(
		#(#SmallInteger 1)
		#(#Character 2)
		#(#SmallFloat64 4)
		#(#LargeNegativeInteger 32)
		#(#LargePositiveInteger 33)
		#(#BoxedFloat64 34)
		#(#Message 35)
		#(#MethodContext 36)
		#(#BlockClosure 37)
		#(#Semaphore 48)
		#(#ByteArray 50)
		#(#Array 51)
		#(#String 52)
		#(#Point 54)
	).
	self includeDisplayAndSensor ifTrue: [
		vmKnownClassNames := vmKnownClassNames, #(#(#Bitmap 53)) ].
	vmKnownClassNames do: [ :pair | | className specialHash classSpec classForeignObject |
		className := pair first.
		specialHash := pair second.
		classSpec := ClassSpec for: (Smalltalk at: className) addClassesTo: classes.
		classForeignObject := self addClassAndMetaclassSpec: classSpec classIndexOrNil: specialHash.
		self map: classSpec toForeignObject: classForeignObject ].
]

{ #category : 'foreign objects' }
SpurImageBuilder >> createForeignObjectFor: anObject hash: identityHash class: aForeignObjectClass [
	"anObject will be included in the new image
	Create and answer an instance of aForeignObjectClass for it.
	For objects that are allocated in memory:
		- Allocate space in the new image for it
		- Add it to the list of foreign objects we'll use to serialize.
	For objects that won't be allocated in memory (they are immediate objects,
	encoded in pointing OOPs, like SmallInteger, etc):
		- Just create and answer a ForeignObject that can encode object in an OOP when needed."

	| fo byteCount |
	aForeignObjectClass instancesAreForImmediateObjects ifTrue: [
		self halt.
		].

	fo := aForeignObjectClass
		newFor: anObject
		oop: nextFreeAddressOfImage
		identityHash: identityHash.
	"If size > 254, header needs an extra word, and oop is pushed to point past it, to the basic header word"
	(self sizeFieldFor: fo) > 254 ifTrue: [
		fo foreignOop: nextFreeAddressOfImage + 8 ].

	"Size in memory. Some objects have specific slot width (like ByteArray).
	Others use the word size, like objects with instance variables and Arrays."
	byteCount := (self sizeInBytesOfHeader: fo) + (self sizeInBytesOfBody: fo).

"{'ForeignObject list node'. fo class. byteCount. anObject basicSize. nextFreeAddressOfImage. fo foreignOopFor: self. anObject} print."

	nextFreeAddressOfImage := nextFreeAddressOfImage + byteCount.

	firstForeignObject isNil
		ifTrue: [ firstForeignObject := fo ]
		ifFalse: [ lastForeignObject nextInList: fo ].
	lastForeignObject := fo.
	^fo
]

{ #category : 'image building' }
SpurImageBuilder >> fillSpecialObjectsArray [
	"Create a SpecialObjectsArray for our new image. See #recreateSpecialObjectsArray.
	Add a ForeignObject for it to our foreign object list and dicitonary.
	Assume the required classes where already added, and their specs are available at ivar 'classes'
	If we were to do a full bootstrap from sources, it is worh considering that the new image will most likely
	have a #recreateSpecialObjectsArray or similar method.
	It would be good to find a way to guarantee that the contents of this array in the bootstrapped image is consistent with it."
"This is done right now for Spur. V3 needs tweaks, for instance:
25: Character table
29: compactClassesArray.
32, 33, 34. Check in V3. Are the instance prototypes still needed in V3?
36 ?
56?"
	"See MicroSqueak - MicroSqueakImageBuilder >> #buildSpecialObjectsArray
	Many entries can be made nil if uninteresting, at least for older VMs."

"Ya mismo. nil, false, true, clases, symbols, arrays de ellos"
	| specialObjectsArray specialSelectors primitiveErrors |
	specialObjectsArray := specialObjectsArrayForeignObject representedObject.
	"Nil false and true get used throughout the interpreter"
	specialObjectsArray at: 1 put: nil.
	specialObjectsArray at: 2 put: false.
	specialObjectsArray at: 3 put: true.
	"This association holds the active process (a ProcessScheduler)"
	"Foreign object for the Association in the new Globals dictionary holding Processor"
	specialObjectsArray at: 4 put: processorBindingForeignObject.
	self assert: processorBindingForeignObject == (globalVariables detect: [ :assocFO |
		assocFO representedObject key representedObject == #Processor ]).
	"Numerous classes below used for type checking and instantiation"
	self includeDisplayAndSensor ifTrue: [
		specialObjectsArray at: 5 put: (classes at: #Bitmap) ].
	specialObjectsArray at: 6 put: (classes at: #SmallInteger).
	specialObjectsArray at: 7 put: (classes at: #String).
	specialObjectsArray at: 8 put: (classes at: #Array).
	"ForeignObjct for the new Smalltalk global dictionary."
	specialObjectsArray at: 9 put: smalltalkForeignObject.
	self assert: smalltalkForeignObject == ((globalVariables detect: [ :assocFO |
		assocFO representedObject key representedObject == #Smalltalk ]) representedObject value).
	specialObjectsArray at: 10 put: (classes at: #BoxedFloat64).
	specialObjectsArray at: 11 put: (classes at: #MethodContext).
	specialObjectsArray at: 12 put: nil. "was BlockContext."
	specialObjectsArray at: 13 put: (classes at: #Point).
	specialObjectsArray at: 14 put: (classes at: #LargePositiveInteger).
	"ForeignObjct for the new Display global Displaycreen."
	displayForeignObject ifNotNil: [
		specialObjectsArray at: 15 put: displayForeignObject.
		self assert: displayForeignObject == ((globalVariables detect: [ :assocFO |
			assocFO representedObject key representedObject == #Display ]) representedObject value) ].
	specialObjectsArray at: 16 put: (classes at: #Message).
	specialObjectsArray at: 17 put: (classes at: #CompiledMethod).
	specialObjectsArray at: 18 put: (self createForeignObjectFor: Semaphore new). "low space Semaphore"
	specialObjectsArray at: 19 put: (classes at: #Semaphore).
	specialObjectsArray at: 20 put: (classes at: #Character).
	specialObjectsArray at: 21 put: (self findOrAddLiteral: #doesNotUnderstand:).
	specialObjectsArray at: 22 put: (self findOrAddLiteral: #cannotReturn:).
	specialObjectsArray at: 23 put: nil. "This is the process signalling low space."
	"An array of the 32 selectors that are compiled as special bytecodes,
	 paired alternately with the number of arguments each takes."
	specialSelectors := #(	#+ 1 #- 1 #< 1 #> 1 #<= 1 #>= 1 #= 1 #~= 1
							#* 1 #/ 1 #\\ 1 #@ 1 #bitShift: 1 #// 1 #bitAnd: 1 #bitOr: 1
							#at: 1 #at:put: 2 #size 0 #next 0 #nextPut: 1 #atEnd 0 #== 1 #class 0
							#blockCopyNOWUNUSED: 1 #value 0 #value: 1 #do: 1 #new 0 #new: 1 #x 0 #y 0 ).
	specialObjectsArray at: 24 put: (self findOrAddLiteral: specialSelectors).
	specialObjectsArray at: 25 put: nil. "was Character table"
	specialObjectsArray at: 26 put: (self findOrAddLiteral: #mustBeBoolean).
	specialObjectsArray at: 27 put: (classes at: #ByteArray).
	specialObjectsArray at: 28 put: (classes at: #Process).
	"An array of up to 31 classes whose instances will have compact headers; an empty array in Spur"
	specialObjectsArray at: 29 put: nil.  "was compactClassesArray."
	specialObjectsArray at: 30 put: (self createForeignObjectFor: Semaphore new). "delay Semaphore"
	specialObjectsArray at: 31 put: (self createForeignObjectFor: Semaphore new). "user interrupt Semaphore"
	specialObjectsArray at: 32 put: nil. "was the prototype Float"
	specialObjectsArray at: 33 put: nil. "was the prototype 4-byte LargePositiveInteger"
	specialObjectsArray at: 34 put: nil. "was the prototype Point"
	specialObjectsArray at: 35 put: (self findOrAddLiteral: #cannotInterpret:).
	specialObjectsArray at: 36 put: nil. "was the prototype MethodContext"
	specialObjectsArray at: 37 put: (classes at: #BlockClosure).
	specialObjectsArray at: 38 put: nil. "was the prototype BlockContext"

	"array of objects referred to by external code"
	specialObjectsArray at: 39 put: (self createForeignObjectFor:(Array new: 20)).
	specialObjectsArray at: 40 put: nil. "Reserved for Mutex in Cog VMs"
	specialObjectsArray at: 41 put: (self createForeignObjectFor: LinkedList new). "Reserved for a LinkedList instance for overlapped calls in CogMT"
	specialObjectsArray at: 42 put: (self createForeignObjectFor: Semaphore new). "finalization Semaphore"
	specialObjectsArray at: 43 put: (classes at: #LargeNegativeInteger).
	"External objects for callout."
	specialObjectsArray at: 44 put: nil.
	specialObjectsArray at: 45 put: nil.
	specialObjectsArray at: 46 put: nil.
	specialObjectsArray at: 47 put: nil.
	specialObjectsArray at: 48 put: nil.
	specialObjectsArray at: 49 put: (self findOrAddLiteral: #aboutToReturn:through:).
	specialObjectsArray at: 50 put: (self findOrAddLiteral: #run:with:in:).
	"51 reserved for immutability message"
	specialObjectsArray at: 51 put: (self findOrAddLiteral: #attemptToAssign:withIndex:).
	primitiveErrors := #(nil "nil => generic error" #'bad receiver'
							#'bad argument' #'bad index'
							#'bad number of arguments'
							#'inappropriate operation'  #'unsupported operation'
							#'no modification' #'insufficient object memory'
							#'insufficient C memory' #'not found' #'bad method'
							#'internal error in named primitive machinery'
							#'object may move' #'resource limit exceeded'
							#'object is pinned' #'primitive write beyond end of object').
	specialObjectsArray at: 52 put: (self findOrAddLiteral: primitiveErrors).
	"53 to 55 are for Alien"
	specialObjectsArray at: 53 put: nil.
	specialObjectsArray at: 54 put: (self findOrAddLiteral: #invokeCallbackContext:). "use invokeCallback:stack:registers:jmpbuf: for old Alien callbacks."
	specialObjectsArray at: 55 put: nil.

	"Weak reference finalization"
	specialObjectsArray at: 56 put: nil.

	"reserved for foreign callback process"
	specialObjectsArray at: 57 put: nil.

	specialObjectsArray at: 58 put: (self findOrAddLiteral: #unusedBytecode).
	"59 reserved for Sista counter tripped message"
	specialObjectsArray at: 59 put: (self findOrAddLiteral: #conditionalBranchCounterTrippedOn:).
	"60 reserved for Sista class trap message"
	specialObjectsArray at: 60 put: (self findOrAddLiteral: #classTrapFor:).
]

{ #category : 'serialization' }
SpurImageBuilder >> headerBytesFor: aForeignObject [
	"Answer the total size in memory and in the generated image.
	Include header bytes, any padding, etc."

	| wordCount sizeHeaderByte answer extraHeader header classIndex |

	classIndex := aForeignObject spurClassIndexFor: self.

	"If size > 254, header needs an extra word, and oop is pushed to point past it, to the basic header word"
	wordCount := self sizeFieldFor: aForeignObject.
	sizeHeaderByte := wordCount <= 254
		ifTrue: [wordCount << 56]
		ifFalse: [16rFF00000000000000].
	header := sizeHeaderByte bitOr:
		((aForeignObject foreignIdentityHashFor: self) << 32)
		+ ((aForeignObject spurObjectFormatFor: self) << 24)
		+ classIndex.
	wordCount <= 254
		ifTrue: [
			answer := ByteArray new: 8.
			answer uint64At: 1 put: header bigEndian: isBigEndian.
			]
		ifFalse: [
			answer := ByteArray new: 16.
			extraHeader := sizeHeaderByte bitOr: wordCount.
			answer uint64At: 1 put: extraHeader bigEndian: isBigEndian.
			answer uint64At: 9 put: header bigEndian: isBigEndian.
			].
	^answer.
]

{ #category : 'initialization' }
SpurImageBuilder >> initialize [
	super initialize.
	lastHash := 1.
	lastClassIndex := 1023. "First regular class will have index 1024, and will be stored in the second page of the class table."
]

{ #category : 'format constants' }
SpurImageBuilder >> lastBridge [
	self subclassResponsibility
]

{ #category : 'format constants' }
SpurImageBuilder >> maxIdentityHash [
	"Answer the maximum identityHash value supported by the VM.
	22 bits in Spur"

	^16r3FFFFF
]

{ #category : 'services' }
SpurImageBuilder >> newClassIndex [
	"Answer the next class index to be used."

	lastClassIndex := lastClassIndex + 1.
	^lastClassIndex
]

{ #category : 'services' }
SpurImageBuilder >> newObjectHash [
	"Use a Marsagalia/Brent xor & shift linear feedback shift register; see https://en.wikipedia.org/wiki/Xorshift.
	 This cycles through all possible 22 bit states (except 0) in 2^22 - 1 iterations. It is a significant improvement
	 over the original linear congruential generator by D.H. Lehmer in 1951, used in Spur versions before 2024/12/20."
	
	"Copied from VMMaker SpurMemoryManager>>#newObjectHash
	Please see additional details there."

	self deny: lastHash = 0.
	lastHash := lastHash bitXor: (lastHash bitShift: -2).
	lastHash := lastHash bitXor: ((lastHash bitShift: 7) bitAnd: 16r3FFFFF "self identityHashHalfWordMask").
	lastHash := lastHash bitXor: (lastHash bitShift: -3).
	^lastHash
]

{ #category : 'image file saving' }
SpurImageBuilder >> saveImageTo: aFileEntry [

	| ba nextForeignObject p |
	ba := ByteArray
		streamContents: [ :byteStream |
			byteStream nextPutAll: (ByteArray new: baseAddressOfImage).

			"Iterate the linked list of foreign objects. Write each."
			nextForeignObject := firstForeignObject.
			[ nextForeignObject notNil ] whileTrue: [
				"asegurarse que la clase esté o dar error."
				(self sizeFieldFor: nextForeignObject) <= 254
					ifTrue: [
						"For objects with only basic header word, oop points to it."
						self assert: byteStream position = (nextForeignObject foreignOopFor: self) ]
					ifFalse: [
						"For objects with an extra header before the basic header word, oop points to basic header word."
						self assert: byteStream position = ((nextForeignObject foreignOopFor: self)-8) ].
				self write: nextForeignObject on: byteStream.
				nextForeignObject := nextForeignObject nextInList ].	

			"Write last segment bridge"
			byteStream nextUint64Put: self lastBridge bigEndian: isBigEndian.
			byteStream nextUint64Put: 0 bigEndian: isBigEndian.

			"Write image header"
			p := byteStream position.
			byteStream position: 0.
			self writeImageFileHeaderOn: byteStream byteSize: p.
			byteStream position: p.
		]
		estimatedSize: nextFreeAddressOfImage.
	aFileEntry forceWriteStreamDo: [ :strm | strm binary; nextPutAll: ba ]
]

{ #category : 'serialization' }
SpurImageBuilder >> sizeFieldFor: aForeignObject [
	"Answer the size field for the object header.
	This is, the number of oop sized slots."

	| slotsPerWord |
	"Objects with 64 bit slots on Spur64, or 32 bit slots on Spur32"
	(aForeignObject slotWidth isNil or: [aForeignObject slotWidth = self wordSize]) ifTrue: [ ^ aForeignObject slotCountFor: self ].

	"For instance, objects with numeric 64 bit slots on Spur32"
	aForeignObject slotWidth > self wordSize ifTrue: [ ^ (aForeignObject slotCountFor: self) * (aForeignObject slotWidth // self wordSize) ].

	"Objects with smaller slots than oop size"
	slotsPerWord := self wordSize / aForeignObject slotWidth.
	^ (aForeignObject slotCountFor: self) + slotsPerWord-1 // slotsPerWord
]

{ #category : 'serialization' }
SpurImageBuilder >> sizeInBytesOfBody: aForeignObject [
	"Answer the byte size of argument, in memory and in the generated image.
	Include any padding."

	| byteCount |

	"No object is smaller than 8 bytes.
	This is to have enough room the VM to turn it into a #become forwarder if needed.
	Include the filler (see below) for Spur32. Both in Spur32 and Spur64 write 8 bytes."
	(aForeignObject slotCountFor: self) = 0 ifTrue: [
		^8 ].

	"Size in memory. Some objects have specific slot width (like ByteArray). Others use the word size, like objects with instance variables and Arrays."
	byteCount := (aForeignObject slotCountFor: self) * (aForeignObject slotWidth ifNil: [ self wordSize ]).

	"Filler. Round to next multiple of 8, both Spur32 and Spur64 allocate multiples of 64 bits"
	byteCount := byteCount + 7 // 8 * 8.

	^byteCount.
]

{ #category : 'serialization' }
SpurImageBuilder >> sizeInBytesOfHeader: aForeignObject [
	"Answer the size of the header for argument, in memory and in the generated image."

	"If size > 254, header needs an extra 64 bits word, and oop is pushed to point past it, to the basic header word"
	(self sizeFieldFor: aForeignObject) > 254 ifTrue: [^16 ].

	"Regular header is 8 bytes."
	^8
]

{ #category : 'image file saving' }
SpurImageBuilder >> write: aForeignObject on: byteStream [

	| headerBytes |

	"Object header"
	headerBytes := self headerBytesFor: aForeignObject.
	byteStream nextPutAll: headerBytes.

	"No object is smaller than 8 bytes.
	This is to have enough room the VM to turn it into a #become forwarder if needed.
	Include the filler (see below) for Spur32. Both in Spur32 and Spur64 write 8 bytes."
	(aForeignObject slotCountFor: self) = 0 ifTrue: [
		byteStream nextPutAll: `ByteArray new: 8`.
		^self ].

	"Object body."
	aForeignObject writeSlotsOn: byteStream forSpur: self.

	"Appropriate filler. All objects use a multiple of 8 bytes.
	Therefore, stream position must also be a multiple of 8.
	Note: This matches #sizeInBytesOfBody:"
	[(byteStream position \\ 8) = 0] whileFalse: [byteStream nextPut: 0].
]

{ #category : 'image file saving' }
SpurImageBuilder >> writeImageFileHeaderOn: aStream byteSize: imageByteSizeIncludingHeader [
	"Write an appropriate image file header.
	Intended to be called after saving the heap to the file, and setting #position: to zero.
	Reviewed with Eliot Miranda on Apr 18, 2024. Thanks Eliot!"
"
readImageFromFile:HeapSize:StartingAt:
"
	| specialObjectsOop savedWindowSize imageHeaderFlags shiftedBit extraVMMemory 
	desiredNumStackPages cogCodeSizeKB desiredEdenBytes maxExtSemTabSize maxLiteralCountForCompile firstSegmentByteSize bytesLeftInOldSpace |

	false ifTrue: [ lastHash := lastHash ].
	specialObjectsOop := specialObjectsArrayForeignObject foreignOopFor: self.
	savedWindowSize := 640<<16 + 480.

	"imageHeaderFlags includes all the bits in vmParameter 48, but shifted to make room for two additional lsb bits: fullScreenFlag and floatsInPlatformOrder.
	((Smalltalk vmParameterAt: 48) bitShift: 2) bitOr: 2
	((((Smalltalk vmParameterAt: 48) bitShift: 2) bitOr: 2) printStringBase: 2 nDigits: 11) reversed
	See comment at #vmParameterAt: , in particular for index 48
	See also #setImageHeaderFlagsFrom: in VMMaker
	"
	imageHeaderFlags := 0.
	shiftedBit := 1.
	#(
		0 		"0: Full screen off."
		1 		"1: Floats are in plarform order."
		0  		"0: Process doesn't have threadAffinity ivar. No threaded FFI support."
		0  		"0: Don't flag interpreted methods by default."
		1  		"1: Preemption does not yield."
		0  		"0: noThreadingOfGUIThread. Currently unused in Cuis. Update this when Cuis supports threaded FFI."
		0  		"0: Don't use the new finalization, intended to support Ephemerons."
		1  		"1: Don't create fake keyboard events for wheel events."
		1  		"1: Don't do mixed arithmetic in the VM. Let the image decide how to do it."
		0  		"0: Don't use UTC seconds from epoch for files (FilePlugin / FileAttributesPlugin)."
		0  		"0: Don't upscaleDisplayIfHighDPI."
	) do: [ :bit |
		imageHeaderFlags := imageHeaderFlags bitOr: (shiftedBit * bit).
		shiftedBit := shiftedBit * 2 ].


	extraVMMemory := 0. 			"Not used in Spur"

	desiredNumStackPages := 0. 		"0 means default value as preferred by the VM. This is vmParameterAt: 43."
	cogCodeSizeKB := 0.				"If zero, set by the VM, depending on the density of the instuction set of the target architecture. vmParameterAt: 47. unused if no cog jitter"
	desiredEdenBytes := 0.			"0 for minimal images. Cuis image is saved with 16777216.
										Typical app images could use something like 128, 256 or 512 MB. Profile your app with various values to find out.  vmParameterAt: 45."
	maxExtSemTabSize := 256 * 0.	"0 means vm default, i.e. 256. This is vmParameterAt: 49"
	maxLiteralCountForCompile := 0. 	"How much literals above which we'd not jit a method. 0 means vm default (60). Unused if no cog jitter"
	firstSegmentByteSize := imageByteSizeIncludingHeader - self imageHeaderSize.
	bytesLeftInOldSpace := 0. 		"0 for bootstrapped images, because there is no heap fragmentation."

	self on: aStream nextUint32Put: self imageFormat.
	self on: aStream nextUint32Put: self imageHeaderSize.
	self on: aStream nexWordPut: imageByteSizeIncludingHeader - self imageHeaderSize. 			"length of heap in file"
	self on: aStream nexWordPut: baseAddressOfImage.											"object memory base address of image"
	self on: aStream nexWordPut: specialObjectsOop.
	self on: aStream nexWordPut: lastHash.
	self on: aStream nexWordPut: savedWindowSize.
	self on: aStream nexWordPut: imageHeaderFlags.
	self on: aStream nextUint32Put: extraVMMemory.

	"Only for Cog"
	aStream nextUint16Put: desiredNumStackPages bigEndian: isBigEndian.
	aStream nextUint16Put: cogCodeSizeKB bigEndian: isBigEndian.

	"40 o 64 bytes so far"

	self on: aStream nextUint32Put: desiredEdenBytes.
	aStream nextUint16Put: maxExtSemTabSize bigEndian: isBigEndian.
	aStream nextUint16Put: maxLiteralCountForCompile bigEndian: isBigEndian.

	"48 o 72 bytes so far"

	self on: aStream nexWordPut: firstSegmentByteSize.
	self on: aStream nexWordPut: bytesLeftInOldSpace.
]
