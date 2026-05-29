Class {
	#name : 'HierarchyBrowser',
	#superclass : 'Browser',
	#instVars : [
		'classList',
		'centralClass'
	],
	#category : 'Tools-Browser',
	#package : 'Tools',
	#tag : 'Browser'
}

{ #category : 'instance creation' }
HierarchyBrowser class >> for: aClass [
	"Open a new HierarchyBrowser on the given class"
	^HierarchyBrowser new initHierarchyForClass: aClass
]

{ #category : 'instance creation' }
HierarchyBrowser class >> for: aClass selector: aSymbol [
	"Open a new HierarchyBrowser on the given class"
	|  newBrowser |
	newBrowser := HierarchyBrowser new initHierarchyForClass: aClass.
	newBrowser setSelector: aSymbol.
	^newBrowser
]

{ #category : 'ui' }
HierarchyBrowser class >> open [
	^ HierarchyBrowserWindow onClass: Object selector: nil
]

{ #category : 'class list' }
HierarchyBrowser >> assureSelectionsShow [
	"This is a workaround for the fact that a hierarchy browser, when launched, often does not show the selected class.
	(jmv) Is this really needed?"

	| saveCatIndex saveMsgIndex |
	saveCatIndex := self messageCategoryListIndex.
	saveMsgIndex := self messageListIndex.
	self classListIndex: self classListIndex.
	self messageCategoryListIndex: saveCatIndex.
	self messageListIndex: saveMsgIndex
]

{ #category : 'class list' }
HierarchyBrowser >> basicClassList [
	^ (classList sorted select: [:name | Smalltalk hasClassNamed: name ])
		collect: [:name | Smalltalk classNamed: name]
]

{ #category : 'initialization' }
HierarchyBrowser >> classListIndex: newIndex [
	"Cause system organization to reflect appropriate category"

	| newClassName classes |
	classes := self classList.
	(classes isInBounds: newIndex) ifTrue: [
		newClassName := (classes at: newIndex) name.
		selectedSystemCategory := systemOrganizer categoryOfElement: newClassName].
	super classListIndex: newIndex.
	self changed: #systemCategorySingleton.
]

{ #category : 'class functions' }
HierarchyBrowser >> classWasDefined: aClass [
	self updateAfterClassChange.
	super classWasDefined: aClass.
]

{ #category : 'initialization' }
HierarchyBrowser >> defaultBrowserTitle [
	^ 'Hierarchy Browser'
]

{ #category : 'initialization' }
HierarchyBrowser >> initAlphabeticListing [
	
	self systemOrganizer: SystemOrganization.
	metaClassIndicated := false.
	listClassesHierarchically := false.
	classList := Smalltalk classNames.
]

{ #category : 'initialization' }
HierarchyBrowser >> initHierarchyForClass: aClassOrMetaClass [
	| nonMetaClass superclasses subclasses |
	centralClass := aClassOrMetaClass.
	nonMetaClass := aClassOrMetaClass theNonMetaClass.
	self systemOrganizer: SystemOrganization.
	metaClassIndicated := aClassOrMetaClass isMeta.
	listClassesHierarchically := true.
	
	superclasses := nonMetaClass allSuperclasses.
	subclasses := nonMetaClass allSubclasses.
	classList := superclasses, {nonMetaClass}, subclasses
		collect: [:aClass | aClass name].
	
	self classListIndex: superclasses size + 1
]

{ #category : 'initialization' }
HierarchyBrowser >> potentialClassNames [
	
	"Answer the names of all the classes that could be viewed in this browser"
	
	^ self basicClassList collect: [:aClass | aClass name ]
]

{ #category : 'menu messages' }
HierarchyBrowser >> removeSystemCategory [
	"If a class category is selected, create a Confirmer so the user can 
	verify that the currently selected class category and all of its classes
 	should be removed from the system. If so, remove it."

	self inform: 'Use a normal Browser, in which you can see 
the entire category you are trying to remove.'
]

{ #category : 'initialization' }
HierarchyBrowser >> systemCategorySingleton [

	| cls |
	cls := self selectedClass.
	^ cls ifNil: [#()]
		ifNotNil: [Array with: cls category]
]

{ #category : 'initialization' }
HierarchyBrowser >> updateAfterClassChange [
	"It is possible that some the classes comprising the hierarchy have changed, so reinitialize the entire browser."

	(centralClass notNil and: [centralClass isObsolete not])
		ifTrue: [self initHierarchyForClass: centralClass]
]
