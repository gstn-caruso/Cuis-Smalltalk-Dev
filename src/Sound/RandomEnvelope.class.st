Class {
	#name : 'RandomEnvelope',
	#superclass : 'Envelope',
	#instVars : [
		'rand',
		'lowLimit',
		'highLimit',
		'delta'
	],
	#category : 'Sound-Synthesis',
	#package : 'Sound',
	#tag : 'Synthesis'
}

{ #category : 'instance creation' }
RandomEnvelope class >> for: aSelector [
	"Answer a random envelope for the given selector."

	^ self new updateSelector: aSelector

]

{ #category : 'accessing' }
RandomEnvelope >> centerPitch: aNumber [
	"If this envelope controls pitch, set its scale to the given number. Otherwise, do nothing."

	updateSelector = #pitch: ifTrue: [self scale: aNumber].

]

{ #category : 'accessing' }
RandomEnvelope >> delta [

	^ delta

]

{ #category : 'accessing' }
RandomEnvelope >> delta: aNumber [

	delta _ aNumber.

]

{ #category : 'envelope compatibility' }
RandomEnvelope >> duration [

	^ 1.0

]

{ #category : 'envelope compatibility' }
RandomEnvelope >> duration: seconds [
	"Do nothing."

]

{ #category : 'accessing' }
RandomEnvelope >> highLimit [

	^ highLimit

]

{ #category : 'accessing' }
RandomEnvelope >> highLimit: aNumber [

	highLimit _ aNumber.

]

{ #category : 'initialization' }
RandomEnvelope >> initialize [

	rand _ Random new.
	lowLimit _ 0.994.
	highLimit _ 1.006.
	delta _ 0.0002.
	currValue _ 1.0.
	scale _ 1.0.

]

{ #category : 'accessing' }
RandomEnvelope >> lowLimit [

	^ lowLimit

]

{ #category : 'accessing' }
RandomEnvelope >> lowLimit: aNumber [

	lowLimit _ aNumber.

]

{ #category : 'envelope compatibility' }
RandomEnvelope >> name [

	^ 'random ', updateSelector

]

{ #category : 'envelopeEditor compatibility' }
RandomEnvelope >> points [

	| env |
	points ifNil: [
		env _ self target envelopes first.
		points _ OrderedCollection new.
		points
			add: 0@(self delta * 5 + 0.5);
			add: (env points at: env loopStartIndex)x@(self highLimit -1 * 5 + 0.5);
			add: (env points at: env loopEndIndex)x@(self highLimit -1 * 5 + 0.5);
			add: (env points last)x@(self lowLimit -1 * 5 + 0.5).
		loopStartIndex _ 2.
		loopEndIndex _ 3.
	].
	^points
]

{ #category : 'envelopeEditor compatibility' }
RandomEnvelope >> setPoints: pointList loopStart: startIndex loopEnd: endIndex [

	self delta: pointList first y - 0.5 / 5.
	self highLimit: (pointList at: startIndex) y - 0.5 / 5 + 1.
	self lowLimit: pointList last y - 0.5 / 5 + 1.
	^super setPoints: pointList loopStart: startIndex loopEnd: endIndex
]

{ #category : 'envelope compatibility' }
RandomEnvelope >> sustainEnd: seconds [
	"Do nothing."

]

{ #category : 'applying' }
RandomEnvelope >> updateTargetAt: mSecs [
	"Send my updateSelector to the given target object with the value of this envelope at the given number of milliseconds from its onset. Answer true if the value changed."

	| r |
	r _ rand next.
	r > 0.5
		ifTrue: [
			currValue _ currValue + delta.
			currValue > highLimit ifTrue: [currValue _ highLimit]]
		ifFalse: [
			currValue _ currValue - delta.
			currValue < lowLimit ifTrue: [currValue _ lowLimit]].
	currValue = lastValue ifTrue: [^ false].
	((target == nil) or: [updateSelector == nil]) ifTrue: [^ false].
	target
		perform: updateSelector
		with: scale * currValue.
	lastValue _ currValue.
	^ true

]

{ #category : 'accessing' }
RandomEnvelope >> volume: aNumber [
	"If this envelope controls volume, set its scale to the given number. Otherwise, do nothing."

	updateSelector = #volume: ifTrue: [self scale: aNumber].

]
