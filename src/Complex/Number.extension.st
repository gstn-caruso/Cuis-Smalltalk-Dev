Extension { #name : 'Number' }

{ #category : '*Complex' }
Number >> arg [
	"Answer the argument of the receiver (see Complex | arg).
	Note: #argument and #phase assume the convention of 0+0i having argument=0"
	
	self isZero ifTrue: [self error: 'Zero (0 + 0 i) does not have an argument.'].
	^self < 0
		ifFalse: [0]
		ifTrue: [Float pi]
]

{ #category : '*Complex' }
Number >> argument [
	"Compatibility with Complex numbers.
	Answer the argument of the receiver (see Complex | argument).
	Answer is in (-Pi .. +Pi]
	Note: Assume the convention of 0+0i having argument=0"

	^self < 0
		ifFalse: [0]
		ifTrue: [Float pi]
]

{ #category : '*Complex' }
Number >> asComplex [
	"Answer a Complex number that represents value of the the receiver."

	^ Complex basicReal: self imaginary: 0
]

{ #category : '*Complex' }
Number >> complexConjugate [
	"Return the complex conjugate of this complex number."

	^self
]

{ #category : '*Complex' }
Number >> i [
	^ Complex real: 0 imaginary: self
]

{ #category : '*Complex' }
Number >> imaginary [
	"Compatibility with Complex numbers"
	^ 0
]

{ #category : '*Complex' }
Number >> phase [
	"Compatibility with Complex numbers.
	Answer the argument of the receiver.
	Answer is in (-Pi .. +Pi]
	Note: Assume the convention of 0+0i having argument=0"

	^ self argument
]

{ #category : '*Complex' }
Number >> real [
	"Compatibility with Complex numbers"
	^ self
]

{ #category : '*Complex' }
Number >> squaredNorm [
	"Answer the square of receiver norm."

	^self squared
]
