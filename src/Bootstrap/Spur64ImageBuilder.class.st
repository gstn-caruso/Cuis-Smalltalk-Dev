"
My instances can save 64 bit Spur images.
"
Class {
	#name : 'Spur64ImageBuilder',
	#superclass : 'SpurImageBuilder',
	#category : 'Bootstrap-Smalltalk Image Builders',
	#package : 'Bootstrap',
	#tag : 'Smalltalk Image Builders'
}

{ #category : 'foreign objects' }
Spur64ImageBuilder >> addFreeLists [
	"
	x-x-x-x-x-x-
	
	Create a ForeignObject for it.
	Add it to the list of foreign objects we'll use to serialize.
	Don't add it to the foreignObjects dictionary!"

	self createForeignObjectFor: nil hash: 0 class: Spur64FreeListsForeignObject.
]

{ #category : 'foreign objects' }
Spur64ImageBuilder >> foreignObjectClassFor: anObject [
	"Answer the correct ForeignObject subclass to represent anObject.
	"
	anObject isInteger ifTrue: [
		^(anObject between: `(2 raisedTo: 60) negated` and: `(2 raisedTo: 60)-1`)
			ifTrue: [ SmallIntegerForeignObject ]
			ifFalse: [ LargeIntegerForeignObject ]].

	anObject isFloat ifTrue: [
		anObject exponentBits = 0 ifTrue: [
			^anObject isDenormalized
				ifFalse: [ SmallFloat64ForeignObject ] "0.0"
				ifTrue: [ BoxedFloat64ForeignObject ] "Denormals" ].
		^(anObject exponentBits - 1023 between: -127 and: 128)
			ifTrue: [ SmallFloat64ForeignObject ]
			ifFalse: [ BoxedFloat64ForeignObject ]].

	anObject class == Character ifTrue: [
		^ImmediateCharacterForeignObject ].
		
	^super foreignObjectClassFor: anObject
]

{ #category : 'services' }
Spur64ImageBuilder >> foreignOopOfImmediateCharacter: aCharacter [

	| numericValue |
	self assert: aCharacter class == Character. 
	numericValue := aCharacter codePoint.
	^(numericValue << 3) + 2.
]

{ #category : 'services' }
Spur64ImageBuilder >> foreignOopOfSmallFloat64: aFloat [

	"Check that aNumber can actually be encoded as a SmalFloat64 for us."
	| answer |
	self deny: aFloat isDenormalized.
	self assert: (aFloat isZero or: [ aFloat exponentBits - 1023 between: -127 and: 128 ]).
	aFloat partBits: [ :signBit :exponentBits :mantissaBits | | exponentBits8 |
		exponentBits8 := exponentBits ~= 0
			ifTrue: [exponentBits - 1023 + 127]
			ifFalse: [0].
		answer := (mantissaBits << 4)
			+ (signBit << 3)
			+ 4
			+ ((exponentBits8 bitAnd: 16rFF) << 56) ].
	^answer
]

{ #category : 'services' }
Spur64ImageBuilder >> foreignOopOfSmallInteger: aNumber [

	"Check that aNumber can actually be encoded as a SmallInteger for us."
	self assert: aNumber <= `(2 raisedTo: 60)-1`.
	self assert: aNumber >= `(2 raisedTo: 60) negated`.
	^aNumber < 0
		ifTrue: [((16r2000000000000000 + aNumber) << 3) + 1]
		ifFalse: [(aNumber << 3) + 1]
]

{ #category : 'format constants' }
Spur64ImageBuilder >> imageFormat [
	"Answer the number that identifies this image format"
	^68021
]

{ #category : 'format constants' }
Spur64ImageBuilder >> imageHeaderSize [
	"In Bytes"
	^128
]

{ #category : 'format constants' }
Spur64ImageBuilder >> lastBridge	 [
	"Memory segment last bridge (See VMMaker - SpurMemoryManager class comment)
	See VMMaker - #initSegmentBridgeWithBytes:at:
	See VMMaker - #initializeObjectMemory:
	For 64 bit Spur:
		MarkedBit: 1<<55
		PinedBit: 1<< 30
		Format: 9 (64 bit indexable)
		ClassIndex: 3 (#segmentBridgePun)"

	^16r80000049000003
]

{ #category : 'services' }
Spur64ImageBuilder >> on: aStream nexWordPut: aNumber [
	"Write #wordSize bytes. Use 'isBigEndian' endianess."

	self on: aStream nextUint64Put: aNumber.
]

{ #category : 'format constants' }
Spur64ImageBuilder >> wordSize [
	"Also size of an oop.
	In Bytes"
	^8
]
