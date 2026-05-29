"
ZipStringMember instances are used to represent files that are going to be written to a ZipArchive.
Their data comes from in-image strings or ByteArrays, though.
"
Class {
	#name : 'ZipStringMember',
	#superclass : 'ZipArchiveMember',
	#instVars : [
		'contents',
		'stream'
	],
	#category : 'Compression-Archives',
	#package : 'Compression',
	#tag : 'Archives'
}

{ #category : 'as yet unclassified' }
ZipStringMember class >> newFrom: aString named: aFileName [
	^(self new) contents: aString; localFileName: aFileName; yourself
]

{ #category : 'initialization' }
ZipStringMember >> contents [
	^contents
]

{ #category : 'initialization' }
ZipStringMember >> contents: aStringOrByteArray [
	contents := aStringOrByteArray asByteArray.
	compressedSize := uncompressedSize := contents size.
	"set the file date to now"
	self setLastModFileDateTimeFrom: Time localSecondClock
]

{ #category : 'initialization' }
ZipStringMember >> initialize [
	super initialize.
	self contents: ''.
	compressionMethod _ desiredCompressionMethod _ CompressionStored.

]

{ #category : 'private' }
ZipStringMember >> readRawChunk: n [
	^stream next: n
]

{ #category : 'private-writing' }
ZipStringMember >> rewindData [
	super rewindData.
	stream _ ReadStream on: contents.
	readDataRemaining _ contents size.
]
