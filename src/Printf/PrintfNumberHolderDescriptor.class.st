Class {
	#name : 'PrintfNumberHolderDescriptor',
	#superclass : 'PrintfFormatDescriptor',
	#instVars : [
		'value'
	],
	#category : 'Printf',
	#package : 'Printf'
}

{ #category : 'rendering' }
PrintfNumberHolderDescriptor >> applyOperator: ignored [

]

{ #category : 'rendering' }
PrintfNumberHolderDescriptor >> render: object [
	value := object.
	^''
	
]

{ #category : 'accessing' }
PrintfNumberHolderDescriptor >> value [
	^value
	
]
