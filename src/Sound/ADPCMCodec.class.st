"
This is a simple ADPCM (adapative delta pulse code modulation) codec. This is a general audio codec that compresses speech, music, or sound effects equally well, and works at any sampling rate (i.e., it contains no frequency-sensitive filters). It compresses 16-bit sample data down to 5, 4, 3, or 2 bits per sample, with lower fidelity and increased noise at the lowest bit rates. Although it does not deliver state-of-the-art compressions, the algorithm is small, simple, and extremely fast, since the encode/decode primitives have been translated into C primitives.

This codec will also encode and decode all Flash .swf file compressed sound formats, both mono and stereo. (Note: stereo Flash compression is not yet implemented, but stereo decompression works.)

"
Class {
	#name : 'ADPCMCodec',
	#superclass : 'SoundCodec',
	#instVars : [
		'predicted',
		'index',
		'deltaSignMask',
		'deltaValueMask',
		'deltaValueHighBit',
		'frameSizeMask',
		'currentByte',
		'bitPosition',
		'byteIndex',
		'encodedBytes',
		'samples',
		'rightSamples',
		'sampleIndex',
		'bitsPerSample',
		'stepSizeTable',
		'indexTable'
	],
	#category : 'Sound-Synthesis',
	#package : 'Sound',
	#tag : 'Synthesis'
}

