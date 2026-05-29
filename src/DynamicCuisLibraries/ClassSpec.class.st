"
A ClassSpec describes a class definition. It includes enough detail for a real class to be created from it. But it is not a class:
- It can not create instances. You need a real class for that.
- It is not a global. It is not in the Smalltalk dictionary. It can not name clash.
- There may be several ClassSpecs for different versions of a class in memory.
- It is a regular object. Doesn't include any detail specific to Cuis ObjectMemory or VM (Spur). Doesn't refer to globals.
- It is easy to serialize and deserialize. Nothing special to take care of.

Note: Does not include any MethodSpec.
"
Class {
	#name : 'ClassSpec',
	#superclass : 'CodeElementSpec',
	#instVars : [
		'name',
		'superclass',
		'type',
		'instVarNames',
		'classVarNames',
		'poolDictionaryNames',
		'classInstVarNames',
		'instVarCountBeforeInstall',
		'instVarCountAfterInstall',
		'methodSpecsInstVarIndexMap'
	],
	#category : 'DynamicCuisLibraries-Code Model',
	#package : 'DynamicCuisLibraries',
	#tag : 'Code Model'
}

{ #category : 'instance creation' }
ClassSpec class >> for: aClass addClassesTo: anOrderedDictionaryOfClasses [
	"aClass is a regular class that exists in the system
	anOrderedDictionaryOfClasses will end having all required ClassSpecs, in a proper hierarchy order."
	"
	| sortedClassSpecs |
	sortedClassSpecs := OrderedDictionary new.
	ClassSpec for: SystemWindow addClassesTo: sortedClassSpecs.
	ClassSpec for: Morph addClassesTo: sortedClassSpecs.
	sortedClassSpecs
	"
	| className answer |
	className := aClass name.
	"Remove prefixes such as 'Noclash_', 'Noclash003_', NoclashMySpecialName_', etc "
	(className beginsWith: 'Noclash') ifTrue: [
		className := (className copyFrom: (className indexOf: $_ )+1 to: className size) asSymbol ].
	anOrderedDictionaryOfClasses at: className ifPresent: [ :existing |
		^existing ].
	answer := self basicNew
		name: className
		superclass: (aClass superclass ifNotNil: [ :sc | self for: sc addClassesTo: anOrderedDictionaryOfClasses ])
		type: aClass typeOfClass
		instVarNames: aClass instVarNames
		classVarNames: aClass classVarNames asArray.
	answer classInstVarNames: aClass class instVarNames.
	
	"Or implement!"
	self assert: aClass sharedPools isEmpty.
	
	anOrderedDictionaryOfClasses at: className put: answer.
	^answer
]

{ #category : 'ematerialization' }
ClassSpec >> allInstVarCountAfterInstall [
	"In the actual Class. How it will look after installing us.
	Including inherited from superclasses"
	| inherited |
	inherited := superclass
		ifNotNil: [ superclass allInstVarCountAfterInstall ]
		ifNil: [ 0 ].
	^instVarCountAfterInstall + inherited
]

{ #category : 'ematerialization' }
ClassSpec >> allInstVarCountBeforeInstall [
	"In the actual Class. Before installing us.
	Including inherited from superclasses"
	| inherited |
	inherited := superclass
		ifNotNil: [ superclass allInstVarCountBeforeInstall ]
		ifNil: [ 0 ].
	^instVarCountBeforeInstall + inherited
]

{ #category : 'accessing' }
ClassSpec >> allInstVarCountInSpec [
	"In this Spec object. Unrelated to actual Class.
	Including inherited from superclasses"
	| inherited |
	inherited := superclass
		ifNotNil: [ superclass allInstVarCountInSpec ]
		ifNil: [ 0 ].
	^instVarNames size + inherited
]

{ #category : 'enumerating' }
ClassSpec >> allSuperclassesDo: aBlock  [
	"Evaluate the argument, aBlock, for each of the receiver's superclasses."

	superclass ifNotNil: [
		aBlock value: superclass.
		superclass allSuperclassesDo: aBlock]
]

{ #category : 'testing' }
ClassSpec >> canBeInstalled [
	"Answer false if we can't be installed in the running system.
	Note: it is assumed that installation will happen in hierarchy order, starting from ProtoObject.

	(ClassSpec for: Morph addClassesTo: OrderedDictionary new) doesExist.
	(ClassSpec for: Morph addClassesTo: OrderedDictionary new) equalsExisting.
	(ClassSpec for: Morph addClassesTo: OrderedDictionary new) canBeInstalled.
	"

	| existing existingSuperclass addedInstanceVariables |
	existing := nil.
	self doesExist ifTrue: [
		"We already exist in the system. Our superclass must match existing superclass."
		existing := Smalltalk at: name.
		existingSuperclass := existing superclass.

		"If either we are sublcass of nil or existing is (but not both), it means we can't be installed"
		existingSuperclass isNil = superclass isNil ifFalse: [ ^false ].

		"Not subclass of nil. Superclass must match by name."
		existingSuperclass notNil ifTrue: [
			existingSuperclass name = superclass name ifFalse: [ ^false ]].

		"We don't allow turning a regular class (ivars) into an array, or any other such changes."
		existing typeOfClass = type ifFalse: [ ^false ].

		"We don't adjust existing class methods for differences in class ivars.
		We don't migrate or become: classes.
		So, class ivars must be the same as in existing class."
		(existing class allClassInstVarNames hasEqualElements: classInstVarNames) ifFalse: [ ^false ]].

	"If no new instance variables are added, shape will not change.
	Also, we'd be not requiring migration of any instances."
	addedInstanceVariables := existing
		ifNil: [ instVarNames ]
		ifNotNil: [ instVarNames reject: [ :v | existing definesInstanceVariableNamed: v ]].
	addedInstanceVariables size = 0 ifTrue: [ ^true ].

	"So we are adding instance variables, either to a new or existing class."
	existing ifNotNil: [
		"We're modifying the shape of the existing class, fail if there are (sub)instances"
		existing withAllSubclassesDo: [ :cls |
			cls someInstance ifNotNil: [ ^false ]].
		"Also fail if some subclass already includes any variable we want to add."
		addedInstanceVariables do: [ :v |
			existing allSubclassesDo: [ :cls |
				(cls definesInstanceVariableNamed: v) ifTrue: [ ^false ]]]].

	"If we try to add an instance variable that is already defined in an existing superclass, we can't be installed."
	self allSuperclassesDo: [ :clsSpec |
		Smalltalk at: clsSpec name ifPresent: [ :cls |
			addedInstanceVariables do: [ :v |
				(cls definesInstanceVariableNamed: v) ifTrue: [ ^false ]]]].

	"It looks like there are no problems then."
	^true
]

{ #category : 'accessing' }
ClassSpec >> classInstVarNames [
	^classInstVarNames
]

{ #category : 'private' }
ClassSpec >> classInstVarNames: iVarNameCollection [
	classInstVarNames := iVarNameCollection
]

{ #category : 'accessing' }
ClassSpec >> classVarNames [
	^classVarNames
]

{ #category : 'testing' }
ClassSpec >> doesExist [
	^(Smalltalk at: name ifAbsent: nil) isBehavior
]

{ #category : 'testing' }
ClassSpec >> equalsExisting [
	"
	(ClassSpec for: Morph addClassesTo: OrderedDictionary new) equalsExisting
	"
	"
	| allClasses |
	allClasses := OrderedDictionary new.
	Smalltalk allClassesDo: [ :each | 
		self assert: (ClassSpec for: each addClassesTo: allClasses) equalsExisting ].
	allClasses
	" 
	| existing existingClassPool |
	superclass notNil ifTrue: [
		superclass equalsExisting ifFalse: [ ^false ]].
	self doesExist ifFalse: [ ^false ].
	existing := Smalltalk at: name ifAbsent: [ ^false ].
	existing isBehavior ifFalse: [ ^false ].  "Must be a class!"
	existing isMeta ifTrue: [ ^false ].          "We only represent the instance side"
	existing name = name ifFalse: [ ^false ].
	existing typeOfClass = type ifFalse: [ ^false ].
	(existing instVarNames hasEqualElements: instVarNames) ifFalse: [ ^false ].
	existingClassPool := existing classPool.
	existingClassPool size = classVarNames size ifFalse: [ ^false ].
	classVarNames do: [ :cVarName |
		(existingClassPool includesKey: cVarName) ifFalse: [ ^false ]].
	(existing sharedPools hasEqualElements: poolDictionaryNames) ifFalse: [ ^false ].
	^true
]

{ #category : 'ematerialization' }
ClassSpec >> instVarCountAfterInstall [
	"In the actual Class. How it will look after installing us."

	^instVarCountAfterInstall
]

{ #category : 'ematerialization' }
ClassSpec >> instVarCountBeforeInstall [
	"In the existing actual Class. Before installing us."

	^instVarCountBeforeInstall
]

{ #category : 'accessing' }
ClassSpec >> instVarNames [
	^instVarNames
]

{ #category : 'ematerialization' }
ClassSpec >> materializeAndInstall [
	
	^self doesExist
		ifFalse: [ self materializeNewClass ]
		ifTrue: [ self mergeInto: (Smalltalk at: name) ].
]

{ #category : 'ematerialization' }
ClassSpec >> materializeNewClass [
	"Only for new classes	"

	| newClass metaclass newMeta builder category |
	builder := ClassBuilder new.
	newClass := builder
		newSubclassOf: (superclass ifNotNil: [ Smalltalk at: superclass name ])
		type: type
		instanceVariables: instVarNames
		from: nil.
	newClass setName: name.

	newClass declareClassVariables: classVarNames.

	poolDictionaryNames ifNotNil: [
		poolDictionaryNames do: [ :poolName | | pool |
			pool := Smalltalk at: poolName asSymbol ifAbsentPut: [ Dictionary new ].
			newClass addSharedPool: pool ]].

	classInstVarNames size = 0 ifFalse: [
		metaclass := newClass class.
		newMeta := builder
			newSubclassOf: metaclass superclass 
			type: metaclass typeOfClass
			instanceVariables: classInstVarNames
			from: metaclass.
		builder mutate: metaclass to: newMeta ].

	"... classify ..."
	(Smalltalk includesKey: #SystemOrganization) ifTrue: [
		category := nil.
		Smalltalk organization classify: newClass name under: category ].
	Smalltalk at: newClass name put: newClass.
	"ver si falta algo de
	name:subclassOf:type:instanceVariableNames:classVariableNames:poolDictionaries:category:unsafe:
	"
	^newClass
]

{ #category : 'ematerialization' }
ClassSpec >> mergeInto: existingClass [
	"Ensure our instance variables, class variables, class instance variables and sharedPools are 
	included in existingClass. Add them as needed."

	| existingIvarNames newIvarNames existingClassVarNames newClassVarNames
	existingClassInstanceVarNames newClassInstanceVarNames classInstanceVarNames
	existingSharedPools newSharedPools
	newClass metaclass newMeta builder |

	existingIvarNames := existingClass instVarNames.
	newIvarNames := instVarNames reject: [ :any | existingIvarNames includes: any ].

	existingClassVarNames := existingClass classPool keys.
	newClassVarNames := classVarNames reject: [ :any | existingClassVarNames includes: any ].

	existingSharedPools := existingClass sharedPools asIdentitySet.
	newSharedPools := #(). "Could create it with #streamContents:...."
	poolDictionaryNames do: [ :poolName | | pool |
		pool := Smalltalk at: poolName asSymbol ifAbsentPut: [ Dictionary new ].
		(existingSharedPools includes: pool) ifFalse: [
			newSharedPools := newSharedPools copyWith: pool ]].

	existingClassInstanceVarNames := existingClass class instVarNames.
	newClassInstanceVarNames := classInstVarNames reject: [ :any | existingClassInstanceVarNames includes: any ].

	"If existingClass is already OK, do nothing."
	(newIvarNames isEmpty and: [ newClassVarNames isEmpty and:
			[ newSharedPools isEmpty and: [ newClassInstanceVarNames isEmpty ]]]) ifTrue: [
		^existingClass ].

	builder := ClassBuilder new.
	newClass := builder
		newSubclassOf: existingClass superclass
		type: type
		instanceVariables: existingIvarNames, newIvarNames
		from: nil.
	newClass setName: existingClass name.
	newClass declareClassVariables: existingClassVarNames, newClassVarNames.

	newSharedPools do: [ :pool |
		newClass addSharedPool: pool ].

	classInstanceVarNames := existingClassInstanceVarNames, newClassInstanceVarNames.
	classInstanceVarNames notEmpty ifTrue: [
		metaclass := newClass class.
		newMeta := builder
			newSubclassOf: metaclass superclass 
			type: metaclass typeOfClass
			instanceVariables: classInstanceVarNames
			from: metaclass.
		builder update: metaclass to: newMeta ].

	existingClass selectorsAndMethodsDo: [ :selector :method |
		newClass addSelectorSilently: selector withMethod: method ].
	existingClass methodDict removeAll.
	existingClass class selectorsAndMethodsDo: [ :selector :method |
		newClass class addSelectorSilently: selector withMethod: method ].
	existingClass class methodDict removeAll.
	
	existingClass hasSubclasses ifTrue: [
		newClass instVarNamed: 'subclasses' put: existingClass subclasses ].
	builder update: existingClass to: newClass.
	^newClass
]

{ #category : 'accessing' }
ClassSpec >> methodSpecsInstVarIndexMap [
	"To be used during materialization and installing"
	^methodSpecsInstVarIndexMap
]

{ #category : 'accessing' }
ClassSpec >> name [
	^name
]

{ #category : 'accessing' }
ClassSpec >> name: aSymbol [

	name := aSymbol.
]

{ #category : 'private' }
ClassSpec >> name: aSymbol superclass: aClassSpec type: classTypeSymbol instVarNames: iVarNameCollection classVarNames: cVarNameCollection [

	name := aSymbol.
	superclass := aClassSpec.
	type := classTypeSymbol.
	instVarNames := iVarNameCollection.
	classVarNames := cVarNameCollection.
	poolDictionaryNames := #().
]

{ #category : 'ematerialization' }
ClassSpec >> preInstall [
	"Prepare classInstVarCountBeforeInstall, classInstVarCountAfterInstall, methodSpecsInstVarIndexMap
	These will be needed for remapping instance variable accesses both from existing CompiledMethods
	and our own MethodSpecs.
	Note: we assume we #canBeInstalled.
	Note: This method is assumed to be called in hierarchy order, especially that our superclassSpec
		instVarCountBeforeInstall and instVarCountAfterInstall have already been set."

	| existingInstVarNames specIvarsOffset afterInstallIvarsOffset |

	methodSpecsInstVarIndexMap := nil.
	"For new classes, nothing to do. No existing class, no existing subclasses.
	Therefore, no existing methods in class or subclasses.
	Additionally any MethodSpec is already OK, no ivar remapping needed."
	self doesExist ifFalse: [
		instVarCountBeforeInstall := nil.
		instVarCountAfterInstall := instVarNames size.
		^self ].

	"We already exist in the system."
	existingInstVarNames := (Smalltalk at: name) instVarNames.
	instVarCountBeforeInstall := existingInstVarNames size.
	instVarCountAfterInstall := instVarCountBeforeInstall. "to be incremented below"

	specIvarsOffset := 0.
	afterInstallIvarsOffset := 0.
	superclass notNil ifTrue: [
		specIvarsOffset := superclass allInstVarCountInSpec.
		afterInstallIvarsOffset := superclass allInstVarCountAfterInstall ].

	"Asking for equality is faster than repeated #indexOf:
	No new instance variables in any superclass and
	no changes in instance variables in us, means no remapping needed."
	(specIvarsOffset = afterInstallIvarsOffset and: [
		existingInstVarNames hasEqualElements: instVarNames ]) ifTrue: [
			^self ].

	"Build ivar remapping dictionary. Update classInstVarCountAfterInstall."
	superclass notNil ifTrue: [
		superclass methodSpecsInstVarIndexMap ifNotNil: [ :superclassMap |
			methodSpecsInstVarIndexMap := superclassMap copy ]].
	methodSpecsInstVarIndexMap isNil ifTrue: [
		methodSpecsInstVarIndexMap := Dictionary new ].
	instVarNames withIndexDo: [ :eachVar :j | | specIvarIndex afterInstallIvarsIndex |
		specIvarIndex := specIvarsOffset + j.
		afterInstallIvarsIndex := afterInstallIvarsOffset +
			(existingInstVarNames indexOf: eachVar
				ifAbsent: [ instVarCountAfterInstall := instVarCountAfterInstall + 1 ]).
		afterInstallIvarsIndex = specIvarIndex ifFalse: [
			methodSpecsInstVarIndexMap add: specIvarIndex -> afterInstallIvarsIndex ]].
]

{ #category : 'printing' }
ClassSpec >> printOn: stream [

	stream nextPut: $<; nextPutAll: self name; nextPutAll: ' Spec'; nextPut: $>
]

{ #category : 'accessing' }
ClassSpec >> superclass [
	^superclass
]

{ #category : 'accessing' }
ClassSpec >> totalClassInstVarCountInSpec [
	"Including inherited from superclasses"
	| inherited |
	inherited := superclass
		ifNotNil: [ superclass totalClassInstVarCountInSpec ]
		ifNil: [ 0 ].
	^classInstVarNames size + inherited
]

{ #category : 'accessing' }
ClassSpec >> typeOfClass [
	^type
]

{ #category : 'enumerating' }
ClassSpec >> withAllSuperclassesDo: aBlock  [
	"Evaluate the argument, aBlock, for each of the receiver's superclasses."
	aBlock value: self.
	superclass
		ifNotNil: [superclass withAllSuperclassesDo: aBlock]
]
