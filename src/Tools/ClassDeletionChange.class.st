"
Used to represent classes that will be deleted on install.
"
Class {
	#name : 'ClassDeletionChange',
	#superclass : 'ChangeListElement',
	#instVars : [
		'className',
		'classDefinition',
		'stamp',
		'appliesTo'
	],
	#category : 'Tools-Changes',
	#package : 'Tools',
	#tag : 'Changes'
}

{ #category : 'instance creation' }
ClassDeletionChange class >> className: aClassName definition: aClassDefinition appliesOnlyTo: packageOrBaseImageNameOrNil stamp: aStamp [

	^self new
		initializeClassName: aClassName
		definition: aClassDefinition
		appliesOnlyTo: packageOrBaseImageNameOrNil
		stamp: aStamp
]

{ #category : 'perform' }
ClassDeletionChange >> addToCodeFile: aCodeFile [
	"Part of building a CodeFile object to represent changes and show them in a CodeFileBrowser."

	aCodeFile classRemoval: self.
]

{ #category : 'accessing' }
ClassDeletionChange >> changeClass [
	^Smalltalk at: className ifAbsent: nil
]

{ #category : 'accessing' }
ClassDeletionChange >> changeClassName [
	^className
]

{ #category : 'accessing' }
ClassDeletionChange >> className: aSymbol [

	className := aSymbol
]

{ #category : 'services' }
ClassDeletionChange >> command [

	^appliesTo
		ifNotNil: [ 'Smalltalk removeClassNamed: #', className, ' ifIn: ', appliesTo printString ]
		ifNil: [ 'Smalltalk removeClassNamed: #', className ].

]

{ #category : 'fileIn/fileOut' }
ClassDeletionChange >> fileIn [

	appliesTo
		ifNotNil: [ Smalltalk removeClassNamed: className ifIn: appliesTo]
		ifNil: [ self changeClass ifNotNil: [ :aClass | aClass removeFromSystem ] ].
]

{ #category : 'fileIn/fileOut' }
ClassDeletionChange >> fileOutOn: stream [
	"File the receiver out on the given file stream"

	| record |

	record := String streamContents: [ :recordStream |
		recordStream
			nextPutAll: 'classRemoval: #';
			nextPutAll: className.
		appliesTo ifNotNil: [
			recordStream
				nextPutAll: ' restrictedTo: ';
				print: appliesTo ].
		recordStream
			nextPutAll: ' stamp: ';
			print: stamp ].

	stream
		nextPut: $!;
		nextChunkPut: record;
		newLine;
		nextChunkPut: self command;
		newLine; newLine.
]

{ #category : 'initialization' }
ClassDeletionChange >> initialize [
	appliesTo := nil.
]

{ #category : 'initialization' }
ClassDeletionChange >> initializeClassName: aClassName definition: aClassDefinition appliesOnlyTo: packageOrBaseImageNameOrNil stamp: aStamp  [

	className := aClassName.
	classDefinition := aClassDefinition.
	appliesTo := packageOrBaseImageNameOrNil.
	stamp := aStamp.
]

{ #category : 'testing' }
ClassDeletionChange >> isClassDeletion [
	^true
]

{ #category : 'accessing' }
ClassDeletionChange >> stamp [

	^stamp
]

{ #category : 'accessing' }
ClassDeletionChange >> string [
	
	^classDefinition ifNil: [ '' ]
]
