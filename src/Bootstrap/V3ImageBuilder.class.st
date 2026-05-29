"
My instances can build new image files, in the V3 (a.k.a. pre-Spur) image format, from a set of Foreign Objects.

The V3 image format is no longer used for Cuis. This class is not currently being developed and could be removed in the future.
"
Class {
	#name : 'V3ImageBuilder',
	#superclass : 'ImageBuilder',
	#category : 'Bootstrap-Smalltalk Image Builders',
	#package : 'Bootstrap',
	#tag : 'Smalltalk Image Builders'
}

{ #category : 'image building' }
V3ImageBuilder >> fillSpecialObjectsArray [
	"Please see implementation for Spur.
	Also see #recreateSpecialObjectsArray.
	See reference implementations (MicroSqueak.pck.st and SystemTracing.pck.st)"

	self error: 'Must implement'
]

{ #category : 'format constants' }
V3ImageBuilder >> imageFormat [
	"Answer the number that identifies this image format"
	^6505
]

{ #category : 'format constants' }
V3ImageBuilder >> imageHeaderSize [
	"In Bytes"
	^64
]

{ #category : 'initialization' }
V3ImageBuilder >> initialize [
	super initialize.
	lastHash := 999.
]

{ #category : 'format constants' }
V3ImageBuilder >> maxIdentityHash [
	"Answer the maximum identityHash value supported by the VM.
	12 bits in V3 images"

	^16rFFF
]

{ #category : 'services' }
V3ImageBuilder >> newObjectHash [
	"Answer a new 16-bit pseudo-random number for use as an identity hash.
	Essentially copied from VMMaker ObjectMemory>>#newObjectHash, answer lower 12 bits"

	lastHash := 13849 + (27181 * lastHash) bitAnd: 65535.
	^ lastHash bitAnd: 16rFFF
]

{ #category : 'services' }
V3ImageBuilder >> on: aStream nexWordPut: aNumber [
	"Write #wordSize bytes. Use 'isBigEndian' endianess."

	self on: aStream nextUint32Put: aNumber.
]

{ #category : 'format constants' }
V3ImageBuilder >> wordSize [
	"Also size of an oop.
	In Bytes"
	^4
]
