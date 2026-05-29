Class {
	#name : 'Indexed64BitForeignObject',
	#superclass : 'AllocatedForeignObject',
	#category : 'Bootstrap-Foreign Objects',
	#package : 'Bootstrap',
	#tag : 'Foreign Objects'
}

{ #category : 'subclass selection' }
Indexed64BitForeignObject class >> canRepresent: anObject [
	"We can work with indexable objects with 64 bit numeric slots."

	^anObject class instSpec = 9
]

{ #category : 'services' }
Indexed64BitForeignObject >> referencedObjectsDo: aBlock [
	"Evaluate aBlock for each object our representedObject points to.
	We don't reference any other objects."
]

{ #category : 'accessing' }
Indexed64BitForeignObject >> slotCount [
	"Answer the number of slots used by our representedObject"

	^representedObject basicSize
]

{ #category : 'accessing' }
Indexed64BitForeignObject >> slotWidth [
	"Answer the size of each slot, in bytes, used by our representedObject.
	Our slots are int64 or uint64."

	^8
]

{ #category : 'accessing' }
Indexed64BitForeignObject >> spurObjectFormat [
	"Answer the format 5 bit field for Object Header in Spur."

	^9
]

{ #category : 'serialization' }
Indexed64BitForeignObject >> writeSlotsOn: byteStream forSpur: anImageBuilder [

	"Actual data"
	1 to: self slotCount do: [ :i |
		anImageBuilder on: byteStream nextUint64Put: (representedObject basicAt: i) ].
]
