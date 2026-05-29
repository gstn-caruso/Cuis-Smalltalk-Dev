"
Can process chunked data.
"
Class {
	#name : 'WebChunkedStream',
	#superclass : 'ReadStream',
	#instVars : [
		'sourceStream',
		'chunkSize'
	],
	#category : 'WebClient-Core',
	#package : 'WebClient',
	#tag : 'Core'
}

{ #category : 'testing' }
WebChunkedStream >> atEnd [
	^chunkSize = 0 and:[super atEnd]
]

{ #category : 'accessing' }
WebChunkedStream >> next [
	"Answer the next decompressed object in the Stream represented by the
	receiver."

	<primitive: 65>
	position >= readLimit
		ifTrue: [^self pastEndRead]
		ifFalse: [^collection at: (position := position + 1)]
]

{ #category : 'accessing' }
WebChunkedStream >> next: anInteger  [
	"Answer the next anInteger elements of my collection.  overriden for simplicity"

	[(position + anInteger >= readLimit) and:[chunkSize ~= 0]] 
		whileTrue:[self nextChunk].

	^super next: anInteger

]

{ #category : 'accessing' }
WebChunkedStream >> nextChunk [
	"Answer the next chunk from a message using chunked transfer encoding."

	| chunk |
	chunkSize = 0 ifTrue:[^'']. "read last chunk"
	chunkSize := Integer readFrom: (sourceStream upToAll: String crlfString) asString base: 16.
	chunkSize = 0 ifFalse:[chunk := sourceStream next: chunkSize].
	sourceStream skip: 2. "CrLf"
	(chunkSize + readLimit - position) <= collection size ifTrue:[
		collection replaceFrom: 1 to: (readLimit-position) with: collection startingAt: position+1.
		readLimit := readLimit - position.
		position := 0.
		collection replaceFrom: readLimit+1 to: readLimit + chunkSize with: chunk startingAt: 1.
		readLimit := readLimit + chunkSize.
	] ifFalse:[
		collection := collection, chunk.
		readLimit := readLimit + chunkSize.
	].
	^chunk

]

{ #category : 'initialize' }
WebChunkedStream >> on: aStream [

	sourceStream := aStream.
	collection := (aStream isBinary ifTrue:[ByteArray] ifFalse:[String]) new.
	position := readLimit := 0.
]

{ #category : 'accessing' }
WebChunkedStream >> pastEndRead [
	"Need more data"

	self nextChunk.
	^self next
]
