Class {
	#name : 'RepeatingSound',
	#superclass : 'AbstractSound',
	#instVars : [
		'sound',
		'iterationCount',
		'iteration',
		'samplesPerIteration'
	],
	#category : 'Sound-Synthesis',
	#package : 'Sound',
	#tag : 'Synthesis'
}

{ #category : 'instance creation' }
RepeatingSound class >> repeat: aSound count: anInteger [
	"Return a RepeatingSound that will repeat the given sound for the given number of iterations."

	^ self new setSound: aSound iterations: anInteger

]

{ #category : 'instance creation' }
RepeatingSound class >> repeatForever: aSound [
	"Return a RepeatingSound that will repeat the given sound forever."

	^ self new setSound: aSound iterations: #forever

]

{ #category : 'copying' }
RepeatingSound >> copySound [
	"Private! Support for copying. Copy my component sound."

	sound _ sound copy.

]

{ #category : 'sound generation' }
RepeatingSound >> doControl [

	super doControl.
	sound doControl.

]

{ #category : 'accessing' }
RepeatingSound >> iterationCount [

	^ iterationCount

]

{ #category : 'accessing' }
RepeatingSound >> iterationCount: aNumber [

	iterationCount _ aNumber.

]

{ #category : 'sound generation' }
RepeatingSound >> mixSampleCount: n into: aSoundBuffer startingAt: startIndex leftVol: leftVol rightVol: rightVol [
	"Play a collection of sounds in sequence."
	"(RepeatingSound new
		setSound: FMSound majorScale
		iterations: 2) play"

	| i count samplesNeeded |
	iteration <= 0 ifTrue: [^ self].
	i _ startIndex.
	samplesNeeded _ n.
	[samplesNeeded > 0] whileTrue: [
		count _ sound samplesRemaining min: samplesNeeded.
		count = 0 ifTrue: [
			iterationCount == #forever
				ifFalse: [
					iteration _ iteration - 1.
					iteration <= 0 ifTrue: [^ self]].  "done"
			sound reset.
			count _ sound samplesRemaining min: samplesNeeded.
			count = 0 ifTrue: [^ self]].  "zero length sound"
		sound mixSampleCount: count
			into: aSoundBuffer
			startingAt: i
			leftVol: leftVol
			rightVol: rightVol.
		i _ i + count.
		samplesNeeded _ samplesNeeded - count].

]

{ #category : 'copying' }
RepeatingSound >> postCopy [
	"Copy my component sound."

	super postCopy.
	self copySound

]

{ #category : 'sound generation' }
RepeatingSound >> reset [

	super reset.
	sound reset.
	samplesPerIteration _ sound samplesRemaining.
	iterationCount == #forever
		ifTrue: [iteration _ 1]
		ifFalse: [iteration _ iterationCount].

]

{ #category : 'sound generation' }
RepeatingSound >> samplesRemaining [

	iterationCount == #forever ifTrue: [^ 1000000].
	iteration > 0
		ifTrue: [^ sound samplesRemaining + ((iteration - 1) * samplesPerIteration)]
		ifFalse: [^ 0].

]

{ #category : 'initialization' }
RepeatingSound >> setPitch: p dur: d loudness: l [

	self error: 'RepeatingSounds do not support playing notes'.

]

{ #category : 'initialization' }
RepeatingSound >> setSound: aSound iterations: anIntegerOrSymbol [
	"Initialize the receiver to play the given sound the given number of times. If iteration count is the symbol #forever, then repeat indefinitely."
	"(RepeatingSound repeat: AbstractSound scaleTest count: 2) play"
	"(RepeatingSound repeatForever: PluckedSound lowMajorScale) play"

	super initialize.
	sound _ aSound.
	iterationCount _ anIntegerOrSymbol.
	self reset.

]

{ #category : 'accessing' }
RepeatingSound >> sound [

	^ sound

]

{ #category : 'accessing' }
RepeatingSound >> sound: aSound [

	sound _ aSound.

]
