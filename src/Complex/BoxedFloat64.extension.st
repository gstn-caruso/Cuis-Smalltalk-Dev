Extension { #name : 'BoxedFloat64' }

{ #category : '*Complex' }
BoxedFloat64 >> arg [
	"Compatibility with Complex numbers."
	self isNaN ifTrue: [^self].
	^super arg
]

{ #category : '*Complex' }
BoxedFloat64 >> argument [
	"Compatibility with Complex numbers."
	self isNaN ifTrue: [^self].
	^super argument
]
