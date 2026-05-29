Class {
	#name : 'StandardFileMenuResult',
	#superclass : 'Object',
	#instVars : [
		'directory',
		'name'
	],
	#category : 'Goodies-Tools-FileList',
	#package : 'Goodies',
	#tag : 'Tools-FileList'
}

{ #category : 'instance creation' }
StandardFileMenuResult class >> directory: aDirectory name: aString [

	^super new directory: aDirectory name: aString
]

{ #category : 'accessing' }
StandardFileMenuResult >> directory [

	^directory
]

{ #category : 'accessing' }
StandardFileMenuResult >> directory: aDirectory [

	^directory _ aDirectory
]

{ #category : 'private' }
StandardFileMenuResult >> directory: aDirectory name: aString [

	directory _ aDirectory.
	name _ aString.
	^self
]

{ #category : 'testing' }
StandardFileMenuResult >> isCommand [

	^name isNil
]

{ #category : 'testing' }
StandardFileMenuResult >> isDirectory [

	^name = ''
]

{ #category : 'accessing' }
StandardFileMenuResult >> name [

	^name
]

{ #category : 'accessing' }
StandardFileMenuResult >> name: aString [

	^name _ aString
]

{ #category : 'accessing' }
StandardFileMenuResult >> printOn: aStream [
	super printOn: aStream.
	aStream nextPutAll: ' with directory: '.
	directory printOn: aStream.
	aStream nextPutAll: ' name: '.
	name printOn: aStream

"StandardFileMenu oldFile"
]
