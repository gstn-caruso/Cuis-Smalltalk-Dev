"
A MethodDefinitionChange represents a change recorded on a file in fileOut format.
It includes a type (more needs to be done here), and additional information
for certain types such as method defs which need class and category.
"
Class {
	#name : 'MethodDefinitionChange',
	#superclass : 'ChangeListElement',
	#instVars : [
		'file',
		'position',
		'class',
		'category',
		'meta',
		'stamp',
		'prior',
		'libraryName'
	],
	#category : 'Tools-Changes',
	#package : 'Tools',
	#tag : 'Changes'
}

{ #category : 'perform' }
MethodDefinitionChange >> addToCodeFile: aCodeFile [
	"Part of building a CodeFile object to represent changes and show them in a CodeFileBrowser."

	aCodeFile method: self.
]

{ #category : 'accessing' }
MethodDefinitionChange >> category [
	^category
]

{ #category : 'accessing' }
MethodDefinitionChange >> changeClass [
	| className cls |
	className := class substrings
		ifEmpty: [ ^ nil ]
		ifNotEmpty: [ :parts |
			parts first ].
	(Smalltalk hasClassNamed: className) ifFalse: [ ^ nil ].
	cls := Smalltalk classNamed: className.
	^ meta
		ifTrue: [ cls class ]
		ifFalse: [ cls ]
]

{ #category : 'accessing' }
MethodDefinitionChange >> changeClassName [
	^class
]

{ #category : 'accessing' }
MethodDefinitionChange >> dateAndTime [

	^CompiledMethod authorAndStamp: stamp partsDo: [ :authorInitials :dateAndTime | dateAndTime ]
]

{ #category : 'initialization' }
MethodDefinitionChange >> file: aFile position: aPosition class: aClassName category: aClassCategory meta: isMeta stamp: aStamp prior: aPrior libraryName: aString [

	file := aFile.
	position := aPosition.
	class := aClassName.
	category := aClassCategory.
	meta := isMeta.
	stamp := aStamp.
	prior := aPrior.
	libraryName := aString.
]

{ #category : 'initialization' }
MethodDefinitionChange >> fileIn [
	"File the receiver in.  Apply the change.  Define the method."

	self changeClass ifNotNil: [ :methodClass |
		methodClass
			compile: self text
			classified: category
			withStamp: stamp
			libraryName: libraryName
			notifying: nil ].
]

{ #category : 'accessing' }
MethodDefinitionChange >> fileName [
	^(file ifNotNil: [ file name ]) 
			ifNil: [ '<no file>' ]
]

{ #category : 'accessing' }
MethodDefinitionChange >> fileOutOn: aFileStream [
	"File the receiver out on the given file stream"

	self changeClass printCategoryChunk: category on: aFileStream
		withStamp: stamp libraryName: libraryName priorMethod: nil.
	aFileStream newLine.
	aFileStream nextChunkPut: self string.
	aFileStream nextChunkPut: ' '; newLine.
	aFileStream newLine.
]

{ #category : 'accessing' }
MethodDefinitionChange >> isMetaClassChange [
	^meta
]

{ #category : 'testing' }
MethodDefinitionChange >> isMethod [

	^true
]

{ #category : 'testing' }
MethodDefinitionChange >> isMethodDefinition [

	^true
]

{ #category : 'accessing' }
MethodDefinitionChange >> methodSelector [
	^(Smalltalk at: class ifAbsent: [Object]) parserClass new parseSelector: self string
]

{ #category : 'accessing' }
MethodDefinitionChange >> stamp [
	^ stamp
]

{ #category : 'accessing' }
MethodDefinitionChange >> string [
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
