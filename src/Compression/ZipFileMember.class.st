"
ZipNewFileMember instances are used to represent files that have been read from a ZipArchive.
Their data stays in the file on disk, so the original Zip file cannot be directly overwritten.
"
Class {
	#name : 'ZipFileMember',
	#superclass : 'ZipArchiveMember',
	#instVars : [
		'externalFileName',
		'stream',
		'localHeaderRelativeOffset',
		'dataOffset'
	],
	#category : 'Compression-Archives',
	#package : 'Compression',
	#tag : 'Archives'
}

{ #category : 'as yet unclassified' }
ZipFileMember class >> newFrom: stream named: fileName [
	^(self new) stream: stream externalFileName: fileName
]

{ #category : 'private-reading' }
ZipFileMember >> canonicalizeFileName [
	"For security reasons, make all paths relative and remove any ../ portions"

	[fileName beginsWith: '/'] whileTrue: [fileName := fileName allButFirst].
	fileName := fileName copyReplaceAll: '../' with: ''
]

{ #category : 'initialization' }
ZipFileMember >> close [
	stream ifNotNil:[stream close].
]

{ #category : 'private-writing' }
ZipFileMember >> copyDataTo: aStream [

	self copyRawDataTo: aStream.
]

{ #category : 'initialization' }
ZipFileMember >> initialize [
	super initialize.
	crc32 _ 0.
	localHeaderRelativeOffset _ 0.
	dataOffset _ 0.
]

{ #category : 'private-writing' }
ZipFileMember >> localHeaderRelativeOffset [
	^localHeaderRelativeOffset
]

{ #category : 'testing' }
ZipFileMember >> looksLikeDirectory [
	^fileName last = $/
		and: [ uncompressedSize = 0 ]
]

{ #category : 'private-reading' }
ZipFileMember >> readCentralDirectoryFileHeaderFrom: aStream [
	"Assumes aStream positioned after signature"

	| fileNameLength extraFieldLength fileCommentLength |

	versionMadeBy := aStream next.
	fileAttributeFormat := aStream next.

	versionNeededToExtract := aStream nextUint16BigEndian: false.
	bitFlag := aStream nextUint16BigEndian: false.
	compressionMethod := aStream nextUint16BigEndian: false.

	lastModFileDateTime := aStream nextUint32BigEndian: false.
	crc32 := aStream nextUint32BigEndian: false.
	compressedSize := aStream nextUint32BigEndian: false.
	uncompressedSize := aStream nextUint32BigEndian: false.

	fileNameLength := aStream nextUint16BigEndian: false.
	extraFieldLength := aStream nextUint16BigEndian: false.
	fileCommentLength := aStream nextUint16BigEndian: false.
	aStream nextUint16BigEndian: false. 	"disk number start"
	internalFileAttributes := aStream nextUint16BigEndian: false.

	externalFileAttributes := aStream nextUint32BigEndian: false.
	localHeaderRelativeOffset := aStream nextUint32BigEndian: false.

	fileName := UnicodeString fromUtf8Bytes: (aStream next: fileNameLength).
	cdExtraField := aStream next: extraFieldLength.
	fileComment := UnicodeString fromUtf8Bytes: (aStream next: fileCommentLength).

	self desiredCompressionMethod: compressionMethod
]

{ #category : 'private-reading' }
ZipFileMember >> readFrom: aStream  [
	"assumes aStream positioned after CD header; leaves stream positioned after my CD entry"

	self readCentralDirectoryFileHeaderFrom: aStream.
	self readLocalDirectoryFileHeaderFrom: aStream.
	self endRead.
	self canonicalizeFileName.

]

{ #category : 'private-reading' }
ZipFileMember >> readLocalDirectoryFileHeaderFrom: aStream  [
	"Positions stream as necessary. Will return stream to its original position"

	| fileNameLength extraFieldLength xcrc32 xcompressedSize xuncompressedSize sig oldPos |

	oldPos := aStream position.

	aStream position: localHeaderRelativeOffset.

	sig := aStream next: 4.
	sig = LocalFileHeaderSignature
		ifFalse: [ aStream position: oldPos.
				^self error: 'bad LH signature at ', localHeaderRelativeOffset hex ].

	versionNeededToExtract := aStream nextUint16BigEndian: false.
	bitFlag := aStream nextUint16BigEndian: false.
	compressionMethod := aStream nextUint16BigEndian: false.

	lastModFileDateTime := aStream nextUint32BigEndian: false.
	xcrc32 := aStream nextUint32BigEndian: false.
	xcompressedSize := aStream nextUint32BigEndian: false.
	xuncompressedSize := aStream nextUint32BigEndian: false.

	fileNameLength := aStream nextUint16BigEndian: false.
	extraFieldLength := aStream nextUint16BigEndian: false.

	fileName := UnicodeString fromUtf8Bytes: (aStream next: fileNameLength).
	localExtraField := aStream next: extraFieldLength.

	dataOffset := aStream position.

	"Don't trash these fields if we already got them from the central directory"
	self hasDataDescriptor ifFalse: [
		crc32 := xcrc32.
		compressedSize := xcompressedSize.
		uncompressedSize := xuncompressedSize.
	].

	aStream position: oldPos.
]

{ #category : 'private-reading' }
ZipFileMember >> readRawChunk: n [
	^stream next: n
]

{ #category : 'private-reading' }
ZipFileMember >> rewindData [
	super rewindData.
	(stream isNil or: [ stream closed ])
		ifTrue: [ self error: 'stream missing or closed' ].
	stream position: (localHeaderRelativeOffset + 4).
	self skipLocalDirectoryFileHeaderFrom: stream.
]

{ #category : 'private-reading' }
ZipFileMember >> skipLocalDirectoryFileHeaderFrom: aStream  [
	"Assumes that stream is positioned after signature."

	|  extraFieldLength fileNameLength |
	aStream next: 22.
	fileNameLength := aStream nextUint16BigEndian: false.
	extraFieldLength := aStream nextUint16BigEndian: false.
	aStream next: fileNameLength.
	aStream next: extraFieldLength.
	dataOffset := aStream position
]

{ #category : 'initialization' }
ZipFileMember >> stream: aStream externalFileName: aFileName [
	stream _ aStream.
	externalFileName _ aFileName.
]

{ #category : 'private-writing' }
ZipFileMember >> uncompressDataTo: aStream [

	| decoder buffer chunkSize crcErrorMessage |
	decoder _ ZipReadStream on: stream.
	decoder expectedCrc: self crc32.
	buffer _ ByteArray new: (32768 min: readDataRemaining).
	crcErrorMessage _ nil.

	[[ readDataRemaining > 0 ] whileTrue: [
		chunkSize _ 32768 min: readDataRemaining.
		buffer _ decoder next: chunkSize into: buffer startingAt: 1.
		aStream next: chunkSize putAll: buffer startingAt: 1.
		readDataRemaining _ readDataRemaining - chunkSize.
	]] on: CRCError do: [ :ex | crcErrorMessage _ ex messageText. ex proceed ].

	crcErrorMessage ifNotNil: [ self isCorrupt: true. CRCError signal: crcErrorMessage ]


]

{ #category : 'private-writing' }
ZipFileMember >> uncompressDataTo: aStream from: start to: finish [

	| decoder buffer chunkSize |
	decoder _ FastInflateStream on: stream.
	readDataRemaining _ readDataRemaining min: finish - start + 1.
	buffer _ ByteArray new: (32768 min: readDataRemaining).
	decoder next: start - 1.

	[ readDataRemaining > 0 ] whileTrue: [
		chunkSize _ 32768 min: readDataRemaining.
		buffer _ decoder next: chunkSize into: buffer startingAt: 1.
		aStream next: chunkSize putAll: buffer startingAt: 1.
		readDataRemaining _ readDataRemaining - chunkSize.
	].

]

{ #category : 'testing' }
ZipFileMember >> usesFileNamed: aFileName [
	"Do I require aFileName? That is, do I care if it's clobbered?"

	^externalFileName asFileEntry = aFileName asFileEntry
]
