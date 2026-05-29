Extension { #name : 'Object' }

{ #category : '*Printf' }
Object >> asArgumentArrayForFormatString [

	^{self}
	
]

{ #category : '*Printf' }
Object >> printLeanString [
	^self printStringLimitedTo: 256
	
]
