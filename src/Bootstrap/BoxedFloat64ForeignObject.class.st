Class {
	#name : 'BoxedFloat64ForeignObject',
	#superclass : 'AllocatedForeignObject',
	#category : 'Bootstrap-Foreign Objects',
	#package : 'Bootstrap',
	#tag : 'Foreign Objects'
}

{ #category : 'services' }
BoxedFloat64ForeignObject >> referencedObjectsDo: aBlock [
	"Evaluate aBlock for each object our representedObject points to.
	We don't reference any other objects."
]

{ #category : 'accessing' }
BoxedFloat64ForeignObject >> slotCount [
	"Answer the number of slots used by our representedObject"

	^2
]

{ #category : 'accessing' }
BoxedFloat64ForeignObject >> slotWidth [
	"Answer the size of each slot, in bytes, used by our representedObject.
	Our slots are int32 or uint32."

	^4
]

{ #category : 'accessing' }
BoxedFloat64ForeignObject >> spurObjectFormat [
	"Answer the format 5 bit field for Object Header in Spur."

	^10
]

{ #category : 'serialization' }
BoxedFloat64ForeignObject >> writeSlotsOn: byteStream forSpur: anImageBuilder [

	"Actual data
	Note: #basicAt: answers as if the Float was in BigEndian, for historical reasons."
	anImageBuilder on: byteStream nextUint32Put: (representedObject basicAt: 2).
	anImageBuilder on: byteStream nextUint32Put: (representedObject basicAt: 1).
]
