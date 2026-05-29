Extension { #name : 'Form' }

{ #category : '*Graphics-Files-Additional' }
Form >> writePNGfile: fileEntry [
	"
	Display writePNGfile: 'display.png' asFileEntry
	"
	PNGReadWriter putForm: self onFile: fileEntry
]

{ #category : '*Graphics-Files-Additional' }
Form >> writePNGfileNamed: fName [
	"
	Display writePNGfileNamed: 'display.png'
	"
	PNGReadWriter putForm: self onFileNamed: fName
]
