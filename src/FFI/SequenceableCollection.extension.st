Extension { #name : 'SequenceableCollection' }

{ #category : '*FFI-Kernel' }
SequenceableCollection >> asMachineWordArray [
	"Answer an IntegerArray or Bytearray with the elements are the elements of the receiver stored as machine words,
	suitable for FFI."

	| answer |
	Smalltalk wordSize = 4 ifTrue: [
		^self as: IntegerArray ].
	answer := ByteArray new: self size * Smalltalk wordSize.
	1 to: self size do: [ :i |
		answer uint64At: i-1*Smalltalk wordSize+1 put: (self at: i) bigEndian: Smalltalk isBigEndian ].
	^answer
]
