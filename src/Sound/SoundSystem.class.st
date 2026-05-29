"
This is the sound system. A sound system offers a small protocol for playing sounds and making beeps and works like a facade towards the rest of Squeak. A sound system is registered in the application registry SoundService and can be accessed by "SoundService default" like for example:

SoundService default playSoundNamed: 'croak'

The idea is that as much sound playing as possible should go through this facade. This way we decouple the sound system from the rest of Squeak and make it pluggable. It also is a perfect spot to check for the Preference class>>soundsEnabled.

Two basic subclasses exist at the time of this writing, the BaseSoundSystem which represents the standard Squeak sound system, and the DummySoundSystem which is a dummy implementation that can be used when there is no sound card available, or when the base sound system isn't in the image, or when you simply don't want to use the available sound card.
"
Class {
	#name : 'SoundSystem',
	#superclass : 'Object',
	#classVars : [
		'Default'
	],
	#category : 'Sound-System-Support',
	#package : 'Sound',
	#tag : 'System-Support'
}

{ #category : 'class initialization' }
SoundSystem class >> default [
	Default ifNil: [ self initialize ].
	^Default
]

{ #category : 'class initialization' }
SoundSystem class >> initialize [
	Default _ self new
]

{ #category : 'as yet unclassified' }
SoundSystem class >> shutDown [
	SoundPlayer shutDown
]

{ #category : 'playing' }
SoundSystem >> beep [
	"There is sound support, so we use the default
	sampled sound for a beep."

	Preferences soundsEnabled ifTrue: [
		SampledSound beep]
]

{ #category : 'playing' }
SoundSystem >> playSampledSound: samples rate: rate [

	Preferences soundsEnabled ifTrue: [
		(SampledSound samples: samples samplingRate: rate) play]
]

{ #category : 'playing' }
SoundSystem >> playSoundNamed: soundName [
	"There is sound support, so we play the given sound."

	Preferences soundsEnabled ifTrue: [
		SampledSound playSoundNamed: soundName asString]
]

{ #category : 'playing' }
SoundSystem >> playSoundNamed: soundName ifAbsentReadFrom: aifFileName [

	Preferences soundsEnabled ifTrue: [
		(SampledSound soundNames includes: soundName) ifFalse: [
			(DirectoryEntry smalltalkImageDirectory // aifFileName) exists ifTrue: [
				SampledSound
					addLibrarySoundNamed: soundName
					fromAIFFfileNamed: aifFileName]].
		(SampledSound soundNames includes: soundName) ifTrue: [
			SampledSound playSoundNamed: soundName]]
]

{ #category : 'playing' }
SoundSystem >> playSoundNamedOrBeep: soundName [
	"There is sound support, so we play the given sound
	instead of beeping."

	Preferences soundsEnabled ifTrue: [
		^self playSoundNamed: soundName]
]

{ #category : 'misc' }
SoundSystem >> randomBitsFromSoundInput: bitCount [
	"Answer a positive integer with the given number of random bits of 'noise' from a sound input source. Typically, one would use a microphone or line input as the sound source, although many sound cards have enough thermal noise that you get random low-order sample bits even with no microphone connected. Only the least signficant bit of the samples is used. Since not all sound cards support 16-bits of sample resolution, we use the lowest bit that changes."
	"(1 to: 10) collect: [:i | SoundSystem new randomBitsFromSoundInput: 512]"

	| recorder buf mid samples bitMask randomBits bit |
	"collect some sound data"
	recorder _ SoundRecorder new clearRecordedSound.
	recorder resumeRecording.
	(Delay forSeconds: 1) wait.
	recorder stopRecording.
	buf _ recorder condensedSamples.

	"grab bitCount samples from the middle"
	mid _ buf monoSampleCount // 2.
	samples _ buf copyFrom: mid to: mid + bitCount - 1.

	"find the least significant bit that varies"
	bitMask _ 1.
	[bitMask < 16r10000 and:
	 [(samples collect: [:s | s bitAnd: bitMask]) asSet size < 2]]
		whileTrue: [bitMask _ bitMask bitShift: 1].
	bitMask = 16r10000 ifTrue: [^ self error: 'sound samples do not vary'].

	"pack the random bits into a positive integer"
	randomBits _ 0.
	1 to: samples size do: [:i |
		bit _ ((samples at: i) bitAnd: bitMask) = 0 ifTrue: [0] ifFalse: [1].
		randomBits _ (randomBits bitShift: 1) + bit].

	^ randomBits	

]

{ #category : 'misc' }
SoundSystem >> sampledSoundChoices [
	^ SampledSound soundNames
]

{ #category : 'misc' }
SoundSystem >> shutDown [
	SoundPlayer shutDown

]

{ #category : 'misc' }
SoundSystem >> soundNameFromUser [
	"Pop up a list of available sound names and answer the one the user chooses, or nil if no choice made"

	^ (SelectionMenu selections: self sampledSoundChoices sorted) startUpWithCaption: 'Sounds'

"
SoundService default soundNameFromUser
"
]

{ #category : 'misc' }
SoundSystem >> soundNamed: soundName [
	^ SampledSound soundNamed: soundName
]
