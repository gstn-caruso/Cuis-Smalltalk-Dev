Class {
	#name : 'GZipWriteStream',
	#superclass : 'ZipWriteStream',
	#pools : [
		'GZipConstants'
	],
	#category : 'Compression-System',
	#package : 'Compression',
	#tag : 'System'
}

{ #category : 'file list services' }
GZipWriteStream class >> compressFile: aFileEntry [
	"Create a compressed file from the file of the given name"

	(aFileEntry readStream) compressFile
]

{ #category : 'file list services' }
GZipWriteStream class >> fileReaderServicesForFileEntry: aFileEntry suffix: suffix [
	"FileList buttons that are serviced by us."
	"Don't offer to compress already-compressed files
	sjc 3-May 2003-added jpeg extension"

	^({ 'gz' . 'sar' . 'zip' . 'gif' . 'jpg' . 'jpeg'. 'pr'. 'png' } includes: suffix)
		ifTrue: [ #() ]
		ifFalse: [ { self serviceCompressFile } ]

]

{ #category : 'file list services' }
GZipWriteStream class >> serviceCompressFile [

	^ (SimpleServiceEntry 
		provider: self 
		label: 'compress file'
		selector: #compressFile:
		description: 'compress file using gzip compression, making a new file'
		icon: #goBottomIcon) triggerFileListChanged
]

{ #category : 'initialization' }
GZipWriteStream >> writeFooter [
	"Write some footer information for the crc"
	super writeFooter.
	0 to: 3 do:[:i| encoder nextBytePut: (crc >> (i*8) bitAnd: 255)].
	0 to: 3 do:[:i| encoder nextBytePut: (bytesWritten >> (i*8) bitAnd: 255)].
]

{ #category : 'initialization' }
GZipWriteStream >> writeHeader [
	"Write the GZip header"
	encoder nextBits: 16 put: GZipMagic.
	encoder nextBits: 8 put: GZipDeflated.
	encoder nextBits: 8 put: 0. "No flags"
	encoder nextBits: 32 put: 0. "no time stamp"
	encoder nextBits: 8 put: 0. "No extra flags"
	encoder nextBits: 8 put: 0. "No OS type"

]
