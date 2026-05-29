Class {
	#name : 'PrintfCharacterFormatDescriptor',
	#superclass : 'PrintfFormatDescriptor',
	#category : 'Printf',
	#package : 'Printf'
}

{ #category : 'rendering' }
PrintfCharacterFormatDescriptor >> applyOperator: object [
	^ String with: 
		(object isNumber ifTrue: [ Character codePoint: object ] ifFalse: [ object ])
]

{ #category : 'printing' }
PrintfCharacterFormatDescriptor >> printOn: aStream [
	super printOn: aStream.
	self printWidthOn: aStream.
	aStream nextPut: $c
	
]
