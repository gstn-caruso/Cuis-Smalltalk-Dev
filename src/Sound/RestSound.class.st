Class {
	#name : 'RestSound',
	#superclass : 'AbstractSound',
	#instVars : [
		'initialCount',
		'count'
	],
	#category : 'Sound-Synthesis',
	#package : 'Sound',
	#tag : 'Synthesis'
}

{ #category : 'instance creation' }
RestSound class >> dur: d [
	"Return a rest of the given duration."

	^ self new setDur: d

]

{ #category : 'instance creation' }
RestSound class >> pitch: p dur: d loudness: l [
	"Return a rest of the given duration."
	"Note: This message allows one to silence one or more voices of a multi-voice piece by using RestSound as their instrument."

	^ self new setDur: d

]

{ #category : 'accessing' }
RestSound >> duration [
	"Answer the duration of this sound in seconds."

	^ initialCount asFloat / self samplingRate

]

{ #category : 'accessing' }
RestSound >> duration: seconds [

	super duration: seconds.
	count _ initialCount _ (seconds * self samplingRate) rounded.

]

{ #category : 'sound generation' }
RestSound >> mixSampleCount: n into: aSoundBuffer startingAt: startIndex leftVol: leftVol rightVol: rightVol [
	"Play silence for a given duration."
	"(RestSound dur: 1.0) play"

	count _ count - n.

]

{ #category : 'sound generation' }
RestSound >> reset [

	super reset.
	count _ initialCount.

]

{ #category : 'accessing' }
RestSound >> samples [
	^ SoundBuffer newMonoSampleCount: initialCount
]

{ #category : 'sound generation' }
RestSound >> samplesRemaining [

	^ count

]

{ #category : 'initialization' }
RestSound >> setDur: d [
	"Set rest duration in seconds."

	initialCount _ (d * self samplingRate asFloat) rounded.
	count _ initialCount.
	self reset.

]
