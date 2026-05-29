Extension { #name : 'SequenceableCollection' }

{ #category : '*Network-Kernel' }
SequenceableCollection >> putOn: aStream [

	self do: [ :each | each putOn: aStream ]
]
