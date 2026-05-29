Class {
	#name : 'Indexed32BitForeignObject',
	#superclass : 'AllocatedForeignObject',
	#category : 'Bootstrap-Foreign Objects',
	#package : 'Bootstrap',
	#tag : 'Foreign Objects'
}

{ #category : 'subclass selection' }
Indexed32BitForeignObject class >> canRepresent: anObject [
	"We can work with indexable objects with 32 bit numeric slots, like WordArray, Bitmap, Float32Array, etc.
	Also for BoxedFloats, but they are handled in a special way. See #foreignObjectClassFor:"

	anObject isFloat ifTrue: [ ^false ].
	^anObject class instSpec = 10
]

{ #category : 'services' }
Indexed32BitForeignObject >> referencedObjectsDo: aBlock [
	"Evaluate aBlock for each object our representedObject points to.
	We don't reference any other objects."
]

{ #category : 'accessing' }
Indexed32BitForeignObject >> slotCount [
	"Answer the number of slots used by our representedObject"

	^representedObject basicSize
]

{ #category : 'accessing' }
Indexed32BitForeignObject >> slotWidth [
	"Answer the size of each slot, in bytes, used by our representedObject.
	Our slots are int32 or uint32."

	^4
]

{ #category : 'accessing' }
Indexed32BitForeignObject >> spurObjectFormatFor: aSpurImageBuilder [
	"Answer the format 5 bit field for Object Header in Spur.
	Use 0 or 1 low bits of size. Answer is 10 for Spur32 and in #(10 11) for Spur64."

	| slotCount oddBits slotsPerWord |
	slotCount := self slotCount.
	slotsPerWord := aSpurImageBuilder wordSize // 4.
	oddBits := ((slotCount / slotsPerWord) ceiling * slotsPerWord) - slotCount.
	^10 bitOr: oddBits
]

{ #category : 'serialization' }
Indexed32BitForeignObject >> writeSlotsOn: byteStream forSpur: anImageBuilder [

	"Actual data"
	1 to: self slotCount do: [ :i |
		anImageBuilder on: byteStream nextUint32Put: (representedObject basicAt: i) ].
]
