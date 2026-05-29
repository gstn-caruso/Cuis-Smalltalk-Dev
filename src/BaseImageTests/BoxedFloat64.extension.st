Extension { #name : 'BoxedFloat64' }

{ #category : '*BaseImageTests-Kernel-Numbers' }
BoxedFloat64 >> primTestAdd: aNumber [
	"Primitive. Answer the sum of the receiver and aNumber. Essential.
	Fail if the argument is not a Float. See Object documentation
	whatIsAPrimitive."

	<primitive: 41>
	^ #fail
]

{ #category : '*BaseImageTests-Kernel-Numbers' }
BoxedFloat64 >> primTestArcTan [

	<primitive: 57>
	^ #fail
]

{ #category : '*BaseImageTests-Kernel-Numbers' }
BoxedFloat64 >> primTestDivideBy: aNumber [
	"Primitive. Answer the result of dividing receiver by aNumber.
	Fail if the argument is not a Float.
	Essential. See Object clas >> whatIsAPrimitive."

	<primitive: 50>
	^ #fail
]

{ #category : '*BaseImageTests-Kernel-Numbers' }
BoxedFloat64 >> primTestEqual: aNumber [
	"Primitive. Compare the receiver with the argument and return true
	if the receiver is equal to the argument. Otherwise return false.
	Fail if the argument is not a Float. Essential. See Object documentation
	whatIsAPrimitive."

	<primitive: 47>
	^#fail
]

{ #category : '*BaseImageTests-Kernel-Numbers' }
BoxedFloat64 >> primTestExp [
	"Primitive. Answer the sum of the receiver and aNumber. Essential.
	Fail if the argument is not a Float. See Object documentation
	whatIsAPrimitive."

	<primitive: 59>
	^ #fail
]

{ #category : '*BaseImageTests-Kernel-Numbers' }
BoxedFloat64 >> primTestExponent [
	"Primitive. Answer the sum of the receiver and aNumber. Essential.
	Fail if the argument is not a Float. See Object documentation
	whatIsAPrimitive."

	<primitive: 53>
	^ #fail
]

{ #category : '*BaseImageTests-Kernel-Numbers' }
BoxedFloat64 >> primTestGreater: aNumber  [
	"Primitive. Compare the receiver with the argument and return true
	if the receiver is greater than the argument. Otherwise return false.
	Fail if the argument is not a Float. Essential. See Object documentation
	whatIsAPrimitive."

	<primitive: 44>
	^#fail
]

{ #category : '*BaseImageTests-Kernel-Numbers' }
BoxedFloat64 >> primTestGreaterEqual: aNumber  [
	"Primitive. Compare the receiver with the argument and return true
	if the receiver is greater than or equal to the argument. Otherwise return
	false. Fail if the argument is not a Float. Optional. See Object documentation 
	whatIsAPrimitive. "

	<primitive: 46>
	^#fail
]

{ #category : '*BaseImageTests-Kernel-Numbers' }
BoxedFloat64 >> primTestLess: aNumber  [
	"Primitive. Compare the receiver with the argument and return true
	if the receiver is less than the argument. Otherwise return false.
	Fail if the argument is not a Float. Essential. See Object documentation
	whatIsAPrimitive."

	<primitive: 43>
	^#fail
]

{ #category : '*BaseImageTests-Kernel-Numbers' }
BoxedFloat64 >> primTestLessEqual: aNumber  [
	"Primitive. Compare the receiver with the argument and return true
	if the receiver is less than or equal to the argument. Otherwise return
	false. Fail if the argument is not a Float. Optional. See Object
	documentation whatIsAPrimitive."

	<primitive: 45>
	^#fail
]

{ #category : '*BaseImageTests-Kernel-Numbers' }
BoxedFloat64 >> primTestLn [
	"Primitive. Answer the sum of the receiver and aNumber. Essential.
	Fail if the argument is not a Float. See Object documentation
	whatIsAPrimitive."

	<primitive: 58>
	^ #fail
]

{ #category : '*BaseImageTests-Kernel-Numbers' }
BoxedFloat64 >> primTestMultiplyBy: aNumber [
	"Primitive. Answer the result of multiplying the receiver by aNumber.
	Fail if the argument is not a Float. Essential. See Object documentation
	whatIsAPrimitive."

	<primitive: 49>
	^ #fail
]

{ #category : '*BaseImageTests-Kernel-Numbers' }
BoxedFloat64 >> primTestNotEqual: aNumber  [
	"Primitive. Compare the receiver with the argument and return true
	if the receiver is not equal to the argument. Otherwise return false.
	Fail if the argument is not a Float. Optional. See Object documentation
	whatIsAPrimitive."

	<primitive: 48>
	^#fail
]

{ #category : '*BaseImageTests-Kernel-Numbers' }
BoxedFloat64 >> primTestSin [
	<primitive: 56>
	^ #fail
]

{ #category : '*BaseImageTests-Kernel-Numbers' }
BoxedFloat64 >> primTestSqrt [
	<primitive: 55>
	^ #fail
]

{ #category : '*BaseImageTests-Kernel-Numbers' }
BoxedFloat64 >> primTestSubtract: aNumber [
	"Primitive. Answer the difference between the receiver and aNumber.
	Fail if the argument is not a Float. Essential. See Object documentation
	whatIsAPrimitive."

	<primitive: 42>
	^ #fail
]

{ #category : '*BaseImageTests-Kernel-Numbers' }
BoxedFloat64 >> primTestTruncated [
	<primitive: 51>
	^ #fail
]
