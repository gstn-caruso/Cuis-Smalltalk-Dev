Class {
	#name : 'Indexed16BitForeignObject',
	#superclass : 'AllocatedForeignObject',
	#category : 'Bootstrap-Foreign Objects',
	#package : 'Bootstrap',
	#tag : 'Foreign Objects'
}

{ #category : 'subclass selection' }
Indexed16BitForeignObject class >> canRepresent: anObject [
	"We can work with indexable objects with 16 bit numeric slots."

	^anObject class instSpec = 11
]

{ #category : 'services' }
Indexed16BitForeignObject >> referencedObjectsDo: aBlock [
	"Evaluate aBlock for each object our representedObject points to.
	We don't reference any other objects."
]

{ #category : 'accessing' }
Indexed16BitForeignObject >> slotCount [
	"Answer the number of slots used by our representedObject"

	^representedObject basicSize
]

{ #category : 'accessing' }
Indexed16BitForeignObject >> slotWidth [
	"Answer the size of each slot, in bytes, used by our representedObject.
	Our slots are int16 or uint16."

	^2
]

{ #category : 'accessing' }
Indexed16BitForeignObject >> spurObjectFormatFor: aSpurImageBuilder [
	"Answer the format 5 bit field for Object Header in Spur.
	Use 1 or 2 low bits of size. Answer in #(12 13) for Spur32 and in #(12 13 14 15) for Spur64."

	| slotCount oddBits slotsPerWord |
	slotCount := self slotCount.
	slotsPerWord := aSpurImageBuilder wordSize // 2.
	oddBits := ((slotCount / slotsPerWord) ceiling * slotsPerWord) - slotCount.
	^12 bitOr: oddBits
]

{ #category : 'serialization' }
Indexed16BitForeignObject >> writeSlotsOn: byteStream forSpur: anImageBuilder [

	"Actual data"
	1 to: self slotCount do: [ :i |
		anImageBuilder on: byteStream nextUint16Put: (representedObject basicAt: i) ].
]
