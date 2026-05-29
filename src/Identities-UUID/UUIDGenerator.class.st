"
This class generates a pseudo-random UUID
by John M McIntosh johnmci@smalltalkconsulting.com

See http://www.webdav.org/specs/draft-leach-uuids-guids-01.txt
"
Class {
	#name : 'UUIDGenerator',
	#superclass : 'Object',
	#instVars : [
		'timeLow',
		'timeMid',
		'timeHiAndVersion',
		'clockSeqHiAndReserved',
		'clockSeqLow',
		'node',
		'randomCounter',
		'randomGenerator',
		'semaphoreForGenerator'
	],
	#classVars : [
		'Default'
	],
	#category : 'Identities-UUID',
	#package : 'Identities',
	#tag : 'UUID'
}

{ #category : 'instance creation' }
UUIDGenerator class >> default [
	Default ifNil: [self generateDefault].
	^Default
]

{ #category : 'instance creation' }
UUIDGenerator class >> generateDefault [
	Default := self new
]

{ #category : 'class initialization' }
UUIDGenerator class >> initialize [
	Smalltalk addToStartUpList: self after: nil.
]

{ #category : 'class initialization' }
UUIDGenerator class >> startUp [
	Default := nil
]

{ #category : 'instance creation' }
UUIDGenerator >> generateBytes: aPlaceHolder forVersion: aVersion [
	aVersion = 4 ifTrue: [self generateFieldsVersion4]
		ifFalse: [self error: 'Unsupported version'].
	self placeFields: aPlaceHolder.
]

{ #category : 'instance creation' }
UUIDGenerator >> generateFieldsVersion4 [

	timeLow := self generateRandomBitsOfLength: 32.
	timeMid := self generateRandomBitsOfLength: 16.
	timeHiAndVersion := 16r4000 bitOr: (self generateRandomBitsOfLength: 12).
	clockSeqHiAndReserved := 16r80 bitOr: (self generateRandomBitsOfLength: 6).
	clockSeqLow := self generateRandomBitsOfLength: 8.
	node := self generateRandomBitsOfLength: 48.
	
]

{ #category : 'generator' }
UUIDGenerator >> generateOneOrZero [
	^self semaphoreForGenerator
		critical: [| value | 
			value := self randomGenerator next.
			self randomCounter: self randomCounter + 1.
			self randomCounter > 100000
				ifTrue: [self setupRandom].
			value < 0.5
				ifTrue: [0]
				ifFalse: [1]].
]

{ #category : 'generator' }
UUIDGenerator >> generateRandomBitsOfLength: aNumberOfBits [
| target |
	target := 0.
	aNumberOfBits isZero ifTrue: [^target].
	target := self generateOneOrZero.
	(aNumberOfBits - 1)  timesRepeat:
		[target := (target bitShift: 1)  bitOr: self generateOneOrZero].
	^target
]

{ #category : 'instance creation' }
UUIDGenerator >> initialize [
	self setupRandom.
	semaphoreForGenerator := Semaphore forMutualExclusion.
	
]

{ #category : 'random seed' }
UUIDGenerator >> makeSeed [
	"Try various methods of getting good seeds"
	| seed |
	seed := self makeUnixSeed.
	seed ifNotNil: [^seed].

	"not sure if this is reliably random... commented out for now. -dew"
	"seed := self makeSeedFromSound.
	seed ifNotNil: [^seed]."
	
	"default"
	[seed := (Time millisecondClockValue bitAnd: 16r3FFFFFFF) bitXor: self hash.
	seed := seed bitXor: (Time localSecondClock bitAnd: 16r3FFFFFFF).
	seed = 0] whileTrue: ["Try again if ever get a seed = 0"].

	^seed

]

{ #category : 'random seed' }
UUIDGenerator >> makeSeedFromSound [
	"
	UUIDGenerator new makeSeedFromSound
	Load the Sound package and uncomment code to use.
	"
	"
	^[SoundSystem default randomBitsFromSoundInput: 32]
		ifError: [nil].
	"
]

{ #category : 'random seed' }
UUIDGenerator >> makeUnixSeed [
	"
	UUIDGenerator new makeUnixSeed
	"
	
	^[
		'/dev/urandom' asFileEntry readStreamDo: [ :stream |
			stream binary.
			(stream next bitShift: 24)
			 + (stream next bitShift: 16)
			 + (stream next bitShift: 8)
			 + stream next
			"(Integer
				byte1: stream next
				byte2: stream next
				byte3: stream next
				byte4: stream next)" ] ] 
		on: Error
		do: [ nil ]
]

{ #category : 'instance creation' }
UUIDGenerator >> placeFields: aByteArray [

	aByteArray at: 1 put: ((timeLow bitShift: -24) bitAnd: 16rFF).
	aByteArray at: 2 put: ((timeLow bitShift: -16) bitAnd: 16rFF).
	aByteArray at: 3 put: ((timeLow bitShift: -8) bitAnd: 16rFF).
	aByteArray at: 4 put: (timeLow bitAnd: 16rFF).
	aByteArray at: 5 put: ((timeMid bitShift: -8) bitAnd: 16rFF).
	aByteArray at: 6 put: (timeMid bitAnd: 16rFF).
	aByteArray at: 7 put: ((timeHiAndVersion bitShift: -8) bitAnd: 16rFF).
	aByteArray at: 8 put: (timeHiAndVersion bitAnd: 16rFF).
	aByteArray at: 9 put: clockSeqHiAndReserved.
	aByteArray at: 10 put: clockSeqLow.
	0 to: 5 do: [:i |
		aByteArray at: 11 + i put: ((node bitShift: (-8*i)) bitAnd: 16rFF)]

]

{ #category : 'accessors and mutators' }
UUIDGenerator >> randomCounter [
	^randomCounter
]

{ #category : 'accessors and mutators' }
UUIDGenerator >> randomCounter: aNumber [
	randomCounter := aNumber

]

{ #category : 'accessors and mutators' }
UUIDGenerator >> randomGenerator [
	^randomGenerator

]

{ #category : 'accessors and mutators' }
UUIDGenerator >> randomGenerator: aGenerator [
	randomGenerator := aGenerator

]

{ #category : 'accessors and mutators' }
UUIDGenerator >> semaphoreForGenerator [
	^semaphoreForGenerator
]

{ #category : 'accessors and mutators' }
UUIDGenerator >> semaphoreForGenerator: aSema [
	semaphoreForGenerator := aSema

]

{ #category : 'instance creation' }
UUIDGenerator >> setupRandom [
	randomCounter := 0.
	randomGenerator := Random seed: self makeSeed.
]
