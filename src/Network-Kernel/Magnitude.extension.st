Extension { #name : 'Magnitude' }

{ #category : '*Network-Kernel' }
Magnitude >> putOn: aStream [

	(aStream isBinary ifTrue: [ self asByteArray ] ifFalse: [ self asString]) putOn: aStream
	
 
]
