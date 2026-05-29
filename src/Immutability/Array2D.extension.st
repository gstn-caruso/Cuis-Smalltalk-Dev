Extension { #name : 'Array2D' }

{ #category : '*Immutability' }
Array2D >> beImmutable [
	
	elements beImmutable.
	^super beImmutable.
	
]

{ #category : '*Immutability' }
Array2D >> beMutable [
	
	elements beMutable.
	^super beMutable
]
