Class {
	#name : 'ZipConstants',
	#superclass : 'SharedPool',
	#classVars : [
		'BaseDistance',
		'BaseLength',
		'BitLengthOrder',
		'DistanceCodes',
		'DynamicBlock',
		'EndBlock',
		'ExtraBitLengthBits',
		'ExtraDistanceBits',
		'ExtraLengthBits',
		'FixedBlock',
		'FixedDistanceTree',
		'FixedLiteralTree',
		'HashBits',
		'HashMask',
		'HashShift',
		'MatchLengthCodes',
		'MaxBitLengthBits',
		'MaxBitLengthCodes',
		'MaxBits',
		'MaxDistCodes',
		'MaxDistance',
		'MaxLengthCodes',
		'MaxLiteralCodes',
		'MaxMatch',
		'MinMatch',
		'NumLiterals',
		'Repeat11To138',
		'Repeat3To10',
		'Repeat3To6',
		'StoredBlock',
		'WindowMask',
		'WindowSize'
	],
	#category : 'Compression-System',
	#package : 'Compression',
	#tag : 'System'
}

{ #category : 'pool initialization' }
ZipConstants class >> initialize [
	"ZipConstants initialize"
	self initializeDeflateConstants.
	self initializeWriteStreamConstants.
]

{ #category : 'pool initialization' }
ZipConstants class >> initializeDeflateConstants [

	WindowSize _ 16r8000.
	WindowMask _ WindowSize - 1.
	MaxDistance _ WindowSize.

	MinMatch _ 3.
	MaxMatch _ 258.

	HashBits _ 15.
	HashMask _ (1 << HashBits) - 1.
	HashShift _ (HashBits + MinMatch - 1) // MinMatch.

]

{ #category : 'pool initialization' }
ZipConstants class >> initializeDistanceCodes [
	| dist |
	BaseDistance _ WordArray new: MaxDistCodes.
	DistanceCodes _ WordArray new: 512.
	dist _ 0.
	1 to: 16 do:[:code|
		BaseDistance at: code put: dist.
		1 to: (1 bitShift: (ExtraDistanceBits at: code)) do:[:n|
			dist _ dist + 1.
			DistanceCodes at: dist put: code-1]].
	dist = 256 ifFalse:[self error:'Whoops?!'].
	dist _ dist >> 7.
	17 to: MaxDistCodes do:[:code|
		BaseDistance at: code put: dist << 7.
		1 to: (1 bitShift: (ExtraDistanceBits at: code)-7) do:[:n|
			dist _ dist + 1.
			DistanceCodes at: 256 + dist put: code-1]].

]

{ #category : 'pool initialization' }
ZipConstants class >> initializeExtraBits [
	ExtraLengthBits _ 
		WordArray withAll: #(0 0 0 0 0 0 0 0 1 1 1 1 2 2 2 2 3 3 3 3 4 4 4 4 5 5 5 5 0).
	ExtraDistanceBits _ 
		WordArray withAll: #(0 0 0 0 1 1 2 2 3 3 4 4 5 5 6 6 7 7 8 8 9 9 10 10 11 11 12 12 13 13).
	ExtraBitLengthBits _ 
		WordArray withAll: #(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 2 3 7).
	BitLengthOrder _
		WordArray withAll: #(16 17 18 0 8 7 9 6 10 5 11 4 12 3 13 2 14 1 15).

]

{ #category : 'pool initialization' }
ZipConstants class >> initializeFixedTrees [
	"ZipWriteStream initializeFixedTrees"
	| counts nodes |
	FixedLiteralTree _ ZipEncoderTree new.
	FixedLiteralTree maxCode: 287.
	counts _ WordArray new: MaxBits+1.
	counts at: 7+1 put: 24.
	counts at: 8+1 put: 144+8.
	counts at: 9+1 put: 112.
	nodes _ Array new: 288.
	1 to: 288 do:[:i| nodes at: i put: (ZipEncoderNode value: i-1 frequency: 0 height: 0)].
	0 to: 143 do:[:i| (nodes at: i+1) setBitLengthTo: 8].
	144 to: 255 do:[:i| (nodes at: i+1) setBitLengthTo: 9].
	256 to: 279 do:[:i| (nodes at: i+1) setBitLengthTo: 7].
	280 to: 287 do:[:i| (nodes at: i+1) setBitLengthTo: 8].
	FixedLiteralTree buildCodes: nodes counts: counts maxDepth: MaxBits.
	FixedLiteralTree setValuesFrom: nodes.

	FixedDistanceTree _ ZipEncoderTree new.
	FixedDistanceTree maxCode: MaxDistCodes.
	FixedDistanceTree
		bitLengths: ((WordArray new: MaxDistCodes+1) atAllPut: 5)
		codes: ((0 to: MaxDistCodes) collect:[:i| FixedDistanceTree reverseBits: i length: 5]).
]

{ #category : 'pool initialization' }
ZipConstants class >> initializeLengthCodes [
	| length |
	BaseLength _ WordArray new: MaxLengthCodes.
	MatchLengthCodes _ WordArray new: MaxMatch - MinMatch + 1.
	length _ 0.
	1 to: MaxLengthCodes - 1 do:[:code|
		BaseLength at: code put: length.
		1 to: (1 bitShift: (ExtraLengthBits at: code)) do:[:n|
			length _ length + 1.
			MatchLengthCodes at: length put: NumLiterals + code]].

]

{ #category : 'pool initialization' }
ZipConstants class >> initializeWriteStreamConstants [

	MaxBits _ 15.
	MaxBitLengthBits _ 7.
	EndBlock _ 256.

	StoredBlock _ 0.
	FixedBlock _ 1.
	DynamicBlock _ 2.

	NumLiterals _ 256.
	MaxLengthCodes _ 29.
	MaxDistCodes _ 30.
	MaxBitLengthCodes _ 19.
	MaxLiteralCodes _ NumLiterals + MaxLengthCodes + 1. "+ End of Block"

	Repeat3To6 _ 16. "Repeat previous bit length 3-6 times (2 bits repeat count)"
	Repeat3To10 _ 17. "Repeat previous bit length 3-10 times (3 bits repeat count)"
	Repeat11To138 _ 18. "Repeat previous bit length 11-138 times (7 bits repeat count)"

	self initializeExtraBits.
	self initializeLengthCodes.
	self initializeDistanceCodes.
	self initializeFixedTrees.

]
