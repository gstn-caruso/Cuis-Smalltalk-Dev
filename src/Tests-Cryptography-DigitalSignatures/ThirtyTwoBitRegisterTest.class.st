Class {
	#name : 'ThirtyTwoBitRegisterTest',
	#superclass : 'TestCase',
	#instVars : [
		'random'
	],
	#category : 'Tests-Cryptography-DigitalSignatures',
	#package : 'Tests',
	#tag : 'Cryptography-DigitalSignatures'
}

{ #category : 'helpers' }
ThirtyTwoBitRegisterTest >> assertBinaryRegisterOperation: registerOperationBlock gives: integerOperationBlock times: n [

	| rx ry |
	rx := ThirtyTwoBitRegister new.
	ry := rx copy.
	n timesRepeat: [
		| x y expectedResult |
		x := self nextRandom.
		y := self nextRandom.
		expectedResult := integerOperationBlock value: x value: y .
		rx load: x.
		ry load: y.
		registerOperationBlock value: rx value: ry.
		self assert: expectedResult equals: rx asInteger ]
]

{ #category : 'helpers' }
ThirtyTwoBitRegisterTest >> assertComparisonRegisterOperation: registerOperationBlock gives: integerOperationBlock times: n [

	| rx ry |
	rx := ThirtyTwoBitRegister new.
	ry := rx copy.
	n timesRepeat: [
		| x y expectedResult actualResult |
		x := self nextRandom.
		y := self nextRandom.
		expectedResult := integerOperationBlock value: x value: y .
		rx load: x.
		ry load: y.
		actualResult := registerOperationBlock value: rx value: ry.
		self assert: expectedResult equals: actualResult ]
]

{ #category : 'helpers' }
ThirtyTwoBitRegisterTest >> assertUnaryRegisterOperation: registerOperationBlock gives: integerOperationBlock times: n [

	| rx |
	rx := ThirtyTwoBitRegister new.
	n timesRepeat: [
		| x expectedResult |
		x := self nextRandom.
		expectedResult := integerOperationBlock value: x.
		rx load: x.
		registerOperationBlock value: rx.
		self assert: expectedResult equals: rx asInteger ]
]

{ #category : 'helpers' }
ThirtyTwoBitRegisterTest >> nextRandom [
	"Return the next random 32-bit unsigned integer value."

	^(random nextInteger: 4294967296) - 1
]

{ #category : 'running' }
ThirtyTwoBitRegisterTest >> setUp [

	random := Random seed: 36rSQUEAK
]

{ #category : 'tests - accumulator ops' }
ThirtyTwoBitRegisterTest >> testAddition [

	self
		assertBinaryRegisterOperation: [ :rx :ry | rx += ry ]
		gives: [ :x :y | x + y bitAnd: 16rFFFFFFFF ]
		times: 10000
]

{ #category : 'tests - accumulator ops' }
ThirtyTwoBitRegisterTest >> testBitAnd [

	self
		assertBinaryRegisterOperation: [ :rx :ry | rx bitAnd: ry ]
		gives: [ :x :y | x bitAnd: y ]
		times: 10000
]

{ #category : 'tests - accumulator ops' }
ThirtyTwoBitRegisterTest >> testBitInvert [

	self
		assertUnaryRegisterOperation: [ :rx | rx bitInvert ]
		gives: [ :x | x bitInvert32 ]
		times: 10000
]

{ #category : 'tests - accumulator ops' }
ThirtyTwoBitRegisterTest >> testBitOr [

	self
		assertBinaryRegisterOperation: [ :rx :ry | rx bitOr: ry ]
		gives: [ :x :y | x bitOr: y ]
		times: 10000
]

{ #category : 'tests - accumulator ops' }
ThirtyTwoBitRegisterTest >> testBitXor [

	self
		assertBinaryRegisterOperation: [ :rx :ry | rx bitXor: ry ]
		gives: [ :x :y | x bitXor: y ]
		times: 10000
]

{ #category : 'tests - comparison' }
ThirtyTwoBitRegisterTest >> testEquals [

	self
		assertComparisonRegisterOperation: [ :rx :ry | rx = ry ]
		gives: [ :x :y | x = y ]
		times: 1000
]

{ #category : 'tests - comparison' }
ThirtyTwoBitRegisterTest >> testGreater [

	self
		assertComparisonRegisterOperation: [ :rx :ry | rx > ry ]
		gives: [ :x :y | x > y ]
		times: 1000
]

{ #category : 'tests - comparison' }
ThirtyTwoBitRegisterTest >> testGreaterOrEqual [

	self
		assertComparisonRegisterOperation: [ :rx :ry | rx >= ry ]
		gives: [ :x :y | x >= y ]
		times: 1000
]

{ #category : 'tests' }
ThirtyTwoBitRegisterTest >> testHi [

	self
		assertUnaryRegisterOperation: [ :rx | rx load: rx hi ]
		gives: [ :x | x bitShift: -16 ]
		times: 1000
]

{ #category : 'tests - accumulator ops' }
ThirtyTwoBitRegisterTest >> testLeftRotateBy [

	0 to: 33 do: [ :shift |
		self
			assertUnaryRegisterOperation: [ :rx | rx leftRotateBy: shift ]
			gives: [ :x | 
				| actualShift |
				actualShift := shift \\ 32.
				(x << actualShift bitOr: x >> (32 - actualShift)) bitAnd: 16rFFFFFFFF ]
			times: 1000 ]
]

{ #category : 'tests - accumulator ops' }
ThirtyTwoBitRegisterTest >> testLeftShift [

	0 to: 33 do: [ :shift |
		self
			assertUnaryRegisterOperation: [ :rx | rx << shift ]
			gives: [ :x | x << shift bitAnd: 16rFFFFFFFF ]
			times: 1000 ]
]

{ #category : 'tests - comparison' }
ThirtyTwoBitRegisterTest >> testLess [

	self
		assertComparisonRegisterOperation: [ :rx :ry | rx < ry ]
		gives: [ :x :y | x < y ]
		times: 1000
]

{ #category : 'tests - comparison' }
ThirtyTwoBitRegisterTest >> testLessOrEqual [

	self
		assertComparisonRegisterOperation: [ :rx :ry | rx <= ry ]
		gives: [ :x :y | x <= y ]
		times: 1000
]

{ #category : 'tests' }
ThirtyTwoBitRegisterTest >> testLoad [

	1000 timesRepeat: [
		| value |
		value := self nextRandom.
		self
			assertUnaryRegisterOperation: [ :rx | rx load: value ]
			gives: [ :x | value ]
			times: 1 ]
]

{ #category : 'tests' }
ThirtyTwoBitRegisterTest >> testLoadFrom [

	self
		assertBinaryRegisterOperation: [ :rx :ry | rx loadFrom: ry ]
		gives: [ :x :y | y ]
		times: 10000
]

{ #category : 'tests' }
ThirtyTwoBitRegisterTest >> testLow [

	self
		assertUnaryRegisterOperation: [ :rx | rx load: rx low ]
		gives: [ :x | x bitAnd: 16rFFFF ]
		times: 1000
]

{ #category : 'tests - accumulator ops' }
ThirtyTwoBitRegisterTest >> testMultiplication [

	self
		assertBinaryRegisterOperation: [ :rx :ry | rx *= ry ]
		gives: [ :x :y | x * y bitAnd: 16rFFFFFFFF ]
		times: 10000
]

{ #category : 'tests - accumulator ops' }
ThirtyTwoBitRegisterTest >> testRightRotateBy [

	0 to: 33 do: [ :shift |
		self
			assertUnaryRegisterOperation: [ :rx | rx rightRotateBy: shift ]
			gives: [ :x | 
				| actualShift |
				actualShift _ shift \\ 32.
				(x >> actualShift bitOr: x << (32 - actualShift))
					bitAnd: 16rFFFFFFFF ]
			times: 1000 ]
]

{ #category : 'tests - accumulator ops' }
ThirtyTwoBitRegisterTest >> testRightShift [

	0 to: 33 do: [ :shift |
		self
			assertUnaryRegisterOperation: [ :rx | rx >> shift ]
			gives: [ :x | x >> shift bitAnd: 16rFFFFFFFF ]
			times: 1000 ]
]
