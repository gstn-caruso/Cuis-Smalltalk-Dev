Class {
	#name : 'ZipEncoder',
	#superclass : 'WriteStream',
	#instVars : [
		'bitBuffer',
		'bitPosition',
		'encodedStream'
	],
	#pools : [
		'ZipConstants'
	],
	#category : 'Compression-System',
	#package : 'Compression',
	#tag : 'System'
}

{ #category : 'accessing' }
ZipEncoder >> bitPosition [
	^encodedStream position + position * 8 + bitPosition.
]

{ #category : 'initialization' }
ZipEncoder >> close [
	self flush.
	encodedStream close.
]

{ #category : 'initialization' }
ZipEncoder >> commit [
	encodedStream next: position putAll: collection.
	position _ readLimit _ 0.
]

{ #category : 'accessing' }
ZipEncoder >> encodedStream [
	^encodedStream
]

{ #category : 'initialization' }
ZipEncoder >> flush [
	self flushBits.
	self commit.
]

{ #category : 'initialization' }
ZipEncoder >> flushBits [
	"Flush currently unsent bits"
	[bitPosition > 0] whileTrue:[
		self nextBytePut: (bitBuffer bitAnd: 255).
		bitBuffer _ bitBuffer bitShift: -8.
		bitPosition _ bitPosition - 8].
	bitPosition _ 0.
]

{ #category : 'accessing' }
ZipEncoder >> nextBits: nBits put: value [
	"Store a value of nBits"
	"self assert:[value >= 0 and:[(1 bitShift: nBits) > value]]."
	bitBuffer _ bitBuffer bitOr: (value bitShift: bitPosition).
	bitPosition _ bitPosition + nBits.
	[bitPosition >= 8] whileTrue:[
		self nextBytePut: (bitBuffer bitAnd: 255).
		bitBuffer _ bitBuffer bitShift: -8.
		bitPosition _ bitPosition - 8].
]

{ #category : 'accessing' }
ZipEncoder >> nextBytePut: anObject  [
	"Primitive. Insert the argument at the next position in the Stream
	represented by the receiver. Fail if the collection of this stream is not an
	Array or a String. Fail if the stream is positioned at its end, or if the
	position is out of bounds in the collection. Fail if the argument is not
	of the right type for the collection. Optional. See Object documentation
	whatIsAPrimitive."

	<primitive: 66>
	position >= writeLimit
		ifTrue: [^ self pastEndPut: anObject]
		ifFalse: 
			[position _ position + 1.
			^collection at: position put: anObject]
]

{ #category : 'initialization' }
ZipEncoder >> on: aCollectionOrStream [
	(aCollectionOrStream is: #Stream)
		ifTrue:[encodedStream _ aCollectionOrStream]
		ifFalse:[	encodedStream _ WriteStream on: aCollectionOrStream].
	super on: (ByteArray new: 4096).
	bitPosition _ bitBuffer _ 0.
]

{ #category : 'private' }
ZipEncoder >> pastEndPut: anObject [
	"Flush the current buffer and store the new object at the beginning"
	self commit.
	^self nextBytePut: anObject asInteger
]

{ #category : 'private' }
ZipEncoder >> privateSendBlock: literalStream with: distanceStream with: litTree with: distTree [
	"Send the current block using the encodings from the given literal/length and distance tree"
	| lit dist code extra sum |
	<primitive: 'primitiveZipSendBlock' module: 'ZipPlugin'>
	sum _ 0.
	[lit _ literalStream next.
	dist _ distanceStream next.
	lit == nil] whileFalse:[
		dist = 0 ifTrue:["lit is a literal"
			sum _ sum + 1.
			self nextBits: (litTree bitLengthAt: lit)
				put: (litTree codeAt: lit).
		] ifFalse:["lit is match length"
			sum _ sum + lit + MinMatch.
			code _ (MatchLengthCodes at: lit + 1).
			self nextBits: (litTree bitLengthAt: code)
				put: (litTree codeAt: code).
			extra _ ExtraLengthBits at: code-NumLiterals.
			extra = 0 ifFalse:[
				lit _ lit - (BaseLength at: code-NumLiterals).
				self nextBits: extra put: lit.
			].
			dist _ dist - 1.
			dist < 256
				ifTrue:[code _ DistanceCodes at: dist + 1]
				ifFalse:[code _ DistanceCodes at: 257 + (dist bitShift: -7)].
			"self assert:[code < MaxDistCodes]."
			self nextBits: (distTree bitLengthAt: code)
				put: (distTree codeAt: code).
			extra _ ExtraDistanceBits at: code+1.
			extra = 0 ifFalse:[
				dist _ dist - (BaseDistance at: code+1).
				self nextBits: extra put: dist.
			].
		].
	].
	^sum
]

{ #category : 'block encoding' }
ZipEncoder >> sendBlock: literalStream with: distanceStream with: litTree with: distTree [
	"Send the current block using the encodings from the given literal/length and distance tree"
	| result |
	result _ 0.
	[literalStream atEnd] whileFalse:[
		result _ result + (self privateSendBlock: literalStream
						with: distanceStream with: litTree with: distTree).
		self commit.
	].
	self nextBits: (litTree bitLengthAt: EndBlock) put: (litTree codeAt: EndBlock).
	^result
]
