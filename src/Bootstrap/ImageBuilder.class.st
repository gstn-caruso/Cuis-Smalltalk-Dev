"
My sub instances can build new image files, from a set of Foreign Objects.

Cuis image files are usually Little Endian Spur64, but could also be big endian. Images intended for 32 bit systems and VMs are in Spur32 format.

ImageBuilder could be extended to support other image formats, if a suitable VM exists for them, For instance, it is entirely possible to complete V3ImageBuilder and make it functional.

- foreignObjects: an IdentityDictionary that holds an appropriate ForeignObject for each object we want to include.
- firstForeignObject: the start of the linked list of ForeignObjects (they have an ivar for next in list).
- lastForeignObject: handy when adding new ones to the list.
"
Class {
	#name : 'ImageBuilder',
	#superclass : 'Object',
	#instVars : [
		'isBigEndian',
		'classes',
		'methods',
		'baseAddressOfImage',
		'nextFreeAddressOfImage',
		'lastHash',
		'firstForeignObject',
		'lastForeignObject',
		'foreignObjectsMap',
		'specialObjectsArrayForeignObject',
		'globalVariables',
		'symbols',
		'processorBindingForeignObject',
		'smalltalkForeignObject',
		'displayForeignObject',
		'startUpMethod'
	],
	#category : 'Bootstrap-Smalltalk Image Builders',
	#package : 'Bootstrap',
	#tag : 'Smalltalk Image Builders'
}

