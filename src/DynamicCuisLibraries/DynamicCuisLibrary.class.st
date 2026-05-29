"
A DynamicCuisLibrary defines a set of classes and methods that can be loaded into a running Cuis image. Its parts, instances of ClassSpec and MethodSpec are not actual Classes and CompiledMethods, but regular objects. Actual Classes and CompiledMethods are created from them at load time.
"
Class {
	#name : 'DynamicCuisLibrary',
	#superclass : 'Object',
	#instVars : [
		'classSpecs',
		'methodSpecs'
	],
	#category : 'DynamicCuisLibraries-Dynamic Libraries',
	#package : 'DynamicCuisLibraries',
	#tag : 'Dynamic Libraries'
}

{ #category : 'file io' }
DynamicCuisLibrary class >> readFromFileNamed: fileName [
	"
	(DynamicCuisLibrary readFromFileNamed: 'DclExample03.dcl')
		canBeInstalled
	"
	"que pasa si el file no existe?"
	| bytes |
	bytes := BasicFileServices binaryContentsOf: fileName.
	^(ReferenceStream on: bytes readStream) next
]

{ #category : 'instance creation' }
DynamicCuisLibrary class >> withClasses: arrayOfClasses classSelectors: arrayOfClassSelectors instanceSelectors: arrayOfInstanceSelectors [
	"
	DynamicCuisLibrary
		withClasses: #( Point )
		classSelectors: #( #(x:y:) )
		instanceSelectors: #( #( initializePvtX:y: x y #printOn:) ).
	"
	^ self new
		classes: arrayOfClasses
		classSelectors: arrayOfClassSelectors
		instanceSelectors: arrayOfInstanceSelectors
]

{ #category : 'creation' }
DynamicCuisLibrary >> buildClassesAndMethods: aBlock [

	| classSpecOrderedDictionary methodSpecOrderedCollection |
	classSpecs := nil.
	methodSpecs := nil.
	classSpecOrderedDictionary := OrderedDictionary new.
	methodSpecOrderedCollection := OrderedCollection new.
	aBlock value: classSpecOrderedDictionary value: methodSpecOrderedCollection.
	classSpecs := classSpecOrderedDictionary values.
	methodSpecs := methodSpecOrderedCollection asArray.
]

{ #category : 'installing' }
DynamicCuisLibrary >> canBeInstalled [
	classSpecs do: [ :each | each canBeInstalled ifFalse: [ ^false ]].

	"Prepare for possible later validation and conversion of MethodSpecs and existing CompiledMethods"
	classSpecs do: [ :classSpec | classSpec preInstall ].

	"Check that all affected classes can be updated"
	(self updateAffectedClassesFormat: false)
		ifFalse: [ ^false ].
	
	"Possible difference between class shapes when the library was built and the shape
	they will have after library install. Check that methods in the library can be corrected for them."
	(self remapMethodSpecInstVarAccesses: false)
		ifFalse: [ ^false ].

	"Possible difference between class shapes in the running image, before and after installing.
	Check that existing methods in the image that would be affected can be corrected for this."
	(self remapExistingMethodsInstVarAccesses: false)
		ifFalse: [ ^false ].

	^true
]

{ #category : 'creation from image' }
DynamicCuisLibrary >> classes: classesOrNames classSelectors: classSideSelectors instanceSelectors: instanceSideSelectors [
	"
	classesOrNames is an Array
	classSideSelectors and instanceSideSelectors are Arrays with same size of classesOrNames.
		Each element is an Array.
	"
	self buildClassesAndMethods: [ :classSpecODict :methodSpecOC |
		classesOrNames with: classSideSelectors with: instanceSideSelectors
					do: [ :classOrName :classSelectors :instanceSelectors | | eachClass |
			eachClass := classOrName isSymbol
				ifTrue: [ Smalltalk at: classOrName ]
				ifFalse: [classOrName ].
			ClassSpec for: eachClass addClassesTo: classSpecODict.
			classSelectors do: [ :selector |
				methodSpecOC add: (MethodSpec
					for: (eachClass class compiledMethodAt: selector)
					addClassesTo: classSpecODict) ].
			instanceSelectors do: [ :selector |
				methodSpecOC add: (MethodSpec
					for: (eachClass compiledMethodAt: selector)
					addClassesTo: classSpecODict) ].
		].
	]
]

{ #category : 'installing' }
DynamicCuisLibrary >> installLibrary [
	"Install classes. Merge into existing classes if appropriate.
	Note: It is absolutely crucial to have called #canBeInstalled before,
	and have received a positive answer."
	
	classSpecs do: [ :classSpec |
		classSpec equalsExisting ifFalse: [
			classSpec materializeAndInstall ]].
	
	self updateAffectedClassesFormat: true.

	"Convert existing methods to new class shapes if needed.
	(ClassSpecs are allowed to add new instance variables to existing classes).
	Failure during this phase is catastrophic."
	self remapExistingMethodsInstVarAccesses: true.

	"Convert method specs to the final shape classes will have.
	(Maybe different because of instance variables in the actual classes that
	are reordered or missing in ClassSpecs)"
	self remapMethodSpecInstVarAccesses: true.

	"Install methods"
	methodSpecs do: [ :methodSpec |
		methodSpec materializeAndInstall ].
]

{ #category : 'installing' }
DynamicCuisLibrary >> remapExistingMethodsInstVarAccesses: doIt [
	"Convert existing methods to new class shapes if needed.
	(ClassSpecs are allowed to add new instance variables to existing classes)
	For this, displace instance variable accesses in our methodSpecs to match the final shape of classes.
	
	If doIt is false:
		- Validate if remapping is possible and answer a boolean.
		- If some CompiledMethod can not be remapped without first expanding it to use
		    long instance variable bytecodes, then DO the conversion now and install and keep only
		    the converted CompiledMethod. (The new CompiledMethod has identical behavior, though.)
		- Don't raise any errors.
		- Don't modify system behavior in any way
		
	If doIt is true:
		- Assume a previous call with doIt=false has validated that the remap is possible.
		- Assume that previous call has already replaced CompiledMethods with long instance
		    variable bytecodes if needed.
		- Go ahead and update CompiledMethods with the remapping and raise an error if problem arises.
	
	Warning: Failure during actual conversion (doIt = true) results an inconsistent system where
		potentially many CompiledMethods will access the wrong instance variables.
		It is extremely dangerous to continue.
	The only safe thing to do is to EXIT THE IMAGE. It is advisable to log some debugging info before."

	classSpecs do: [ :classSpec | | previousIvarCount delta |
		previousIvarCount := classSpec instVarCountBeforeInstall.
		previousIvarCount notNil ifTrue: [
			delta := classSpec instVarCountAfterInstall - previousIvarCount.
			delta > 0 ifTrue: [
				(Smalltalk at: classSpec name) allSubclassesDo: [ :modifiedShapeClass |
					modifiedShapeClass selectors do: [ :selector | | compiledMethod result |
						compiledMethod := modifiedShapeClass compiledMethodAt: selector.
						result := compiledMethod encoderClass displaceInstVarAccessesIn: compiledMethod  starting: previousIvarCount+1 by: delta doIt: doIt.
						result ifFalse: [
							doIt ifFalse: [
								compiledMethod := compiledMethod encoderClass withLongInstVarAccessBytecodes: compiledMethod.
								compiledMethod isNil ifTrue: [ ^false ].
								modifiedShapeClass addSelectorSilently: selector withMethod: compiledMethod.
								result := compiledMethod encoderClass displaceInstVarAccessesIn: compiledMethod  starting: previousIvarCount+1 by: delta doIt: doIt ]].
						result ifFalse: [ ^false ]]]]]].
	doIt ifTrue: [ Smalltalk voidCogVMState ].
	^true.
]

{ #category : 'installing' }
DynamicCuisLibrary >> remapMethodSpecInstVarAccesses: doIt [
	"Remap all instance variable accesses in our methodSpecs to match the final shape of classes.
	
	If doIt is false:
		- Validate if remapping is possible and answer a boolean.
		- If some methodSpec can not be remapped without first expanding it to use
		    long instance variable bytecodes, then DO the conversion now and keep only
		    the converted methodSpec.
		- Don't raise any errors.
		
	If doIt is true:
		- Assume a previous call with doIt=false has validated that the remap is possible.
		- Assume that previous call has already replaced MethodSpecs with long instance
		    variable bytecodes if needed.
		- Go ahead and update MethodSpecs with the remapping and raise an error if problem arises."

	1 to: methodSpecs size do: [ :i | | methodSpec result |
		methodSpec := methodSpecs at: i.
		methodSpec classSpec methodSpecsInstVarIndexMap ifNotNil: [ :map |
			
			result := methodSpec encoderClass remapInstVarAccessesIn: methodSpec asPer: map doIt: doIt.
			result ifFalse: [
				doIt ifFalse: [
					methodSpec := methodSpec encoderClass withLongInstVarAccessBytecodes: methodSpec.
					methodSpec isNil ifTrue: [ ^false ].
					methodSpecs at: i put: methodSpec.
					result := methodSpec encoderClass remapInstVarAccessesIn: methodSpec asPer: map doIt: doIt ]].
			result ifFalse: [ ^false ]]].
	^true
]

{ #category : 'installing' }
DynamicCuisLibrary >> updateAffectedClassesFormat: doIt [
	"Update the format field of affected classes.
	These are any existing class whose shape is modified (new instance variables are added by the corresponding ClassSpec)
	AND all their subclasses."
	
	"Warning: Failure during conversion results an inconsistent system where the format field of many classes is invalid.
		It is very dangerous to continue.
	The only safe thing to do is to EXIT THE IMAGE. It is advisable to log some debugging info before."

	| format oldInstVarCount newInstVarCount |
	classSpecs do: [ :classSpec | | previousIvarCount delta |
		previousIvarCount := classSpec instVarCountBeforeInstall.
		previousIvarCount notNil ifTrue: [
			delta := classSpec instVarCountAfterInstall - previousIvarCount.
			delta > 0 ifTrue: [
				(Smalltalk at: classSpec name) withAllSubclassesDo: [ :modifiedShapeClass |
					oldInstVarCount := modifiedShapeClass instSize.
					newInstVarCount := oldInstVarCount + delta.
					newInstVarCount > 16rFFFF ifTrue: [ ^false ].
					doIt ifTrue: [
						format := (modifiedShapeClass format bitAnd: 16r1F0000) + newInstVarCount.
						modifiedShapeClass setFormat: format ]]]]].
	^true.
]

{ #category : 'file io' }
DynamicCuisLibrary >> writeOnFile: fileEntry [
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
	fileEntry forceWriteStreamDo: [ :fileStream |
		fileStream binary.
		(ReferenceStream on: fileStream) nextPut: self ].
]
