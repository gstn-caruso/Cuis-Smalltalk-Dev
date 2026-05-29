"
I respresent a sequence of sound samples, often used to record a single note played by a real instrument. I can be pitch-shifted up or down, and can include a looped portion to allow a sound to be sustained indefinitely.

"
Class {
	#name : 'LoopedSampledSound',
	#superclass : 'AbstractSound',
	#instVars : [
		'initialCount',
		'count',
		'releaseCount',
		'sampleCountForRelease',
		'leftSamples',
		'rightSamples',
		'originalSamplingRate',
		'perceivedPitch',
		'gain',
		'firstSample',
		'lastSample',
		'loopEnd',
		'scaledLoopLength',
		'scaledIndex',
		'scaledIndexIncr'
	],
	#classVars : [
		'FloatLoopIndexScaleFactor',
		'LoopIndexFractionMask',
		'LoopIndexScaleFactor'
	],
	#category : 'Sound-Synthesis',
	#package : 'Sound',
	#tag : 'Synthesis'
}

{ #category : 'instance creation' }
LoopedSampledSound class >> fromAIFFFileNamed: fileName mergeIfStereo: mergeFlag [
	"Initialize this sound from the data in the given AIFF file. If mergeFlag is true and the file is stereo, its left and right channels are mixed together to produce a mono sampled sound."

	| aiffFileReader |
	aiffFileReader _ AIFFFileReader new.
	aiffFileReader readFromFile: fileName
		mergeIfStereo: mergeFlag
		skipDataChunk: false.
	self new fromAIFFFileReader: aiffFileReader mergeIfStereo: mergeFlag
]

{ #category : 'class initialization' }
LoopedSampledSound class >> initialize [
	"LoopedSampledSound initialize"

	LoopIndexScaleFactor _ 512.
	FloatLoopIndexScaleFactor _ LoopIndexScaleFactor asFloat.
	LoopIndexFractionMask _ LoopIndexScaleFactor - 1.

]

{ #category : 'instance creation' }
LoopedSampledSound class >> samples: aSoundBuffer loopEnd: loopEndIndex loopLength: loopSampleCount pitch: perceivedPitchInHz samplingRate: samplingRateInHz [
	"See the comment in the instance method of this name."

	^ self basicNew
		samples: aSoundBuffer
		loopEnd: loopEndIndex
		loopLength: loopSampleCount
		pitch: perceivedPitchInHz
		samplingRate: samplingRateInHz

]

{ #category : 'instance creation' }
LoopedSampledSound class >> unloopedSamples: aSoundBuffer pitch: perceivedPitchInHz samplingRate: samplingRateInHz [
	"See the comment in the instance method of this name."

	^ self basicNew
		unloopedSamples: aSoundBuffer
		pitch: perceivedPitchInHz
		samplingRate: samplingRateInHz

]

{ #category : 'initialization' }
LoopedSampledSound >> addReleaseEnvelope [
	"Add a simple release envelope to this sound."

	| p env |
	p _ OrderedCollection new.
	p add: 0@1.0; add: 10@1.0; add: 100@1.0; add: 120@0.0.
	env _ (VolumeEnvelope points: p loopStart: 2 loopEnd: 3) target: self.
	envelopes size > 0 ifTrue: [  "remove any existing volume envelopes"
		envelopes copy do: [:e |
			(e isKindOf: VolumeEnvelope) ifTrue: [self removeEnvelope: e]]].
	self addEnvelope: env.

]

{ #category : 'accessing' }
LoopedSampledSound >> beUnlooped [

	scaledLoopLength _ 0.

]

{ #category : 'disk i/o' }
LoopedSampledSound >> comeFullyUpOnReload: smartRefStream [
	"Convert my sample buffers from ByteArrays into SampleBuffers after raw loading from a DataStream. Answer myself."

	leftSamples == rightSamples
		ifTrue: [
			leftSamples _ SoundBuffer fromByteArray: self leftSamples.
			rightSamples _ leftSamples]
		ifFalse: [
			leftSamples _ SoundBuffer fromByteArray: self leftSamples.
			rightSamples _ SoundBuffer fromByteArray: self rightSamples].


]

{ #category : 'initialization' }
LoopedSampledSound >> computeSampleCountForRelease [
	"Calculate the number of samples before the end of the note after which looping back will be be disabled. The units of this value, sampleCountForRelease, are samples at the original sampling rate. When playing a specific note, this value is converted to releaseCount, which is number of samples to be computed at the current pitch and sampling rate."
	"Details: For short loops, set the sampleCountForRelease to the loop length plus the number of samples between loopEnd and lastSample. Otherwise, set it to 1/10th of a second worth of samples plus the number of samples between loopEnd and lastSample. In this case, the trailing samples will be played only if the last loop-back occurs within 1/10th of a second of the total note duration, and the note may be shortened by up to 1/10th second. For long loops, this is the best we can do."

	(scaledLoopLength > 0 and: [lastSample > loopEnd])
		ifTrue: [
			sampleCountForRelease _ (lastSample - loopEnd) +
				(self loopLength min: (originalSamplingRate / 10.0)) asInteger]
		ifFalse: [sampleCountForRelease _ 0].

	releaseCount _ sampleCountForRelease.

]

{ #category : 'accessing' }
LoopedSampledSound >> duration [
	"Answer the duration of this sound in seconds."

	^ initialCount asFloat / self samplingRate asFloat

]

{ #category : 'accessing' }
LoopedSampledSound >> duration: seconds [

	super duration: seconds.
	count _ initialCount _ (seconds * self samplingRate) rounded.

]

{ #category : 'other' }
LoopedSampledSound >> findStartPointAfter: index [
	"Answer the index of the last zero crossing sample before the given index."

	| i |
	i _ index min: lastSample.

	"scan backwards to the last zero-crossing"
	(leftSamples at: i) > 0
		ifTrue: [
			[i > 1 and: [(leftSamples at: i) > 0]] whileTrue: [i _ i - 1]]
		ifFalse: [
			[i > 1 and: [(leftSamples at: i) < 0]] whileTrue: [i _ i - 1]].
	^ i

]

{ #category : 'other' }
LoopedSampledSound >> findStartPointForThreshold: threshold [
	"Answer the index of the last zero crossing sample before the first sample whose absolute value (in either the right or left channel) exceeds the given threshold."

	| i |
	i _ self indexOfFirstPointOverThreshold: threshold.
	i >= lastSample ifTrue: [^ self error: 'no sample exceeds the given threshold'].

	"scan backwards to the last zero-crossing"
	(leftSamples at: i) > 0
		ifTrue: [
			[i > 1 and: [(leftSamples at: i) > 0]] whileTrue: [i _ i - 1]]
		ifFalse: [
			[i > 1 and: [(leftSamples at: i) < 0]] whileTrue: [i _ i - 1]].
	^ i

]

{ #category : 'accessing' }
LoopedSampledSound >> firstSample [

	^ firstSample

]

{ #category : 'accessing' }
LoopedSampledSound >> firstSample: aNumber [

	firstSample _ (aNumber asInteger max: 1) min: lastSample.

]

{ #category : 'initialization' }
LoopedSampledSound >> fromAIFFFileNamed: fileName mergeIfStereo: mergeFlag [
	"Initialize this sound from the data in the given AIFF file. If mergeFlag is true and the file is stereo, its left and right channels are mixed together to produce a mono sampled sound."

	| aiffFileReader |
	aiffFileReader _ AIFFFileReader new.
	aiffFileReader readFromFile: fileName
		mergeIfStereo: mergeFlag
		skipDataChunk: false.
	aiffFileReader isLooped
		ifTrue: [
			self samples: aiffFileReader leftSamples
				loopEnd: aiffFileReader loopEnd
				loopLength: aiffFileReader loopLength
				pitch: aiffFileReader pitch
				samplingRate: aiffFileReader samplingRate]
		ifFalse: [
			self unloopedSamples: aiffFileReader leftSamples
				pitch: aiffFileReader pitch
				samplingRate: aiffFileReader samplingRate].

	"the following must be done second, since the initialization above sets
	 leftSamples and rightSamples to the same sample data"
	aiffFileReader isStereo
		ifTrue: [rightSamples _ aiffFileReader rightSamples].

	initialCount _ (leftSamples size * self samplingRate) // originalSamplingRate.
	self loudness: 1.0.

	self addReleaseEnvelope.

]

{ #category : 'initialization' }
LoopedSampledSound >> fromAIFFFileReader: aiffFileReader mergeIfStereo: mergeFlag [
	"Initialize this sound from the data in the given AIFF file. If mergeFlag is true and the file is stereo, its left and right channels are mixed together to produce a mono sampled sound."

	aiffFileReader isLooped
		ifTrue: [
			self samples: aiffFileReader leftSamples
				loopEnd: aiffFileReader loopEnd
				loopLength: aiffFileReader loopLength
				pitch: aiffFileReader pitch
				samplingRate: aiffFileReader samplingRate]
		ifFalse: [
			self unloopedSamples: aiffFileReader leftSamples
				pitch: aiffFileReader pitch
				samplingRate: aiffFileReader samplingRate].

	"the following must be done second, since the initialization above sets
	 leftSamples and rightSamples to the same sample data"
	aiffFileReader isStereo
		ifTrue: [rightSamples _ aiffFileReader rightSamples].

	initialCount _ (leftSamples size * self samplingRate) // originalSamplingRate.
	self loudness: 1.0.

	self addReleaseEnvelope.

]

{ #category : 'accessing' }
LoopedSampledSound >> gain [

	^ gain

]

{ #category : 'accessing' }
LoopedSampledSound >> gain: aNumber [

	gain _ aNumber asFloat.

]

{ #category : 'other' }
LoopedSampledSound >> indexOfFirstPointOverThreshold: threshold [
	"Answer the index of the first sample whose absolute value exceeds the given threshold."

	| s |
	leftSamples == rightSamples
		ifTrue: [
			1 to: lastSample do: [:i |
				s _ leftSamples at: i.
				s < 0 ifTrue: [s _ 0 - s].
				s > threshold ifTrue: [^ i]]]
		ifFalse: [
			1 to: lastSample do: [:i |
				s _ leftSamples at: i.
				s < 0 ifTrue: [s _ 0 - s].
				s > threshold ifTrue: [^ i].
				s _ rightSamples at: i.
				s < 0 ifTrue: [s _ 0 - s].
				s > threshold ifTrue: [^ i]]].
	^ lastSample + 1

]

{ #category : 'initialization' }
LoopedSampledSound >> initialize [
	"This default initialization creates a loop consisting of a single cycle of a sine wave."
	"(LoopedSampledSound pitch: 440.0 dur: 1.0 loudness: 0.4) play"

	| samples |
	super initialize.
	samples _ FMSound sineTable.
	self samples: samples
		loopEnd: samples size
		loopLength: samples size
		pitch: 1.0
		samplingRate: samples size.
	self addReleaseEnvelope.
	self setPitch: 440.0 dur: 1.0 loudness: 0.5.

]

{ #category : 'accessing' }
LoopedSampledSound >> isLooped [

	^ scaledLoopLength ~= 0.  "zero loop length means unlooped"

]

{ #category : 'accessing' }
LoopedSampledSound >> isStereo [

	^ leftSamples ~~ rightSamples

]

{ #category : 'accessing' }
LoopedSampledSound >> leftSamples [

	^ leftSamples

]

{ #category : 'accessing' }
LoopedSampledSound >> leftSamples: aSampleBuffer [

	leftSamples _ aSampleBuffer.

]

{ #category : 'accessing' }
LoopedSampledSound >> loopEnd [

	^ loopEnd

]

{ #category : 'accessing' }
LoopedSampledSound >> loopLength [

	^ scaledLoopLength / FloatLoopIndexScaleFactor

]

{ #category : 'sound generation' }
LoopedSampledSound >> mixSampleCount: n into: aSoundBuffer startingAt: startIndex leftVol: leftVol rightVol: rightVol [
	"Play samples from a wave table by stepping a fixed amount through the table on every sample. The table index and increment are scaled to allow fractional increments for greater pitch accuracy.  If a loop length is specified, then the index is looped back when the loopEnd index is reached until count drops below releaseCount. This allows a short sampled sound to be sustained indefinitely."
	"(LoopedSampledSound pitch: 440.0 dur: 5.0 loudness: 0.5) play"

	| lastIndex sampleIndex i s compositeLeftVol compositeRightVol nextSampleIndex m isInStereo rightVal leftVal |
	<primitive:'primitiveMixLoopedSampledSound' module:'SoundGenerationPlugin'>
	self var: #aSoundBuffer declareC: 'short int *aSoundBuffer'.
	self var: #leftSamples declareC: 'short int *leftSamples'.
	self var: #rightSamples declareC: 'short int *rightSamples'.

	isInStereo _ leftSamples ~~ rightSamples.
	compositeLeftVol _ (leftVol * scaledVol) // ScaleFactor.
	compositeRightVol _  (rightVol * scaledVol) // ScaleFactor.

	i _ (2 * startIndex) - 1.
	lastIndex _ (startIndex + n) - 1.
	startIndex to: lastIndex do: [:sliceIndex |
		sampleIndex _ (scaledIndex _ scaledIndex + scaledIndexIncr) // LoopIndexScaleFactor.
		((sampleIndex > loopEnd) and: [count > releaseCount]) ifTrue: [
			"loop back if not within releaseCount of the note end"
			"note: unlooped sounds will have loopEnd = lastSample"
			sampleIndex _ (scaledIndex _ scaledIndex - scaledLoopLength) // LoopIndexScaleFactor].
		(nextSampleIndex _ sampleIndex + 1) > lastSample ifTrue: [
			sampleIndex > lastSample ifTrue: [count _ 0. ^ nil].  "done!"
			scaledLoopLength = 0
				ifTrue: [nextSampleIndex _ sampleIndex]
				ifFalse: [nextSampleIndex _ ((scaledIndex - scaledLoopLength) // LoopIndexScaleFactor) + 1]].

		m _ scaledIndex bitAnd: LoopIndexFractionMask.
		rightVal _ leftVal _
			(((leftSamples at: sampleIndex) * (LoopIndexScaleFactor - m)) +
			 ((leftSamples at: nextSampleIndex) * m)) // LoopIndexScaleFactor.
		isInStereo ifTrue: [
			rightVal _
				(((rightSamples at: sampleIndex) * (LoopIndexScaleFactor - m)) +
				 ((rightSamples at: nextSampleIndex) * m)) // LoopIndexScaleFactor].

		leftVol > 0 ifTrue: [
			s _ (aSoundBuffer at: i) + ((compositeLeftVol * leftVal) // ScaleFactor).
			s >  32767 ifTrue: [s _  32767].  "clipping!"
			s < -32767 ifTrue: [s _ -32767].  "clipping!"
			aSoundBuffer at: i put: s].
		i _ i + 1.
		rightVol > 0 ifTrue: [
			s _ (aSoundBuffer at: i) + ((compositeRightVol * rightVal) // ScaleFactor).
			s >  32767 ifTrue: [s _  32767].  "clipping!"
			s < -32767 ifTrue: [s _ -32767].  "clipping!"
			aSoundBuffer at: i put: s].
		i _ i + 1.

		scaledVolIncr ~= 0 ifTrue: [  "update volume envelope if it is changing"
			scaledVol _ scaledVol + scaledVolIncr.
			((scaledVolIncr > 0 and: [scaledVol >= scaledVolLimit]) or:
			 [scaledVolIncr < 0 and: [scaledVol <= scaledVolLimit]])
				ifTrue: [  "reached the limit; stop incrementing"
					scaledVol _ scaledVolLimit.
					scaledVolIncr _ 0].
			compositeLeftVol _ (leftVol * scaledVol) // ScaleFactor.
			compositeRightVol _  (rightVol * scaledVol) // ScaleFactor]].

	count _ count - n.

]

{ #category : 'disk i/o' }
LoopedSampledSound >> objectForDataStream: refStrm [
    "Answer an object to store on a data stream, a copy of myself whose SampleBuffers have been converted into ByteArrays."

	refStrm replace: leftSamples with: leftSamples asByteArray.
	refStrm replace: rightSamples with: rightSamples asByteArray.
	"substitution will be made in DataStream nextPut:"
	^ self

]

{ #category : 'accessing' }
LoopedSampledSound >> originalSamplingRate [

	^ originalSamplingRate

]

{ #category : 'accessing' }
LoopedSampledSound >> perceivedPitch [

	^ perceivedPitch

]

{ #category : 'accessing' }
LoopedSampledSound >> pitch [

	^ (scaledIndexIncr asFloat * perceivedPitch * self samplingRate asFloat) /
	  (originalSamplingRate * FloatLoopIndexScaleFactor)

]

{ #category : 'accessing' }
LoopedSampledSound >> pitch: p [

	scaledIndexIncr _
		((p asFloat * originalSamplingRate * FloatLoopIndexScaleFactor) /
		 (perceivedPitch * self samplingRate asFloat)) asInteger.

	sampleCountForRelease > 0
		ifTrue: [releaseCount _ (sampleCountForRelease * LoopIndexScaleFactor) // scaledIndexIncr]
		ifFalse: [releaseCount _ 0].

]

{ #category : 'sound generation' }
LoopedSampledSound >> reset [

	super reset.
	count _ initialCount.
	scaledIndex _ firstSample * LoopIndexScaleFactor.

]

{ #category : 'accessing' }
LoopedSampledSound >> rightSamples [

	^ rightSamples

]

{ #category : 'accessing' }
LoopedSampledSound >> rightSamples: aSampleBuffer [

	rightSamples _ aSampleBuffer.

]

{ #category : 'accessing' }
LoopedSampledSound >> samples [
	"For compatability with SampledSound. Just return my left channel (which is the only channel if I am mono)."

	^ leftSamples

]

{ #category : 'initialization' }
LoopedSampledSound >> samples: aSoundBuffer loopEnd: loopEndIndex loopLength: loopSampleCount pitch: perceivedPitchInHz samplingRate: samplingRateInHz [
	"Make this sound use the given samples array with a loop of the given length starting at the given index. The loop length may have a fractional part; this is necessary to achieve pitch accuracy for short loops."

	| loopStartIndex |
	super initialize.
	loopStartIndex _ (loopEndIndex - loopSampleCount) truncated + 1.
	((1 <= loopStartIndex) and:
	 [loopStartIndex < loopEndIndex and:
	 [loopEndIndex <= aSoundBuffer size]])
		ifFalse: [self error: 'bad loop parameters'].

	leftSamples _ rightSamples _ aSoundBuffer.
	originalSamplingRate _ samplingRateInHz asFloat.
	perceivedPitch _ perceivedPitchInHz asFloat.
	gain _ 1.0.
	firstSample _ 1.
	lastSample _ leftSamples size.
	lastSample >= (SmallInteger maxVal // LoopIndexScaleFactor) ifTrue: [
		self error: 'cannot handle more than ',
			(SmallInteger maxVal // LoopIndexScaleFactor) printString, ' samples'].
	loopEnd _ loopEndIndex.
	scaledLoopLength _ (loopSampleCount * LoopIndexScaleFactor) asInteger.
	scaledIndexIncr _ (samplingRateInHz * LoopIndexScaleFactor) // self samplingRate.
	self computeSampleCountForRelease.

]

{ #category : 'sound generation' }
LoopedSampledSound >> samplesRemaining [
	"Answer the number of samples remaining until the end of this sound."

	^ count

]

{ #category : 'initialization' }
LoopedSampledSound >> setPitch: pitchNameOrNumber dur: d loudness: vol [
	"(LoopedSampledSound pitch: 440.0 dur: 2.5 loudness: 0.4) play"

	super setPitch: pitchNameOrNumber dur: d loudness: vol.
	self pitch: (self nameOrNumberToPitch: pitchNameOrNumber).
	self reset.

]

{ #category : 'sound generation' }
LoopedSampledSound >> stopAfterMSecs: mSecs [
	"Terminate this sound this note after the given number of milliseconds."

	count _ (mSecs * self samplingRate) // 1000.

]

{ #category : 'file i/o' }
LoopedSampledSound >> storeSampleCount: samplesToStore bigEndian: bigEndianFlag on: aBinaryStream [
	"Store my samples on the given stream at the current SoundPlayer sampling rate. If bigFlag is true, then each 16-bit sample is stored most-significant byte first (AIFF files), otherwise it is stored least-significant byte first (WAV files)."

	(self isStereo or: [self samplingRate ~= originalSamplingRate]) ifTrue: [
		^ super storeSampleCount: samplesToStore bigEndian: bigEndianFlag on: aBinaryStream].

	"optimization: if I'm not stereo and sampling rates match, just store my buffer"
	(aBinaryStream isFileStream)
		ifTrue: [  "optimization for files: write sound buffer directly to file"
			aBinaryStream next: (leftSamples size // 2) putAll: leftSamples startingAt: 1]  "size in words"
		ifFalse: [  "for non-file streams:"
			1 to: leftSamples monoSampleCount do: [:i | aBinaryStream nextInt16Put: (leftSamples at: i) bigEndian: bigEndianFlag ]]
]

{ #category : 'initialization' }
LoopedSampledSound >> unloopedSamples: aSoundBuffer pitch: perceivedPitchInHz samplingRate: samplingRateInHz [
	"Make this sound play the given samples unlooped. The samples have the given perceived pitch when played at the given sampling rate. By convention, unpitched sounds such as percussion sounds should specify a pitch of nil or 100 Hz."

	super initialize.
	leftSamples _ rightSamples _ aSoundBuffer.
	originalSamplingRate _ samplingRateInHz asFloat.
	perceivedPitchInHz
		ifNil: [perceivedPitch _ 100.0]
		ifNotNil: [perceivedPitch _ perceivedPitchInHz asFloat].
	gain _ 1.0.
	firstSample _ 1.
	lastSample _ leftSamples size.
	lastSample >= (SmallInteger maxVal // LoopIndexScaleFactor) ifTrue: [
		self error: 'cannot handle more than ',
			(SmallInteger maxVal // LoopIndexScaleFactor) printString, ' samples'].
	loopEnd _ leftSamples size.
	scaledLoopLength _ 0.  "zero length means unlooped"
	scaledIndexIncr _ (samplingRateInHz * LoopIndexScaleFactor) // self samplingRate.
	self computeSampleCountForRelease.

]
