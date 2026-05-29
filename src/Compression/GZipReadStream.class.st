Class {
	#name : 'GZipReadStream',
	#superclass : 'FastInflateStream',
	#pools : [
		'GZipConstants'
	],
	#category : 'Compression-System',
	#package : 'Compression',
	#tag : 'System'
}

{ #category : 'fileIn/Out' }
GZipReadStream class >> fileReaderServicesForFileEntry: aFileEntry suffix: suffix [
	"FileList buttons that are serviced by us."

	^suffix = 'gz'
		ifTrue: [ {self serviceViewDecompress. self serviceDecompressToFile} ]
		ifFalse: [ #() ]
]

{ #category : 'fileIn/Out' }
GZipReadStream class >> saveContents: aFileEntry [
	"Save the contents of a gzipped file"
	| zipped buffer newFile |
	newFile := aFileEntry parent // aFileEntry baseName.
	newFile writeStreamDo: [ :unzipped |
		unzipped binary.
		aFileEntry readStreamDo: [ :zipContents |
			zipped _ GZipReadStream on: zipContents.
			buffer _ ByteArray new: 50000.
			'Extracting ' , aFileEntry asString
				displayProgressAt: Sensor mousePoint
				from: 0
				to: zipped sourceStream size
				during: [ :barBlock | 
					[ zipped atEnd ]
						whileFalse: [
							barBlock value: zipped sourceStream position.
							unzipped nextPutAll: (zipped nextInto: buffer) ]]]].
	^ newFile 
]

{ #category : 'fileIn/Out' }
GZipReadStream class >> serviceDecompressToFile [

	^ (SimpleServiceEntry 
		provider: self 
		label: 'decompress to file'
		selector: #saveContents:
		description: 'decompress to file'
		icon: #goTopIcon) triggerFileListChanged
]

{ #category : 'fileIn/Out' }
GZipReadStream class >> serviceViewDecompress [

	^ SimpleServiceEntry 
		provider: self 
		label: 'view decompressed'
		selector: #viewContents:
		description: 'view decompressed'
		icon: #findIcon
]

{ #category : 'fileIn/Out' }
GZipReadStream class >> viewContents: aFileEntry [
	"Open the decompressed contents of the .gz file with the given name.  This method is only required for the registering-file-list of Squeak 3.3a and beyond, but does no harm in an earlier system"

	(aFileEntry readStream ) ifNotNil: [ :aStream | 
		aStream viewGZipContents]
]

{ #category : 'initialization' }
GZipReadStream >> on: aCollection from: firstIndex to: lastIndex [
	"Check the header of the GZIP stream."
	| method magic flags length |
	super on: aCollection from: firstIndex to: lastIndex.
	crc _ 16rFFFFFFFF.
	magic _ self nextBits: 16.
	(magic = GZipMagic) 
		ifFalse:[^self error:'Not a GZipped stream'].
	method _ self nextBits: 8.
	(method = GZipDeflated)
		ifFalse:[^self error:'Bad compression method'].
	flags _ self nextBits: 8.
	(flags anyMask: GZipEncryptFlag) 
		ifTrue:[^self error:'Cannot decompress encrypted stream'].
	(flags anyMask: GZipReservedFlags)
		ifTrue:[^self error:'Cannot decompress stream with unknown flags'].
	"Ignore stamp, extra flags, OS type"
	self nextBits: 16; nextBits: 16. "stamp"
	self nextBits: 8. "extra flags"
	self nextBits: 8. "OS type"
	(flags anyMask: GZipContinueFlag) "Number of multi-part archive - ignored"
		ifTrue:[self nextBits: 16]. 
	(flags anyMask: GZipExtraField) "Extra fields - ignored"
		ifTrue:[	length _ self nextBits: 16.
				1 to: length do:[:i| self nextBits: 8]].
	(flags anyMask: GZipNameFlag) "Original file name - ignored"
		ifTrue:[[(self nextBits: 8) = 0] whileFalse].
	(flags anyMask: GZipCommentFlag) "Comment - ignored"
		ifTrue:[[(self nextBits: 8) = 0] whileFalse].

]

{ #category : 'crc' }
GZipReadStream >> updateCrc: oldCrc from: start to: stop in: aCollection [
	"Answer an updated CRC for the range of bytes in aCollection"
	^ZipWriteStream updateCrc: oldCrc from: start to: stop in: aCollection.
]

{ #category : 'crc' }
GZipReadStream >> verifyCrc [
	| stored |
	stored := 0.
	0 to: 24 by: 8 do: [ :i |
		sourcePos >= sourceLimit ifTrue: [ ^ self crcError: 'No checksum (proceed to ignore)' ].
		stored := stored + (self nextByte bitShift: i) ].
	stored := stored bitXor: 16rFFFFFFFF.
	stored = crc ifFalse: [ ^ self crcError: 'Wrong checksum (proceed to ignore)' ].
	^stored
]
