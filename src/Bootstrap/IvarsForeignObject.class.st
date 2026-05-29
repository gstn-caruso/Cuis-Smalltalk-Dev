Class {
	#name : 'IvarsForeignObject',
	#superclass : 'AllocatedForeignObject',
	#category : 'Bootstrap-Foreign Objects',
	#package : 'Bootstrap',
	#tag : 'Foreign Objects'
}

{ #category : 'subclass selection' }
IvarsForeignObject class >> canRepresent: anObject [
	"We can work with regular classes with instance variables, like Point and OrderedCollection.
	We don't work with classes or metaclasses."

	anObject isBehavior ifTrue: [ ^false ].
	(anObject is: #CodeElementSpec) ifTrue: [ ^false ].
	^anObject class instSpec = 1
]

{ #category : 'printing' }
IvarsForeignObject >> printRepresentedObjectOn: aStream [

]

{ #category : 'services' }
IvarsForeignObject >> referencedObjectsDo: aBlock [
	"Evaluate aBlock for each object our representedObject points to.
	To be redefined in classes whose representedObject actually holds OOP slots, like Arrays or object with instance variables."

	1 to: self slotCount do: [ :i |
		aBlock value: (representedObject instVarAt: i) ].
]

{ #category : 'accessing' }
IvarsForeignObject >> slotCount [
	"Answer the number of slots used by our representedObject"

	^representedObject class instSize
]

{ #category : 'accessing' }
IvarsForeignObject >> slotWidth [
	"Answer the size of each slot, in bytes, used by our representedObject.
	Answer nil. Our slots are oops."

	^nil
]

{ #category : 'accessing' }
IvarsForeignObject >> spurObjectFormat [
	"Answer the format 5 bit field for Object Header in Spur."

	^1
]

{ #category : 'serialization' }
IvarsForeignObject >> writeSlotsOn: byteStream forSpur: anImageBuilder [

	1 to: self slotCount do: [ :i | | each fo |
		each := representedObject instVarAt: i.
		fo := (each is: #ForeignObject)
			ifTrue: [ each ]
			ifFalse: [ anImageBuilder findForeignObjectFor: each ].
		anImageBuilder on: byteStream nexWordPut: (fo foreignOopFor: anImageBuilder) ].
]
