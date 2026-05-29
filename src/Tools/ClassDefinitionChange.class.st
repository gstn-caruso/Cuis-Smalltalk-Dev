"
A ClassDefinitionChange represents a change recorded on a file in fileOut format.
It includes a type (more needs to be done here), and additional information
for certain types such as method defs which need class and category.
"
Class {
	#name : 'ClassDefinitionChange',
	#superclass : 'ChangeListElement',
	#instVars : [
		'file',
		'position',
		'class',
		'category',
		'meta',
		'stamp'
	],
	#category : 'Tools-Changes',
	#package : 'Tools',
	#tag : 'Changes'
}

{ #category : 'perform' }
ClassDefinitionChange >> addToCodeFile: aCodeFile [
	"Part of building a CodeFile object to represent changes and show them in a CodeFileBrowser."

	aCodeFile classDefinition: self.
]

{ #category : 'accessing' }
ClassDefinitionChange >> changeClass [
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
ClassDefinitionChange >> changeClassName [
	^class
]

{ #category : 'accessing' }
ClassDefinitionChange >> dateAndTime [

	^CompiledMethod authorAndStamp: stamp partsDo: [ :authorInitials :dateAndTime | dateAndTime ]
]

{ #category : 'initialization' }
ClassDefinitionChange >> file: aFile position: aPosition class: aClassName category: aClassCategory meta: isMeta stamp: aStamp [

	file := aFile.
	position := aPosition.
	class := aClassName.
	category := aClassCategory.
	meta := isMeta.
	stamp := aStamp.
]

{ #category : 'initialization' }
ClassDefinitionChange >> fileIn [
	"File the receiver in.  Apply the change.  (Re)Define the class."

	Compiler evaluate: self string.
]

{ #category : 'accessing' }
ClassDefinitionChange >> fileName [
	^(file ifNotNil: [ file name ]) 
			ifNil: [ '<no file>' ]
]

{ #category : 'accessing' }
ClassDefinitionChange >> fileOutOn: aFileStream [
	"File the receiver out on the given file stream"

	aFileStream nextPut: $!.
	aFileStream nextChunkPut: 
		'classDefinition: ', 
		(self isMetaClassChange ifTrue: [self changeClassName, ' class'] ifFalse: [self changeClassName]) printString,
		' category: ', category printString.
	aFileStream newLine.
	aFileStream nextChunkPut: self string.
	aFileStream newLine.
]

{ #category : 'testing' }
ClassDefinitionChange >> isClassDefinition [
	^true
]

{ #category : 'accessing' }
ClassDefinitionChange >> isMetaClassChange [
	^meta
]

{ #category : 'accessing' }
ClassDefinitionChange >> stamp [
	^ stamp
]

{ #category : 'accessing' }
ClassDefinitionChange >> string [
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
