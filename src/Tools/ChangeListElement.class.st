"
I am the superclass of elements of a ChangeList. My subinstances are built from fileout files.
"
Class {
	#name : 'ChangeListElement',
	#superclass : 'Object',
	#category : 'Tools-Changes',
	#package : 'Tools',
	#tag : 'Changes'
}

{ #category : 'perform' }
ChangeListElement >> addToCodeFile: aCodeFile [
	"Part of building a CodeFile object to represent changes and show them in a CodeFileBrowser."

	self subclassResponsibility
]

{ #category : 'accessing' }
ChangeListElement >> changeClass [
	^nil
]

{ #category : 'accessing' }
ChangeListElement >> changeClassName [
	^nil
]

{ #category : 'accessing' }
ChangeListElement >> compilerClass [
	^self changeClass
		ifNotNil: [ :cls | cls compilerClass ]
		ifNil: [ Compiler ]
]

{ #category : 'fileIn/fileOut' }
ChangeListElement >> fileIn [

	self subclassResponsibility 
]

{ #category : 'fileIn/fileOut' }
ChangeListElement >> fileOutOn: aFileStream [

	self subclassResponsibility 
]

{ #category : 'testing' }
ChangeListElement >> isClassComment [
	^false
]

{ #category : 'testing' }
ChangeListElement >> isClassDefinition [
	^false
]

{ #category : 'testing' }
ChangeListElement >> isClassDeletion [
	^false
]

{ #category : 'testing' }
ChangeListElement >> isClassRenamed [
	^false
]

{ #category : 'testing' }
ChangeListElement >> isDoIt [

	^false
]

{ #category : 'testing' }
ChangeListElement >> isMethod [

	^false
]

{ #category : 'testing' }
ChangeListElement >> isMethodDefinition [

	^false
]

{ #category : 'testing' }
ChangeListElement >> isMethodDeletion [
	^false
]

{ #category : 'accessing' }
ChangeListElement >> methodSelector [
	^nil
]

{ #category : 'accessing' }
ChangeListElement >> string [

	self subclassResponsibility 
]

{ #category : 'accessing' }
ChangeListElement >> text [
	"In Cuis, all source code is plain Strings"
	^self string
]
