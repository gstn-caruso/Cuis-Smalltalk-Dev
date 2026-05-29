"
Subinstances of me are members in a ZipArchive.
They represent different data sources:
	* ZipDirectoryMember -- a directory to be added to a zip file
	* ZipFileMember -- a file or directory that is already in a zip file
	* ZipNewFilemember -- a file that is to be added to a zip file
	* ZipStringMember -- a string that is to be added to a zip file

They can write their data to another stream either copying, compressing,
or decompressing as desired.
"
Class {
	#name : 'ZipArchiveMember',
	#superclass : 'ArchiveMember',
	#instVars : [
		'lastModFileDateTime',
		'fileAttributeFormat',
		'versionMadeBy',
		'versionNeededToExtract',
		'bitFlag',
		'compressionMethod',
		'desiredCompressionMethod',
		'desiredCompressionLevel',
		'internalFileAttributes',
		'externalFileAttributes',
		'cdExtraField',
		'localExtraField',
		'fileComment',
		'crc32',
		'compressedSize',
		'uncompressedSize',
		'writeLocalHeaderRelativeOffset',
		'readDataRemaining'
	],
	#pools : [
		'ZipFileConstants'
	],
	#category : 'Compression-Archives',
	#package : 'Compression',
	#tag : 'Archives'
}

