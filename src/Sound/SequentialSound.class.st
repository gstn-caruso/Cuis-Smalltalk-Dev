Class {
	#name : 'SequentialSound',
	#superclass : 'AbstractSound',
	#instVars : [
		'sounds',
		'currentIndex'
	],
	#category : 'Sound-Synthesis',
	#package : 'Sound',
	#tag : 'Synthesis'
}

{ #category : 'composition' }
SequentialSound >> , aSound [
	"Return the concatenation of the receiver and the argument sound."

	^ self add: aSound

]

{ #category : 'composition' }
SequentialSound >> add: aSound [

	sounds _ sounds copyWith: aSound.

]

{ #category : 'composition' }
SequentialSound >> compressWith: codecClass [
	^ self copy transformSounds: [:s | s compressWith: codecClass]
]

{ #category : 'composition' }
SequentialSound >> compressWith: codecClass atRate: aSamplingRate [
	^ self copy transformSounds: [:s | s compressWith: codecClass atRate: aSamplingRate]
]

{ #category : 'copying' }
SequentialSound >> copySounds [
	"Private! Support for copying. Copy my component sounds."

	sounds _ sounds collect: [:s | s copy].

]

{ #category : 'sound generation' }
SequentialSound >> doControl [

	super doControl.
	currentIndex > 0
		ifTrue: [(sounds at: currentIndex) doControl].

]

{ #category : 'accessing' }
SequentialSound >> duration [
	"Answer the duration of this sound in seconds."

	"7 dec 2000 - handle compressed sounds. better way??"

	| dur |
	dur _ 0.
	sounds do: [:snd | dur _ dur + snd asSound duration].
	^ dur

]

{ #category : 'initialization' }
SequentialSound >> initialize [

	super initialize.
	sounds _ #().
	currentIndex _ 0.

]

{ #category : 'sound generation' }
SequentialSound >> mixSampleCount: n into: aSoundBuffer startingAt: startIndex leftVol: leftVol rightVol: rightVol [
	"Play a collection of sounds in sequence."
	"PluckedSound chromaticScale play"

	| finalIndex i snd remaining count |
	currentIndex = 0 ifTrue: [^ self].  "already done"
	finalIndex _ (startIndex + n) - 1.
	i _ startIndex.
	[i <= finalIndex] whileTrue: [
		snd _ (sounds at: currentIndex).
		[(remaining _ snd samplesRemaining) <= 0] whileTrue: [
			"find next undone sound"
			currentIndex < sounds size
				ifTrue: [
					currentIndex _ currentIndex + 1.
					snd _ (sounds at: currentIndex)]
				ifFalse: [
					currentIndex _ 0.
					^ self]].  "no more sounds"
		count _ (finalIndex - i) + 1.
		remaining < count ifTrue: [count _ remaining].
		snd mixSampleCount: count into: aSoundBuffer startingAt: i leftVol: leftVol rightVol: rightVol.
		i _ i + count].

]

{ #category : 'copying' }
SequentialSound >> postCopy [
	"Copy my component sounds."

	super postCopy.
	self copySounds

]

{ #category : 'composition' }
SequentialSound >> pruneFinishedSounds [
	"Remove any sounds that have been completely played."

	| newSnds |
	(currentIndex > 1 and: [currentIndex < sounds size]) ifFalse: [^ self].
	newSnds _ sounds copyFrom: currentIndex to: sounds size.
	currentIndex _ 1.
	sounds _ newSnds.

]

{ #category : 'composition' }
SequentialSound >> removeFirstCompleteSoundOrNil [
	"Remove the first sound if it has been completely recorded."

	| firstSound |

	sounds size > 0 ifFalse: [^ nil].
	firstSound _ sounds first.
	sounds _ sounds copyFrom: 2 to: sounds size.
	^firstSound

]

{ #category : 'sound generation' }
SequentialSound >> reset [

	super reset.
	sounds do: [:snd | snd reset].
	sounds size > 0 ifTrue: [currentIndex _ 1].

]

{ #category : 'sound generation' }
SequentialSound >> samplesRemaining [

	currentIndex = 0
		ifTrue: [^ 0]
		ifFalse: [^ 1000000].

]

{ #category : 'accessing' }
SequentialSound >> sounds [

	^ sounds

]

{ #category : 'copying' }
SequentialSound >> transformSounds: tfmBlock [
	"Private! Support for copying. Copy my component sounds."

	sounds _ sounds collect: tfmBlock
]
