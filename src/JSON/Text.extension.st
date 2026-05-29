Extension { #name : 'Text' }

{ #category : '*JSON-printing' }
Text >> jsonWriteOn: aStream [
	self string jsonWriteOn: aStream
]
