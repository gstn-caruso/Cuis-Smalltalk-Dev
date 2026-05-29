Extension { #name : 'Object' }

{ #category : '*Network-Kernel' }
Object >> putOn:aStream [
	^aStream nextPut:self.

]
