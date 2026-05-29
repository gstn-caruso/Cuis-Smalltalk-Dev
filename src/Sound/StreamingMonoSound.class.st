"
I implement a streaming player for monophonic Sun (.au) and AIFF (.aif) audio files.
Example of use:
	(StreamingMonoSound onFileNamed: 'song.aif') play.

"
Class {
	#name : 'StreamingMonoSound',
	#superclass : 'AbstractSound',
	#instVars : [
		'stream',
		'volume',
		'repeat',
		'headerStart',
		'audioDataStart',
		'streamSamplingRate',
		'totalSamples',
		'codec',
		'mixer',
		'leftoverSamples',
		'lastBufferMSecs',
		'mutex'
	],
	#category : 'Sound-Synthesis',
	#package : 'Sound',
	#tag : 'Synthesis'
}

{ #category : 'instance creation' }
StreamingMonoSound class >> onFileNamed: fileName [
	"Answer an instance of me for playing the file with the given name."

	^self onFileNamed: fileName headerStart: 0
]

{ #category : 'instance creation' }
StreamingMonoSound class >> onFileNamed: fileName headerStart: anInteger [
	"Answer an instance of me for playing audio data starting at the given position in the file with the given name."

	| answer |
	fileName asFileEntry readStreamDo: [ :f |
		answer _ self new initStream: f headerStart: anInteger ].
	^answer

]

{ #category : 'private' }
StreamingMonoSound >> createMixer [
	"Create a mixed sound consisting of sampled sounds with one sound buffer's worth of samples."

	| snd |
	mixer _ MixedSound new.
	snd _ SampledSound
		samples: (SoundBuffer newMonoSampleCount: 2)  "buffer size will be adjusted dynamically"
		samplingRate: streamSamplingRate.
	mixer add: snd pan: 0.5 volume: volume.

]

{ #category : 'private' }
StreamingMonoSound >> currentSampleIndex [
	"Answer the index of the current sample."

	| bytePosition frameIndex |
	bytePosition _ stream position - audioDataStart.
	codec
		ifNil: [^ bytePosition // 2]
		ifNotNil: [
			frameIndex _ bytePosition // codec bytesPerEncodedFrame.
			^ (frameIndex * codec samplesPerFrame) - leftoverSamples monoSampleCount].

]

{ #category : 'accessing' }
StreamingMonoSound >> duration [
	"Answer the duration of this sound in seconds."

	^ totalSamples asFloat / streamSamplingRate

]

{ #category : 'other' }
StreamingMonoSound >> extractFrom: startSecs to: endSecs [
	"Extract a portion of this sound between the given start and end times. The current implementation only works if the sound is uncompressed."

	| emptySound first last sampleCount byteStream sndBuf |
	codec ifNotNil: [^ self error: 'only works on uncompressed sounds'].
	emptySound := SampledSound samples: SoundBuffer new samplingRate: streamSamplingRate.
	first := (startSecs * streamSamplingRate) truncated max: 0.
	last := ((endSecs * streamSamplingRate) truncated min: totalSamples) - 1.
	first >= last ifTrue: [^ emptySound].
	codec ifNotNil: [self error: 'extracting from compressed sounds is not supported'].
	sampleCount := last + 1 - first.
	stream position: audioDataStart + (2 * first).
	byteStream := ReadStream on: (stream next: 2 * sampleCount).
	sndBuf := SoundBuffer newMonoSampleCount: sampleCount.
	1 to: sampleCount do: [:i | sndBuf at: i put: (byteStream nextInt16BigEndian: true)].
	^ SampledSound samples: sndBuf samplingRate: streamSamplingRate

]

{ #category : 'initialization' }
StreamingMonoSound >> initStream: aStream headerStart: anInteger [
	"Initialize for streaming from the given stream. The audio file header starts at the given stream position."

	stream _ aStream.
	volume _ 1.0.
	repeat _ false.
	headerStart _ anInteger.
	self reset.

]

{ #category : 'private' }
StreamingMonoSound >> loadBuffer: aSoundBuffer compressedSampleCount: sampleCount [
	"Load the given sound buffer from the compressed sample stream."
	"Details: Most codecs decode in multi-sample units called 'frames'. Since the requested sampleCount is typically not an even multiple of the frame size, we need to deal with partial frames. The unused samples from a partial frame are retained until the next call to this method."

	| n samplesNeeded frameCount encodedBytes r decodedCount buf j |
	"first, use any leftover samples"
	n _ self loadFromLeftovers: aSoundBuffer sampleCount: sampleCount.
	samplesNeeded _ sampleCount - n.
	samplesNeeded <= 0 ifTrue: [^ self].

	"decode an integral number of full compression frames"
	frameCount _ samplesNeeded // codec samplesPerFrame.
	encodedBytes _ stream next: (frameCount * codec bytesPerEncodedFrame).
	r _ codec decodeFrames: frameCount from: encodedBytes at: 1 into: aSoundBuffer at: n + 1.
	decodedCount _ r last.
	decodedCount >= samplesNeeded ifTrue: [^ self].

	"decode one last compression frame to finish filling the buffer"
	buf _ SoundBuffer newMonoSampleCount: codec samplesPerFrame.
	encodedBytes _ stream next: codec bytesPerEncodedFrame.
	codec decodeFrames: 1 from: encodedBytes at: 1 into: buf at: 1.
	j _ 0.
	(n + decodedCount + 1) to: sampleCount do: [:i |
		aSoundBuffer at: i put: (buf at: (j _ j + 1))].

	"save the leftover samples"
	leftoverSamples _ buf copyFrom: (j + 1) to: buf monoSampleCount.

]

{ #category : 'private' }
StreamingMonoSound >> loadBuffer: aSoundBuffer uncompressedSampleCount: sampleCount [
	"Load the given sound buffer from the uncompressed sample stream."

	"read directly into the sample buffer; count is in 32-bit words"
	stream next: sampleCount // 2 into: aSoundBuffer startingAt: 1.
	aSoundBuffer restoreEndianness.

	"read the final sample if sampleCount is odd:"
	sampleCount odd ifTrue: [aSoundBuffer at: sampleCount put: (stream nextInt16BigEndian: true)].

]

{ #category : 'private' }
StreamingMonoSound >> loadBuffersForSampleCount: count [
	"Load the sound buffers from the stream."

	| snd buf sampleCount |
	snd _ mixer sounds first.
	buf _ snd samples.
	buf monoSampleCount = count ifFalse: [
		buf _ SoundBuffer newMonoSampleCount: count.
		snd setSamples: buf samplingRate: streamSamplingRate].
	sampleCount _ count min: (totalSamples - self currentSampleIndex).
	sampleCount < count ifTrue: [buf primFill: 0].

	codec
		ifNil: [self loadBuffer: buf uncompressedSampleCount: sampleCount]
		ifNotNil: [self loadBuffer: buf compressedSampleCount: sampleCount].

	mixer reset.

]

{ #category : 'private' }
StreamingMonoSound >> loadFromLeftovers: aSoundBuffer sampleCount: sampleCount [
	"Load the given sound buffer from the samples leftover from the last frame. Answer the number of samples loaded, which typically is less than sampleCount."

	| leftoverCount n |
	leftoverCount _ leftoverSamples monoSampleCount.
	leftoverCount = 0 ifTrue: [^ 0].

	n _ leftoverCount min: sampleCount.
	1 to: n do: [:i | aSoundBuffer at: i put: (leftoverSamples at: i)].
	n < sampleCount
		ifTrue: [leftoverSamples _ SoundBuffer new]
		ifFalse: [leftoverSamples _ leftoverSamples copyFrom: n + 1 to: leftoverSamples size].
	^ n

]

{ #category : 'playing' }
StreamingMonoSound >> millisecondsSinceStart [
	"Answer the number of milliseconds of this sound started playing."

	| mSecs |
	(stream isNil or: [stream closed]) ifTrue: [^ 0].
	mSecs _ self currentSampleIndex * 1000 // streamSamplingRate.
	(self isPlaying and: [lastBufferMSecs > 0]) ifTrue: [
		"adjust mSecs by the milliseconds since the last buffer"
		mutex critical: [
			mSecs _ self currentSampleIndex * 1000 // streamSamplingRate.
			mSecs _ mSecs + (Time localMillisecondClock - lastBufferMSecs)]].
	^ mSecs + 350 - (2 * SoundPlayer bufferMSecs)

]

{ #category : 'playing' }
StreamingMonoSound >> playSampleCount: n into: aSoundBuffer startingAt: startIndex [
	"Mix the next n samples of this sound into the given buffer starting at the given index"

	self repeat ifTrue: [  "loop if necessary"
		(totalSamples - self currentSampleIndex) < n ifTrue: [self startOver]].

	mutex critical: [
		lastBufferMSecs _ Time localMillisecondClock.
		self loadBuffersForSampleCount: (n * streamSamplingRate) // SoundPlayer samplingRate.
		mixer playSampleCount: n into: aSoundBuffer startingAt: startIndex].

]

{ #category : 'private' }
StreamingMonoSound >> positionCodecTo: desiredSampleIndex [
	"Position to the closest frame before the given sample index when using a codec. If using the ADPCM codec, try to ensure that it is in sync with the compressed sample stream."

	| desiredFrameIndex desiredPosition tmpStream tmpCodec byteBuf bufFrames sampleBuf frameCount n startOffset |
	(codec isKindOf: ADPCMCodec) ifFalse: [
		"stateless codecs (or relatively stateless ones, like GSM: just jump to frame boundary"
		desiredFrameIndex _ desiredSampleIndex // codec samplesPerFrame.
		stream position: audioDataStart + (desiredFrameIndex * codec bytesPerEncodedFrame).
		codec reset.
		^ self].

	"compute the desired stream position"
	desiredFrameIndex _ desiredSampleIndex // codec samplesPerFrame.
	desiredPosition _ audioDataStart + (desiredFrameIndex * codec bytesPerEncodedFrame).

	"copy stream and codec"
	(stream isFileStream)
		ifTrue: [tmpStream _ (stream name asFileEntry readStream ) binary]
		ifFalse: [tmpStream _ "stream deepCopy" stream contents readStream].	"To kill #deepCopy. Not sure if right, though (jmv)"
	tmpCodec _ codec copy reset.

	"reset the codec and start back about 30 seconds to try to get codec in sync"
	startOffset _ ((desiredFrameIndex - 80000) max: 0) * codec bytesPerEncodedFrame.
	tmpStream position: audioDataStart + startOffset.

	"decode forward to the desired position"
	byteBuf _ ByteArray new: (32000 roundTo: codec bytesPerEncodedFrame).
	bufFrames _ byteBuf size // codec bytesPerEncodedFrame.
	sampleBuf _ SoundBuffer newMonoSampleCount: bufFrames * codec samplesPerFrame.
	frameCount _ (desiredPosition - tmpStream position) // codec bytesPerEncodedFrame.
	[frameCount > 0] whileTrue: [
		n _ bufFrames min: frameCount.
		tmpStream next: n * codec bytesPerEncodedFrame into: byteBuf startingAt: 1.
		tmpCodec decodeFrames: n from: byteBuf at: 1 into: sampleBuf at: 1.
		frameCount _ frameCount - n].

	codec _ tmpCodec.
	stream position: tmpStream position.
	(tmpStream isFileStream) ifTrue: [tmpStream close].
]

{ #category : 'private' }
StreamingMonoSound >> readAIFFHeader [
	"Read an AIFF file header from stream."

	| aiffReader |
	aiffReader _ AIFFFileReader new.
	aiffReader readFromStream: stream mergeIfStereo: false skipDataChunk: true.
	aiffReader channelCount = 1 ifFalse: [self error: 'not monophonic'].
	aiffReader bitsPerSample = 16 ifFalse: [self error: 'not 16-bit'].

	audioDataStart _ headerStart + aiffReader channelDataOffset.
	streamSamplingRate _ aiffReader samplingRate.
	totalSamples _ aiffReader frameCount min: (stream size - audioDataStart) // 2.
	codec _ nil.

]

{ #category : 'private' }
StreamingMonoSound >> readHeader [
	"Read the sound file header from my stream."

	| id |
	stream position: headerStart.
	id _ (stream next: 4) asString.
	stream position: headerStart.
	id = 'FORM' ifTrue: [^ self readAIFFHeader].
	self error: 'unrecognized sound file format'.

]

{ #category : 'accessing' }
StreamingMonoSound >> repeat [
	"Answer the repeat flag."

	^ repeat

]

{ #category : 'accessing' }
StreamingMonoSound >> repeat: aBoolean [
	"Set the repeat flag. If true, this sound will loop back to the beginning when it gets to the end."

	repeat _ aBoolean.

]

{ #category : 'playing' }
StreamingMonoSound >> reset [

	super reset.
	self startOver.
	self createMixer.

]

{ #category : 'playing' }
StreamingMonoSound >> samplesRemaining [
	"Answer the number of samples remaining to be played."

	| result |
	(stream isNil or: [stream closed]) ifTrue: [^ 0].
	self repeat ifTrue: [^ 1000000].
	result _ (totalSamples - self currentSampleIndex) max: 0.
	result <= 0 ifTrue: [
		stream close.
		mixer _ nil.
		codec _ nil ].
	^ result
]

{ #category : 'accessing' }
StreamingMonoSound >> soundPosition [
	"Answer the relative position of sound playback as a number between 0.0 and 1.0."

	(stream isNil or: [stream closed]) ifTrue: [^ 0.0].
	^ self currentSampleIndex asFloat / totalSamples

]

{ #category : 'accessing' }
StreamingMonoSound >> soundPosition: fraction [
	"Jump to the position the given fraction through the sound file. The argument is a number between 0.0 and 1.0."

	| desiredSampleIndex |
	(stream isNil or: [stream closed]) ifTrue: [^ self].
	desiredSampleIndex _ ((totalSamples * fraction) truncated max: 0) min: totalSamples.
	codec
		ifNil: [stream position: audioDataStart + (desiredSampleIndex * 2)]
		ifNotNil: [self positionCodecTo: desiredSampleIndex].
	leftoverSamples _ SoundBuffer new.

]

{ #category : 'private' }
StreamingMonoSound >> startOver [
	"Jump back to the first sample."

	stream reopen; binary.
	self readHeader.
	stream position: audioDataStart.
	leftoverSamples _ SoundBuffer new.
	lastBufferMSecs _ 0.
	mutex _ Semaphore forMutualExclusion.

]

{ #category : 'accessing' }
StreamingMonoSound >> streamSamplingRate [
	"Answer the sampling rate of the MP3 stream."

	^ streamSamplingRate

]

{ #category : 'accessing' }
StreamingMonoSound >> volume [
	"Answer my volume."

	^ volume

]

{ #category : 'accessing' }
StreamingMonoSound >> volume: aNumber [
	"Set my volume to the given number between 0.0 and 1.0."

	volume _ aNumber.
	self createMixer.

]
