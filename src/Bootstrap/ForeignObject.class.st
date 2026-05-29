"
Foreign objects are representatives of actual objects we may want to include in a new Smalltalk image. Subclasses represent the different kind of classes that are possible.
"
Class {
	#name : 'ForeignObject',
	#superclass : 'Object',
	#instVars : [
		'representedObject',
		'nameOfClassToInstantiate'
	],
	#category : 'Bootstrap-Foreign Objects',
	#package : 'Bootstrap',
	#tag : 'Foreign Objects'
}

{ #category : 'subclass selection' }
ForeignObject class >> canRepresent: anObject [
	"Subclasses should answer true for objects they can represent."

	^false
]

{ #category : 'testing' }
ForeignObject class >> instancesAreForImmediateObjects [
	"Answer true if our instances represent objects that will not be allocated in a new image,
	because they will be immediate, and fully encoded in their OOP."

	self subclassResponsibility
]

{ #category : 'subclass selection' }
ForeignObject class >> subclassFor: anObject [
	"Find a subclass that can handle it.
	Note: Errors for Characters, Integers and Floats. Senders beware."

	self allSubclassesDo: [ :subclass |
		(subclass canRepresent: anObject) ifTrue: [ ^subclass ]].
	self error: 'None found'
]

{ #category : 'accessing' }
ForeignObject >> foreignIdentityHashFor: anImageBuilder [
	"IdentityHash to be used in the newly created image."

	^self subclassResponsibility
]

{ #category : 'accessing' }
ForeignObject >> foreignOopFor: anImageBuilder [
	"Oop (Object Pointer) to be used in the newly created image."

	^self subclassResponsibility
]

{ #category : 'testing' }
ForeignObject >> is: aSymbol [

	^ aSymbol == #ForeignObject or: [ super is: aSymbol ]
]

{ #category : 'accessing' }
ForeignObject >> nameOfClassToInstantiate: aSymbol [
	nameOfClassToInstantiate := aSymbol
]

{ #category : 'printing' }
ForeignObject >> printOn: aStream [
	aStream
		nextPutAll: self class name withArticle;
		nextPutAll: '. Foreign class named: '; nextPutAll: nameOfClassToInstantiate;
		nextPutAll: '. Object: '.
	self printRepresentedObjectOn: aStream.
]

{ #category : 'printing' }
ForeignObject >> printRepresentedObjectOn: aStream [
	aStream nextPutAll: representedObject shortPrintString
]

{ #category : 'services' }
ForeignObject >> referencedObjectsDo: aBlock [
	"Evaluate aBlock for each object our representedObject points to.
	To be redefined in classes whose representedObject actually holds OOP slots, like Arrays or object with instance variables.
	Also to be redefined as NOP on classes whose representedObjects don't hold pointers at all."

	self halt: 'think what to do!'
]

{ #category : 'accessing' }
ForeignObject >> representedObject [

	^representedObject
]

{ #category : 'accessing' }
ForeignObject >> slotCount [
	"Answer the number of slots used by our representedObject"

	^self subclassResponsibility
]

{ #category : 'accessing' }
ForeignObject >> slotCountFor: anImageBuilder [
	"Answer the number of slots used by our representedObject.
	Redefined where #slotCount is meaningless without anImageBuilder."

	^self slotCount
]

{ #category : 'accessing' }
ForeignObject >> slotWidth [
	"Answer the size of each slot, in bytes, used by our representedObject.
	If our slots are oops, and therefore word size, answer nil."

	^self subclassResponsibility
]

{ #category : 'accessing' }
ForeignObject >> spurClassIndexFor: aSpurImageBuilder [
	"Use argument if appropriate to fetch a ClassForeignObject for us.
	Answer its #foreignIdentityHash.
	May be redefined by subclasses."

	^(aSpurImageBuilder findClassNamed: nameOfClassToInstantiate) foreignIdentityHashFor: aSpurImageBuilder
]

{ #category : 'accessing' }
ForeignObject >> spurObjectFormat [
	"Answer the format 5 bit field for Object Header in Spur."

	^self subclassResponsibility
]

{ #category : 'accessing' }
ForeignObject >> spurObjectFormatFor: aSpurImageBuilder [
	"Answer the format 5 bit field for Object Header in Spur."

	^self spurObjectFormat
]

{ #category : 'serialization' }
ForeignObject >> writeSlotsOn: byteStream forSpur: anImageBuilder [

	self subclassResponsibility.
]
