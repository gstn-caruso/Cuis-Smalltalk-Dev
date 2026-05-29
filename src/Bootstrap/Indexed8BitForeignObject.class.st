Class {
	#name : 'Indexed8BitForeignObject',
	#superclass : 'AllocatedForeignObject',
	#category : 'Bootstrap-Foreign Objects',
	#package : 'Bootstrap',
	#tag : 'Foreign Objects'
}

{ #category : 'subclass selection' }
Indexed8BitForeignObject class >> canRepresent: anObject [
	"We can work with ByteArray and the like."

	^anObject class instSpec = 16
]

{ #category : 'comparing' }
Indexed8BitForeignObject >> identityHash [
	"MethodDictionaries are created using the ForeignObjects as keys. See #addMethodDictionaryFor:
	When MethodDictionaries are later serialized, keys (so far, instances of this class) will be replaced by
	instances of Symbol, that will use this very identityHash value.
	Answer it as our #identityHash, so MethodDictionaries are created using the correct key hash values."

	^identityHash
]

{ #category : 'printing' }
Indexed8BitForeignObject >> printRepresentedObjectOn: aStream [
	representedObject isString ifFalse: [
		^super printRepresentedObjectOn: aStream ].
	aStream nextPutAll: representedObject printString.
]

{ #category : 'services' }
Indexed8BitForeignObject >> referencedObjectsDo: aBlock [
	"Evaluate aBlock for each object our representedObject points to.
	We don't reference any other objects."
]

{ #category : 'accessing' }
Indexed8BitForeignObject >> slotCount [
	"Answer the number of slots used by our representedObject"

	^representedObject basicSize
]

{ #category : 'accessing' }
Indexed8BitForeignObject >> slotWidth [
	"Answer the size of each slot, in bytes, used by our representedObject.
	Our slots are int8 or uint8."

	^1
]

{ #category : 'accessing' }
Indexed8BitForeignObject >> spurObjectFormatFor: aSpurImageBuilder [
	"Answer the format 5 bit field for Object Header in Spur.
	Use 2 or 3 low bits of size. Answer in #(16 17 18 19) for Spur32 and in #(16 17 18 19 20 21 22 23) for Spur64."

	| oddBits slotCount slotsPerWord |
	slotCount := self slotCount.
	slotsPerWord := aSpurImageBuilder wordSize.
	oddBits := ((slotCount / slotsPerWord) ceiling * slotsPerWord) - slotCount.
	^16 bitOr: oddBits
]

{ #category : 'serialization' }
Indexed8BitForeignObject >> writeSlotsOn: byteStream forSpur: anImageBuilder [

	"Actual data"
	1 to: self slotCount do: [ :i |
		byteStream nextPut: (representedObject basicAt: i) ].
]
