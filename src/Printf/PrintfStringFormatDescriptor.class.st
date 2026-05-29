Class {
	#name : 'PrintfStringFormatDescriptor',
	#superclass : 'PrintfFormatDescriptor',
	#instVars : [
		'widthDescriptor'
	],
	#category : 'Printf',
	#package : 'Printf'
}

{ #category : 'rendering' }
PrintfStringFormatDescriptor >> applyOperator: object [
	^ object
	
]

{ #category : 'printing' }
PrintfStringFormatDescriptor >> printOn: aStream [
	super printOn: aStream.
	self printWidthOn: aStream.
	aStream nextPut: $s
	
]

{ #category : 'printing' }
PrintfStringFormatDescriptor >> printWidthOn: aStream [
	widthDescriptor ifNotNil: [aStream nextPutAll: '.*']
	
]

{ #category : 'accessing' }
PrintfStringFormatDescriptor >> stringLength [
	^widthDescriptor ifNotNil: [widthDescriptor value] ifNil: [super stringLength]
	
]

{ #category : 'accessing' }
PrintfStringFormatDescriptor >> widthDescriptor: aPrintfNumberFormatDescriptor [

	widthDescriptor := aPrintfNumberFormatDescriptor
	
]
