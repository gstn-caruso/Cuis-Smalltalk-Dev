Extension { #name : 'String' }

{ #category : '*Network-Kernel' }
String >> putOn:aStream [

	^aStream nextPutAll: self.

]

{ #category : '*Network-Kernel' }
String >> translated [
	^self
]
