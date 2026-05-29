Extension { #name : 'ReadWriteStream' }

{ #category : '*Compression' }
ReadWriteStream >> isZipArchive [
	"Determine if this appears to be a valid Zip archive"
	|  sig |
	self binary.
	sig := self next: 4.
	self position: self position - 4. "rewind"
	^ (ZipArchive validSignatures includes: sig)
]

{ #category : '*Compression' }
ReadWriteStream >> unzippedContentsOf: memberFileName [
	"Decompress this file if needed, and return its bytes.
	No file is written.  File extension may be .gz or anything else.  Also works on archives (.zip, .gZip)."

	| bytes archive which |
	self binary.
	self isZipArchive ifFalse: [
		^self error: 'Not a Zip file' ].
	
	archive := ZipArchive new readFrom: self.
	which := archive members 
		detect: [:any | any fileName  = memberFileName] 
		ifNone: nil.
	which ifNil: [
		archive close.
		^ self error: 'Can''t find requested file in archive'].
	bytes := which contents.
	archive close.
	^ bytes
]

{ #category : '*Compression' }
ReadWriteStream >> unzippedStringContentsOf: memberFileName [
	"Decompress this file if needed, and return a String with its contents.
	No file is written.  File extension may be .gz or anything else.  Also works on archives (.zip, .gZip)."

	| bytes |
	bytes := self unzippedContentsOf: memberFileName.
	^UnicodeString fromUtf8Bytes: bytes.
]

{ #category : '*Compression' }
ReadWriteStream >> unzippedStringLFContentsOf: memberFileName [
	"Decompress this file if needed, and return a String with its contents.
	No file is written.  File extension may be .gz or anything else.  Also works on archives (.zip, .gZip).
	Convert line terminators to LF. Useful for Smalltalk code from Squeak."

	| bytes |
	bytes := self unzippedContentsOf: memberFileName.
	(bytes includes: 13) ifTrue: [
		bytes := String string: bytes withLineEndings: #(10) ].
	^UnicodeString fromUtf8Bytes: bytes.
]
