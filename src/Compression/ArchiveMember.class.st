"
This is the abstract superclass for archive members, which are files or directories stored in archives.
"
Class {
	#name : 'ArchiveMember',
	#superclass : 'Object',
	#instVars : [
		'fileName',
		'isCorrupt'
	],
	#category : 'Compression-Archives',
	#package : 'Compression',
	#tag : 'Archives'
}

{ #category : 'as yet unclassified' }
ArchiveMember class >> newDirectoryNamed: aString [
	self subclassResponsibility
]

{ #category : 'as yet unclassified' }
ArchiveMember class >> newFromFile: aFileName [
	self subclassResponsibility
]

{ #category : 'as yet unclassified' }
ArchiveMember class >> newFromString: aString [
	self subclassResponsibility
]

{ #category : 'initialization' }
ArchiveMember >> close [

]

{ #category : 'accessing' }
ArchiveMember >> fileName [
	^fileName
]

{ #category : 'accessing' }
ArchiveMember >> fileName: aName [
	fileName _ aName
]

{ #category : 'initialization' }
ArchiveMember >> initialize [
	fileName _ ''.
	isCorrupt _ false.
]

{ #category : 'accessing' }
ArchiveMember >> isCorrupt [
	^isCorrupt ifNil: [ isCorrupt _ false ]
]

{ #category : 'accessing' }
ArchiveMember >> isCorrupt: aBoolean [
	"Mark this member as being corrupt."
	isCorrupt := aBoolean
]

{ #category : 'accessing' }
ArchiveMember >> localFileName: aString [
	"Set my internal filename.
	Returns the (possibly new) filename.
	aString will be translated from local FS format into Unix format."

	^fileName _ aString copyReplaceAll: '\' with: '/'.
]

{ #category : 'printing' }
ArchiveMember >> printOn: aStream [
	super printOn: aStream.
	aStream nextPut: $(;
		nextPutAll: self fileName;
		nextPut: $)
]

{ #category : 'testing' }
ArchiveMember >> usesFileNamed: aFileName [
	"Do I require aFileName? That is, do I care if it's clobbered?"
	^false
]
