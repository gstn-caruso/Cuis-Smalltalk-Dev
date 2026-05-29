Extension { #name : 'WriteStream' }

{ #category : '*JSON-printing' }
WriteStream >> jsonPrint: anObject [
	anObject jsonWriteOn: self
]
