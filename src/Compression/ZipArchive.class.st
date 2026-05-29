"
A ZipArchive represents an archive that is read and/or written using the PKZIP file format.

ZipArchive instances know how to read and write such archives; their members are subinstances of ZipArchiveMember.
"
Class {
	#name : 'ZipArchive',
	#superclass : 'Archive',
	#instVars : [
		'centralDirectorySize',
		'centralDirectoryOffsetWRTStartingDiskNumber',
		'zipFileComment',
		'writeCentralDirectoryOffset',
		'writeEOCDOffset'
	],
	#pools : [
		'ZipFileConstants'
	],
	#category : 'Compression-Archives',
	#package : 'Compression',
	#tag : 'Archives'
}

{ #category : 'constants' }
ZipArchive class >> compressionDeflated [
	^CompressionDeflated
]

{ #category : 'constants' }
ZipArchive class >> compressionLevelDefault [
	^CompressionLevelDefault
]

{ #category : 'constants' }
ZipArchive class >> compressionLevelNone [
	^CompressionLevelNone 
]

{ #category : 'constants' }
ZipArchive class >> compressionStored [
	^CompressionStored
]

{ #category : 'file list services' }
ZipArchive class >> fileReaderServicesForFileEntry: aFileEntry suffix: suffix [
	"FileList buttons that are swe know about."

	suffix = 'mcz'
		ifTrue: [ ^ {
			CodeFileBrowser serviceBrowseMCZCode.
			ChangeList serviceMCZContents
		} ].
	^#()
]

{ #category : 'constants' }
ZipArchive class >> findEndOfCentralDirectoryFrom: stream [
	"Seek in the given stream to the end, then read backwards until we find the
	signature of the central directory record. Leave the file positioned right
	before the signature.

	Answers the file position of the EOCD, or 0 if not found."

	| data fileLength seekOffset pos maxOffset |
	stream setToEnd.
	fileLength := stream position.
	"If the file length is less than 18 for the EOCD length plus 4 for the signature, we have a problem"
	fileLength < 22 ifTrue: [^ self error: 'file is too short'].
	
	seekOffset := 0.
	pos := 0.
	data := ByteArray new: 4100.
	maxOffset := 40960 min: fileLength.	"limit search range to 40K"

	[
		seekOffset := (seekOffset + 4096) min: fileLength.
		stream position: fileLength - seekOffset.
		data := stream next: (4100 min: seekOffset) into: data startingAt: 1.
		pos := self
			lastIndexOfPKSignature: EndOfCentralDirectorySignature
			in: data.
		pos = 0 and: [seekOffset < maxOffset]
	] whileTrue.

	^ pos > 0
		ifTrue: [ | newPos | stream position: (newPos := (stream position + pos - seekOffset - 1)). newPos]
		ifFalse: [0]
]

{ #category : 'file format' }
ZipArchive class >> isZipArchive: aStreamOrFileName [
	"Answer whether the given filename represents a valid zip file."

	| stream eocdPosition |
	stream := (aStreamOrFileName is: #Stream)
		ifTrue: [aStreamOrFileName]
		ifFalse: [aStreamOrFileName asFileEntry readStream ].
	stream ifNil: [^ false].
	"nil happens sometimes somehow"
	stream binary.
	stream size < 22 ifTrue: [^ false].
	eocdPosition := self findEndOfCentralDirectoryFrom: stream.
	stream ~= aStreamOrFileName ifTrue: [stream close].
	^ eocdPosition > 0
]

{ #category : 'constants' }
ZipArchive class >> lastIndexOfPKSignature: aSignature in: data [
	"Answer the last index in data where aSignature (4 bytes long) occurs, or 0 if not found"
	| a b c d |
	a := aSignature first.
	b := aSignature second.
	c := aSignature third.
	d := aSignature fourth.
	(data size - 3) to: 1 by: -1 do: [ :i |
		(((data at: i) = a)
			and: [ ((data at: i + 1) = b)
				and: [ ((data at: i + 2) = c)
					and: [ ((data at: i + 3) = d) ]]])
						ifTrue: [ ^i ]
	].
	^0
]

{ #category : 'constants' }
ZipArchive class >> validSignatures [
	"Return the valid signatures for a zip file"
	^Array 
		with: LocalFileHeaderSignature
		with: CentralDirectoryFileHeaderSignature
		with: EndOfCentralDirectorySignature
]

{ #category : 'initialization' }
ZipArchive >> close [
	self members do:[:m| m close].
]

{ #category : 'archive operations' }
ZipArchive >> extractAllTo: aDirectoryEntry [
	"Extract all elements to the given directory"
	Utilities informUserDuring: [ :barBlock | self extractAllTo: aDirectoryEntry informing: barBlock]
]

{ #category : 'archive operations' }
ZipArchive >> extractAllTo: aDirectoryEntry informing: barBlock [
	"Extract all elements to the given directory"
	^self extractAllTo: aDirectoryEntry informing: barBlock overwrite: false
]

{ #category : 'archive operations' }
ZipArchive >> extractAllTo: aDirectory informing: barBlock overwrite: allOverwrite [
	"Extract all elements to the given directory"
	| dir overwriteAll response |
	overwriteAll := allOverwrite.
	self members do:[:entry|
		entry isDirectory ifTrue:[
			barBlock ifNotNil:[barBlock value: 'Creating ', entry fileName].
			dir := (entry fileName findTokens:'/') 
					inject: aDirectory into:[:base :part| base / part].
			dir assureExistence.
		].
	].
	self members do:[:entry|
		entry isDirectory ifFalse:[
			barBlock ifNotNil:[barBlock value: 'Extracting ', entry fileName].
			response := entry extractInDirectory: aDirectory overwrite: overwriteAll.
			response == #retryWithOverwrite ifTrue:[
				overwriteAll := true.
				response := entry extractInDirectory: aDirectory overwrite: overwriteAll.
			].
			response == #abort ifTrue:[^self].
			response == #failed ifTrue:[
				(self confirm: 'Failed to extract ', entry fileName, '. Proceed?') ifFalse:[^self].
			].
		].
	].

]

{ #category : 'initialization' }
ZipArchive >> initialize [
	super initialize.
	writeEOCDOffset _ writeCentralDirectoryOffset _ 0.
	zipFileComment _ ''.

]

{ #category : 'private' }
ZipArchive >> memberClass [
	^ZipArchiveMember
]

{ #category : 'accessing' }
ZipArchive >> prependedDataSize [
	"Answer the size of whatever data exists before my first member.
	Assumes that I was read from a file or stream (i.e. the first member is a ZipFileMember)"
	^members isEmpty
		ifFalse: [ members first localHeaderRelativeOffset ]
		ifTrue: [ centralDirectoryOffsetWRTStartingDiskNumber ]
]

{ #category : 'private' }
ZipArchive >> readEndOfCentralDirectoryFrom: aStream [
	"Read EOCD, starting from position before signature."
	| signature zipFileCommentLength |
	signature := self readSignatureFrom: aStream.
	signature = EndOfCentralDirectorySignature ifFalse: [ ^self error: 'bad signature at ', aStream position printString ].

	aStream nextUint16BigEndian: false. "# of this disk"
	aStream nextUint16BigEndian: false. "# of disk with central dir start"
	aStream nextUint16BigEndian: false. "# of entries in central dir on this disk"
	aStream nextUint16BigEndian: false. "total # of entries in central dir"
	centralDirectorySize := aStream nextUint32BigEndian: false. "size of central directory"
	centralDirectoryOffsetWRTStartingDiskNumber := aStream nextUint32BigEndian: false. "offset of start of central directory"
	zipFileCommentLength := aStream nextUint16BigEndian: false. "zip file comment"
	zipFileComment := UnicodeString fromUtf8Bytes: (aStream next: zipFileCommentLength).

]

{ #category : 'reading' }
ZipArchive >> readFrom: aStreamOrFileName [
	| stream name eocdPosition |
	stream _ (aStreamOrFileName is: #Stream)
		ifTrue: [name _ aStreamOrFileName name. aStreamOrFileName]
		ifFalse: [(name _ aStreamOrFileName) asFileEntry readStream].
	stream binary.
	eocdPosition _ self class findEndOfCentralDirectoryFrom: stream.
	eocdPosition <= 0 ifTrue: [self error: 'can''t find EOCD position'].
	self readEndOfCentralDirectoryFrom: stream.
	stream position: eocdPosition - centralDirectorySize.
	self readMembersFrom: stream named: name
]

{ #category : 'private' }
ZipArchive >> readMembersFrom: stream named: fileName [
	| newMember signature |
	[
		newMember _ self memberClass newFromZipFile: stream named: fileName.
		signature _ self readSignatureFrom: stream.
		signature = EndOfCentralDirectorySignature ifTrue: [ ^self ].
		signature = CentralDirectoryFileHeaderSignature
			ifFalse: [ self error: 'bad CD signature at ', (stream position - 4) hex ].
		newMember readFrom: stream.
		newMember looksLikeDirectory ifTrue: [ newMember _ newMember asDirectory ].
		self addMember: newMember.
	] repeat.
]

{ #category : 'private' }
ZipArchive >> readSignatureFrom: stream [
	"Returns next signature from given stream, leaves stream positioned afterwards."

	| signatureData | 
	signatureData := ByteArray new: 4.
	stream next: 4 into: signatureData.
	({ CentralDirectoryFileHeaderSignature . LocalFileHeaderSignature . EndOfCentralDirectorySignature }
		includes: signatureData)
			ifFalse: [ ^self error: 'bad signature ', signatureData asHex, ' at position ', (stream position - 4) printString ].
	^signatureData

]

{ #category : 'private' }
ZipArchive >> writeCentralDirectoryTo: aStream [
	| offset |
	offset _ writeCentralDirectoryOffset.
	members do: [ :member |
		member writeCentralDirectoryFileHeaderTo: aStream.
		offset _ offset + member centralDirectoryHeaderSize.
	].
	writeEOCDOffset _ offset.
	self writeEndOfCentralDirectoryTo: aStream.


]

{ #category : 'private' }
ZipArchive >> writeEndOfCentralDirectoryTo: aStream [

	| zipFileCommentBytes |
	zipFileCommentBytes := zipFileComment asByteArray.
	aStream nextPutAll: EndOfCentralDirectorySignature.
	aStream nextUint16Put: 0 bigEndian: false. "diskNumber"
	aStream nextUint16Put: 0 bigEndian: false. "diskNumberWithStartOfCentralDirectory"
	aStream nextUint16Put: members size bigEndian: false. "numberOfCentralDirectoriesOnThisDisk"
	aStream nextUint16Put: members size bigEndian: false. "numberOfCentralDirectories"
	aStream nextUint32Put: writeEOCDOffset - writeCentralDirectoryOffset bigEndian: false. "size of central dir"
	aStream nextUint32Put: writeCentralDirectoryOffset bigEndian: false. "offset of central dir"
	aStream nextUint16Put: zipFileCommentBytes size bigEndian: false. "zip file comment"
	zipFileCommentBytes isEmpty ifFalse: [ aStream nextPutAll: zipFileCommentBytes ].


]

{ #category : 'writing' }
ZipArchive >> writeTo: stream [
	stream binary.
	members do: [ :member |
		member writeTo: stream.
		member endRead.
	].
	writeCentralDirectoryOffset _ stream position.
	self writeCentralDirectoryTo: stream.
	
]

{ #category : 'writing' }
ZipArchive >> writeTo: stream prepending: aString [
	stream binary.
	stream nextPutAll: aString.
	members do: [ :member |
		member writeTo: stream.
		member endRead.
	].
	writeCentralDirectoryOffset _ stream position.
	self writeCentralDirectoryTo: stream.
	
]

{ #category : 'writing' }
ZipArchive >> writeTo: stream prependingFileNamed: aFileName [
	| prepended buffer |
	stream binary.
	prepended _ aFileName asFileEntry readStream.
	prepended binary.
	buffer _ ByteArray new: (prepended size min: 32768).
	[ prepended atEnd ] whileFalse: [ | bytesRead |
		bytesRead _ prepended readInto: buffer startingAt: 1 count: buffer size.
		stream next: bytesRead putAll: buffer startingAt: 1
	].
	members do: [ :member |
		member writeTo: stream.
		member endRead.
	].
	writeCentralDirectoryOffset _ stream position.
	self writeCentralDirectoryTo: stream.
	
]

{ #category : 'writing' }
ZipArchive >> writeToFileNamed: aFileName prepending: aString [

	"Catch attempts to overwrite existing zip file"
	(self canWriteToFileNamed: aFileName)
		ifFalse: [ ^self error: (aFileName, ' is needed by one or more members in this archive') ].
	aFileName asFileEntry forceWriteStreamDo: [ :stream |
		self writeTo: stream prepending: aString ]
]

{ #category : 'writing' }
ZipArchive >> writeToFileNamed: aFileName prependingFileNamed: anotherFileName [

	"Catch attempts to overwrite existing zip file"
	(self canWriteToFileNamed: aFileName)
		ifFalse: [ ^self error: (aFileName, ' is needed by one or more members in this archive') ].
	aFileName asFileEntry forceWriteStreamDo: [ :stream |
		self writeTo: stream prependingFileNamed: anotherFileName ]
]

{ #category : 'accessing' }
ZipArchive >> zipFileComment [
	^zipFileComment
]

{ #category : 'accessing' }
ZipArchive >> zipFileComment: aString [
	zipFileComment _ aString
]
