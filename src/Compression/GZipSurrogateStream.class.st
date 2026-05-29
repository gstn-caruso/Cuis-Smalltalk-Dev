"
A pseudo stream that allows SmartRefStream to write directly to a gzipped file. There are some peculiarities of the project exporting process that require:

1. We ignore #close since the file is closed and may be reopened to continue writing. We implement #reallyClose for when we know that all writing is over.

2. We use a BitBlt to write WordArrayForSegment objects. Bit of a hack, but there it is.

| fileStream wa |

wa _ WordArrayForSegment new: 30000.
1 to: wa size do: [ :i | wa at: i put: i].
fileStream _ GZipSurrogateStream newFileNamed: 'xxx3.gz' inDirectory: FileDirectory smalltalkImageDirectory.
fileStream nextPutAll: 'this is a test'.
fileStream nextPutAll: wa.
fileStream reallyClose.

"
Class {
	#name : 'GZipSurrogateStream',
	#superclass : 'Object',
	#instVars : [
		'gZipStream',
		'zippedFileStream',
		'bufferStream',
		'positionThusFar'
	],
	#category : 'Compression-System',
	#package : 'Compression',
	#tag : 'System'
}

{ #category : 'as yet unclassified' }
GZipSurrogateStream >> binary [

	self bufferStream binary
]

{ #category : 'as yet unclassified' }
GZipSurrogateStream >> bufferStream [

	^bufferStream ifNil: [bufferStream := ReadWriteStream on: (ByteArray new: 5000)].

]

{ #category : 'as yet unclassified' }
GZipSurrogateStream >> close [
	
	"we don't want to until user is really done"
	


]

{ #category : 'as yet unclassified' }
GZipSurrogateStream >> closed [

	^false
]

{ #category : 'as yet unclassified' }
GZipSurrogateStream >> fileOutClass: extraClass andObject: theObject [
	"Write a file that has both the source code for the named class and an object as bits.  Any instance-specific object will get its class written automatically."

	| class srefStream |

	self timeStamp.

	extraClass ifNotNil: [
		class _ extraClass.	"A specific class the user wants written"
		class sharedPools size > 0 ifTrue: [
			class shouldFileOutPools ifTrue: [class fileOutSharedPoolsOn: self]
		].
		class fileOutOn: self moveSource: false toFile: 0
	].

	"Append the object's raw data"
	srefStream _ SmartRefStream on: self.
	srefStream nextPut: theObject.  "and all subobjects"
	srefStream close.		"also closes me - well it thinks it does, anyway"

]

{ #category : 'as yet unclassified' }
GZipSurrogateStream >> flushBuffer [

	| data |
	bufferStream ifNil: [^self].
	data _ bufferStream contents asByteArray.
	gZipStream nextPutAll: data.
	positionThusFar _ positionThusFar + data size.
	bufferStream _ nil.

]

{ #category : 'as yet unclassified' }
GZipSurrogateStream >> newLine [
	"Append a newLine character to the receiver.
	The Cuis convention is to use lf on output."

	self bufferStream newLine
]

{ #category : 'as yet unclassified' }
GZipSurrogateStream >> next [

	^self bufferStream next
]

{ #category : 'as yet unclassified' }
GZipSurrogateStream >> nextChunkPut: aString [

	self bufferStream nextChunkPut: aString
]

{ #category : 'as yet unclassified' }
GZipSurrogateStream >> nextPut: aByte [

	^self bufferStream nextPut: aByte

]

{ #category : 'as yet unclassified' }
GZipSurrogateStream >> nextPutAll: aString [

	^aString writeOnGZIPByteStream: self

]

{ #category : 'as yet unclassified' }
GZipSurrogateStream >> nextPutAllBytes: aString [

	^self bufferStream nextPutAll: aString

]

{ #category : 'as yet unclassified' }
GZipSurrogateStream >> nextPutAllWordArray: aWordArray [

	| ba hackwa hackba blt rowsAtATime sourceOrigin rowsRemaining |

	self flag: #bob.		"do we need to be concerned by bytesPerElement??"
	ba _ nil.
	rowsAtATime _ 2000.		"or 8000 bytes"
	hackwa _ Form new hackBits: aWordArray.
	sourceOrigin _ 0@0.
	[(rowsRemaining _ hackwa height - sourceOrigin y) > 0] whileTrue: [
		rowsAtATime _ rowsAtATime min: rowsRemaining.
		(ba isNil or: [ba size ~= (rowsAtATime * 4)]) ifTrue: [
			ba _ ByteArray new: rowsAtATime * 4.
			hackba _ Form new hackBits: ba.
			blt _ (BitBlt toForm: hackba) sourceForm: hackwa.
		].
		blt 
			combinationRule: Form over;
			sourceOrigin: sourceOrigin;
			destX: 0 destY: 0 width: 4 height: rowsAtATime;
			copyBits.
		self bufferStream nextPutAll: ba.
		self flushBuffer.
		sourceOrigin _ sourceOrigin x @ (sourceOrigin y + rowsAtATime).
	].

]

{ #category : 'as yet unclassified' }
GZipSurrogateStream >> nextSignedInt32Put: int32 bigEndian: bigEndian [

	^self bufferStream nextInt32Put: int32 bigEndian: bigEndian
]

{ #category : 'as yet unclassified' }
GZipSurrogateStream >> nextStringPut: s  [
	"Append the string, s, to the receiver.  Only used by DataStream.  Max size of 64*256*256*256."

	| length |
	(length _ s size) < 192
		ifTrue: [self nextPut: length]
		ifFalse: 
			[self nextPut: (length digitAt: 4)+192.
			self nextPut: (length digitAt: 3).
			self nextPut: (length digitAt: 2).
			self nextPut: (length digitAt: 1)].
	self nextPutAll: s.
	^s
]

{ #category : 'as yet unclassified' }
GZipSurrogateStream >> nextWordsPutAll: aCollection [
	"Write the argument a word-like object in big endian format on the receiver.
	May be used to write other than plain word-like objects (such as ColorArray)."
	^self nextPutAllWordArray: aCollection
]

{ #category : 'as yet unclassified' }
GZipSurrogateStream >> originalContents [

	^''		"used only to determine if we are byte-structured"
]

{ #category : 'as yet unclassified' }
GZipSurrogateStream >> position [

	^self bufferStream position + positionThusFar
]

{ #category : 'as yet unclassified' }
GZipSurrogateStream >> reallyClose [

	self flushBuffer.
	gZipStream close.

]

{ #category : 'as yet unclassified' }
GZipSurrogateStream >> reopen [

	"ignore"
]

{ #category : 'as yet unclassified' }
GZipSurrogateStream >> setToEnd [

	"ignore"
]

{ #category : 'as yet unclassified' }
GZipSurrogateStream >> skip: aNumber [

	^self bufferStream skip: aNumber

]
