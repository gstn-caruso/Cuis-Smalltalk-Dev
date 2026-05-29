Class {
	#name : 'ClassRenamedChange',
	#superclass : 'ChangeListElement',
	#instVars : [
		'previousName',
		'newName',
		'stamp'
	],
	#category : 'Tools-Changes',
	#package : 'Tools',
	#tag : 'Changes'
}

{ #category : 'instance creation' }
ClassRenamedChange class >> from: previousClassName to: newClassName stamp: aString [
	^self new initializeFrom: previousClassName to: newClassName stamp: aString 
]

{ #category : 'perform' }
ClassRenamedChange >> addToCodeFile: aCodeFile [
	"Part of building a CodeFile object to represent changes and show them in a CodeFileBrowser."

	aCodeFile classRenaming: self.
]

{ #category : 'accessing' }
ClassRenamedChange >> changeClass [
	^Smalltalk at: previousName ifAbsent: nil
]

{ #category : 'accessing' }
ClassRenamedChange >> changeClassName [
	^ previousName 
]

{ #category : 'printing' }
ClassRenamedChange >> command [
	^ 'Smalltalk renameClassNamed: #', previousName, ' as: #', newName
]

{ #category : 'fileIn/fileOut' }
ClassRenamedChange >> fileIn [

	Smalltalk renameClassNamed: previousName as: newName
]

{ #category : 'fileIn/fileOut' }
ClassRenamedChange >> fileOutOn: aFileStream [
	"File the receiver out on the given file stream"

	aFileStream nextPut: $!.
	aFileStream nextChunkPut: 'classRenamed: #', previousName, ' as: #', newName.
	aFileStream newLine.
	
	aFileStream nextChunkPut: self command.
	aFileStream newLine.
]

{ #category : 'initialization' }
ClassRenamedChange >> initializeFrom: previousClassName to: newClassName stamp: aString  [

	previousName := previousClassName.
	newName := newClassName.
	stamp := aString.
]

{ #category : 'testing' }
ClassRenamedChange >> isClassRenamed [
	^true
]

{ #category : 'accessing' }
ClassRenamedChange >> newClassName [
	^ newName 
]

{ #category : 'accessing' }
ClassRenamedChange >> stamp [
	^stamp
]

{ #category : 'printing' }
ClassRenamedChange >> string [
	^ 'Smalltalk renameClassNamed: #', previousName, ' as: #', newName
]
