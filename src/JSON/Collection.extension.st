Extension { #name : 'Collection' }

{ #category : '*JSON' }
Collection >> jsonObjectWriteOn: aStream [
	"Write as 'JSON Object' format
	This is a list of (name:value) pairs, and is analogous to Smalltalk Dictionaries where names (keys) are strings.
	Assume the receiver is either:
	- a Dictionary
	- a collection of Association objects (or some sort of object that on #jsonWriteOn: print like an Association)"

	| needComma |
	needComma := false.
	aStream nextPut: ${.
	self associationsDo: [ :assoc |
		needComma
			ifTrue: [ aStream nextPut: $, ; space]
			ifFalse: [ needComma := true ].
		assoc jsonWriteOn: aStream ].
	aStream nextPut: $}
]

{ #category : '*JSON' }
Collection >> jsonWriteElement: element on: aStream [
	"Allow for specific subclasses (FloatArray, using 32 bit Floats!) to use specific way to write its elements"

	element jsonWriteOn: aStream
]

{ #category : '*JSON' }
Collection >> jsonWriteOn: aStream [
	"By default, use array braces "
	| useNewLines |
	aStream nextPut: $[.

	useNewLines _ nil.
	self do: [ :each |
		useNewLines ifNil: [
			useNewLines _ each isLiteral not ].
		self jsonWriteElement: each on: aStream.
	] separatedBy: [
		aStream nextPut: $, .
		useNewLines ifTrue: [ aStream newLine ]].

	aStream nextPut: $]
]
