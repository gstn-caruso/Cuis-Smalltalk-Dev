"
This class is only meant to be used by for loading DynamicCuisLibraries. Main reaso is that MinimalImages, don't have the full System-File System and System-Files categories.

 This class can't replace any kind of Stream, and can only deal with the whole contents of files at once.
"
Class {
	#name : 'BasicFileServices',
	#superclass : 'Object',
	#category : 'DynamicCuisLibraries',
	#package : 'DynamicCuisLibraries'
}

{ #category : 'services' }
BasicFileServices class >> binaryContentsOf: fileName [
	"
	Answer a ByteArray with the complete contents of a file.
	Name must be ASCII. It is just a file name. No path.
	BasicFileServices binaryContentsOf: 'comoVamos.txt'
	"
	| fileID size bytes count |
	fileID := self primOpen: fileName writable: false.
	size := self primSize: fileID.
	bytes := ByteArray new: size.
	count := self primRead: fileID into: bytes startingAt: 1 count: size.
	count ifNil: [
		"Alternatively, answer nil."
		^ self error: 'Could not read file: ', fileName ].
	count < size ifTrue: [ bytes := bytes copyFrom: 1 to: count ].
	self primClose: fileID.
	^bytes
]

{ #category : 'primitives' }
BasicFileServices class >> primClose: id [
	<primitive: 'primitiveFileClose' module: 'FilePlugin'>
	^nil
]

{ #category : 'primitives' }
BasicFileServices class >> primOpen: fileNameAsUtf8Bytes writable: writableFlag [
	<primitive: 'primitiveFileOpen' module: 'FilePlugin'>
	^ nil

]

{ #category : 'primitives' }
BasicFileServices class >> primRead: id into: byteArray startingAt: startIndex count: count [
	<primitive: 'primitiveFileRead' module: 'FilePlugin'>
	^nil
]

{ #category : 'primitives' }
BasicFileServices class >> primSize: id [
	<primitive: 'primitiveFileSize' module: 'FilePlugin'>
	^0

]

{ #category : 'primitives' }
BasicFileServices class >> primWorkingDirectory [
	<primitive: 'primitiveGetWorkingDirectory' module: 'FilePlugin' error: ec>
	^nil
]
