Class {
	#name : 'ZeroSizeForeignObject',
	#superclass : 'AllocatedForeignObject',
	#category : 'Bootstrap-Foreign Objects',
	#package : 'Bootstrap',
	#tag : 'Foreign Objects'
}

{ #category : 'subclass selection' }
ZeroSizeForeignObject class >> canRepresent: anObject [
	"We can work with nil, false, true and regular objects with no instance variables."

	^anObject class instSpec = 0
]

{ #category : 'accessing' }
ZeroSizeForeignObject >> slotCount [
	"Answer the number of slots used by our representedObject"

	^0
]

{ #category : 'accessing' }
ZeroSizeForeignObject >> slotWidth [
	"Answer the size of each slot, in bytes, used by our representedObject
	It is irrelevant, our #slotCount is zero."

	^nil
]

{ #category : 'accessing' }
ZeroSizeForeignObject >> spurObjectFormat [
	"Answer the format 5 bit field for Object Header in Spur."

	^0
]

{ #category : 'serialization' }
ZeroSizeForeignObject >> writeSlotsOn: byteStream forSpur: anImageBuilder [

]
