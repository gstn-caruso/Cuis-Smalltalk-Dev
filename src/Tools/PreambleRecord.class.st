"
A PreambleRecord represents a change recorded on a file in fileOut format.
It includes a type (more needs to be done here), and additional information
for certain types such as method defs which need class and category.
"
Class {
	#name : 'PreambleRecord',
	#superclass : 'ChangeListElement',
	#instVars : [
		'file',
		'position',
		'stamp'
	],
	#category : 'Tools-Changes',
	#package : 'Tools',
	#tag : 'Changes'
}

{ #category : 'perform' }
PreambleRecord >> addToCodeFile: aCodeFile [
	"Part of building a CodeFile object to represent changes and show them in a CodeFileBrowser."

	aCodeFile preamble: self.
]

{ #category : 'accessing' }
PreambleRecord >> dateAndTime [

	^CompiledMethod authorAndStamp: stamp partsDo: [ :authorInitials :dateAndTime | dateAndTime ]
]

{ #category : 'initialization' }
PreambleRecord >> file: aFile position: aPosition [

	file := aFile.
	position := aPosition.
"
file closed ifFalse: [
	'' print.
	file print.
	self print.
	thisContext printStack: 10 ]
"
]

{ #category : 'initialization' }
PreambleRecord >> fileIn [
	"File the receiver in.
	Nothing to do for us."

]

{ #category : 'accessing' }
PreambleRecord >> fileName [
	^(file ifNotNil: [ file name ]) 
			ifNil: [ '<no file>' ]
]

{ #category : 'accessing' }
PreambleRecord >> fileOutOn: aFileStream [
	"File the receiver out on the given file stream"

	aFileStream nextPut: $!.
	aFileStream nextChunkPut: self string.
	aFileStream newLine.
]

{ #category : 'accessing' }
PreambleRecord >> stamp [
	^ stamp
]

{ #category : 'accessing' }
PreambleRecord >> string [
	"The file is usually closed. But if it happens to be open, leave it like that."
	| string mustOpenAndClose |
	mustOpenAndClose := file closed.
	mustOpenAndClose ifTrue: [
		file openReadOnly ].
	file position: position.
	string := file nextChunk withCuisLineEndings.
	mustOpenAndClose ifTrue: [
		file close].
	^ string
]
