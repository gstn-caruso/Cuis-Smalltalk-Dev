Class {
	#name : 'VolumeEnvelope',
	#superclass : 'Envelope',
	#instVars : [
		'targetVol',
		'mSecsForChange'
	],
	#category : 'Sound-Synthesis',
	#package : 'Sound',
	#tag : 'Synthesis'
}

{ #category : 'as yet unclassified' }
VolumeEnvelope >> computeSlopeAtMSecs: mSecs [
	"Private! Find the next inflection point of this envelope and compute its target volume and the number of milliseconds until the inflection point is reached."

	| t i |
	((loopEndMSecs notNil) and: [mSecs >= loopEndMSecs]) ifTrue: [  "decay phase"
		t _ (points at: loopEndIndex) x + (mSecs - loopEndMSecs).
		i _ self indexOfPointAfterMSecs: t startingAt: loopEndIndex.
		i ifNil: [  "past end"
			targetVol _ points last y * decayScale.
			mSecsForChange _ 0.
			nextRecomputeTime _ mSecs + 1000000.
			^ self].
		targetVol _ (points at: i) y * decayScale.
		mSecsForChange _ (((points at: i) x - t) min: (endMSecs - mSecs)) max: 4.
		nextRecomputeTime _ mSecs + mSecsForChange.
		^ self].

	mSecs < loopStartMSecs ifTrue: [  "attack phase"
		i _ self indexOfPointAfterMSecs: mSecs startingAt: 1.
		targetVol _ (points at: i) y.
		mSecsForChange _ ((points at: i) x - mSecs) max: 4.
		nextRecomputeTime _ mSecs + mSecsForChange.
		((loopEndMSecs notNil) and: [nextRecomputeTime > loopEndMSecs])
			ifTrue: [nextRecomputeTime _ loopEndMSecs].
		^ self].

	"sustain and loop phase"
	noChangesDuringLoop ifTrue: [
		targetVol _ (points at: loopEndIndex) y.
		mSecsForChange _ 10.
		loopEndMSecs
			ifNil: [nextRecomputeTime _ mSecs + 10]  "unknown end time"
			ifNotNil: [nextRecomputeTime _ loopEndMSecs].
		^ self].

	loopMSecs = 0 ifTrue: [^ (points at: loopEndIndex) y].  "looping on a single point"
	t _ loopStartMSecs + ((mSecs - loopStartMSecs) \\ loopMSecs).
	i _ self indexOfPointAfterMSecs: t startingAt: loopStartIndex.
	targetVol _ (points at: i) y.
	mSecsForChange _ ((points at: i) x - t) max: 4.
	nextRecomputeTime _ (mSecs + mSecsForChange) min: loopEndMSecs.

]

{ #category : 'as yet unclassified' }
VolumeEnvelope >> reset [
	"Reset the state for this envelope."

	super reset.
	target initialVolume: points first y * scale.
	nextRecomputeTime _ 0.

]

{ #category : 'as yet unclassified' }
VolumeEnvelope >> updateSelector [
	"Needed by the envelope editor."

	^ #volume:

]

{ #category : 'as yet unclassified' }
VolumeEnvelope >> updateTargetAt: mSecs [
	"Update the volume envelope slope and limit for my target. Answer false."

	mSecs < nextRecomputeTime ifTrue: [^ false].
	self computeSlopeAtMSecs: mSecs.
	mSecsForChange < 5 ifTrue: [mSecsForChange _ 5].  "don't change instantly to avoid clicks"
	target adjustVolumeTo: targetVol * scale overMSecs: mSecsForChange.
	^ false

]

{ #category : 'as yet unclassified' }
VolumeEnvelope >> volume: aNumber [
	"Set the maximum volume of a volume-controlling envelope."

	scale _ aNumber asFloat.

]
