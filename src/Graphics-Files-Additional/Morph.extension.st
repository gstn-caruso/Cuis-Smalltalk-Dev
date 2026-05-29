Extension { #name : 'Morph' }

{ #category : '*Graphics-Files-Additional' }
Morph >> exportAsPNG [
	"Export the receiver's image as a PNG."
	self request: 'Enter file name'
		initialAnswer: (self printStringLimitedTo: 20),'.png'
		do: [:aString| (self imageForm: 32) writePNGfileNamed: aString]
]
