"
Both for LargePositiveInteger and LargeNegativeInteger.
"
Class {
	#name : 'LargeIntegerForeignObject',
	#superclass : 'AllocatedForeignObject',
	#category : 'Bootstrap-Foreign Objects',
	#package : 'Bootstrap',
	#tag : 'Foreign Objects'
}

{ #category : 'services' }
LargeIntegerForeignObject >> referencedObjectsDo: aBlock [
	"Evaluate aBlock for each object our representedObject points to.
	We don't reference any other objects."
]

{ #category : 'accessing' }
LargeIntegerForeignObject >> slotCount [
	"Answer the number of slots used by our representedObject"

	^representedObject basicSize
]

{ #category : 'accessing' }
LargeIntegerForeignObject >> slotWidth [
	"Answer the size of each slot, in bytes, used by our representedObject.
	Our slots are int8 or uint8."

	^1
]

{ #category : 'accessing' }
LargeIntegerForeignObject >> spurObjectFormatFor: aSpurImageBuilder [
	"Answer the format 5 bit field for Object Header in Spur.
	Use 2 or 3 low bits of size. Answer in #(16 17 18 19) for Spur32 and in #(16 17 18 19 20 21 22 23) for Spur64."

	| oddBits slotCount slotsPerWord |
	slotCount := self slotCount.
	slotsPerWord := aSpurImageBuilder wordSize.
	oddBits := ((slotCount / slotsPerWord) ceiling * slotsPerWord) - slotCount.
	^16 bitOr: oddBits
]

{ #category : 'serialization' }
LargeIntegerForeignObject >> writeSlotsOn: byteStream forSpur: anImageBuilder [

	"Actual data"
	1 to: self slotCount do: [ :i |
		byteStream nextPut: (representedObject basicAt: i) ].
]
