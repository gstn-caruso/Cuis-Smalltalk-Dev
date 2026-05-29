Class {
	#name : 'SoundRecorder',
	#superclass : 'Object',
	#instVars : [
		'stereo',
		'samplingRate',
		'recordLevel',
		'recordedBuffers',
		'recordedSound',
		'recordProcess',
		'bufferAvailableSema',
		'paused',
		'meteringBuffer',
		'meterLevel',
		'soundPlaying',
		'currentBuffer',
		'nextIndex',
		'codec',
		'desiredSampleRate'
	],
	#classVars : [
		'CanRecordWhilePlaying',
		'RecorderActive'
	],
	#category : 'Sound-Synthesis',
	#package : 'Sound',
	#tag : 'Synthesis'
}

{ #category : 'accessing' }
SoundRecorder class >> anyActive [
	"Return true if any sound recorder is actively recording"
	^RecorderActive == true
]

{ #category : 'accessing' }
SoundRecorder class >> canRecordWhilePlaying [
	"Return true if this platform supports simultaneous sound recording and playback."

	^CanRecordWhilePlaying
]

{ #category : 'class initialization' }
SoundRecorder class >> initialize [
	"
	SoundRecorder initialize
	"
	"Details: Some computers cannot record and playback sound at the same time. If CanRecordWhilePlaying is false, then the SoundRecorder alternates between recording and playing. If it is true, sounds can be playing during recording."

	CanRecordWhilePlaying _ true. "Until proven otherwise!"
	CanRecordWhilePlaying _ false. "Or `SoundSystem new randomBitsFromSoundInput: 512` fails..."

]

{ #category : 'private' }
SoundRecorder >> allocateBuffer [
	"Allocate a new buffer and reset nextIndex."

	| bufferTime |
	bufferTime _ stereo  "Buffer time = 1/2 second"
		ifTrue: [self samplingRate asInteger]
		ifFalse: [self samplingRate asInteger // 2].
	currentBuffer _ SoundBuffer newMonoSampleCount:
		"Multiple of samplesPerFrame that is approx. bufferTime long"
		(bufferTime truncateTo: self samplesPerFrame).
	nextIndex _ 1.

]

{ #category : 'recording controls' }
SoundRecorder >> clearRecordedSound [
	"Clear the sound recorded thus far. Go into pause mode if currently recording."

	paused _ true.
	recordedSound _ SequentialSound new.
	self allocateBuffer.

]

{ #category : 'accessing' }
SoundRecorder >> codec: aSoundCodec [

	codec _ aSoundCodec
]

{ #category : 'results' }
SoundRecorder >> condensedSamples [
	"Return a single SoundBuffer that is the contatenation of all my recorded buffers."

	| sz newBuf i |
	recordedBuffers _ recordedSound sounds collect: [:snd | snd samples].
	recordedBuffers isEmpty ifTrue: [^ SoundBuffer new: 0].
	recordedBuffers size = 1 ifTrue: [^ recordedBuffers first copy].
	sz _ recordedBuffers inject: 0 into: [:tot :buff | tot + buff size].
	newBuf _ SoundBuffer newMonoSampleCount: sz.
	i _ 1.
	recordedBuffers do: [:b |
		1 to: b size do: [:j |
			newBuf at: i put: (b at: j).
			i _ i + 1]].
	recordedBuffers _ nil.
	^ newBuf

]

{ #category : 'results' }
SoundRecorder >> condensedStereoSound [
	"Decompose my buffers into left and right channels and return a mixed sound consisting of the those two channels. This may be take a while, since the data must be copied into new buffers."

	| sz leftBuf rightBuf leftI rightI left |
	sz _ recordedBuffers inject: 0 into: [:tot :buff | tot + buff size].
	leftBuf _ SoundBuffer newMonoSampleCount: (sz + 1) // 2.
	rightBuf _ SoundBuffer newMonoSampleCount: (sz + 1) // 2.
	leftI _ rightI _ 1.
	left _ true.
	recordedBuffers do: [:b |
		1 to: b size do: [:j |
			left
				ifTrue: [leftBuf at: leftI put: (b at: j). leftI _ leftI + 1. left _ false]
				ifFalse: [rightBuf at: rightI put: (b at: j). rightI _ rightI + 1. left _ true]]].
	^ MixedSound new
		add: (SampledSound new setSamples: leftBuf samplingRate: samplingRate) pan: 0.0;
		add: (SampledSound new setSamples: rightBuf samplingRate: samplingRate) pan: 1.0

]

{ #category : 'trimming' }
SoundRecorder >> copyFrom: startPlace to: endPlace normalize: nFactor dcOffset: dcOffset [
	"Return a new SoundBuffer containing the samples in the given range."

	| startBufIndex startSampleIndex endBufIndex endSampleIndex
	 count resultBuf j buf firstInBuf n |
	startBufIndex _ startPlace at: 1.
	startSampleIndex _ startPlace at: 2.
	endBufIndex _ endPlace at: 1.
	endSampleIndex _ endPlace at: 2.

	startBufIndex = endBufIndex
		ifTrue: [count _ endSampleIndex + 1 - startSampleIndex]
		ifFalse: [
			count _ ((recordedBuffers at: startBufIndex) size + 1 - startSampleIndex).  "first buffer"
			count _ count + endSampleIndex.  "last buffer"
			startBufIndex + 1 to: endBufIndex - 1 do:
				[:i | count _ count + (recordedBuffers at: i) size]].  "middle buffers"
	resultBuf _ SoundBuffer newMonoSampleCount: count.

	j _ 1.  "next destination index in resultBuf"
	startBufIndex to: endBufIndex do: [:i |
		buf _ recordedBuffers at: i.
		firstInBuf _ 1.
	 	n _ buf size.
		i = startBufIndex ifTrue: [
			n _ (recordedBuffers at: startBufIndex) size + 1 - startSampleIndex.
			firstInBuf _ startSampleIndex].
		i = endBufIndex ifTrue: [
			i = startBufIndex
				ifTrue: [n _ endSampleIndex + 1 - startSampleIndex]
				ifFalse: [n _ endSampleIndex]].
		self copyTo: resultBuf from: j to: (j + n - 1)
			from: buf startingAt: firstInBuf
			normalize: nFactor dcOffset: dcOffset.
		j _ j + n].
	^ resultBuf

]

{ #category : 'trimming' }
SoundRecorder >> copyTo: resultBuf from: startIndex to: endIndex from: buf startingAt: firstInBuf normalize: nFactor dcOffset: dcOffset [
	"Copy samples from buf to resultBuf removing the DC offset and normalizing their volume in the process."

	| indexOffset |
	indexOffset _ firstInBuf - startIndex.
	startIndex to: endIndex do: [:i |
		resultBuf at: i put: (((buf at: (i + indexOffset)) - dcOffset) * nFactor) // 1000].

]

{ #category : 'accessing' }
SoundRecorder >> desiredSampleRate: newRate [

	"use of this method indicates a strong desire for the specified rate, even if
	the OS/hardware are not cooperative"

	desiredSampleRate _ samplingRate _ newRate  "Best are 44100 22050 11025"

]

{ #category : 'private' }
SoundRecorder >> emitBuffer: buffer [

	| sound ratio resultBuf |

	"since some sound recording devices cannot (or will not) record below a certain sample rate,
	trim the samples down if the user really wanted fewer samples"

	(desiredSampleRate isNil or: [(ratio _ samplingRate // desiredSampleRate) <= 1]) ifTrue: [
		sound _ SampledSound new setSamples: buffer samplingRate: samplingRate.
	] ifFalse: [
		resultBuf _ SoundBuffer 
			averageEvery: ratio 
			from: buffer 
			upTo: buffer monoSampleCount.
		sound _ SampledSound new setSamples: resultBuf samplingRate: samplingRate / ratio.
	].

	recordedSound add: (codec ifNil: [sound] ifNotNil: [codec compressSound: sound])
]

{ #category : 'private' }
SoundRecorder >> emitPartialBuffer [
	| s |
	s _ self samplesPerFrame.
	self emitBuffer: (currentBuffer copyFrom: 1 to: ((nextIndex-1) +( s-1) truncateTo: s))
]

{ #category : 'trimming' }
SoundRecorder >> endPlace [

	^ Array with: recordedBuffers size with: recordedBuffers last size
]

{ #category : 'trimming' }
SoundRecorder >> firstSampleOverThreshold: threshold dcOffset: dcOffset startingAt: startPlace [
	"Beginning at startPlace, this routine will return the first place at which a sample exceeds the given threshold."

	| buf s iStart jStart nThreshold |
	nThreshold _ threshold negated.
	iStart _ startPlace first.
	jStart _ startPlace second.
	iStart to: recordedBuffers size do:
		[:i | buf _ recordedBuffers at: i.
		jStart to: buf size do:
			[:j | s _ (buf at: j) - dcOffset.
			(s < nThreshold or: [s > threshold]) ifTrue:
				["found a sample over threshold"
				^ Array with: i with: j]].
		jStart _ 1].
	^ self endPlace
]

{ #category : 'recording controls' }
SoundRecorder >> hasRecordedSound [
	"Answer whether the receiver currently has any recorded sound"

	^ self recordedSound notNil
]

{ #category : 'initialization' }
SoundRecorder >> initialize [
	"SoundRecorder new"

	stereo _ false.
	samplingRate _ 11025.
	recordLevel _ 0.5.
	self initializeRecordingState.

]

{ #category : 'initialization' }
SoundRecorder >> initializeRecordingState [

	recordProcess _ nil.
	bufferAvailableSema _ nil.
	paused _ true.
	meteringBuffer _ nil.
	meterLevel _ 0.
	soundPlaying _ nil.
	currentBuffer _ nil.
	nextIndex _ 1.

]

{ #category : 'accessing' }
SoundRecorder >> isPaused [
	"Return true if recording is paused."

	^ paused

]

{ #category : 'private' }
SoundRecorder >> meterFrom: start count: count in: buffer [
	"Update the meter level with the maximum signal level in the given range of the given buffer."

	| last max sample |
	count = 0 ifTrue: [^ self].  "no new samples"
	last _ start + count - 1.
	max _ 0.
	start to: last do: [:i |
		sample _ buffer at: i.
		sample < 0 ifTrue: [sample _ sample negated].
		sample > max ifTrue: [max _ sample]].
	meterLevel _ max.

]

{ #category : 'accessing' }
SoundRecorder >> meterLevel [
	"Return the meter level, an integer in the range [0..100] where zero is silence and 100 represents the maximum signal level possible without clipping."

	^ (100 * meterLevel) // 32768

]

{ #category : 'trimming' }
SoundRecorder >> normalizeFactorFor: percentOfMaxVolume min: min max: max dcOffset: dcOffset [
	"Return a normalization factor for the range of sample values and DC offset. A normalization factor is a fixed-point number that will be divided by 1000 after multiplication with each sample value."

	| peak factor |
	peak _ (max - dcOffset) max: (min - dcOffset) negated.
	peak = 0 ifTrue: [^ 1000].
	factor _ (32767.0 * percentOfMaxVolume) / (100.0 * peak).
	^ (factor * 1000.0) asInteger

]

{ #category : 'recording controls' }
SoundRecorder >> pause [
	"Go into pause mode. The record level continues to be updated, but no sound is recorded."

	paused _ true.
	(currentBuffer notNil and: [nextIndex > 1])
		ifTrue: [
			self emitPartialBuffer.
			self allocateBuffer].

	soundPlaying ifNotNil: [
		soundPlaying pause.
		soundPlaying _ nil].
	"Note: there can be problems if canRecordWhilePlaying is true. Recorders which only pause will inhibit other recorders from recording. I chose to make #stopPlaying unconditional in a subclass. The same might be appropriate here at the expense of making recorders resumable"

	SoundRecorder canRecordWhilePlaying ifFalse: [self stopRecording].

]

{ #category : 'trimming' }
SoundRecorder >> place: startPlace plus: nSamples [
	"Return the place that is nSamples (may be negative) beyond thisPlace."

	| i j remaining buf |
	i _ startPlace first.
	j _ startPlace second.
	nSamples >= 0
	ifTrue: [remaining _ nSamples.
			[buf _ recordedBuffers at: i.
			(j + remaining) <= buf size ifTrue: [^ Array with: i with: j + remaining].
			i < recordedBuffers size]
				whileTrue: [remaining _ remaining - (buf size - j + 1).
							i _ i+1.  j _ 1].
			^ self endPlace]
	ifFalse: [remaining _ nSamples negated.
			[buf _ recordedBuffers at: i.
			(j - remaining) >= 1 ifTrue: [^ Array with: i with: j - remaining].
			i > 1]
				whileTrue: [remaining _ remaining - j.
							i _ i-1.  j _ (recordedBuffers at: i) size].
			^ #(1 1)]
]

{ #category : 'recording controls' }
SoundRecorder >> playback [
	"Playback the sound that has been recorded."

	self pause.
	soundPlaying _ self recordedSound.
	soundPlaying play.

]

{ #category : 'primitives' }
SoundRecorder >> primGetActualRecordingSampleRate [
	"Return the actual sample rate being used for recording. This primitive fails unless sound recording is currently in progress."

	<primitive: 'primitiveSoundGetRecordingSampleRate' module: 'SoundPlugin'>
	self primitiveFailed

]

{ #category : 'primitives' }
SoundRecorder >> primRecordSamplesInto: aWordArray startingAt: index [
	"Record a sequence of 16-bit sound samples into the given array starting at the given sample index. Return the number of samples recorded, which may be zero if no samples are currently available."

	<primitive: 'primitiveSoundRecordSamples' module: 'SoundPlugin'>
	self primitiveFailed

]

{ #category : 'primitives' }
SoundRecorder >> primSetRecordLevel: anInteger [
	"Set the desired recording level to the given value in the range 0-1000, where 0 is the lowest recording level and 1000 is the maximum. Do nothing if the sound input hardware does not support changing the recording level."

	<primitive: 'primitiveSoundSetRecordLevel' module: 'SoundPlugin'>
	self primitiveFailed

]

{ #category : 'primitives' }
SoundRecorder >> primStartRecordingDesiredSampleRate: samplesPerSec stereo: stereoFlag semaIndex: anInteger [
	"Start sound recording with the given stereo setting. Use a sampling rate as close to the desired rate as the underlying platform will support. If the given semaphore index is > 0, it is taken to be the index of a Semaphore in the external objects array to be signalled every time a recording buffer is filled."

	<primitive: 'primitiveSoundStartRecording' module: 'SoundPlugin'>
	self primitiveFailed

]

{ #category : 'primitives' }
SoundRecorder >> primStopRecording [
	"Stop sound recording. Does nothing if recording is not currently in progress. Do not fail if plugin is not available"

	<primitive: 'primitiveSoundStopRecording' module: 'SoundPlugin'>
]

{ #category : 'accessing' }
SoundRecorder >> recordLevel [

	^ recordLevel

]

{ #category : 'accessing' }
SoundRecorder >> recordLevel: level [
	"Set the desired recording level to the given value in the range 0.0 to 1.0, where 0.0 is the lowest recording level and 1.0 is the maximum. Do nothing if the sound input hardware does not support changing the recording level."
	"Details: On the Macintosh, the lowest possible record level attenuates the input signal, but does not silence it entirely." 

	recordLevel _ (level asFloat min: 1.0) max: 0.0.
	recordProcess ifNotNil: [
		self primSetRecordLevel: (1000.0 * recordLevel) asInteger].

]

{ #category : 'private' }
SoundRecorder >> recordLoop [
	"Record process loop that records samples."

	| n sampleCount |
	n _ 0.
	[true] whileTrue: [
		n = 0 ifTrue: [bufferAvailableSema wait].
		paused
			ifTrue: [
				n _ self primRecordSamplesInto: meteringBuffer startingAt: 1.
				self meterFrom: 1 count: n in: meteringBuffer]
			ifFalse: [
				n _ self primRecordSamplesInto: currentBuffer startingAt: nextIndex.
				self meterFrom: nextIndex count: n in: currentBuffer.
				nextIndex _ nextIndex + n.
				stereo
					ifTrue: [sampleCount _ currentBuffer stereoSampleCount]
					ifFalse: [sampleCount _ currentBuffer monoSampleCount].
				nextIndex > sampleCount
					ifTrue: [
						self emitBuffer: currentBuffer.
						self allocateBuffer]]].

]

{ #category : 'results' }
SoundRecorder >> recordedSound [
	"Return the sound that was recorded."

	^ recordedSound

]

{ #category : 'recording controls' }
SoundRecorder >> resumeRecording [
	"Continue recording from the point at which it was last paused."

	self flag: #bob.
	"Note: If canRecordWhilePlaying is true, then recordings may never get started (at least by this method). One possibility, used in a subclass, is to make the #startPlaying unconditional. Another would be to use #startPlaying instead of #resumePlaying in appropriate cases"

	SoundRecorder canRecordWhilePlaying ifFalse: [self startRecording].
	paused _ false.

]

{ #category : 'private' }
SoundRecorder >> samplesPerFrame [
	"Can be overridden to quantize buffer size for, eg, fixed-frame codecs"

	^codec
		ifNil: [1]
		ifNotNil: [codec samplesPerFrame]
]

{ #category : 'accessing' }
SoundRecorder >> samplingRate [

	^ samplingRate

]

{ #category : 'accessing' }
SoundRecorder >> samplingRate: newRate [

	samplingRate _ newRate  "Best are 44100 22050 11025"

]

{ #category : 'trimming' }
SoundRecorder >> scanForEndThreshold: threshold dcOffset: dcOffset minLull: lull startingAt: startPlace [
	"Beginning at startPlace, this routine will find the last sound that exceeds threshold, such that if you look lull samples later you will not find another sound over threshold within the following block of lull samples.
	Return the place that is lull samples beyond to that last sound.
	If no end of sound is found, return endPlace."

	| buf s iStart jStart nThreshold n |
	nThreshold _ threshold negated.
	iStart _ startPlace first.
	jStart _ startPlace second.
	n _ 0.
	iStart to: recordedBuffers size do:
		[:i | buf _ recordedBuffers at: i.
		jStart to: buf size do:
			[:j | s _ (buf at: j) - dcOffset.
			(s < nThreshold or: [s > threshold])
				ifTrue: ["found a sample over threshold"
						n _ 0]
				ifFalse: ["still not over threshold"
						n _ n + 1.
						n >= lull ifTrue: [^ Array with: i with: j]]].
		jStart _ 1].
	^ self endPlace
]

{ #category : 'trimming' }
SoundRecorder >> scanForStartThreshold: threshold dcOffset: dcOffset minDur: duration startingAt: startPlace [
	"Beginning at startPlace, this routine will find the first sound that exceeds threshold, such that if you look duration samples later you will find another sound over threshold within the following block of duration samples.
	Return the place that is duration samples prior to that first sound.
	If no sound is found, return endPlace."

	| soundPlace lookPlace nextSoundPlace thirdPlace |
	soundPlace _ self firstSampleOverThreshold: threshold dcOffset: dcOffset
					startingAt: startPlace.
	[soundPlace = self endPlace ifTrue: [^ soundPlace].
	"Found a sound -- look duration later"
	lookPlace _ self place: soundPlace plus: duration.
	nextSoundPlace _ self firstSampleOverThreshold: threshold dcOffset: dcOffset
					startingAt: lookPlace.
	thirdPlace _ self place: lookPlace plus: duration.
	nextSoundPlace first < thirdPlace first
		or: [nextSoundPlace first = thirdPlace first
			and: [nextSoundPlace second < thirdPlace second]]]
		whileFalse: [soundPlace _ nextSoundPlace].

	"Yes, there is sound in the next interval as well"
	^ self place: soundPlace plus: 0-duration

]

{ #category : 'trimming' }
SoundRecorder >> segmentsAbove: threshold normalizedVolume: percentOfMaxVolume [
	"Break the current recording up into a sequence of sound segments separated by silences."

	| max min sum totalSamples bufSize s dcOffset firstPlace endPlace resultBuf nFactor lastPlace segments gapSize minDur minLull soundSize restSize |
	stereo ifTrue: [self error: 'stereo trimming is not yet supported'].
	paused ifFalse: [self error: 'must stop recording before trimming'].
	(recordedSound == nil or: [recordedSound sounds isEmpty]) ifTrue:[^ self].
	"Reconstruct buffers so old trimming code will work"
	recordedBuffers _ recordedSound sounds collect: [:snd | snd samples].
	soundSize _ restSize _ 0.

	max _ min _ sum _ totalSamples _ 0.
	recordedBuffers do: [:buf |
		bufSize _ buf size.
		totalSamples _ totalSamples + buf size.
		1 to: bufSize do: [:i |
			s _ buf at: i.
			s > max ifTrue: [max _ s].
			s < min ifTrue: [min _ s].
			sum _ sum + s]].
	dcOffset _ sum // totalSamples.

	minDur _ (samplingRate/20.0) asInteger.  " 1/20 second "
	minLull _ (samplingRate/4.0) asInteger.  " 1/2 second "
	segments _ SequentialSound new.
	endPlace _ self endPlace.
	lastPlace _ #(1 1).
	[firstPlace _ self scanForStartThreshold: threshold
						dcOffset: dcOffset
						minDur: minDur
						startingAt: lastPlace.
	firstPlace = endPlace]
		whileFalse:
		[firstPlace = lastPlace ifFalse:
			["Add a silence equal to the gap size"
			"Wasteful but simple way to get gap size..."
			gapSize _ (self copyFrom: lastPlace to: firstPlace
						normalize: 1000 dcOffset: dcOffset) size - 2.
			"... -2 makes up for overlap of one sample on either end"
			segments add: (RestSound dur: gapSize asFloat / samplingRate).
			restSize _ restSize + gapSize.
"Transcript cr; print: firstPlace; space; print: lastPlace; space; print: gapSize; space; show: 'gap'."
			].
		lastPlace _ self scanForEndThreshold: threshold
						dcOffset: dcOffset
						minLull: minLull + minDur
						startingAt: firstPlace.
		"Allow room for lead time of next sound"
		lastPlace _ self place: lastPlace plus: minDur negated.
		nFactor _ self normalizeFactorFor: percentOfMaxVolume
						min: min max: max dcOffset: dcOffset.
		resultBuf _ self copyFrom: firstPlace to: lastPlace
						normalize: nFactor dcOffset: dcOffset.
		soundSize _ soundSize + resultBuf size.
"Transcript cr; print: firstPlace; space; print: lastPlace; space; print: resultBuf size; space; show: 'sound'."
		segments add: (codec
			ifNil: [SampledSound new setSamples: resultBuf samplingRate: samplingRate]
			ifNotNil: [codec compressSound: (SampledSound new setSamples: resultBuf samplingRate: samplingRate)])].

	"Final gap for consistency"
	gapSize _ (self copyFrom: lastPlace to: self endPlace
				normalize: 1000 dcOffset: dcOffset) size - 1.
	segments add: (RestSound dur: gapSize asFloat / samplingRate).
	restSize _ restSize + gapSize.
	self inform: ((soundSize+restSize/samplingRate) roundTo: 0.1) printString , ' secs reduced to ' , ((soundSize/samplingRate) roundTo: 0.1) printString.
	recordedBuffers _ nil.
	^ segments
]

{ #category : 'results' }
SoundRecorder >> soundSegments [

	^ self segmentsAbove: 1000 normalizedVolume: 80.0

]

{ #category : 'recording controls' }
SoundRecorder >> startRecording [
	"Turn of the sound input driver and start the recording process. Initially, recording is paused."

	| semaIndex |
	recordLevel ifNil: [recordLevel := 0.5].  "lazy initialization"
	SoundRecorder canRecordWhilePlaying ifFalse: [SoundPlayer shutDown].
	recordProcess ifNotNil: [self stopRecording].
	paused := true.
	meteringBuffer := SoundBuffer newMonoSampleCount: 1024.
	meterLevel := 0.
	self allocateBuffer.
	bufferAvailableSema := Semaphore new.
	semaIndex := Smalltalk registerExternalObject: bufferAvailableSema.
	self primStartRecordingDesiredSampleRate: samplingRate asInteger
		stereo: stereo
		semaIndex: semaIndex.
	RecorderActive := true.
	samplingRate := self primGetActualRecordingSampleRate.
	self primSetRecordLevel: (1000.0 * recordLevel) asInteger.
	recordProcess := [self recordLoop] newProcess.
	recordProcess
		priority: Processor userInterruptPriority;
		name: 'Sound Recorder';
		resume.

]

{ #category : 'recording controls' }
SoundRecorder >> stopRecording [
	"Stop the recording process and turn of the sound input driver."

	recordProcess ifNotNil: [recordProcess terminate].
	recordProcess _ nil.
	self primStopRecording.
	RecorderActive _ false.
	Smalltalk unregisterExternalObject: bufferAvailableSema.
	(currentBuffer notNil and: [nextIndex > 1])
		ifTrue: [self emitPartialBuffer].
	self initializeRecordingState.

]

{ #category : 'trimming' }
SoundRecorder >> suppressSilence [

	recordedSound _ self soundSegments
]

{ #category : 'trimming' }
SoundRecorder >> trim: threshold normalizedVolume: percentOfMaxVolume [
	"Remove the leading and trailing parts of this recording that are below the given threshold. Remove any DC offset and scale the recording so that its peaks are the given percent of the maximum volume."

	| max min sum totalSamples bufSize s dcOffset startPlace endPlace resultBuf nFactor |
	stereo ifTrue: [self error: 'stereo trimming is not yet supported'].
	paused ifFalse: [self error: 'must stop recording before trimming'].
	recordedBuffers _ recordedSound sounds collect: [:snd | snd samples].
	recordedBuffers isEmpty ifTrue: [^ self].

	max _ min _ sum _ totalSamples _ 0.
	recordedBuffers do: [:buf |
		bufSize _ buf size.
		totalSamples _ totalSamples + buf size.
		1 to: bufSize do: [:i |
			s _ buf at: i.
			s > max ifTrue: [max _ s].
			s < min ifTrue: [min _ s].
			sum _ sum + s]].
	dcOffset _ sum // totalSamples.

	"a place is an array of <buffer index><index of sample in buffer>"
	startPlace _ self scanForStartThreshold: threshold
					dcOffset: dcOffset
					minDur: (samplingRate/60.0) asInteger "at least 1/60th of a second"
					startingAt: #(1 1).
	startPlace = self endPlace ifTrue:
		["no samples above threshold"
		recordedBuffers _ nil.  ^ self].

	endPlace _ self scanForEndThreshold: threshold
					dcOffset: dcOffset
					minLull: (samplingRate/5) asInteger
					startingAt: startPlace.
	nFactor _ self normalizeFactorFor: percentOfMaxVolume min: min max: max dcOffset: dcOffset.
	resultBuf _ self copyFrom: startPlace to: endPlace normalize: nFactor dcOffset: dcOffset.
	recordedSound _ SampledSound new setSamples: resultBuf samplingRate: samplingRate.
	recordedBuffers _ nil

]

{ #category : 'recording controls' }
SoundRecorder >> verifyExistenceOfRecordedSound [
	"If the receiver has a recorded sound, answer true; if not, put up an informer and answer false"

	^ self recordedSound
		ifNotNil:
			[true]
		ifNil: [
			self inform: 'please record a sound first'.
			false]
]
