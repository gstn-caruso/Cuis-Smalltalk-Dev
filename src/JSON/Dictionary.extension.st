Extension { #name : 'Dictionary' }

{ #category : '*JSON-writing' }
Dictionary >> jsonWriteOn: aStream [
	"Dictionaries are written as 'JSON Objects'
	Use the general implementation for that."

	self jsonObjectWriteOn: aStream
]