{ #category : 'globals' }
ImageBuilder >> addDisplay [
	"This assumes the shape of DisplayScreen and included ivars will not change..."

	| display foreignObjectsForBindingAndValue bitmap bitmapFO |
	display := DisplayScreen basicNew.
	display setExtent: 8@8 depth: 32.
	foreignObjectsForBindingAndValue := self addGlobalNamed: #Display value: display.
	displayForeignObject := foreignObjectsForBindingAndValue second.
	
	bitmap := display bits.
	bitmapFO := self createForeignObjectFor: bitmap.
	self map: bitmap toForeignObject: bitmapFO.
]

{ #category : 'image building examples' }
ImageBuilder >> addExample07LoadDynamicLibraryMethods [

	{

		BlockClosure>>#timeToRun.
		Time class>>#millisecondsToRun:.
		Time class>>#localMillisecondClock.
		Time class>>#primLocalMicrosecondClock.

	} do: [ :compiledMethod |
		self addExistingMethod: compiledMethod ].
]

{ #category : 'foreign objects' }
ImageBuilder >> addExistingMethod: aCompiledMethod [

	| methodSpec methodForeignObject |
	self deny: (methods anySatisfy: [ :mthodSpec |
		(mthodSpec classSpec name = aCompiledMethod methodClass theNonMetaClass name) &
		(mthodSpec isClassSide = aCompiledMethod methodClass isMeta) &
		(mthodSpec selector = aCompiledMethod selector) ]).
	methodSpec := MethodSpec for: aCompiledMethod addClassesTo: classes.	
	methodForeignObject := self addMethodSpec: methodSpec.
	methods add: methodSpec.
	^methodForeignObject
]

{ #category : 'image building' }
ImageBuilder >> addFundamentalClasses [
	"Some classes that are needed for any Cuis image:
	- nil, false and true are always present and need their class
	- all superclasses for VM known classes
	- all classes and superclasses for SpecialObjectsArray.
	Do not include those already added in #addVmKnownClasses.
	Add ForeignObjects both for class and metaclass to the list.
	But only add the one for the class to the foreignObjects dictionary, because they share the spec."
	"This first implementation uses the fact that these classes already exist in the image we are running.
	It would be better to build them from scratch, using alternative class protocol in ClassSpec,
	most likely by compiling a source code file."

	| fundamentalClassNames |
	fundamentalClassNames := #(#UndefinedObject #False #True
		#ProtoObject #Object #Boolean #Magnitude #Number #Integer #Float
		#Collection #SequenceableCollection #CharacterSequence #Symbol #ArrayedCollection #LinkedList
		#Set #Dictionary #IdentityDictionary #SystemDictionary
		#LookupKey #Association
		#InstructionStream #ContextPart
		#ProcessorScheduler #Link #Process
		#Behavior #ClassDescription #Class #Metaclass
		#MethodDictionary
		#CompiledMethod #AdditionalMethodState #Pragma
		#SharedQueue).
	self includeDisplayAndSensor ifTrue: [
		fundamentalClassNames := fundamentalClassNames, #(#Form #DisplayScreen #InputSensor #EventSensor ) ].
	fundamentalClassNames do: [ :className | | classSpec classForeignObject |
		classSpec := ClassSpec for: (Smalltalk at: className) addClassesTo: classes.	
		classForeignObject := self addClassAndMetaclassSpec: classSpec classIndexOrNil: nil.
		self map: classSpec toForeignObject: classForeignObject ].
]

{ #category : 'image building' }
ImageBuilder >> addFundamentalObjectsAndClasses [
	"
	Objects and classes added here are absolutely required for building
	a healthy image that includes what the VM expects.
	"

	self addSpecial: nil hash: 1 nameOfClassToInstantiate: #UndefinedObject.
	self addSpecial: false hash: 2 nameOfClassToInstantiate: #False.
	self addSpecial: true hash: 3 nameOfClassToInstantiate: #True.
	
	self addSpurHiddenObjectsIfRequired.

	"SpecialObjects Array. Ivar specialObjectsArrayForeignObject holds its fo.
	Apparently the Spur VM saves the image with the SOA at this position,
	\after the ClassTable and its first two pages. Do the same here."
	self addSpecialObjectsArray.

	"Add classes known by the Spur VM"
	self addVmKnownClasses.
	"Add other classes absolutely required by the VM, and their superclasses."
	self addFundamentalClasses.

	"Create basic globals"
	"Smalltalk globals inspect"
	self addProcessor.
	self includeDisplayAndSensor ifTrue: [
		self addDisplay.
		self addSensor ].
	self addSmalltalk.
	self addUndeclared.

	"After adding classes, we can fill the contents of the SpecialObjects array"
	self fillSpecialObjectsArray.
]

{ #category : 'foreign objects' }
ImageBuilder >> addGlobalNamed: aSymbol value: anObject [
	"The key aSymbol is added to the foreignObjectsMap.
	The value is not, as it should be referenced through the key, or through the association, as a global binding.
	The association is also not mapped, as any reference to globals is handled via a LiteralVariableSpec,
	that will query the new globals dictionary when needed.

	Not mapping the global value and the association means there's some risk of someone else mapping them,
	therefore adding them twice to the new image.
	We may change this decision as we know better (jmv, May 24, 2023).

	Answer a two element array holding the ForeignObject of the Association(binding)
		and the ForeignObject of anObject."

	| keyForeignObject valueForeignObject globalBindingAssociation globalBindingAssociationForeignObject |
	"Add the global name to the list, to the map, and to the 'symbols' ivar."
	keyForeignObject := self findOrAddLiteral: aSymbol.

	"Don't add global value to the map. Usually, nobody should refer to it directly, only by name/binding."
	valueForeignObject := self findOrAdd: anObject.

	"Don't add the Association to the map. Access should usually be from CompiledMethods, and the
	corresponding LiteralVariableSpec will hold the name, and should now khow to get to them,"	
	globalBindingAssociation := Association key: keyForeignObject value: valueForeignObject.
	globalBindingAssociationForeignObject := self createForeignObjectFor: globalBindingAssociation.
	globalVariables add: globalBindingAssociationForeignObject.

	^{ globalBindingAssociationForeignObject. valueForeignObject }
]

{ #category : 'image building' }
ImageBuilder >> addMethodDictionariesAndStuff [
	"Fix Class hierarchies, build MethodDictionaries.
	Build the Smalltalk SystemDictionary."

	"Superclasses of method methodClass may not be mapped yet. Additionally, add all as subclasses of their superclass."
	classes do: [ :classSpec | | classForeignObject |
		classForeignObject := self findOrAddClassSpec: classSpec.
		classSpec superclass ifNotNil: [ :superclassSpec |
			(foreignObjectsMap at: superclassSpec) addSubclass: classForeignObject ]].

	"Now turn the subclasses OrderedCollections into a foreign object for an Array"
	classes do: [ :classSpec | | classForeignObject |
		classForeignObject :=  foreignObjectsMap at: classSpec.
		classForeignObject subclassesForeignObject:
			(self createForeignObjectFor: classForeignObject subclassForeignObjects asArray) ].

	"Build MethodDictionaries. No additional classes or methods will be allowed!"
	classes do: [ :classSpec | | classForeignObject metaClassForeignObject |
		classForeignObject := foreignObjectsMap at: classSpec.
		self addMethodDictionaryFor: classForeignObject.
		metaClassForeignObject := classForeignObject metaclassForeignObject.
		self addMethodDictionaryFor: metaClassForeignObject ].

	"Now that we have all the required globals at ivar 'globalVariables', fill the contents of the Smalltalk object."
	self fillSmalltalkDictionary.
]

{ #category : 'foreign objects' }
ImageBuilder >> addMethodSpec: aMethodSpec [

	| methodForeignObject classOrMetaclassForeignObject |
	self findOrAddLiteral: aMethodSpec selector.
	methodForeignObject := self createForeignObjectFor: aMethodSpec.
	classOrMetaclassForeignObject := self findOrAddClassSpec: aMethodSpec classSpec.
	aMethodSpec isClassSide ifTrue: [
		classOrMetaclassForeignObject := classOrMetaclassForeignObject metaclassForeignObject ].
	methodForeignObject methodClassForeignObject: classOrMetaclassForeignObject.
	classOrMetaclassForeignObject addMethod: methodForeignObject.

	"Aca es donde hay que agregar a la imagen cosas como literales, pragmas, ver qué más."
	aMethodSpec literals do: [ :each | | lit |
		lit := each.
		(lit is: #LiteralVariableSpec)
			ifTrue: [
				"If we are to ever be able to resolve this name, the name itself must already
				be there, as a key in some #classPool or the Smalltalk dictionary!"
				"self findOrAddLiteral: lit variableName"]
			ifFalse: [
				self findOrAddLiteral: lit]].

	^methodForeignObject
]

{ #category : 'image building' }
ImageBuilder >> addMethodsIn: libraryName [

	"Add required methods."
	Smalltalk allClassesDo: [ :cls |
		cls class methodsDo: [ :cm |
			(cm propertyValueAt: #libraryName) == libraryName ifTrue: [
				self addExistingMethod: cm ]].
		cls methodsDo: [ :cm |
			(cm propertyValueAt: #libraryName) == libraryName ifTrue: [
				self addExistingMethod: cm ]]].
]

{ #category : 'globals' }
ImageBuilder >> addProcessor [
	"This assumes the shape of ProcessorScheduler, Process, and included ivars will not change...
	When bootstrapping from files, or from a separate hierarchy,
		see MicroSqueak - MicroSqueakImageBuilder >> #buildScheduler"

	| processor foreignObjectsForBindingAndValue |
	processor := ProcessorScheduler basicNew.
	foreignObjectsForBindingAndValue := self addGlobalNamed: #Processor value: processor.
	processorBindingForeignObject := foreignObjectsForBindingAndValue first.
]

{ #category : 'globals' }
ImageBuilder >> addSensor [
	"The actual instance will be created on startup.
	See EventSensor class >> #install
	Here we add the global, so the association is ready for that method to actually assign to the global."

	self addGlobalNamed: #Sensor value: nil.
]

{ #category : 'globals' }
ImageBuilder >> addSmalltalk [
	"This assumes the shape of SystemDictionary will not change..."

	| smalltalkObject foreignObjectsForBindingAndValue |
	smalltalkObject := SystemDictionary basicNew.
	foreignObjectsForBindingAndValue := self addGlobalNamed: #Smalltalk value: smalltalkObject.
	smalltalkForeignObject := foreignObjectsForBindingAndValue second.
]

{ #category : 'foreign objects' }
ImageBuilder >> addSpecial: anObject hash: identityHash nameOfClassToInstantiate: nameOfClassToInstantiate [
	"For special objects nil true, false"

	| foreignObject foClass |
	foClass := self foreignObjectClassFor: anObject.
	foreignObject := self createForeignObjectFor: anObject hash: identityHash class: foClass.
	foreignObject nameOfClassToInstantiate: nameOfClassToInstantiate.
	self map: anObject toForeignObject: foreignObject.
	^foreignObject
]

{ #category : 'image building' }
ImageBuilder >> addSpecialObjectsArray [
	"Create a SpecialObjectsArray for our new image. See #recreateSpecialObjectsArray.
	Add a ForeignObject for it to our foreign object list and dicitonary.
	See #fillSpecialObjectsArray."

	| specialObjectsArray |
	specialObjectsArray := Array new: 60.
	specialObjectsArrayForeignObject := self createForeignObjectFor: specialObjectsArray.
]

{ #category : 'image building' }
ImageBuilder >> addSpurHiddenObjectsIfRequired [
	"NOP here. Only for Spur."
]

{ #category : 'globals' }
ImageBuilder >> addStartProcess [
	"This assumes the shape of ProcessorScheduler, Process, and included ivars will not change...
	When bootstrapping from files, or from a separate hierarchy,
		see MicroSqueak - MicroSqueakImageBuilder >> #buildScheduler"

	| methodContext startProcess processor emptyArray |
	emptyArray := #().
	methodContext := MethodContext
		sender: nil
		receiver: smalltalkForeignObject
		method: startUpMethod
		arguments: emptyArray.

	"Set program counter. Quire like doing:
	methodContext pc: startUpMethod initialPC,
	(as already done during MethodContext creation above)
	but we need do it for the target image word size, not the running image word size!"
	methodContext pc: (startUpMethod numLiterals + 1) * self wordSize + 1.

	startProcess := Process
		forContext: (self createForeignObjectFor: methodContext)
		priority: 40.
	startProcess name: 'Startup'.
	self map: emptyArray toForeignObject: (self createForeignObjectFor: emptyArray).
	self findOrAdd: startProcess name.
	
	processor := processorBindingForeignObject representedObject value representedObject.
	processor
		instVarNamed: 'quiescentProcessLists'
		put: (self createForeignObjectFor: ((1 to: 80) collect: [ :i | self createForeignObjectFor: LinkedList new ])).
	processor
		instVarNamed: 'activeProcess'
		put: (self createForeignObjectFor: startProcess).
]

{ #category : 'globals' }
ImageBuilder >> addUndeclared [
	"This assumes the shape of Dictionary will not change..."

	| undeclaredDictionary dictArray dictArrayForeignObject |
	undeclaredDictionary := Dictionary new.
	"Now replace the array inside with a ForeignObject for it"
	dictArray := undeclaredDictionary array.
	dictArrayForeignObject := self createForeignObjectFor: dictArray.
	undeclaredDictionary instVarNamed: 'array' put: dictArrayForeignObject.
	self addGlobalNamed: #Undeclared value: undeclaredDictionary.
]

{ #category : 'image building' }
ImageBuilder >> addVmKnownClasses [
"
Copied and adapted from the Spur implementation, that requires specific identityHash for these classe.
This implementation hasn't yet been tested!
"
	"Some classes are known by the VM.
	- They have specific classIndex and identityHash
	- They are stored in the first page of the class table
	Add ForeignObjects both for class and metaclass to the list.
	But only add the one for the class to the foreignObjects dictionary, because they share the spec."
	"This first implementation uses the fact that these classes already exist in the image we are running.
	It would be better to build them from scratch, using alternative class protocol in ClassSpec,
	most likely by compiling a source code file."

	| vmKnownClassNames |
	vmKnownClassNames := #(
		#SmallInteger
		#Character
		#LargeNegativeInteger
		#LargePositiveInteger
		#BoxedFloat64
		#Message
		#MethodContext
		#BlockClosure
		#Semaphore
		#ByteArray
		#Array
		#String
		#Point).
	self includeDisplayAndSensor ifTrue: [
		vmKnownClassNames := vmKnownClassNames, #(#Bitmap) ].
	vmKnownClassNames do: [ :className | | classSpec classForeignObject |
		classSpec := ClassSpec for: (Smalltalk at: className) addClassesTo: classes.	
		classForeignObject := self addClassAndMetaclassSpec: classSpec classIndexOrNil: nil.
		self map: classSpec toForeignObject: classForeignObject ].
]

{ #category : 'image building' }
ImageBuilder >> addWithAllMethods: classNames [
	"Note: Superclasses are included if not already, but their methods are not added.
	If super implementation or inherited behavior is needed, this won't suffice."

	"Classes included with ALL their methods."
	classNames
		do: [ :className | | cls classSpec |
			cls := Smalltalk at: className.
			classSpec := ClassSpec for: cls addClassesTo: classes.	
			self findOrAddClassSpec: classSpec.
			cls class methodsDo: [ :compiledMethod |
				self addExistingMethod: compiledMethod ].
			cls methodsDo: [ :compiledMethod |
				self addExistingMethod: compiledMethod ]].
]

{ #category : 'image building examples' }
ImageBuilder >> buildExample01Stdout [
	"
	Spur64ImageBuilder new
		buildExample01Stdout;
		saveImageTo: 'Example01Stdout.image' asFileEntry.
	"
	"
	Spur32ImageBuilder new
		buildExample01Stdout;
		saveImageTo: 'Example01Stdout32.image' asFileEntry.
	"

	| startUpMethodForeignObject |

	"Any image will include these. They are mandatory."
	self addFundamentalObjectsAndClasses.

	"Most images will need these."
	self addMethodsIn: #MinimalKernel01.

	"Set what this image will do when run."
	startUpMethod := SystemDictionary>>#bootstrappedExample01Stdout.
	startUpMethodForeignObject := self addExistingMethod: startUpMethod.
	self map: startUpMethod toForeignObject: startUpMethodForeignObject.

	"Create special methods to warn about improper execution of inherited methods when proper method was not included."
	self createAndAddWarningMethodsForMissing.

	"Add additionally stuff to the image. This is the same for any image."
	self addMethodDictionariesAndStuff.

	"Creating the start process requires CompiledMethods to be there"
	self addStartProcess.
]

{ #category : 'image building examples' }
ImageBuilder >> buildExample02DoesNotUnderstand [
	"
	Spur64ImageBuilder new
		buildExample02DoesNotUnderstand;
		saveImageTo: 'Example02DoesNotUnderstand.image' asFileEntry.
	"
	"
	Spur32ImageBuilder new
		buildExample02DoesNotUnderstand;
		saveImageTo: 'Example02DoesNotUnderstand32.image' asFileEntry.
	"

	| startUpMethodForeignObject |

	"Any image will include these. They are mandatory."
	self addFundamentalObjectsAndClasses.

	"Most images will need these."
	self addMethodsIn: #MinimalKernel01.

	"Set what this image will do when run."
	startUpMethod := SystemDictionary>>#bootstrappedExample02DoesNotUnderstand.
	startUpMethodForeignObject := self addExistingMethod: startUpMethod.
	self map: startUpMethod toForeignObject: startUpMethodForeignObject.

	"Create special methods to warn about improper execution of inherited methods when proper method was not included."
	self createAndAddWarningMethodsForMissing.

	"Add additionally stuff to the image. This is the same for any image."
	self addMethodDictionariesAndStuff.

	"Creating the start process requires CompiledMethods to be there"
	self addStartProcess.
]

{ #category : 'image building examples' }
ImageBuilder >> buildExample03Float [
	"
	Spur64ImageBuilder new
		buildExample03Float;
		saveImageTo: 'Example03Float.image' asFileEntry.
	"
	"
	Spur32ImageBuilder new
		buildExample03Float;
		saveImageTo: 'Example03Float32.image' asFileEntry.
	"

	| startUpMethodForeignObject |

	"Any image will include these. They are mandatory."
	self addFundamentalObjectsAndClasses.

	"Most images will need these."
	self addMethodsIn: #MinimalKernel01.

	"Set what this image will do when run."
	self addMethodsIn: #MinimalKernel03Float.
	startUpMethod := SystemDictionary>>#bootstrappedExample03Float.
	startUpMethodForeignObject := self addExistingMethod: startUpMethod.
	self map: startUpMethod toForeignObject: startUpMethodForeignObject.

	"Create special methods to warn about improper execution of inherited methods when proper method was not included."
	self createAndAddWarningMethodsForMissing.

	"Add additionally stuff to the image. This is the same for any image."
	self addMethodDictionariesAndStuff.

	"Creating the start process requires CompiledMethods to be there"
	self addStartProcess.
]

{ #category : 'image building examples' }
ImageBuilder >> buildExample04SymbolExperiments [
	"
	Spur64ImageBuilder new
		buildExample04SymbolExperiments;
		saveImageTo: 'Example04SymbolExperiments.image' asFileEntry.
	"
	"
	Spur32ImageBuilder new
		buildExample04SymbolExperiments;
		saveImageTo: 'Example054ymbolExperiments32.image' asFileEntry.
	"

	| startUpMethodForeignObject |

	"Any image will include these. They are mandatory."
	self addFundamentalObjectsAndClasses.

	"Most images will need these."
	self addMethodsIn: #MinimalKernel01.

	"Set what this image will do when run."
	self addMethodsIn: #MinimalKernel02Symbol.
	startUpMethod := SystemDictionary>>#bootstrappedExample04SymbolExperiments.
	startUpMethodForeignObject := self addExistingMethod: startUpMethod.
	self map: startUpMethod toForeignObject: startUpMethodForeignObject.

	"Create special methods to warn about improper execution of inherited methods when proper method was not included."
	self createAndAddWarningMethodsForMissing.

	"Add additionally stuff to the image. This is the same for any image."
	self addMethodDictionariesAndStuff.

	"Creating the start process requires CompiledMethods to be there"
	self addStartProcess.
]

{ #category : 'image building examples' }
ImageBuilder >> buildExample05FileExperiments [
	"
	Spur64ImageBuilder new
		buildExample05FileExperiments;
		saveImageTo: 'Example05FileExperiments.image' asFileEntry.
	"
	"
	Spur32ImageBuilder new
		buildExample05FileExperiments;
		saveImageTo: 'Example05FileExperiments32.image' asFileEntry.
	"

	| startUpMethodForeignObject |

	"Any image will include these. They are mandatory."
	self addFundamentalObjectsAndClasses.

	"Most images will need these."
	self addMethodsIn: #MinimalKernel01.

	"Set what this image will do when run."
	self addMethodsIn: #MinimalKernel07VMnImage.
	self addMethodsIn: #MinimalKernel08BasicFileServices.
	startUpMethod := SystemDictionary>>#bootstrappedExample05FileExperiments.
	startUpMethodForeignObject := self addExistingMethod: startUpMethod.
	self map: startUpMethod toForeignObject: startUpMethodForeignObject.

	"Create special methods to warn about improper execution of inherited methods when proper method was not included."
	self createAndAddWarningMethodsForMissing.

	"Add additionally stuff to the image. This is the same for any image."
	self addMethodDictionariesAndStuff.

	"Creating the start process requires CompiledMethods to be there"
	self addStartProcess.
]

{ #category : 'image building examples' }
ImageBuilder >> buildExample06LoadDynamicLibrary [
	"
	Spur64ImageBuilder new
		buildExample06LoadDynamicLibrary;
		saveImageTo: 'Example06LoadDynamicLibrary.image' asFileEntry.
	"
	"
	Spur32ImageBuilder new
		buildExample06LoadDynamicLibrary;
		saveImageTo: 'Example06LoadDynamicLibrary32.image' asFileEntry.
	"
	"
	Feature require: 'TestDynamicCuisLibraries'.
	""
	| sourceForLibrary lib |
	sourceForLibrary := NoclashABC_DclExample03.
	lib := DynamicCuisLibrary
		withClasses: { sourceForLibrary }
		classSelectors: { sourceForLibrary class selectors }
		instanceSelectors: { sourceForLibrary selectors }.
	lib writeOnFile: 'DclExample03.dcl' asFileEntry
	"
	| startUpMethodForeignObject |

	"Any image will include these. They are mandatory."
	self addFundamentalObjectsAndClasses.

	"Most images will need these."
	self addMethodsIn: #MinimalKernel01.

	"Set what this image will do when run."
	self addMethodsIn: #MinimalKernel02Symbol.
	self addMethodsIn: #MinimalKernel04HashedCollections.
	self addMethodsIn: #MinimalKernel05ClassAndMethodCreation.
	self addMethodsIn: #MinimalKernel06ObjectSerialization.
	self addMethodsIn: #MinimalKernel08BasicFileServices.
	self addMethodsIn: #MinimalKernel09CodeLibraryLoad.
	startUpMethod := SystemDictionary>>#bootstrappedExample06LoadDynamicLibrary.
	startUpMethodForeignObject := self addExistingMethod: startUpMethod.
	self map: startUpMethod toForeignObject: startUpMethodForeignObject.

	"Create special methods to warn about improper execution of inherited methods when proper method was not included."
	self createAndAddWarningMethodsForMissing.

	"Add additionally stuff to the image. This is the same for any image."
	self addMethodDictionariesAndStuff.

	"Creating the start process requires CompiledMethods to be there"
	self addStartProcess.
]

{ #category : 'image building examples' }
ImageBuilder >> buildExample07LoadDynamicLibrary [
	"
	Spur64ImageBuilder new
		buildExample07LoadDynamicLibrary;
		saveImageTo: 'Example07LoadDynamicLibrary.image' asFileEntry.
	"
	"
	Spur32ImageBuilder new
		buildExample06LoadDynamicLibrary;
		saveImageTo: 'Example07LoadDynamicLibrary32.image' asFileEntry.
	"

	| startUpMethodForeignObject |

	"Any image will include these. They are mandatory."
	self addFundamentalObjectsAndClasses.

	"Most images will need these."
	self addMethodsIn: #MinimalKernel01.

	"Set what this image will do when run."
	self addMethodsIn: #MinimalKernel02Symbol.
	self addMethodsIn: #MinimalKernel04HashedCollections.
	self addMethodsIn: #MinimalKernel05ClassAndMethodCreation.
	self addMethodsIn: #MinimalKernel06ObjectSerialization.
	self addMethodsIn: #MinimalKernel08BasicFileServices.
	self addMethodsIn: #MinimalKernel09CodeLibraryLoad.
	self addExample07LoadDynamicLibraryMethods.
	startUpMethod := SystemDictionary>>#bootstrappedExample07LoadDynamicLibrary.
	startUpMethodForeignObject := self addExistingMethod: startUpMethod.
	self map: startUpMethod toForeignObject: startUpMethodForeignObject.

	"Create special methods to warn about improper execution of inherited methods when proper method was not included."
	self createAndAddWarningMethodsForMissing.

	"Add additionally stuff to the image. This is the same for any image."
	self addMethodDictionariesAndStuff.

	"Creating the start process requires CompiledMethods to be there"
	self addStartProcess.
]

{ #category : 'image building' }
ImageBuilder >> createAndAddWarningMethodsForMissing [
	"Create special methods to warn about improper execution of inherited methods when proper method was not included."

	| includedSelectorsByClass excluded |
	excluded := #(
		#(nil 							printOn: 				ProtoObject)
		#(Object 						error: 					ProtoObject)
		#(Object 						doesNotUnderstand: 	ProtoObject)
		#(Object 						become: 				ProtoObject)
		#('Symbol class' 					initialize 				ProtoObject) 	"Included in library MinimalKernel02Symbol"
		#(SystemDictionary 			at:put: 					Object) 			"Included in library MinimalKernel04HashedCollections"
		#(Behavior 						postCopy 				Object)  		"Included in library MinimalKernel05ClassAndMethodCreation"
		#(Class 						copy 					Object)  		"Included in library MinimalKernel05ClassAndMethodCreation"
		#(Metaclass 					postCopy 				Object)  		"Included in library MinimalKernel05ClassAndMethodCreation"
		#(Metaclass 					new 					Behavior)  		"Included in library MinimalKernel05ClassAndMethodCreation"
		#(Message 						= 						Object)
		#(Message 						hash 					Object)
		#(Point 						= 						Object)
		#(Point 						hash 					Object)
		#(AdditionalMethodState 		at: 						Object)
		#(AdditionalMethodState 		at:put: 					Object)
		#(MethodSpec 					at: 						Object)
		#(MethodSpec 					at:put: 					Object)
		#(CompiledMethod 			= 						ByteArray)
		#(CompiledMethod 			hash 					ByteArray)
		#(MethodContext 				instVarAt:put: 			Object)
		#('CompiledMethod class' 		initialize 				ProtoObject)
		#('Character class' 				initialize 				ProtoObject)
		#(CharacterSequence 			writeStream 			SequenceableCollection)
		).
	includedSelectorsByClass := Dictionary new.
	methods do: [ :methodSpec |
		(includedSelectorsByClass at: {methodSpec classSpec. methodSpec isClassSide}
			ifAbsentPut: [ Set new ]) add: methodSpec selector ].

	classes do: [ :classSpec |
		{true. false} do: [ :classSideFlag |
			| includedSelectors existingClass |
			includedSelectors := includedSelectorsByClass at: {classSpec. classSideFlag} ifAbsent: [`Set new`].
			existingClass := Smalltalk at: classSpec name.
			classSideFlag ifTrue: [
				existingClass := existingClass class ].
			"Assume it doesn't make much sense for classes without any method at all."
			includedSelectors notEmpty ifTrue: [
				existingClass selectorsDo: [ :missingSelector |
					(includedSelectors includes: missingSelector) ifFalse: [
						(self includedDefinition: missingSelector in: classSpec isClassMethod: classSideFlag all: includedSelectorsByClass)
							ifNotNil: [ :inheritedFromString |
								(excluded anySatisfy: [ :spec | (spec first isNil or: [ spec first = existingClass name ]) and: [ spec second = missingSelector and: [ spec third = inheritedFromString ]]]) ifFalse: [
									includedSelectors size > 0 ifTrue: [ "Don't report empty classes."
										('Warning: ', existingClass name, ' >> #', missingSelector, ' not included, but inherited from ', inheritedFromString) print.
										"{classSpec. existingClass. inheritedFromString. missingSelector} print." ].
									self createWarningMethodFor: missingSelector in: classSpec isClassMethod: classSideFlag inheritedFrom: inheritedFromString ]]
					]]]]].
]

{ #category : 'foreign objects' }
ImageBuilder >> createForeignObjectFor: anObject [
	"anObject will be included in the new image
	Create and answer an instance of aForeignObjectClass for it.
	For objects that are allocated in memory:
		- Allocate space in the new image for it
		- Add it to the list of foreign objects we'll use to serialize.
	For objects that won't be allocated in memory (they are immediate objects,
	encoded in pointing OOPs, like SmallInteger, etc):
		- Just create and answer a ForeignObject that can encode object in an OOP when needed."

	| foreignObject foClass possiblyConvertedObject |
	"We can't convert UnicodeString to String here. We need to have the original object as key in the foreignObjectsMap"
	self deny: anObject class == UnicodeString.
	possiblyConvertedObject := anObject.
	possiblyConvertedObject class == UnicodeSymbol ifTrue: [
		self assert: possiblyConvertedObject isAscii.
		self halt.
		possiblyConvertedObject := Symbol basicFromString: possiblyConvertedObject asString asByteString ].
	foClass := self foreignObjectClassFor: possiblyConvertedObject.
	foreignObject := foClass instancesAreForImmediateObjects
		ifTrue: [ foClass newFor: possiblyConvertedObject ]
		ifFalse: [ self createForeignObjectFor: possiblyConvertedObject hash: self newObjectHash class: foClass ].
	^foreignObject
]

{ #category : 'foreign objects' }
ImageBuilder >> createForeignObjectFor: anObject hash: identityHash class: aForeignObjectClass [
	"anObject will be included in the new image
	Create and answer an instance of aForeignObjectClass for it.
	For objects that are allocated in memory:
		- Allocate space in the new image for it
		- Add it to the list of foreign objects we'll use to serialize.
	For objects that won't be allocated in memory (they are immediate objects,
	encoded in pointing OOPs, like SmallInteger, etc):
		- Just create and answer a ForeignObject that can encode object in an OOP when needed."

	self subclassResponsibility
]

{ #category : 'image building' }
ImageBuilder >> createWarningMethodFor: missingSelector in: classSpec isClassMethod: classSideFlag inheritedFrom: desc [
	"Made by playing with a method with this source code:
		hack3
			self warning: 'eso eso eso'
			^super hack3.
	And then going with the debugger through
		MethodSpec for: self addClassesTo: IdentityDictionary new.	
	Did the same with similar methods #hack3: and #hack3:b:
	The only difference was in header. Took logic from
		#computeMethodHeaderForNumArgs:numTemps:numLits:primitive:"

	 | warningString fallbackMethodSpec bytecodes sistaBytecodes header |
	warningString := String streamContents: [ :strm |
		strm
			nextPutAll: '======== ';
			nextPutAll: classSpec name asString.
		classSideFlag ifTrue: [ strm nextPutAll: ' class' ].
		strm
			nextPutAll: '>>#';
			nextPutAll: missingSelector;
			nextPutAll: ' was not included, but it is inherited from ';
			nextPutAll: desc ].

	"Sista bytecodes."
	bytecodes := #[76 33 144 216 76 235 16 92 ].
	sistaBytecodes := true.
	header := 4 + (missingSelector numArgs bitShift: 24) + (missingSelector numArgs bitShift: 18).
	fallbackMethodSpec := MethodSpec basicNew
		classSpec: classSpec
		isClassSide: classSideFlag
		selector: missingSelector
		headerSignFlag: sistaBytecodes
		header: header
		literals: {#warning:. warningString}
		pragmas: nil
		bytecodes: bytecodes.
	self addMethodSpec: fallbackMethodSpec.
	methods add: fallbackMethodSpec.
]

{ #category : 'smalltalk dictionary' }
ImageBuilder >> fillSmalltalkDictionary [
	"Create thre contents of the Smalltalk SystemDictionary for the new image.
	Do it here, by 'remote control'. Assumes the structure of SystemDictionary is same as in this image,
	reflected in this code."

	| smalltalkObject smalltalkSize smalltalkArray smalltalkArrayForeignObject keyForeignObject classForeignObject |

	"Fetch the newly created, empty Smalltalk remote object."
	smalltalkObject := smalltalkForeignObject representedObject.
	self assert: smalltalkObject == (globalVariables detect: [ :assocFO |
		assocFO representedObject key representedObject == #Smalltalk ])
			representedObject value representedObject.

	"Create large enough."
	smalltalkSize := classes size + globalVariables size.
	smalltalkArray := Array new: smalltalkSize * 2.

	"Fill the 'array' ivar, using the identityHash from the foreignObjects of the keys, as they will be
	assigned to them on image serialization. Do it both for classes and other globals."
	classes do: [ :classSpec |
		keyForeignObject := foreignObjectsMap at: classSpec name.
		classForeignObject := foreignObjectsMap at: classSpec.
		self systemDictionaryArray: smalltalkArray at: keyForeignObject put: classForeignObject  ].
	globalVariables do: [ :assocForeignObject |
		self systemDictionaryArray: smalltalkArray add: assocForeignObject  ].

	"Done. Give them to it."
	smalltalkObject instVarNamed: 'tally' put: smalltalkSize.
	smalltalkArrayForeignObject := self createForeignObjectFor: smalltalkArray.
	smalltalkObject instVarNamed: 'array' put: smalltalkArrayForeignObject.
]

{ #category : 'image building' }
ImageBuilder >> fillSpecialObjectsArray [
	"Please see implementation for Spur.
	Also see #recreateSpecialObjectsArray.
	See reference implementations (MicroSqueak.pck.st and SystemTracing.pck.st)"

	"Maybe after implementing for all subclasses, move a refactored version up here."
]

{ #category : 'foreign objects' }
ImageBuilder >> findClassNamed: aSymbol [
	"Answer the foreign object that represents the class that will be named as the argument."

	^foreignObjectsMap at: (classes at: aSymbol)
]

{ #category : 'foreign objects' }
ImageBuilder >> findForeignObjectFor: anObjectToInclude [
	"anObjectToInclude must already be mapped,
	except for immediates. We can create them on the fly."

	| foClass |

	foreignObjectsMap at: anObjectToInclude ifPresent: [ :found | ^found ].

	foClass := self foreignObjectClassFor: anObjectToInclude.
	foClass instancesAreForImmediateObjects
		ifTrue: [ ^foClass newFor: anObjectToInclude ].

	^self error: 'Object not allocated (No ForeignObject found for it)'.
]

{ #category : 'foreign objects' }
ImageBuilder >> findGlobalBindingNamed: aSymbol [
	"Answer the foreign object for the Association that holds global named as the argument.
	Answer nil if no such global"

	^smalltalkForeignObject representedObject "a SystemDictionary for the new image"
		array representedObject  								"its #array"
			detect: [ :associationForeignObject |
				associationForeignObject notNil and: [
					associationForeignObject representedObject key representedObject
						= aSymbol ] ]
			ifNone: nil
]

{ #category : 'foreign objects' }
ImageBuilder >> findOrAdd: anObjectToInclude [
	"anObjectToInclude will be included in the new image.
	Create and add a ForeignObject if needed.
	Add it to the foreignObjectsMap, so we use the same instance next time anObjectToInclude shows up."
	| fo |
"Para la serializacion. Ir validando lo que vaya apareciendo...
Por ejemplo, las refs a globales deberian entrar por nombre. Si aca empezamos a meter lo que aparezca, podriamos, por ejemplo, duplicar Display, Sensor, Processor, Smalltalk."
	^foreignObjectsMap at: anObjectToInclude ifAbsent: [
		fo := self createForeignObjectFor: anObjectToInclude.
		self map: anObjectToInclude toForeignObject: fo.
		fo ]
]

{ #category : 'foreign objects' }
ImageBuilder >> findOrAddClassSpec: classSpec [
	"Ensure argument is added, but don't add it twice"

	| classForeignObject |
	foreignObjectsMap at: classSpec ifPresent: [ :clsFO |
		^clsFO ].
	classForeignObject := self addClassAndMetaclassSpec: classSpec classIndexOrNil: nil.
	self map: classSpec toForeignObject: classForeignObject.
	^classForeignObject.
]

{ #category : 'foreign objects' }
ImageBuilder >> findOrAddLiteral: aLiteral [
	"aLiteral can be a String or Symbol. Also an Array of them.
	Additionally, aLiteral may be any object that answers true to #isLiteral
	This restriction could be lifted. It is in place so we control and understand what we are adding!
	"
	"We could consider searching foreignObjectsMap for any object equal to aLiteral.
	That would avoid, for example, may instances of the empty String, or things like that."
	"Ensure argument is added, but don't add it twice.
	
	Add argument to the list.
	Also add it to map.
	Also add it to the 'symbols' instance variable. Wel'll use this to create a Symbol Table in the new image.
	(This should be quite similar to how we build the new Smalltalk SystemDictionary for the new image.)"


	| newForeignObject |
	self assert: aLiteral isLiteral.
	
	foreignObjectsMap at: aLiteral ifPresent: [ :foreignObject |
		^foreignObject ].

	newForeignObject := self createForeignObjectFor: aLiteral.
	newForeignObject class instancesAreForImmediateObjects ifTrue: [
		^ newForeignObject ].

	self map: aLiteral toForeignObject: newForeignObject.

	aLiteral isSymbol ifTrue: [
		symbols add: newForeignObject ].
	
	newForeignObject referencedObjectsDo: [ :each |
		self findOrAddLiteral: each ].

	^newForeignObject
]

{ #category : 'foreign objects' }
ImageBuilder >> foreignObjectClassFor: anObject [
	"Answer the correct ForeignObject subclass to represent anObject.
	Redefined in subclasses for some specific cases."

	^ForeignObject subclassFor: anObject.
]

{ #category : 'format constants' }
ImageBuilder >> imageFormat [
	"Answer the number that identifies this image format"
	self subclassResponsibility 
]

{ #category : 'format constants' }
ImageBuilder >> imageHeaderSize [
	"In Bytes"
	self subclassResponsibility 
]

{ #category : 'image building' }
ImageBuilder >> includeDisplayAndSensor [
	"Some images may need them, but minimal headless images won't."
	^false
]

{ #category : 'image building' }
ImageBuilder >> includedDefinition: missingSelector in: classSpec isClassMethod: classSideFlag all: includedSelectorsByClass [
	"missingSelector is defined for classSpec but wasn't included.
	Answer the inherited version that would be run instead, if any."

	classSpec superclass ifNotNil: [ :superclassSpec |
		(self includedDefinition: missingSelector start: superclassSpec isClassMethod: classSideFlag all: includedSelectorsByClass)
			ifNotNil: [ :includedDefinition |
				^classSideFlag
					ifTrue: [ includedDefinition name asString, ' class' ]
					ifFalse: [	 includedDefinition name asString ]]].

	"Class side methods can also be inherited from the instance side of class Class."
	classSideFlag ifTrue: [| classClassSpec |
		classClassSpec := classes at: #Class.
		(self includedDefinition: missingSelector start: classClassSpec isClassMethod: false all: includedSelectorsByClass)
			ifNotNil: [ :includedDefinition |
				^includedDefinition name asString ]].

	^nil
]

{ #category : 'image building' }
ImageBuilder >> includedDefinition: missingSelector start: classSpec isClassMethod: classSideFlag all: includedSelectorsByClass [
	"Find the closest included definition of missingSelector.
	Start search at classSpec and go upwards in the hierarchy,"

	classSpec withAllSuperclassesDo: [ :superclassSpec |
		includedSelectorsByClass
			at: { superclassSpec. classSideFlag }
			ifPresent: [ :includedSelectors |
				(includedSelectors includes: missingSelector) ifTrue: [
					^superclassSpec ]]].
	^nil
]

{ #category : 'initialization' }
ImageBuilder >> initialize [
	isBigEndian := false. "default"
	classes := OrderedDictionary new.
	methods := IdentitySet new.
	baseAddressOfImage := self imageHeaderSize. 	"Base address. Start of Object Memory."
	nextFreeAddressOfImage := baseAddressOfImage.
	foreignObjectsMap := IdentityDictionary new.
	globalVariables  := OrderedCollection new.
	symbols := OrderedCollection new.
]

{ #category : 'foreign objects' }
ImageBuilder >> map: localObject toForeignObject: foreignObject [
	"Any reference to localObject will be converted to a reference to the object to be materialized by foreignObject."

	(foreignObjectsMap includesKey: localObject) ifTrue: [
		self error: 'Object to map to ForeignObjects added twice!' ].
	foreignObjectsMap at: localObject put: foreignObject
]

{ #category : 'format constants' }
ImageBuilder >> maxIdentityHash [
	"Answer the maximum identityHash value supported by the VM."

	self subclassResponsibility 
]

{ #category : 'services' }
ImageBuilder >> newObjectHash [
	^self subclassResponsibility
]

{ #category : 'services' }
ImageBuilder >> on: aStream nexWordPut: aNumber [
	"Write #wordSize bytes. Use 'isBigEndian' endianess."
	self subclassResponsibility
]

{ #category : 'services' }
ImageBuilder >> on: aStream nextUint16Put: aNumber [
	"Write 2 bytes. Use 'isBigEndian' endianess."

	aStream nextUint16Put: aNumber bigEndian: isBigEndian.
]

{ #category : 'services' }
ImageBuilder >> on: aStream nextUint32Put: aNumber [
	"Write 4 bytes. Use 'isBigEndian' endianess."

	aStream nextUint32Put: aNumber bigEndian: isBigEndian.
]

{ #category : 'services' }
ImageBuilder >> on: aStream nextUint64Put: aNumber [
	"Write 8 bytes. Use 'isBigEndian' endianess."

	aStream nextUint64Put: aNumber bigEndian: isBigEndian.
]

{ #category : 'smalltalk dictionary' }
ImageBuilder >> systemDictionaryArray: array add: anAssociationForeignObject [
	"Essentially copied from Dictionary >> #add:
	Assumes SystemDictionary will be pretty much the same in the generated image.
	Raise an error if same key added twice: this is specific for adding globals to a new image,
	and we'd better know what we are doing."

	| keyForeignObject index |
	keyForeignObject := anAssociationForeignObject representedObject key.
	index := self systemDictionaryArray: array scanFor: keyForeignObject.
	(array at: index) ifNotNil: [ self error: 'Duplicated global!' ].
	array at: index put: anAssociationForeignObject.
]

{ #category : 'smalltalk dictionary' }
ImageBuilder >> systemDictionaryArray: array at: keyForeignObject put: classForeignObject [
	"Essentially copied from Dictionary >> #at:put:
	Assumes SystemDictionary will be pretty much the same in the generated image.
	Raise an error if same key added twice: this is specific for adding globals to a new image,
	and we'd better know what we are doing."

	| index globalBindingAssociation globalBindingAssociationForeignObject |
	index := self systemDictionaryArray: array scanFor: keyForeignObject.
	(array at: index) ifNotNil: [ self error: 'Duplicated global!' ].
	globalBindingAssociation := Association key: keyForeignObject value: classForeignObject.
	globalBindingAssociationForeignObject := self createForeignObjectFor: globalBindingAssociation.
	array at: index put: globalBindingAssociationForeignObject.
]

{ #category : 'smalltalk dictionary' }
ImageBuilder >> systemDictionaryArray: array scanFor: keyForeignObject [
	"Essentially copied from IdentityDictionary >> #scanFor:
	Assumes SystemDictionary will be pretty much the same in the generated image."

	| finish scale start element |
	finish := array size.
	scale := finish // (self maxIdentityHash + 1).
	scale = 0 ifTrue: [scale := 1].
	start := (keyForeignObject foreignIdentityHashFor: self) * scale \\ finish + 1.

	"Search from (hash mod size) to the end."
	start to: finish do: [ :index |
		((element := array at: index) == nil or: [element representedObject key == keyForeignObject])
			ifTrue: [^ index ]].

	"Search from 1 to where we started."
	1 to: start-1 do: [ :index |
		((element := array at: index) == nil or: [element representedObject key == keyForeignObject])
			ifTrue: [^ index ]].

	self error: 'There is no free space in the newly created Smalltalk dictionary!'.
]

{ #category : 'format constants' }
ImageBuilder >> wordSize [
	"Also size of an oop.
	In Bytes"
	self subclassResponsibility 
]

{ #category : 'image file saving' }
ImageBuilder >> writeImageFileHeaderOn: aStream byteSize: imageByteSizeIncludingHeader [
	"Write an appropriate image file header.
	Intended to be called after saving the heap to the file, and setting #position: to zero."

	self subclassResponsibility
]
