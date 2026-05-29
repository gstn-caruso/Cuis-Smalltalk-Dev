"
Used to represent methods that will be deleted on install.
"
Class {
	#name : 'MethodDeletionChange',
	#superclass : 'ChangeListElement',
	#instVars : [
		'methodReference',
		'sourceCode',
		'stamp',
		'appliesTo'
	],
	#category : 'Tools-Changes',
	#package : 'Tools',
	#tag : 'Changes'
}

{ #category : 'instance creation' }
MethodDeletionChange class >> methodReference: aMethodReference appliesOnlyTo: packageOrBaseImageNameOrNil source: aSourceCode stamp: aStamp [

	^self new
		initializeMethodReference: aMethodReference
		appliesOnlyTo: packageOrBaseImageNameOrNil
		source: aSourceCode
		stamp: aStamp
]

{ #category : 'perform' }
MethodDeletionChange >> addToCodeFile: aCodeFile [
	"Part of building a CodeFile object to represent changes and show them in a CodeFileBrowser."

	aCodeFile removedMethod: self command with: self.
]

{ #category : 'accessing' }
MethodDeletionChange >> changeClass [
	^methodReference actualClass
]

{ #category : 'accessing' }
MethodDeletionChange >> changeClassName [
	^methodReference classIsMeta
		ifFalse: [ methodReference classSymbol ]
		ifTrue: [ methodReference classSymbol, ' class' ]
]

{ #category : 'services' }
MethodDeletionChange >> command [

	^String streamContents: [ :stream |
		stream
			nextPutAll: self changeClassName;
			nextPutAll: ' removeSelector: ';
			nextPutAll: self methodSelector storeString.
		appliesTo ifNotNil: [
			stream nextPutAll: ' ifIn: '; print: appliesTo ]]
]

{ #category : 'fileIn/fileOut' }
MethodDeletionChange >> fileIn [

	appliesTo
		ifNotNil: [ methodReference actualClass removeSelector: self methodSelector ifIn: appliesTo ]
		ifNil: [ methodReference actualClass removeSelector: self methodSelector ].
]

{ #category : 'fileIn/fileOut' }
MethodDeletionChange >> fileOutOn: stream [
	"File the receiver out on the given file stream"

	| record |

	record := String streamContents: [ :recordStream |
		recordStream
			nextPutAll: 'methodRemoval: ';
			nextPutAll: self changeClassName;
			space;
			nextPutAll: self methodSelector storeString.
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
		newLine.
]

{ #category : 'initialization' }
MethodDeletionChange >> initialize [
	appliesTo := nil.
]

{ #category : 'initialization' }
MethodDeletionChange >> initializeMethodReference: aMethodReference appliesOnlyTo: packageOrBaseImageNameOrNil source: aSourceCode stamp: aStamp   [

	methodReference := aMethodReference.
	appliesTo := packageOrBaseImageNameOrNil.
	sourceCode := aSourceCode.
	stamp := aStamp.
]

{ #category : 'accessing' }
MethodDeletionChange >> isMetaClassChange [
	^methodReference classIsMeta
]

{ #category : 'testing' }
MethodDeletionChange >> isMethod [
	^true
]

{ #category : 'testing' }
MethodDeletionChange >> isMethodDeletion [
	^true
]

{ #category : 'accessing' }
MethodDeletionChange >> methodReference: aMethodReference [
	methodReference := aMethodReference
]

{ #category : 'accessing' }
MethodDeletionChange >> methodSelector [
	^methodReference selector
]

{ #category : 'accessing' }
MethodDeletionChange >> stamp [

	^stamp
]

{ #category : 'accessing' }
MethodDeletionChange >> string [

	^sourceCode ifNil: [ '' ]
]