{ #category : 'instance creation' }
ADPCMCodec class >> new [

	^ super new
		initializeForBitsPerSample: 4
		samplesPerFrame: 0.

]

{ #category : 'instance creation' }
ADPCMCodec class >> newBitsPerSample: bitsPerSample [

	^ super new
		initializeForBitsPerSample: bitsPerSample
		samplesPerFrame: 0.

]

{ #category : 'primitive generation' }
ADPCMCodec class >> translatedPrimitives [
	"Answer a string containing the translated C code for my primitives."
	"Note: This code currently must be hand-edited to remove several methods that are inlined (thus not needed) but not pruned out by the ST-to-C translator."

	^#(
		(ADPCMCodec privateDecodeMono:)
		(ADPCMCodec privateDecodeStereo:)
		(ADPCMCodec privateEncodeMono:)
		(ADPCMCodec privateEncodeStereo:)
		(ADPCMCodec indexForDeltaFrom:to:)
		(ADPCMCodec nextBits:)
		(ADPCMCodec nextBits:put:))

]

{ #category : 'codec stuff' }
ADPCMCodec >> bytesPerEncodedFrame [
	"Answer the number of bytes required to hold one frame of compressed sound data."
	"Note: When used as a normal codec, the frame size is always 8 samples which results in (8 * bitsPerSample) / 8 = bitsPerSample bytes."

	| bitCount |
	frameSizeMask = 0 ifTrue: [^ bitsPerSample].
	"Following assumes mono:"
	bitCount _ 16 + 6 + ((self samplesPerFrame - 1) * bitsPerSample).
	^ (bitCount + 7) // 8

]

{ #category : 'codec stuff' }
ADPCMCodec >> compressAndDecompress: aSound [
	"Compress and decompress the given sound. Overridden to use same bits per sample for both compressing and decompressing."

	| compressed decoder |
	compressed _ self compressSound: aSound.
	decoder _ self class new
		initializeForBitsPerSample: bitsPerSample
		samplesPerFrame: 0.
	^ decoder decompressSound: compressed


]

{ #category : 'private' }
ADPCMCodec >> decode: aByteArray bitsPerSample: bits [

	^ self
		decode: aByteArray
		sampleCount: (aByteArray size * 8) // bits
		bitsPerSample: bits
		frameSize: 0
		stereo: false

]

{ #category : 'private' }
ADPCMCodec >> decode: aByteArray sampleCount: count bitsPerSample: bits frameSize: frameSize stereo: stereoFlag [

	self initializeForBitsPerSample: bits samplesPerFrame: frameSize.
	encodedBytes _ aByteArray.
	byteIndex _ 0.
	bitPosition _ 0.
	currentByte _ 0.
	stereoFlag
		ifTrue: [
			self resetForStereo.
			samples _ SoundBuffer newMonoSampleCount: count.
			rightSamples _ SoundBuffer newMonoSampleCount: count.
			sampleIndex _ 0.
			self privateDecodeStereo: count.
			^ Array with: samples with: rightSamples]
		ifFalse: [
			samples _ SoundBuffer newMonoSampleCount: count.
			sampleIndex _ 0.
			self privateDecodeMono: count.
			^ samples]

]

{ #category : 'private' }
ADPCMCodec >> decodeFlash: aByteArray sampleCount: sampleCount stereo: stereoFlag [

	| bits |
	encodedBytes _ aByteArray.
	byteIndex _ 0.
	bitPosition _ 0.
	currentByte _ 0.
	bits _ 2 + (self nextBits: 2).  "bits per sample"
	self initializeForBitsPerSample: bits samplesPerFrame: 4096.
	stereoFlag
		ifTrue: [
			self resetForStereo.
			samples _ SoundBuffer newMonoSampleCount: sampleCount.
			rightSamples _ SoundBuffer newMonoSampleCount: sampleCount.
			sampleIndex _ 0.
			self privateDecodeStereo: sampleCount.
			^ Array with: samples with: rightSamples]
		ifFalse: [
			samples _ SoundBuffer newMonoSampleCount: sampleCount.
			sampleIndex _ 0.
			self privateDecodeMono: sampleCount.
			^ Array with: samples].

]

{ #category : 'codec stuff' }
ADPCMCodec >> decodeFrames: frameCount from: srcByteArray at: srcIndex into: dstSoundBuffer at: dstIndex [
	"Decode the given number of monophonic frames starting at the given index in the given ByteArray of compressed sound data and storing the decoded samples into the given SoundBuffer starting at the given destination index. Answer a pair containing the number of bytes of compressed data consumed and the number of decompressed samples produced."
	"Note: Assume that the sender has ensured that the given number of frames will not exhaust either the source or destination buffers."

	encodedBytes _ srcByteArray.
	byteIndex _ srcIndex - 1.
	bitPosition _ 0.
	currentByte _ 0.
	samples _ dstSoundBuffer.
	sampleIndex _ dstIndex - 1.
	self privateDecodeMono: (frameCount * self samplesPerFrame).
	^ Array with: (byteIndex - (srcIndex - 1)) with: (sampleIndex - (dstIndex - 1))

]

{ #category : 'private' }
ADPCMCodec >> encode: aSoundBuffer bitsPerSample: bits [

	^ self
		encodeLeft: aSoundBuffer
		right: nil
		bitsPerSample: bits
		frameSize: 0
		forFlash: false

]

{ #category : 'private' }
ADPCMCodec >> encodeFlashLeft: leftSoundBuffer right: rightSoundBuffer bitsPerSample: bits [

	^ self
		encodeLeft: leftSoundBuffer
		right: rightSoundBuffer
		bitsPerSample: bits
		frameSize: 4096
		forFlash: true

]

{ #category : 'codec stuff' }
ADPCMCodec >> encodeFrames: frameCount from: srcSoundBuffer at: srcIndex into: dstByteArray at: dstIndex [
	"Encode the given number of frames starting at the given index in the given monophonic SoundBuffer and storing the encoded sound data into the given ByteArray starting at the given destination index. Encode only as many complete frames as will fit into the destination. Answer a pair containing the number of samples consumed and the number of bytes of compressed data produced."
	"Note: Assume that the sender has ensured that the given number of frames will not exhaust either the source or destination buffers."

	samples _ srcSoundBuffer.
	sampleIndex _ srcIndex - 1.
	encodedBytes _ dstByteArray.
	byteIndex _ dstIndex - 1.
	bitPosition _ 0.
	currentByte _ 0.
	self privateEncodeMono: (frameCount * self samplesPerFrame).
	^ Array with: frameCount with: (byteIndex - (dstIndex - 1))

]

{ #category : 'private' }
ADPCMCodec >> encodeLeft: leftSoundBuffer right: rightSoundBuffer bitsPerSample: bits frameSize: frameSize forFlash: flashFlag [

	| stereoFlag sampleCount sampleBitCount bitCount |
	self initializeForBitsPerSample: bits samplesPerFrame: frameSize.
	stereoFlag _ rightSoundBuffer notNil.
	sampleCount _ leftSoundBuffer monoSampleCount.
	stereoFlag
		ifTrue: [sampleBitCount _ 2 * (sampleCount * bitsPerSample)]
		ifFalse: [sampleBitCount _ sampleCount * bitsPerSample].
	bitCount _ sampleBitCount +
		(self headerBitsForSampleCount: sampleCount stereoFlag: stereoFlag).

	encodedBytes _ ByteArray new: ((bitCount / 8) ceiling roundUpTo: self bytesPerEncodedFrame).
	byteIndex _ 0.
	bitPosition _ 0.
	currentByte _ 0.
	flashFlag ifTrue: [self nextBits: 2 put: bits - 2].
	stereoFlag
		ifTrue: [
			samples _ Array with: leftSoundBuffer with: rightSoundBuffer.
			sampleIndex _ Array with: 0 with: 0.
			self privateEncodeStereo: sampleCount]
		ifFalse: [
			samples _ leftSoundBuffer.
			sampleIndex _ 0.
			self privateEncodeMono: sampleCount].

	^ encodedBytes

]

{ #category : 'private' }
ADPCMCodec >> headerBitsForSampleCount: sampleCount stereoFlag: stereoFlag [
	"Answer the number of extra header bits required for the given number of samples. This will be zero if I am not using frame headers."

	| frameCount bitsPerHeader |
	frameSizeMask = 0 ifTrue: [^ 0].
	frameCount _ (sampleCount / self samplesPerFrame) ceiling.
	bitsPerHeader _ 16 + 6.
	stereoFlag ifTrue: [bitsPerHeader _ 2 * bitsPerHeader].
	^ frameCount * bitsPerHeader

]

{ #category : 'private' }
ADPCMCodec >> indexForDeltaFrom: thisSample to: nextSample [
	"Answer the best index to use for the difference between the given samples."
	"Details: Scan stepSizeTable for the first entry >= the absolute value of the difference between sample values. Since indexes are zero-based, the index used during decoding will be the one in the following stepSizeTable entry. Since the index field of a Flash frame header is only six bits, the maximum index value is 63."
	"Note: Since there does not appear to be any documentation of how Flash acutally computes the indices used in its frame headers, this algorithm was guessed by reverse-engineering the Flash ADPCM decoder."

	| diff bestIndex |
	self inline: true.

	diff _ nextSample - thisSample.
	diff < 0 ifTrue: [diff _ 0 - diff].
	bestIndex _ 63.
	1 to: 62 do: [:j |
		bestIndex = 63 ifTrue: [
			(stepSizeTable at: j) >= diff ifTrue: [bestIndex _ j]]].
	^ bestIndex

]

{ #category : 'private' }
ADPCMCodec >> initializeForBitsPerSample: sampleBits samplesPerFrame: frameSize [

	self resetForMono.
	stepSizeTable _ #(7 8 9 10 11 12 13 14 16 17 19 21 23 25 28 31 34 37 41 45 50 55 60 66 73 80 88 97 107 118 130 143 157 173 190 209 230 253 279 307 337 371 408 449 494 544 598 658 724 796 876 963 1060 1166 1282 1411 1552 1707 1878 2066 2272 2499 2749 3024 3327 3660 4026 4428 4871 5358 5894 6484 7132 7845 8630 9493 10442 11487 12635 13899 15289 16818 18500 20350 22385 24623 27086 29794 32767).

	indexTable _ nil.
	sampleBits = 2 ifTrue: [
		indexTable _ #(-1 2)].
	sampleBits = 3 ifTrue: [
		indexTable _ #(-1 -1 2 4)].
	sampleBits = 4 ifTrue: [
		indexTable _ #(-1 -1 -1 -1 2 4 6 8)].
	sampleBits = 5 ifTrue: [
		indexTable _ #(-1 -1 -1 -1 -1 -1 -1 -1 1 2 4 6 8 10 13 16)].
	indexTable ifNil: [self error: 'unimplemented bits/sample'].

	bitsPerSample _ sampleBits.
	deltaSignMask _ 1 bitShift: bitsPerSample - 1.
	deltaValueMask _ deltaSignMask - 1.
	deltaValueHighBit _ deltaSignMask / 2.

	frameSize <= 1
		ifTrue: [frameSizeMask _ 0]
		ifFalse: [
			(frameSize = (1 bitShift: frameSize highBit - 1))
				ifFalse: [self error: 'frameSize must be a power of two'].
			frameSizeMask _ frameSize - 1].

	"keep as SoundBuffer to allow fast access from primitive"
	indexTable _ SoundBuffer fromArray: indexTable.
	stepSizeTable _ SoundBuffer fromArray: stepSizeTable.

]

{ #category : 'bit streaming' }
ADPCMCodec >> nextBits: n [
	"Answer the next n bits of my bit stream as an unsigned integer."

	| result remaining shift |
	self inline: true.

	result _ 0.
	remaining _ n.
	[true] whileTrue: [
		shift _ remaining - bitPosition.
		result _ result + (currentByte bitShift: shift).
		shift > 0
			ifTrue: [  "consumed currentByte buffer; fetch next byte"
				remaining _ remaining - bitPosition.			
				currentByte _ (encodedBytes at: (byteIndex _ byteIndex + 1)).
				bitPosition _ 8]
			ifFalse: [  "still some bits left in currentByte buffer"
				bitPosition _ bitPosition - remaining.
				"mask out the consumed bits:"
				currentByte _ currentByte bitAnd: (255 bitShift: (bitPosition - 8)).
				^ result]].

]

{ #category : 'bit streaming' }
ADPCMCodec >> nextBits: n put: anInteger [
	"Write the next n bits to my bit stream."

	| buf bufBits bitsAvailable shift |
	self inline: true.

	buf _ anInteger.
	bufBits _ n.
	[true] whileTrue: [
		bitsAvailable _ 8 - bitPosition.
		shift _ bitsAvailable - bufBits.  "either left or right shift"
		"append high bits of buf to end of currentByte:"
		currentByte _ currentByte + (buf bitShift: shift).
		shift < 0
			ifTrue: [  "currentByte buffer filled; output it"
				encodedBytes at: (byteIndex _ byteIndex + 1) put: currentByte.
				bitPosition _ 0.
				currentByte _ 0.
				"clear saved high bits of buf:"
				buf _ buf bitAnd: (1 bitShift: 0 - shift) - 1.
				bufBits _ bufBits - bitsAvailable]
			ifFalse: [  "still some bits available in currentByte buffer"
				bitPosition _ bitPosition + bufBits.
				^ self]].

]

{ #category : 'private' }
ADPCMCodec >> privateDecodeMono: count [

	| delta step predictedDelta bit |
	<primitive: 'primitiveDecodeMono' module: 'ADPCMCodecPlugin'>
	self var: #stepSizeTable declareC: 'short int *stepSizeTable'.
	self var: #indexTable declareC: 'short int *indexTable'.
	self var: #samples declareC: 'short int *samples'.
	self var: #encodedBytes declareC: 'unsigned char *encodedBytes'.

	1 to: count do: [:i |
		(i bitAnd: frameSizeMask) = 1
			ifTrue: [  "start of frame; read frame header"
				predicted _ self nextBits: 16.
				predicted > 32767 ifTrue: [predicted _ predicted - 65536].
				index _ self nextBits: 6.
				samples at: (sampleIndex _ sampleIndex + 1) put: predicted]
			ifFalse: [
				delta _ self nextBits: bitsPerSample.
				step _ stepSizeTable at: index + 1.
				predictedDelta _ 0.
				bit _ deltaValueHighBit.
				[bit > 0] whileTrue: [
					(delta bitAnd: bit) > 0 ifTrue: [predictedDelta _ predictedDelta + step].
					step _ step bitShift: -1.
					bit _ bit bitShift: -1].
				predictedDelta _ predictedDelta + step.

				(delta bitAnd: deltaSignMask) > 0
					ifTrue: [predicted _ predicted - predictedDelta]
					ifFalse: [predicted _ predicted + predictedDelta].
				predicted > 32767
					ifTrue: [predicted _ 32767]
					ifFalse: [predicted < -32768 ifTrue: [predicted _ -32768]].

				index _ index + (indexTable at: (delta bitAnd: deltaValueMask) + 1).
				index < 0
					ifTrue: [index _ 0]
					ifFalse: [index > 88 ifTrue: [index _ 88]].

				samples at: (sampleIndex _ sampleIndex + 1) put: predicted]].

]

{ #category : 'private' }
ADPCMCodec >> privateDecodeStereo: count [

	| predictedLeft predictedRight indexLeft indexRight deltaLeft deltaRight
	 stepLeft stepRight predictedDeltaLeft predictedDeltaRight bit |

	<primitive: 'primitiveDecodeStereo' module: 'ADPCMCodecPlugin'>
	self var: #stepSizeTable declareC: 'short int *stepSizeTable'.
	self var: #indexTable declareC: 'short int *indexTable'.
	self var: #samples declareC: 'short int *samples'.
	self var: #encodedBytes declareC: 'unsigned char *encodedBytes'.
	self var: #rightSamples declareC: 'short int *rightSamples'.
	self var: #predicted declareC: 'short int *predicted'.
	self var: #index declareC: 'short int *index'.

	"make local copies of decoder state variables"
	predictedLeft _ predicted at: 1.
	predictedRight _ predicted at: 2.
	indexLeft _ index at: 1.
	indexRight _ index at: 2.

	1 to: count do: [:i |
		(i bitAnd: frameSizeMask) = 1
			ifTrue: [  "start of frame; read frame header"
				predictedLeft _ self nextBits: 16.
				indexLeft _ self nextBits: 6.
				predictedRight _ self nextBits: 16.
				indexRight _ self nextBits: 6.
				predictedLeft > 32767 ifTrue: [predictedLeft _ predictedLeft - 65536].
				predictedRight > 32767 ifTrue: [predictedRight _ predictedRight - 65536].
				samples at: (sampleIndex _ sampleIndex + 1) put: predictedLeft.
				rightSamples at: sampleIndex put: predictedRight]
			ifFalse: [
				deltaLeft _ self nextBits: bitsPerSample.
				deltaRight _ self nextBits: bitsPerSample.
				stepLeft _ stepSizeTable at: indexLeft + 1.
				stepRight _ stepSizeTable at: indexRight + 1.
				predictedDeltaLeft _ predictedDeltaRight _ 0.
				bit _ deltaValueHighBit.
				[bit > 0] whileTrue: [
					(deltaLeft bitAnd: bit) > 0 ifTrue: [
						predictedDeltaLeft _ predictedDeltaLeft + stepLeft].
					(deltaRight bitAnd: bit) > 0 ifTrue: [
						predictedDeltaRight _ predictedDeltaRight + stepRight].
					stepLeft _ stepLeft bitShift: -1.
					stepRight _ stepRight bitShift: -1.
					bit _ bit bitShift: -1].
				predictedDeltaLeft _ predictedDeltaLeft + stepLeft.
				predictedDeltaRight _ predictedDeltaRight + stepRight.

				(deltaLeft bitAnd: deltaSignMask) > 0
					ifTrue: [predictedLeft _ predictedLeft - predictedDeltaLeft]
					ifFalse: [predictedLeft _ predictedLeft + predictedDeltaLeft].
				(deltaRight bitAnd: deltaSignMask) > 0
					ifTrue: [predictedRight _ predictedRight - predictedDeltaRight]
					ifFalse: [predictedRight _ predictedRight + predictedDeltaRight].
				predictedLeft > 32767
					ifTrue: [predictedLeft _ 32767]
					ifFalse: [predictedLeft < -32768 ifTrue: [predictedLeft _ -32768]].
				predictedRight > 32767
					ifTrue: [predictedRight _ 32767]
					ifFalse: [predictedRight < -32768 ifTrue: [predictedRight _ -32768]].

				indexLeft _ indexLeft + (indexTable at: (deltaLeft bitAnd: deltaValueMask) + 1).
				indexLeft < 0
					ifTrue: [indexLeft _ 0]
					ifFalse: [indexLeft > 88 ifTrue: [indexLeft _ 88]].
				indexRight _ indexRight + (indexTable at: (deltaRight bitAnd: deltaValueMask) + 1).
				indexRight < 0
					ifTrue: [indexRight _ 0]
					ifFalse: [indexRight > 88 ifTrue: [indexRight _ 88]].

				samples at: (sampleIndex _ sampleIndex + 1) put: predictedLeft.
				rightSamples at: sampleIndex put: predictedRight]].

	"save local copies of decoder state variables"
	predicted at: 1 put: predictedLeft.
	predicted at: 2 put: predictedRight.
	index at: 1 put: indexLeft.
	index at: 2 put: indexRight.

]

{ #category : 'private' }
ADPCMCodec >> privateEncodeMono: count [

	| step sign diff delta predictedDelta bit p |
	<primitive: 'primitiveEncodeMono' module: 'ADPCMCodecPlugin'>
	self var: #stepSizeTable declareC: 'short int *stepSizeTable'.
	self var: #indexTable declareC: 'short int *indexTable'.
	self var: #samples declareC: 'short int *samples'.
	self var: #encodedBytes declareC: 'unsigned char *encodedBytes'.

	step _ stepSizeTable at: 1.
	1 to: count do: [:i |
		(i bitAnd: frameSizeMask) = 1 ifTrue: [
			predicted _ samples at: (sampleIndex _ sampleIndex + 1).
			(p _ predicted) < 0 ifTrue: [p _ p + 65536].
			self nextBits: 16 put: p.
			i < count ifTrue: [
				index _ self indexForDeltaFrom: predicted to: (samples at: sampleIndex + 1)].
			self nextBits: 6 put: index.
		] ifFalse: [
			"compute sign and magnitude of difference from the predicted sample"
			sign _ 0.
			diff _ (samples at: (sampleIndex _ sampleIndex + 1)) - predicted.
			diff < 0 ifTrue: [
				sign _ deltaSignMask.
				diff _ 0 - diff].

			"Compute encoded delta and the difference that this will cause in the predicted sample value during decoding. Note that this code approximates:
				delta _ (4 * diff) / step.
				predictedDelta _ ((delta + 0.5) * step) / 4;
			but in the shift step bits are dropped. Thus, even if you have fast mul/div hardware you cannot use it since you would get slightly different bits what than the algorithm defines."
			delta _ 0.
			predictedDelta _ 0.
			bit _ deltaValueHighBit.
			[bit > 0] whileTrue: [
				diff >= step ifTrue: [
					delta _ delta + bit.
					predictedDelta _ predictedDelta + step.
					diff _ diff - step].
				step _ step bitShift: -1.
				bit _ bit bitShift: -1].
			predictedDelta _ predictedDelta + step.

			"compute and clamp new prediction"
			sign > 0
				ifTrue: [predicted _ predicted - predictedDelta]
				ifFalse: [predicted _ predicted + predictedDelta].
			predicted > 32767
				ifTrue: [predicted _ 32767]
				ifFalse: [predicted < -32768 ifTrue: [predicted _ -32768]].

			"compute new index and step values"
			index _ index + (indexTable at: delta + 1).
			index < 0
				ifTrue: [index _ 0]
				ifFalse: [index > 88 ifTrue: [index _ 88]].
			step _ stepSizeTable at: index + 1.

			"output encoded, signed delta"
			self nextBits: bitsPerSample put: (sign bitOr: delta)]].

	bitPosition > 0 ifTrue: [  "flush the last output byte, if necessary"
		encodedBytes at: (byteIndex _ byteIndex + 1) put: currentByte].

]

{ #category : 'private' }
ADPCMCodec >> privateEncodeStereo: count [

	<primitive: 'primitiveEncodeStereo' module: 'ADPCMCodecPlugin'>
	"not yet implemented"
	self inline: false.
	self success: false.
]

{ #category : 'codec stuff' }
ADPCMCodec >> reset [

	self resetForMono.

]

{ #category : 'codec stuff' }
ADPCMCodec >> resetForMono [
	"Reset my encoding and decoding state for mono."

	predicted _ 0.
	index _ 0.

]

{ #category : 'codec stuff' }
ADPCMCodec >> resetForStereo [
	"Reset my encoding and decoding state for stereo."

	"keep state as SoundBuffers to allow fast access from primitive"
	predicted _ SoundBuffer new: 2.
	index _ SoundBuffer new: 2.

]

{ #category : 'codec stuff' }
ADPCMCodec >> samplesPerFrame [
	"Answer the number of sound samples per compression frame."

	frameSizeMask > 0 ifTrue: [^ frameSizeMask + 1].
	^ 8  "frame size when there are no running headers"

]
