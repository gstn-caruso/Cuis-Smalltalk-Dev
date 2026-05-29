Extension { #name : 'OrderedCollection' }

{ #category : '*Immutability' }
OrderedCollection >> beImmutable [
	
	array beImmutable.
	^super beImmutable 
]

{ #category : '*Immutability' }
OrderedCollection >> beMutable [
	
	array beMutable.
	^super beMutable 
]
