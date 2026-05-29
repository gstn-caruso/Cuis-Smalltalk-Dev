"
Wraps a PositionableStream. Allows access to TIFF simple multi-byte types, remembering whether this TIFF is big-endian or little-endian.
By Martin McClure

Structure:
 stream				PositionableStream -- my underlying stream
 bigEndian			Boolean -- false if little-endian, true if big-endian
 compressionType	Integer -- currently supported: 1: no compression, 5 LZW compression

Only implements enough Stream protocol to let TIFFReadWriter and its cohorts to do their job.
"
Class {
	#name : 'TIFFStream',
	#superclass : 'Object',
	#instVars : [
		'stream',
		'bigEndian',
		'compressionType',
		'remainBitCount',
		'outCodes',
		'maxOutCodes',
		'outCount',
		'prefixTable',
		'suffixTable',
		'bitMask',
		'clearCode',
		'eoiCode',
		'freeCode',
		'codeSize',
		'maxCode',
		'finChar',
		'oldCode'
	],
	#category : 'Graphics-Files-Additional',
	#package : 'Graphics',
	#tag : 'Files-Additional'
}

{ #category : 'instance creation' }
TIFFStream class >> on: aPositionableStream bigEndian: aBoolean [

	"Answer an instance of the receiver for encoding and/or decoding TIFFs on the given."

	^ self new 
		on: aPositionableStream 
		bigEndian: aBoolean.

]

{ #category : 'LZW uncompressions' }
TIFFStream >> checkLZWCodeSize [

	(freeCode+1 > maxCode and: [ codeSize < 12 ]) ifTrue: [
		codeSize := codeSize + 1.
		maxCode := (1 bitShift: codeSize) - 1 ]
]

{ #category : 'accessing' }
TIFFStream >> compressionType: aNumber [
	compressionType _ aNumber.
	aNumber = 5 ifTrue: [
		self initializeLZWDecompression ]
]

{ #category : 'LZW uncompressions' }
TIFFStream >> initializeLZWDecompression [

	maxOutCodes := 4096.
	remainBitCount := 0.
	outCodes := ByteArray new: maxOutCodes + 1.
	outCount := 0.
	prefixTable := Array new: 4096.
	suffixTable := Array new: 4096.
	bitMask := (1 bitShift: 8) - 1
]

{ #category : 'accessing' }
TIFFStream >> isBigEndian [
	"Return true if I am a big-endian TIFF, false if I am little-endian."
	^ bigEndian.

]

{ #category : 'TIFF type access' }
TIFFStream >> newStrip [
	remainBitCount _ 0.
	self reInitializeLZWDecompression
]

{ #category : 'stream access' }
TIFFStream >> next: anInteger [

	"Answer the next anInteger elements of my stream's collection."
	^ stream next: anInteger.
]

{ #category : 'TIFF type access' }
TIFFStream >> nextByte [
	"Answer the next 8-bit unsigned quantity from the stream."

	^ stream next.
]

{ #category : 'TIFF type access' }
TIFFStream >> nextByteInBody [
	"Answer the next 8-bit unsigned quantity from the stream.
	Uncompress data if appropriate"
	compressionType = 5 ifTrue: [
		^self nextLZWUncompressedByte ].
	^ stream next
]

{ #category : 'LZW uncompressions' }
TIFFStream >> nextLZWCode [
	| integer readBitCount shiftCount byte |
	integer := 0.
	remainBitCount = 0 
		ifTrue: [
			readBitCount := 8.
			shiftCount := 0 ]
		ifFalse: [
			readBitCount := remainBitCount.
			shiftCount := remainBitCount - 8 ].
	[ readBitCount < codeSize ] whileTrue: [
		byte := self nextByte.
		byte == nil ifTrue: [ ^ eoiCode ].
		remainBitCount = 0 ifFalse: [
			byte _ byte bitAnd: (1 bitShift: remainBitCount)-1.
			remainBitCount _ 0 ].
		integer := (integer bitShift: 8) + byte.
		shiftCount := shiftCount + 8.
		readBitCount := readBitCount + 8 ].
	(remainBitCount := readBitCount - codeSize) = 0 
		ifTrue: [ byte := self nextByte ]
		ifFalse: [ byte := self peek ].
	byte == nil ifTrue: [ ^ eoiCode ].
	integer := (integer bitShift: 8) + byte.
	integer _ integer bitShift: remainBitCount negated.
	^integer
]

{ #category : 'LZW uncompressions' }
TIFFStream >> nextLZWUncompressedByte [
	"Answer the next 8-bit unsigned quantity from the stream."
	| answer |
	outCount = 0 ifTrue: [
		self readAdditionalLZWStuff ].
	
	answer _ outCodes at: outCount.
	outCount _ outCount - 1.
	^answer
]

{ #category : 'TIFF type access' }
TIFFStream >> nextUint16 [
	"Read a 16-bit unsigned quantity from the stream."

	^ stream nextUint16BigEndian: bigEndian
]

{ #category : 'TIFF type access' }
TIFFStream >> nextUint32 [
	"Read a 32-bit unsigned quantity from the stream."

	^ stream nextUint32BigEndian: bigEndian
]

{ #category : 'private' }
TIFFStream >> on: aPositionableStream bigEndian: aBoolean [

	"Make aPositionableStream be the stream I'm wrapping. Interpret it as big or little-endian according to aBoolean."
	stream _ aPositionableStream.
	bigEndian _ aBoolean.

]

{ #category : 'stream access' }
TIFFStream >> peek [

	"Answer the next byte of my underlying stream."
	^ stream peek.


]

{ #category : 'stream access' }
TIFFStream >> position [

	"Answer the current position of accessing the sequence of objects."
	^ stream position.
]

{ #category : 'stream access' }
TIFFStream >> position: anInteger  [

	"Set the current position for accessing the objects to be anInteger, as long 
	as anInteger is within the bounds of the receiver's contents. If it is not, 
	create an error notification."
	stream position: anInteger.
]

{ #category : 'LZW uncompressions' }
TIFFStream >> reInitializeLZWDecompression [
	clearCode := 1 bitShift: 8.
	eoiCode := clearCode + 1.
	freeCode := clearCode + 2.
	codeSize := 9.	
	maxCode := (1 bitShift: codeSize) - 1
]

{ #category : 'LZW uncompressions' }
TIFFStream >> readAdditionalLZWStuff [
	"Answer the next 8-bit unsigned quantity from the stream."
	| code curCode inCode |
	code := self nextLZWCode.
	code = eoiCode ifTrue: [
		^nil ].

	code = clearCode 
		ifTrue: [
			self reInitializeLZWDecompression.
			curCode := oldCode := code := self nextLZWCode.
			finChar := curCode]
		ifFalse: [
			curCode := inCode := code.
			curCode >= freeCode ifTrue: [
				curCode := oldCode.
				outCodes 
					at: (outCount := outCount + 1)
					put: finChar ].
			[ curCode > bitMask ] whileTrue: [
				outCount > maxOutCodes ifTrue: [ ^ self error: 'corrupt LZW TIFF file (OutCount)' ].
				outCodes 
					at: (outCount := outCount + 1)
					put: (suffixTable at: curCode + 1).
				curCode := prefixTable at: curCode + 1 ].
			finChar := curCode.
			prefixTable 
				at: freeCode + 1
				put: oldCode.
			suffixTable 
				at: freeCode + 1
				put: finChar.
			oldCode := inCode.
			freeCode := freeCode + 1.
			self checkLZWCodeSize ].
	outCodes 
		at: (outCount := outCount + 1)
		put: finChar
]

{ #category : 'stream access' }
TIFFStream >> reset [
	"Goto start."
	stream reset
]

{ #category : 'stream access' }
TIFFStream >> size [

	"Answer the size of my underlying stream."
	^ stream size.


]

{ #category : 'stream access' }
TIFFStream >> skip: anInteger [
	"Set the receiver's position to be the current position+anInteger."

	stream skip: anInteger.
]
