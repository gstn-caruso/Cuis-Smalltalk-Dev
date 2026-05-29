"
A UnspecificRecord represents a change recorded on a file in fileOut format.
It includes a type (more needs to be done here), and additional information
for certain types such as method defs which need class and category.
"
Class {
	#name : 'UnspecificRecord',
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
UnspecificRecord >> addToCodeFile: aCodeFile [
	"Part of building a CodeFile object to represent changes and show them in a CodeFileBrowser."

	aCodeFile doIt: self.
]

{ #category : 'accessing' }
UnspecificRecord >> dateAndTime [

	^CompiledMethod authorAndStamp: stamp partsDo: [ :authorInitials :dateAndTime | dateAndTime ]
]

{ #category : 'initialization' }
UnspecificRecord >> file: aFile position: aPosition [

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
UnspecificRecord >> fileIn [
	"File the receiver in.  Evaluate the DoIt."

	| s |
	((s := self string) beginsWith: '----') ifFalse: [
		Compiler evaluate: s ].
]

{ #category : 'accessing' }
UnspecificRecord >> fileName [
	^(file ifNotNil: [ file name ]) 
			ifNil: [ '<no file>' ]
]

{ #category : 'accessing' }
UnspecificRecord >> fileOutOn: aFileStream [
	"File the receiver out on the given file stream"

	aFileStream nextChunkPut: self string.
	aFileStream newLine.
]

{ #category : 'testing' }
UnspecificRecord >> isDoIt [

	^true
]

{ #category : 'accessing' }
UnspecificRecord >> stamp [
	^ stamp
]

{ #category : 'accessing' }
UnspecificRecord >> string [
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
