"
A ClassCommentChange represents a change recorded on a file in fileOut format.
It includes a type (more needs to be done here), and additional information
for certain types such as method defs which need class and category.
"
Class {
	#name : 'ClassCommentChange',
	#superclass : 'ChangeListElement',
	#instVars : [
		'file',
		'position',
		'class',
		'stamp'
	],
	#category : 'Tools-Changes',
	#package : 'Tools',
	#tag : 'Changes'
}

{ #category : 'perform' }
ClassCommentChange >> addToCodeFile: aCodeFile [
	"Part of building a CodeFile object to represent changes and show them in a CodeFileBrowser."

	aCodeFile classComment: self.
]

{ #category : 'accessing' }
ClassCommentChange >> changeClass [
	| className |
	className := class substrings
		ifEmpty: [ ^ nil ]
		ifNotEmpty: [ :parts |
			parts first ].
	^(Smalltalk hasClassNamed: className) ifTrue: [
		Smalltalk classNamed: className ]
]

{ #category : 'accessing' }
ClassCommentChange >> changeClassName [
	^class
]

{ #category : 'accessing' }
ClassCommentChange >> dateAndTime [

	^CompiledMethod authorAndStamp: stamp partsDo: [ :authorInitials :dateAndTime | dateAndTime ]
]

{ #category : 'initialization' }
ClassCommentChange >> file: aFile position: aPosition class: aClassName stamp: aStamp [

	file := aFile.
	position := aPosition.
	class := aClassName.
	stamp := aStamp.
]

{ #category : 'initialization' }
ClassCommentChange >> fileIn [
	"File the receiver in.  Apply the change.  Update the class comment."

	(Smalltalk at: class)
		comment: self text
		stamp: stamp.
]

{ #category : 'accessing' }
ClassCommentChange >> fileName [
	^(file ifNotNil: [ file name ]) 
			ifNil: [ '<no file>' ]
]

{ #category : 'accessing' }
ClassCommentChange >> fileOutOn: aFileStream [
	"File the receiver out on the given file stream"

	aFileStream nextPut: $!.
	aFileStream nextChunkPut: class asString, ' commentStamp: ', stamp storeString.
	aFileStream newLine.
	aFileStream nextChunkPut: self string.
	aFileStream newLine.
]

{ #category : 'testing' }
ClassCommentChange >> isClassComment [
	^true
]

{ #category : 'accessing' }
ClassCommentChange >> stamp [
	^ stamp
]

{ #category : 'accessing' }
ClassCommentChange >> string [
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
