Class {
	#name : 'IndexedOopsForeignObject',
	#superclass : 'AllocatedForeignObject',
	#category : 'Bootstrap-Foreign Objects',
	#package : 'Bootstrap',
	#tag : 'Foreign Objects'
}

{ #category : 'subclass selection' }
IndexedOopsForeignObject class >> canRepresent: anObject [
	"We can work with Array and the like."

	^anObject class instSpec = 2
]

{ #category : 'printing' }
IndexedOopsForeignObject >> printRepresentedObjectOn: aStream [

]

{ #category : 'services' }
IndexedOopsForeignObject >> referencedObjectsDo: aBlock [
	"Evaluate aBlock for each object our representedObject points to.
	To be redefined in classes whose representedObject actually holds OOP slots, like Arrays or object with instance variables."

	representedObject do: [ :each |
		aBlock value: each ].
]

{ #category : 'accessing' }
IndexedOopsForeignObject >> slotCount [
	"Answer the number of slots used by our representedObject"

	^representedObject basicSize
]

{ #category : 'accessing' }
IndexedOopsForeignObject >> slotWidth [
	"Answer the size of each slot, in bytes, used by our representedObject.
	Answer nil. Our slots are oops."

	^nil
]

{ #category : 'accessing' }
IndexedOopsForeignObject >> spurObjectFormat [
	"Answer the format 5 bit field for Object Header in Spur."

	^2
]

{ #category : 'serialization' }
IndexedOopsForeignObject >> writeSlotsOn: byteStream forSpur: anImageBuilder [

	representedObject do: [ :each | | fo |
		fo := (each is: #ForeignObject)
			ifTrue: [ each ]
			ifFalse: [ anImageBuilder findForeignObjectFor: each ].
		anImageBuilder on: byteStream nexWordPut: (fo foreignOopFor: anImageBuilder) ].
]
