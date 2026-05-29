"
I am an abstract class that describes the protocol for sound codecs. Each codec (the name stems from "COder/DECoder") describes a particular algorithm for compressing and decompressing sound data. Most sound codecs are called 'lossy' because they lose information; the decompressed sound data is not exactly the same as the original data.

"
Class {
	#name : 'SoundCodec',
	#superclass : 'Object',
	#category : 'Sound-Synthesis',
	#package : 'Sound',
	#tag : 'Synthesis'
}

{ #category : 'subclass responsibilities' }
SoundCodec >> bytesPerEncodedFrame [
	"Answer the number of bytes required to hold one frame of compressed sound data. Answer zero if this codec produces encoded frames of variable size."

	self subclassResponsibility.

]

{ #category : 'compress/decompress' }
SoundCodec >> compressAndDecompress: aSound [
	"Compress and decompress the given sound. Useful for testing."
	"(MuLawCodec new compressAndDecompress: (SampledSound soundNamed: 'camera')) play"

	^ (self compressSound: aSound) asSound

]

{ #category : 'compress/decompress' }
SoundCodec >> compressSound: aSound [
	"Compress the entirety of the given sound with this codec. Answer a CompressedSoundData."

	| compressed channels |
	compressed _ CompressedSoundData new
		codecName: self class name;
		soundClassName: aSound class name.
	(aSound isKindOf: SampledSound) ifTrue: [
		channels _ Array new: 1.
		channels at: 1 put: (self encodeSoundBuffer: aSound samples).
		compressed
			channels: channels;
			samplingRate: aSound originalSamplingRate;
			firstSample: 1;
			loopEnd: aSound samples size;
			loopLength: 0.0;
			perceivedPitch: 100.0;
			gain: aSound loudness.
		^ compressed].
	(aSound isKindOf: LoopedSampledSound) ifTrue: [
		aSound isStereo
			ifTrue: [
				channels _ Array new: 2.
				channels at: 1 put: (self encodeSoundBuffer: aSound leftSamples).
				channels at: 2 put: (self encodeSoundBuffer: aSound rightSamples)]
			ifFalse: [
				channels _ Array new: 1.
				channels at: 1 put: (self encodeSoundBuffer: aSound leftSamples)].
		compressed
			channels: channels;
			samplingRate: aSound originalSamplingRate;
			firstSample: aSound firstSample;
			loopEnd: aSound loopEnd;
			loopLength: aSound loopLength;
			perceivedPitch: aSound perceivedPitch;
			gain: aSound gain.
		^ compressed].
	self error: 'you can only compress sampled sounds'.

]

{ #category : 'compress/decompress' }
SoundCodec >> compressSound: aSound atRate: desiredSampleRate [
	"Compress the entirety of the given sound with this codec. Answer a CompressedSoundData."

	| compressed channels samples newRate ratio buffer |

	compressed _ CompressedSoundData new
		codecName: self class name;
		soundClassName: aSound class name.
	(aSound isKindOf: SampledSound) ifTrue: [
		(desiredSampleRate isNil or: 
				[(ratio _ aSound originalSamplingRate // desiredSampleRate) <= 1]) ifTrue: [
			samples _ aSound samples.
			newRate _ aSound originalSamplingRate.
		] ifFalse: [
			buffer _ aSound samples.
			samples _ SoundBuffer 
				averageEvery: ratio 
				from: buffer 
				upTo: buffer monoSampleCount.
			newRate _ aSound originalSamplingRate / ratio.
		].

		channels _ Array new: 1.
		channels at: 1 put: (self encodeSoundBuffer: samples).
		compressed
			channels: channels;
			samplingRate: newRate;
			firstSample: 1;
			loopEnd: samples size;
			loopLength: 0.0;
			perceivedPitch: 100.0;
			gain: aSound loudness.
		^ compressed].
	(aSound isKindOf: LoopedSampledSound) ifTrue: [
		aSound isStereo
			ifTrue: [
				channels _ Array new: 2.
				channels at: 1 put: (self encodeSoundBuffer: aSound leftSamples).
				channels at: 2 put: (self encodeSoundBuffer: aSound rightSamples)]
			ifFalse: [
				channels _ Array new: 1.
				channels at: 1 put: (self encodeSoundBuffer: aSound leftSamples)].
		compressed
			channels: channels;
			samplingRate: aSound originalSamplingRate;
			firstSample: aSound firstSample;
			loopEnd: aSound loopEnd;
			loopLength: aSound loopLength;
			perceivedPitch: aSound perceivedPitch;
			gain: aSound gain.
		^ compressed].
	self error: 'you can only compress sampled sounds'.

]

{ #category : 'private' }
SoundCodec >> decodeCompressedData: aByteArray [
	"Decode the entirety of the given encoded data buffer with this codec. Answer a monophonic SoundBuffer containing the uncompressed samples."

	| frameCount result increments |
	frameCount _ self frameCount: aByteArray.
	result _ SoundBuffer newMonoSampleCount: frameCount * self samplesPerFrame.
	self reset.
	increments _ self decodeFrames: frameCount from: aByteArray at: 1 into: result at: 1.
	((increments first = aByteArray size) and: [increments last = result size]) ifFalse: [
		self error: 'implementation problem; increment sizes should match buffer sizes'].
	^ result

]

{ #category : 'subclass responsibilities' }
SoundCodec >> decodeFrames: frameCount from: srcByteArray at: srcIndex into: dstSoundBuffer at: dstIndex [
	"Decode the given number of monophonic frames starting at the given index in the given ByteArray of compressed sound data and storing the decoded samples into the given SoundBuffer starting at the given destination index. Answer a pair containing the number of bytes of compressed data consumed and the number of decompressed samples produced."
	"Note: Assume that the sender has ensured that the given number of frames will not exhaust either the source or destination buffers."

	self subclassResponsibility.

]

{ #category : 'compress/decompress' }
SoundCodec >> decompressSound: aCompressedSound [
	"Decompress the entirety of the given compressed sound with this codec and answer the resulting sound."

	| channels sound |
	channels _ aCompressedSound channels
		collect: [:compressed | self decodeCompressedData: compressed].
	'SampledSound' = aCompressedSound soundClassName ifTrue: [
		sound _ SampledSound
			samples: channels first
			samplingRate: (aCompressedSound samplingRate).
		sound loudness: aCompressedSound gain.
		^ sound].
	'LoopedSampledSound' = aCompressedSound soundClassName ifTrue: [
		aCompressedSound loopLength = 0
			ifTrue: [
				sound _ LoopedSampledSound
					unloopedSamples: channels first
					pitch: aCompressedSound perceivedPitch
					samplingRate: aCompressedSound samplingRate]
			ifFalse: [
				sound _ LoopedSampledSound
					samples: channels first
					loopEnd: aCompressedSound loopEnd
					loopLength: aCompressedSound loopLength
					pitch: aCompressedSound perceivedPitch
					samplingRate: aCompressedSound samplingRate].
		channels size > 1 ifTrue: [sound rightSamples: channels last].
		sound
			firstSample: aCompressedSound firstSample;
			gain: aCompressedSound gain.
		sound
			setPitch: 100.0
			dur: (channels first size / aCompressedSound samplingRate)
			loudness: 1.0.
		^ sound].
	self error: 'unknown sound class'.

]

{ #category : 'subclass responsibilities' }
SoundCodec >> encodeFrames: frameCount from: srcSoundBuffer at: srcIndex into: dstByteArray at: dstIndex [
	"Encode the given number of frames starting at the given index in the given monophonic SoundBuffer and storing the encoded sound data into the given ByteArray starting at the given destination index. Encode only as many complete frames as will fit into the destination. Answer a pair containing the number of samples consumed and the number of bytes of compressed data produced."
	"Note: Assume that the sender has ensured that the given number of frames will not exhaust either the source or destination buffers."

	self subclassResponsibility.

]

{ #category : 'private' }
SoundCodec >> encodeSoundBuffer: aSoundBuffer [
	"Encode the entirety of the given monophonic SoundBuffer with this codec. Answer a ByteArray containing the compressed sound data."

	| codeFrameSize frameSize fullFrameCount lastFrameSamples result increments finalFrame i lastIncs |
	frameSize _ self samplesPerFrame.
	fullFrameCount _ aSoundBuffer monoSampleCount // frameSize.
	lastFrameSamples _ aSoundBuffer monoSampleCount - (fullFrameCount * frameSize).
	codeFrameSize _ self bytesPerEncodedFrame.
	codeFrameSize = 0 ifTrue:
		["Allow room for 1 byte per sample for variable-length compression"
		codeFrameSize _ frameSize].
	lastFrameSamples > 0
		ifTrue: [result _ ByteArray new: (fullFrameCount + 1) * codeFrameSize]
		ifFalse: [result _ ByteArray new: fullFrameCount * codeFrameSize].
	self reset.
	increments _ self encodeFrames: fullFrameCount from: aSoundBuffer at: 1 into: result at: 1.
	lastFrameSamples > 0 ifTrue: [
		finalFrame _ SoundBuffer newMonoSampleCount: frameSize.
		i _ fullFrameCount * frameSize.
		1 to: lastFrameSamples do: [:j |
			finalFrame at: j put: (aSoundBuffer at: (i _ i + 1))].
		lastIncs _ self encodeFrames: 1 from: finalFrame at: 1 into: result at: 1 + increments second.
		increments _ Array with: increments first + lastIncs first
							with: increments second + lastIncs second].
	increments second < result size
		ifTrue: [^ result copyFrom: 1 to: increments second]
		ifFalse: [^ result]

]

{ #category : 'private' }
SoundCodec >> frameCount: aByteArray [
	"Compute the frame count for this byteArray.  This default computation will have to be overridden by codecs with variable frame sizes."

	| codeFrameSize |
	codeFrameSize _ self bytesPerEncodedFrame.
	(aByteArray size \\ codeFrameSize) = 0 ifFalse:
		[self error: 'encoded buffer is not an even multiple of the encoded frame size'].
	^ aByteArray size // codeFrameSize
]

{ #category : 'subclass responsibilities' }
SoundCodec >> reset [
	"Reset my encoding and decoding state. Optional. This default implementation does nothing."

]

{ #category : 'subclass responsibilities' }
SoundCodec >> samplesPerFrame [
	"Answer the number of sound samples per compression frame."

	self subclassResponsibility.

]
