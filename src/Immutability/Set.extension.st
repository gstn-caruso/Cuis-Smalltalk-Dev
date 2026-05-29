Extension { #name : 'Set' }

{ #category : '*Immutability' }
Set >> beImmutable [
	
	array beImmutable.
	^super beImmutable 
]

{ #category : '*Immutability' }
Set >> beMutable [
	
	array beMutable.
	^super beMutable 
]
