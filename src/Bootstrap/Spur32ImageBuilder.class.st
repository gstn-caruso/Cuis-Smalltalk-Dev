"
My instances can save 32 bit Spur images.
"
Class {
	#name : 'Spur32ImageBuilder',
	#superclass : 'SpurImageBuilder',
	#category : 'Bootstrap-Smalltalk Image Builders',
	#package : 'Bootstrap',
	#tag : 'Smalltalk Image Builders'
}

{ #category : 'foreign objects' }
Spur32ImageBuilder >> addFreeLists [
	"
	x-x-x-x-x-x-
	
	Create a ForeignObject for it.
	Add it to the list of foreign objects we'll use to serialize.
	Don't add it to the foreignObjects dictionary!"

	self createForeignObjectFor: nil hash: 0 class: Spur32FreeListsForeignObject.
]

{ #category : 'foreign objects' }
Spur32ImageBuilder >> foreignObjectClassFor: anObject [
	"Answer the correct ForeignObject subclass to represent anObject.
	"
	anObject isInteger ifTrue: [
		^(anObject between: `(2 raisedTo: 30) negated` and: `(2 raisedTo: 30)-1`)
			ifTrue: [ SmallIntegerForeignObject ]
			ifFalse: [ LargeIntegerForeignObject ]].

	anObject isFloat ifTrue: [
		^BoxedFloat64ForeignObject ].

	anObject class == Character ifTrue: [
		^ImmediateCharacterForeignObject ].
		
	^super foreignObjectClassFor: anObject
]

{ #category : 'services' }
Spur32ImageBuilder >> foreignOopOfImmediateCharacter: aCharacter [

	| numericValue |
	self assert: aCharacter class == Character. 
	numericValue := aCharacter codePoint.
	^(numericValue << 2) + 2.
]

{ #category : 'services' }
Spur32ImageBuilder >> foreignOopOfSmallInteger: aNumber [

	"Check that aNumber can actually be encoded as a SmallInteger for us."
	self assert: aNumber <= `(2 raisedTo: 30)-1`.
	self assert: aNumber >= `(2 raisedTo: 30) negated`.
	^aNumber < 0
		ifTrue: [((16r80000000 + aNumber) << 1) + 1]
		ifFalse: [(aNumber << 1) + 1]
]

{ #category : 'format constants' }
Spur32ImageBuilder >> imageFormat [
	"Answer the number that identifies this image format"
	^6521
]

{ #category : 'format constants' }
Spur32ImageBuilder >> imageHeaderSize [
	"In Bytes"
	^64
]

{ #category : 'format constants' }
Spur32ImageBuilder >> lastBridge	 [
	"Memory segment last bridge (See VMMaker - SpurMemoryManager class comment)
	See VMMaker - #initSegmentBridgeWithBytes:at:
	See VMMaker - #initializeObjectMemory:
	For 32 bit Spur:
		MarkedBit: 1<<55
		PinedBit: 1<< 30
		Format: A (32 bit indexable)
		ClassIndex: 3 (#segmentBridgePun)"

	^16r8000004A000003
]

{ #category : 'services' }
Spur32ImageBuilder >> on: aStream nexWordPut: aNumber [
	"Write #wordSize bytes. Use 'isBigEndian' endianess."

	self on: aStream nextUint32Put: aNumber.
]

{ #category : 'format constants' }
Spur32ImageBuilder >> wordSize [
	"Also size of an oop.
	In Bytes"
	^4
]