{ #category : 'instance creation' }
ZipArchiveMember class >> newFromDirectory: aFileName [
	^ZipDirectoryMember newNamed: aFileName
]

{ #category : 'instance creation' }
ZipArchiveMember class >> newFromFile: aFileName [
	^ZipNewFileMember newNamed: aFileName
]

{ #category : 'instance creation' }
ZipArchiveMember class >> newFromStringOrByteArray: aStringByteArray named: aFileName [
	^ZipStringMember newFrom: aStringByteArray named: aFileName
]

{ #category : 'instance creation' }
ZipArchiveMember class >> newFromZipFile: stream named: fileName [
	^ZipFileMember newFrom: stream named: fileName
]

{ #category : 'private' }
ZipArchiveMember >> asDirectory [
	^ZipDirectoryMember new copyFrom: self
]

{ #category : 'accessing' }
ZipArchiveMember >> centralDirectoryHeaderSize [
	^ 46 + fileName asByteArray size + cdExtraField size + fileComment asByteArray size
]

{ #category : 'accessing' }
ZipArchiveMember >> clearExtraFields [
	cdExtraField := ByteArray new.
	localExtraField := ByteArray new.
]

{ #category : 'private-writing' }
ZipArchiveMember >> compressDataTo: aStream [
	"Copy my deflated data to the given stream."
	| encoder startPos endPos |

	encoder := ZipWriteStream on: aStream.
	startPos := aStream position.

	[ readDataRemaining > 0 ] whileTrue: [ | data |
		data := self readRawChunk: (4096 min: readDataRemaining).
		data := data asByteArray.
		encoder nextPutAll: data.
		readDataRemaining := readDataRemaining - data size.
	].
	encoder finish. "not close!"
	endPos := aStream position.
	compressedSize := endPos - startPos.
	crc32 := encoder crc.

]

{ #category : 'accessing' }
ZipArchiveMember >> compressedSize [
	"Return the compressed size for this member.
	This will not be set for members that were constructed from strings
	or external files until after the member has been written."
	^compressedSize
]

{ #category : 'accessing' }
ZipArchiveMember >> compressionMethod [
	"Returns my compression method. This is the method that is
	currently being used to compress my data.

	This will be CompressionStored for added string or file members,
	or CompressionStored or CompressionDeflated (others are possible but not handled)"

	^compressionMethod
]

{ #category : 'reading' }
ZipArchiveMember >> contents [
	"Answer my contents as a ByteArray."

	^ByteArray
		streamContents: [ :strm | self extractTo: strm ]
		estimatedSize: self uncompressedSize.
]

{ #category : 'private-writing' }
ZipArchiveMember >> copyDataTo: aStream [

	compressionMethod = CompressionStored ifTrue: [ ^self copyDataWithCRCTo: aStream ].

	self copyRawDataTo: aStream.
]

{ #category : 'private-writing' }
ZipArchiveMember >> copyDataWithCRCTo: aStream [
	"Copy my data to aStream. Also set the CRC-32.
	Only used when compressionMethod = desiredCompressionMethod = CompressionStored"

	uncompressedSize _ compressedSize _ readDataRemaining.

	crc32 _ 16rFFFFFFFF.

	[ readDataRemaining > 0 ] whileTrue: [ | data |
		data _ self readRawChunk: (4096 min: readDataRemaining).
		aStream nextPutAll: data.
		crc32 _ ZipWriteStream updateCrc: crc32 from: 1 to: data size in: data.
		readDataRemaining _ readDataRemaining - data size.
	].

	crc32 _ crc32 bitXor: 16rFFFFFFFF.

]

{ #category : 'private-writing' }
ZipArchiveMember >> copyRawDataTo: aStream [

	[ readDataRemaining > 0 ] whileTrue: [ | data |
		data _ self readRawChunk: (4096 min: readDataRemaining).
		aStream nextPutAll: data.
		readDataRemaining _ readDataRemaining - data size.
	].

]

{ #category : 'private-writing' }
ZipArchiveMember >> copyRawDataTo: aStream from: start to: finish [

	readDataRemaining _ readDataRemaining min: finish - start + 1.

	self readRawChunk: start - 1.

	[ readDataRemaining > 0 ] whileTrue: [ | data |
		data _ self readRawChunk: (32768 min: readDataRemaining).
		aStream nextPutAll: data.
		readDataRemaining _ readDataRemaining - data size.
	].

]

{ #category : 'accessing' }
ZipArchiveMember >> crc32 [
	^crc32
]

{ #category : 'accessing' }
ZipArchiveMember >> crc32String [
	| hexString |
	hexString _ crc32 hex.
	^('00000000' copyFrom: 1 to: 11 - (hexString size)) , (hexString copyFrom: 4 to: hexString size)
]

{ #category : 'accessing' }
ZipArchiveMember >> desiredCompressionLevel [
	^desiredCompressionLevel
]

{ #category : 'accessing' }
ZipArchiveMember >> desiredCompressionLevel: aNumber [
	"Set my desiredCompressionLevel
	This is the method that will be used to write.
	Returns prior desiredCompressionLevel.

	Valid arguments are 0 (CompressionLevelNone) through 9,
	including 6 (CompressionLevelDefault).

	0 (CompressionLevelNone) will change the desiredCompressionMethod
	to CompressionStored. All other arguments will change the
	desiredCompressionMethod to CompressionDeflated."

	| old |
	old _ desiredCompressionLevel.
	desiredCompressionLevel _ aNumber.
	desiredCompressionMethod _ (aNumber > 0)
		ifTrue: [ CompressionDeflated ]
		ifFalse: [ CompressionStored ].
	^old
]

{ #category : 'accessing' }
ZipArchiveMember >> desiredCompressionMethod [
	"Get my desiredCompressionMethod.
	This is the method that will be used to write"

	^desiredCompressionMethod
]

{ #category : 'accessing' }
ZipArchiveMember >> desiredCompressionMethod: aNumber [
	"Set my desiredCompressionMethod
	This is the method that will be used to write.
	Answers prior desiredCompressionMethod.

	Only CompressionDeflated or CompressionStored are valid arguments.

	Changing to CompressionStored will change my desiredCompressionLevel
	to CompressionLevelNone; changing to CompressionDeflated will change my
	desiredCompressionLevel to CompressionLevelDefault."

	| old |
	old _ desiredCompressionMethod.
	desiredCompressionMethod _ aNumber.
	desiredCompressionLevel _ (aNumber = CompressionDeflated)
			ifTrue: [ CompressionLevelDefault ]
			ifFalse: [ CompressionLevelNone ].
	compressionMethod = CompressionStored ifTrue: [ compressedSize _ uncompressedSize ].
	^old.
]

{ #category : 'private' }
ZipArchiveMember >> dosToSqueakTime: dt [
	"DOS years start at 1980, so add 1980."
	| year mon mday hour min sec date time |

	year := (( dt bitShift: -25 ) bitAnd: 16r7F ).
	mon := (( dt bitShift: -21 ) bitAnd: 16r0F ).
	mday := (( dt bitShift: -16 ) bitAnd: 16r1F ).
	date := Date newDay: mday month: mon year: year+1980.

	hour := (( dt bitShift: -11 ) bitAnd: 16r1F ).
	min := (( dt bitShift: -5 ) bitAnd: 16r3F ).
	sec := (( dt bitShift: 1 ) bitAnd: 16r3E ).
	time := ((( hour * 60 ) + min ) * 60 ) + sec.

	^date secondsSinceSqueakEpoch + time

	
]

{ #category : 'private' }
ZipArchiveMember >> endRead [
	readDataRemaining _ 0.
]

{ #category : 'extraction' }
ZipArchiveMember >> extractInDirectory: aDirectoryEntry [

	self extractToFileNamed: self localFileName inDirectory: aDirectoryEntry

]

{ #category : 'extraction' }
ZipArchiveMember >> extractInDirectory: aDirectory overwrite: overwriteAll [
	"Extract this entry into the given directory. Answer #okay, #failed, #abort, or #retryWithOverwrite."
	| path fileDir file index localName |
	path := fileName findTokens:'/'.
	localName := path last.
	fileDir := path allButLast inject: aDirectory into:[:base :part| base / part].
	fileDir assureExistence.
	"file := [fileDir privateNewFile: localName] on: FileExistsException do:[:ex| ex return: nil]."
	file := [FileIOAccessor new privateNewFile: (aDirectory /  (self fileName))] on: FileExistsException do:[:ex| ex return: nil].
	file ifNil:[
		overwriteAll ifFalse:[
			[index := (PopUpMenu labelArray:{
						'Yes, overwrite'. 
						'No, don''t overwrite'. 
						'Overwrite ALL files'.
						'Cancel operation'
					} lines: #(2)) startUpWithCaption: fileName, ' already exists. Overwrite?'.
			index == nil] whileTrue.
			index = 4 ifTrue:[^#abort].
			index = 3 ifTrue:[^#retryWithOverwrite].
			index = 2 ifTrue:[^#okay].
		].
		file := [fileDir privateForceNewFile: localName] on: Error do:[:ex| ex return].
		file ifNil:[^#failed].
	].
	self extractTo: file.
	file close.
	^#okay
]

{ #category : 'extraction' }
ZipArchiveMember >> extractTo: aStream [
	| oldCompression |
	self isEncrypted ifTrue: [ self error: 'encryption is unsupported' ].
	aStream binary.
	oldCompression _ self desiredCompressionMethod: CompressionStored.
	self rewindData.
	self writeDataTo: aStream.
	self desiredCompressionMethod: oldCompression.
	self endRead.
]

{ #category : 'extraction' }
ZipArchiveMember >> extractTo: aStream from: start to: finish [
	| oldCompression |
	self isEncrypted ifTrue: [ self error: 'encryption is unsupported' ].
	aStream binary.
	oldCompression _ self desiredCompressionMethod: CompressionStored.
	self rewindData.
	self writeDataTo: aStream from: start to: finish.
	self desiredCompressionMethod: oldCompression.
	self endRead.
]

{ #category : 'extraction' }
ZipArchiveMember >> extractToFileNamed: aFileName [

	self extractToFileNamed: aFileName inDirectory: DirectoryEntry currentDirectory
]

{ #category : 'extraction' }
ZipArchiveMember >> extractToFileNamed: aLocalFileName inDirectory: aDirectoryEntry [

	self isEncrypted ifTrue: [ ^self error: 'encryption unsupported' ].
	self isDirectory
		ifFalse: [
			(aDirectoryEntry / aLocalFileName) forceWriteStreamDo: [ :stream |
				self extractTo: stream ] ]
		ifTrue: [
			(aDirectoryEntry / aLocalFileName) asDirectoryEntry assureExistence ]
]

{ #category : 'accessing' }
ZipArchiveMember >> fileComment [
	^fileComment
]

{ #category : 'accessing' }
ZipArchiveMember >> fileComment: aString [
	fileComment _ aString
]

{ #category : 'testing' }
ZipArchiveMember >> hasDataDescriptor [
	^ (bitFlag bitAnd: 8)	~= 0 "GPBF_HAS_DATA_DESCRIPTOR_MASK"
]

{ #category : 'initialization' }
ZipArchiveMember >> initialize [
	"https://pkware.cachefly.net/webdocs/casestudies/APPNOTE.TXT"

	super initialize.
	"Bit 11: Language encoding flag (EFS).  If this bit is set,
                the filename and comment fields for this file
                MUST be encoded using UTF-8. (see APPENDIX D)"
	bitFlag := `2 raisedTo: 11`.

	lastModFileDateTime := 0.
	fileAttributeFormat := FaUnix.
	versionMadeBy := 20.
	versionNeededToExtract := 20.
	compressionMethod := CompressionStored.
	desiredCompressionMethod := CompressionDeflated.
	desiredCompressionLevel := CompressionLevelDefault.
	internalFileAttributes := 0.
	externalFileAttributes := 0.
	fileName := ''.
	cdExtraField := ByteArray new.
	localExtraField := ByteArray new.
	fileComment := ''.
	crc32 := 0.
	compressedSize := 0.
	uncompressedSize := 0.
	self unixFileAttributes: DefaultFilePermissions.
]

{ #category : 'testing' }
ZipArchiveMember >> isDirectory [
	^false
]

{ #category : 'testing' }
ZipArchiveMember >> isEncrypted [
	"Return true if this member is encrypted (this is unsupported)"
	^ (bitFlag bitAnd: 1) ~= 0
]

{ #category : 'testing' }
ZipArchiveMember >> isTextFile [
	"Returns true if I am a text file.
	Note that this module does not currently do anything with this flag
	upon extraction or storage.
	That is, bytes are stored in native format whether or not they came
	from a text file."
	^ (internalFileAttributes bitAnd: 1) ~= 0

]

{ #category : 'testing' }
ZipArchiveMember >> isTextFile: aBoolean [
	"Set whether I am a text file.
	Note that this module does not currently do anything with this flag
	upon extraction or storage.
	That is, bytes are stored in native format whether or not they came
	from a text file."
	internalFileAttributes _ aBoolean
		ifTrue: [ internalFileAttributes bitOr: 1 ]
		ifFalse: [ internalFileAttributes bitAnd: 1 bitInvert ]

]

{ #category : 'accessing' }
ZipArchiveMember >> lastModTime [
	"Return my last modification date/time stamp,
	converted to Squeak seconds"

	^self dosToSqueakTime: lastModFileDateTime
]

{ #category : 'accessing' }
ZipArchiveMember >> localFileName [
	"Answer my fileName in terms of the local directory naming convention"
	^fileName
]

{ #category : 'testing' }
ZipArchiveMember >> looksLikeDirectory [
	^false
]

{ #category : 'private' }
ZipArchiveMember >> mapPermissionsFromUnix: unixPerms [
	^ unixPerms bitShift: 16.
]

{ #category : 'private' }
ZipArchiveMember >> mapPermissionsToUnix: dosPerms [
	^ dosPerms bitShift: -16.
]

{ #category : 'private' }
ZipArchiveMember >> readRawChunk: n [
	self subclassResponsibility
]

{ #category : 'private-writing' }
ZipArchiveMember >> refreshLocalFileHeaderTo: aStream [
	"Re-writes my local header to the given stream.
	To be called after writing the data stream.
	Assumes that fileName and localExtraField sizes didn't change since last written."

	| here |
	here := aStream position.
	aStream position: writeLocalHeaderRelativeOffset.

	aStream nextPutAll: LocalFileHeaderSignature.
	aStream nextUint16Put: versionNeededToExtract bigEndian: false.
	aStream nextUint16Put: bitFlag bigEndian: false.
	aStream nextUint16Put: desiredCompressionMethod bigEndian: false.
	aStream nextUint32Put: lastModFileDateTime bigEndian: false.
	aStream nextUint32Put: crc32 bigEndian: false.
	aStream nextUint32Put: (desiredCompressionMethod = CompressionStored
							ifTrue: [ uncompressedSize ]
							ifFalse: [ compressedSize ]) bigEndian: false.
	aStream nextUint32Put: uncompressedSize bigEndian: false.
	aStream nextUint16Put: fileName asByteArray size bigEndian: false.
	aStream nextUint16Put: localExtraField size bigEndian: false.

	aStream position: here
]

{ #category : 'private' }
ZipArchiveMember >> rewindData [
	readDataRemaining _  (desiredCompressionMethod = CompressionDeflated
		and: [ compressionMethod = CompressionDeflated ])
			ifTrue: [ compressedSize ]
			ifFalse: [ uncompressedSize ].

]

{ #category : 'accessing' }
ZipArchiveMember >> setLastModFileDateTimeFrom: aSmalltalkTime [

	lastModFileDateTime := self squeakToDosTime: aSmalltalkTime
]

{ #category : 'accessing' }
ZipArchiveMember >> splitFileName [
	"Answer my name split on slash boundaries. A directory will have a trailing empty string."
	^ fileName findTokens: '/'.
]

{ #category : 'private' }
ZipArchiveMember >> squeakToDosTime: secs [
	"Convert to MS-DOS time format
	See: https://docs.microsoft.com/de-de/windows/win32/api/winbase/nf-winbase-dosdatetimetofiletime?redirectedfrom=MSDN
	"

	| dosTime dateTime |

	dateTime _ Time dateAndTimeFromSeconds: 
		(secs isInteger
			ifFalse: [ secs secondsSinceSqueakEpoch ]
			ifTrue: [ secs ]).
	dosTime _ (dateTime second second) bitShift: -1.
	dosTime _ dosTime bitOr: ((dateTime second minute) bitShift: 5).
	dosTime _ dosTime bitOr: ((dateTime second hour) bitShift: 11).
	dosTime _ dosTime bitOr: ((dateTime first dayOfMonth) bitShift: `16 + 0`).
	dosTime _ dosTime bitOr: ((dateTime first monthIndex) bitShift: `16 + 5`).
	dosTime _ dosTime bitOr: (((dateTime first yearNumber) - 1980) bitShift: `16 + 9`).
	self assert: dosTime >= 0.
	^ dosTime

]

{ #category : 'accessing' }
ZipArchiveMember >> uncompressedSize [
	"Return the uncompressed size for this member."
	^uncompressedSize
]

{ #category : 'accessing' }
ZipArchiveMember >> unixFileAttributes [
	^self mapPermissionsToUnix: externalFileAttributes.
]

{ #category : 'accessing' }
ZipArchiveMember >> unixFileAttributes: perms [
	| oldPerms newPerms |
	oldPerms _ self mapPermissionsToUnix: externalFileAttributes.
	newPerms _  self isDirectory
			ifTrue: [ (perms bitAnd: FileAttrib bitInvert) bitOr: DirectoryAttrib ]
			ifFalse: [ (perms bitAnd: DirectoryAttrib bitInvert) bitOr: FileAttrib ].
	externalFileAttributes _ self mapPermissionsFromUnix: newPerms.
	^oldPerms.
]

{ #category : 'private-writing' }
ZipArchiveMember >> writeCentralDirectoryFileHeaderTo: aStream [
	"C2 v3 V4 v5 V2"

	| fileNameBytes fileCommentBytes |
	aStream nextPutAll: CentralDirectoryFileHeaderSignature.
	aStream nextPut: versionMadeBy.
	aStream nextPut: fileAttributeFormat.

	aStream nextUint16Put: versionNeededToExtract bigEndian: false.
	aStream nextUint16Put: bitFlag bigEndian: false. "Bit 11: Language encoding flag (EFS) is set. See #initialize."
	aStream nextUint16Put: desiredCompressionMethod bigEndian: false.

	aStream nextUint32Put: lastModFileDateTime bigEndian: false.

	"These next 3 should have been updated during the write of the data"
	aStream nextUint32Put: crc32 bigEndian: false.
	aStream nextUint32Put: (desiredCompressionMethod = CompressionStored
							ifTrue: [ uncompressedSize ]
							ifFalse: [ compressedSize ]) bigEndian: false.
	aStream nextUint32Put: uncompressedSize bigEndian: false.

	fileNameBytes := fileName asByteArray.
	fileCommentBytes := fileComment asByteArray.
	aStream nextUint16Put: fileNameBytes size bigEndian: false.
	aStream nextUint16Put: cdExtraField size bigEndian: false.
	aStream nextUint16Put: fileCommentBytes size bigEndian: false.
	aStream nextUint16Put: 0 bigEndian: false.		"diskNumberStart"
	aStream nextUint16Put: internalFileAttributes bigEndian: false.

	aStream nextUint32Put: externalFileAttributes bigEndian: false.
	aStream nextUint32Put: writeLocalHeaderRelativeOffset bigEndian: false.

	aStream nextPutAll: fileNameBytes.
	aStream nextPutAll: cdExtraField.
	aStream nextPutAll: fileCommentBytes.
]

{ #category : 'private-writing' }
ZipArchiveMember >> writeDataDescriptorTo: aStream [
	"This writes a data descriptor to the given stream.
	Assumes that crc32, writeOffset, and uncompressedSize are
	set correctly (they should be after a write).
	Further, the local file header should have the
	GPBF_HAS_DATA_DESCRIPTOR_MASK (8) bit set."

	aStream nextUint32Put: crc32 bigEndian: false.
	aStream nextUint32Put: compressedSize bigEndian: false.
	aStream nextUint32Put: uncompressedSize bigEndian: false
]

{ #category : 'private-writing' }
ZipArchiveMember >> writeDataTo: aStream [
	"Copy my (possibly inflated or deflated) data to the given stream.
	This might do compression, decompression, or straight copying, depending
	on the values of compressionMethod and desiredCompressionMethod"

	"Note: Do not shortcut this method if uncompressedSize = 0. Even in this case
	data may be produced by the compressor (i.e., '' zipped size > 0) and must
	be stored in the file or else other utilities will treat the zip file as corrupt."

	(compressionMethod = CompressionStored and: [ desiredCompressionMethod = CompressionDeflated ])
		ifTrue: [ ^self compressDataTo: aStream ].

	(compressionMethod = CompressionDeflated and: [ desiredCompressionMethod = CompressionStored ])
		ifTrue: [ ^self uncompressDataTo: aStream ].

	self copyDataTo: aStream.
]

{ #category : 'private-writing' }
ZipArchiveMember >> writeDataTo: aStream from: start to: finish [
	"Copy my (possibly inflated or deflated) data to the given stream.
	But only the specified byte range.
	This might do decompression, or straight copying, depending
	on the values of compressionMethod and desiredCompressionMethod"

	uncompressedSize = 0 ifTrue: [ ^self ].	"nothing to do because no data"
	start > finish ifTrue: [ ^self ].
	start > uncompressedSize ifTrue: [ ^self ].

	(compressionMethod = CompressionStored and: [ desiredCompressionMethod = CompressionDeflated ])
		ifTrue: [ ^self error: 'only supports uncompression or copying right now' ].

	(compressionMethod = CompressionDeflated and: [ desiredCompressionMethod = CompressionStored ])
		ifTrue: [ ^self uncompressDataTo: aStream from: start to: finish ].

	self copyRawDataTo: aStream from: start to: finish.
]

{ #category : 'private-writing' }
ZipArchiveMember >> writeLocalFileHeaderTo: aStream [
	"Write my local header to a file handle.
	Stores the offset to the start of the header in my
	writeLocalHeaderRelativeOffset member."

	| fileNameBytes |
	aStream nextPutAll: LocalFileHeaderSignature.
	aStream nextUint16Put: versionNeededToExtract bigEndian: false.
	aStream nextUint16Put: bitFlag bigEndian: false. "Bit 11: Language encoding flag (EFS) is set. See #initialize."
	aStream nextUint16Put: desiredCompressionMethod bigEndian: false.

	aStream nextUint32Put: lastModFileDateTime bigEndian: false.
	aStream nextUint32Put: crc32 bigEndian: false.
	aStream nextUint32Put: (desiredCompressionMethod = CompressionStored
							ifTrue: [ uncompressedSize ]
							ifFalse: [ compressedSize ]) bigEndian: false.
	aStream nextUint32Put: uncompressedSize bigEndian: false.

	fileNameBytes := fileName asByteArray.
	aStream nextUint16Put: fileNameBytes size bigEndian: false.
	aStream nextUint16Put: localExtraField size bigEndian: false.

	aStream nextPutAll: fileNameBytes.
	aStream nextPutAll: localExtraField.
]

{ #category : 'writing' }
ZipArchiveMember >> writeTo: aStream [
	self rewindData.
	writeLocalHeaderRelativeOffset _ aStream position.
	self writeLocalFileHeaderTo: aStream.
	self writeDataTo: aStream.
	self refreshLocalFileHeaderTo: aStream.
]
