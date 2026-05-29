Class {
	#name : 'ZLibReadStream',
	#superclass : 'FastInflateStream',
	#category : 'Compression-System',
	#package : 'Compression',
	#tag : 'System'
}

{ #category : 'initialization' }
ZLibReadStream >> on: aCollection from: firstIndex to: lastIndex [
	"Check the header of the ZLib stream."
	| method byte |
	super on: aCollection from: firstIndex to: lastIndex.
	crc _ 1.
	method _ self nextBits: 8.
	(method bitAnd: 15) = 8 ifFalse:[^self error:'Unknown compression method'].
	(method bitShift: -4) + 8 > 15 ifTrue:[^self error:'Invalid window size'].
	byte _ self nextBits: 8.
	(method bitShift: 8) + byte \\ 31 = 0 ifFalse:[^self error:'Incorrect header'].
	(byte anyMask: 32) ifTrue:[^self error:'Need preset dictionary'].

]

{ #category : 'crc' }
ZLibReadStream >> updateCrc: oldCrc from: start to: stop in: aCollection [
	"Answer an updated CRC for the range of bytes in aCollection"
	^ZLibWriteStream updateAdler32: oldCrc from: start to: stop in: aCollection.
]

{ #category : 'crc' }
ZLibReadStream >> verifyCrc [
	| stored |
	stored := 0.
	24 to: 0 by: -8 do: [ :i |
		sourcePos >= sourceLimit ifTrue: [ ^ self crcError: 'No checksum (proceed to ignore)' ].
		stored := stored + (self nextByte bitShift: i) ].
	stored = crc ifFalse: [ ^ self crcError: 'Wrong checksum (proceed to ignore)' ].
	^stored
]
