Class {
	#name : 'ComplexTest',
	#superclass : 'ProtoObject',
	#category : 'Tests-Complex',
	#package : 'Tests',
	#tag : 'Complex'
}

{ #category : 'helpers' }
ComplexTest >> effectiveZeroExponentForTrigonometry [

	^-46
]

{ #category : 'helpers' }
ComplexTest >> hyperbolicPrecision [

	^384
]

{ #category : 'tests - accessing' }
ComplexTest >> testAbs [
	
	| c |
	c _ (6 - 6 i).
	self assert: c abs  = 72 sqrt.
	c _ 2.0e306 + 3.0e305 i.
	self assert: c abs = c safeAbs.
	c _ 2.0e-155 + 3.0e-155 i.
	self assert: c abs = c safeAbs.
]

{ #category : 'tests - arithmetic' }
ComplexTest >> testAdd [
	
	| c |
	c := (5 - 6 i) + (-5 + 8 i).     "Complex with Complex"
	self assert: (c =  (0 + 2 i)).
]

{ #category : 'tests - mathematical functions' }
ComplexTest >> testArcTan [
	| c |
	c := (0.5 + 0 i).
	self assert: (c arcTan real isWithin: 2 floatsFrom: c real arcTan).
	#(-0.5 -2 -3 0 0.5 2 3) do: [ :real |
		#(-0.5 -2 -3 0 0.5 2 3) do: [ :imag |
			c := real + imag i.
			self verify: c arcTan tan isTrigonometricallyEqualTo: c ]]
]

{ #category : 'tests - accessing' }
ComplexTest >> testArg [
	
	| c |
	c := (0 + 5 i) .
	self assert: c arg  = (Float pi/ 2).
	
]

{ #category : 'tests - bugs' }
ComplexTest >> testBug1 [

	self assert: (0.5 * (2+0i) ln) exp = (0.5 * 2 ln) exp.
]

{ #category : 'tests - misc' }
ComplexTest >> testComplexCollection [
	
	| array array2 |
	array := Array with: 1 + 2i with:  3 + 4i with: 5 + 6i.
	array2 := 2 * array.
	array with:  array2 do: [:one :two | self assert: (2 * one) = two ] 
]

{ #category : 'tests - arithmetic' }
ComplexTest >> testComplexConjugate [
	
	| c cc |
	c := (5 - 6 i).
	cc := c complexConjugate.
	self assert: cc real = c real.
	self assert: cc imaginary = c imaginary negated.
]

{ #category : 'tests - conversion and rounding' }
ComplexTest >> testConversion [
	
	self assert: ((1 + 2i) + 1) =  (2 + 2 i).
	self assert: (1 + (1 + 2i)) =  (2 + 2 i).
	self assert: ((1 + 2i) + 1.0) =  (2.0 + 2 i).
	self assert: (1.0 + (1 + 2i)) =  (2.0 + 2 i).
	self assert: ((1 + 2i) + (2/3)) = ((5/3) + 2 i ).
	self assert: ((2/3) + (1 + 2i)) = ((5/3) + 2 i )
]

{ #category : 'tests - mathematical functions' }
ComplexTest >> testCos [
	| c c2 |
	c := (2 + 0 i).
	self assert: c cos = c real cos.
	c := (2 + 3 i).
	c2 := c i exp + c i negated exp / 2.
	self verify: c cos isTrigonometricallyEqualTo: c2.
]

{ #category : 'tests - function properties' }
ComplexTest >> testCos2PlusSin2 [
	| c |
	#(-0.5 -2 -3 0 0.5 2 3) do:  [:real |
	#(-0.5 -2 -3 0 0.5 2 3) do: [ :imag |
		c := real + imag i.
		self verify: (c cos squared + c sin squared) isTrigonometricallyEqualTo: 1.0 ]]
]

{ #category : 'tests - mathematical functions' }
ComplexTest >> testCosh [
	| c c2 |
	c := (2 + 0 i).
	self assert: c cosh = c real cosh.
	c := (2 + 3 i).
	c2 := c exp + c negated exp / 2.
	self verify: c cosh isHyperbolicallyEqualTo: c2.
	c2 := c i cos.
	self verify: c cosh isHyperbolicallyEqualTo: c2.
]

{ #category : 'tests - function properties' }
ComplexTest >> testCosh2MinusSinh2 [
	| c |
	#(-0.5 -2 -3 0 0.5 2 3) do: [:real |
	#(-0.5 -2 -3 0 0.5 2 3) do: [:imag |
		c := real + imag i.
		self verify: (c cosh squared - c sinh squared) isHyperbolicallyEqualTo: 1.0 ]]
]

{ #category : 'tests - creation' }
ComplexTest >> testCreation [
	| c c1 c2 c3 |
	c _ 1 + 2i.
	self assert: c real = 1.
	self assert: c imaginary = 2.


	c1 _ 1/3 + (10/11)i.
	self assert: c1 real = (1/3).
	self assert: c1 imaginary = (10/11).
	self assert: c1 - (10/11)i = (1/3).
	self assert: 1 + c1 = (4/3 + (10/11)i).
	self assert: c1+1 = (4/3 + (10/11)i).

	c1 _ 0.5 + (10/11)i.
	self assert: 1.0 + c1 = (1.5 + (10/11)i).
	self assert: c1+1.0 = (1.5 + (10/11)i).

	c2 _ Complex abs: 5 arg: 0.
	self assert: c2 = 5.
	self assert: c2 isComplex.
	c3 _ Complex abs: 5 arg: Float twoPi.
	self assert: c3 = 5.
	self assert: c2 isComplex.

	c2 _ Complex abs: 5.1 arg: 0.
	self assert: c2 = 5.1.
	c3 _ Complex abs: 5.1 arg: Float twoPi.
	self assert: c3 = 5.1.
]

{ #category : 'tests - creation' }
ComplexTest >> testCreation2 [
	
	| c |
	c := 5 i.
	self assert: (c real = 0).
	self assert: (c imaginary = 5).
	
	c := 6 + 7 i.
	self assert: (c real = 6).
	self assert: ( c imaginary = 7).
	
	c := 5.6 - 8 i.
	self assert: (c real = 5.6).
	self assert: (c imaginary = -8).
	
	c := Complex real: 10 imaginary: 5.
	self assert: (c real = 10).
	self assert: (c imaginary = 5).
	
	c := Complex abs: 5 arg: (Float pi/2).
	self assert: (c real rounded = 0).
	self assert: (c imaginary = 5).
	
]

{ #category : 'tests - arithmetic' }
ComplexTest >> testDivideComplexByZero [

	self assert: 1 i / 0.0 = Complex infinity.
	self assert: 1 i + 1 / 0.0 = Complex infinity.
	self assert: 1 i / -0.0 = Complex infinity.
	self assert: 1 i + 1 / -0.0 = Complex infinity.
	self assert: 1 i / (Complex basicReal: 0.0 imaginary: 0.0) = Complex infinity.
	self assert: 1 i / (Complex basicReal: 0.0 imaginary: -0.0) = Complex infinity.
	self assert: 1 i / (Complex basicReal: -0.0 imaginary: 0.0) = Complex infinity.
	self assert: 1 i / (Complex basicReal: -0.0 imaginary: -0.0) = Complex infinity.
	self assert: 1 i + 1 / (Complex basicReal: 0.0 imaginary: 0.0) = Complex infinity.
	self assert: 1 i + 1 / (Complex basicReal: 0.0 imaginary: -0.0) = Complex infinity.
	self assert: 1 i + 1 / (Complex basicReal: -0.0 imaginary: 0.0) = Complex infinity.
	self assert: 1 i + 1 / (Complex basicReal: -0.0 imaginary: -0.0) = Complex infinity.

	self assert: -1  / (Complex basicReal: 0.0 imaginary: 0.0) = Float negativeInfinity.
	self assert: -1  / (Complex basicReal: 0.0 imaginary: -0.0) = Float negativeInfinity.
	self assert: -1  / (Complex basicReal: -0.0 imaginary: 0.0) = Float negativeInfinity.
	self assert: -1  / (Complex basicReal: -0.0 imaginary: -0.0) = Float negativeInfinity.
	self assert: -1.0  / (Complex basicReal: 0.0 imaginary: 0.0) = Float negativeInfinity.
	self assert: -1.0  / (Complex basicReal: 0.0 imaginary: -0.0) = Float negativeInfinity.
	self assert: -1.0  / (Complex basicReal: -0.0 imaginary: 0.0) = Float negativeInfinity.
	self assert: -1.0  / (Complex basicReal: -0.0 imaginary: -0.0) = Float negativeInfinity.
]

{ #category : 'tests - arithmetic' }
ComplexTest >> testDivideComplexZeroByZero [

	self assert: ((Complex basicReal: 0.0 imaginary: 0.0) / 0) isComplexNaN.
	self assert: ((Complex basicReal: 0.0 imaginary: -0.0) / 0) isComplexNaN.
	self assert: ((Complex basicReal: -0.0 imaginary: 0.0) / 0) isComplexNaN.
	self assert: ((Complex basicReal: -0.0 imaginary: -0.0) / 0) isComplexNaN.
	self assert: ((Complex basicReal: 0.0 imaginary: 0.0) / -0) isComplexNaN.
	self assert: ((Complex basicReal: 0.0 imaginary: -0.0) / -0) isComplexNaN.
	self assert: ((Complex basicReal: -0.0 imaginary: 0.0) / -0) isComplexNaN.
	self assert: ((Complex basicReal: -0.0 imaginary: -0.0) / -0) isComplexNaN.
	self assert: ((Complex basicReal: 0.0 imaginary: 0.0) / 0.0) isComplexNaN.
	self assert: ((Complex basicReal: 0.0 imaginary: -0.0) / 0.0) isComplexNaN.
	self assert: ((Complex basicReal: -0.0 imaginary: 0.0) / 0.0) isComplexNaN.
	self assert: ((Complex basicReal: -0.0 imaginary: -0.0) / 0.0) isComplexNaN.
	self assert: ((Complex basicReal: 0.0 imaginary: 0.0) / -0.0) isComplexNaN.
	self assert: ((Complex basicReal: 0.0 imaginary: -0.0) / -0.0) isComplexNaN.
	self assert: ((Complex basicReal: -0.0 imaginary: 0.0) / -0.0) isComplexNaN.
	self assert: ((Complex basicReal: -0.0 imaginary: -0.0) / -0.0) isComplexNaN.
	self assert: ((Complex basicReal: 0.0 imaginary: 0.0) / (Complex basicReal: 0.0 imaginary: 0.0)) isComplexNaN.
	self assert: ((Complex basicReal: 0.0 imaginary: -0.0) / (Complex basicReal: 0.0 imaginary: 0.0)) isComplexNaN.
	self assert: ((Complex basicReal: -0.0 imaginary: 0.0) / (Complex basicReal: 0.0 imaginary: 0.0)) isComplexNaN.
	self assert: ((Complex basicReal: -0.0 imaginary: -0.0) / (Complex basicReal: 0.0 imaginary: 0.0)) isComplexNaN.
	self assert: ((Complex basicReal: 0.0 imaginary: 0.0) / (Complex basicReal: 0.0 imaginary: -0.0)) isComplexNaN.
	self assert: ((Complex basicReal: 0.0 imaginary: -0.0) / (Complex basicReal: 0.0 imaginary: -0.0)) isComplexNaN.
	self assert: ((Complex basicReal: -0.0 imaginary: 0.0) / (Complex basicReal: 0.0 imaginary: -0.0)) isComplexNaN.
	self assert: ((Complex basicReal: -0.0 imaginary: -0.0) / (Complex basicReal: 0.0 imaginary: -0.0)) isComplexNaN.
	self assert: ((Complex basicReal: 0.0 imaginary: 0.0) / (Complex basicReal: -0.0 imaginary: 0.0)) isComplexNaN.
	self assert: ((Complex basicReal: 0.0 imaginary: -0.0) / (Complex basicReal: -0.0 imaginary: 0.0)) isComplexNaN.
	self assert: ((Complex basicReal: -0.0 imaginary: 0.0) / (Complex basicReal: -0.0 imaginary: 0.0)) isComplexNaN.
	self assert: ((Complex basicReal: -0.0 imaginary: -0.0) / (Complex basicReal: -0.0 imaginary: 0.0)) isComplexNaN.
	self assert: ((Complex basicReal: 0.0 imaginary: 0.0) / (Complex basicReal: -0.0 imaginary: -0.0)) isComplexNaN.
	self assert: ((Complex basicReal: 0.0 imaginary: -0.0) / (Complex basicReal: -0.0 imaginary: -0.0)) isComplexNaN.
	self assert: ((Complex basicReal: -0.0 imaginary: 0.0) / (Complex basicReal: -0.0 imaginary: -0.0)) isComplexNaN.
	self assert: ((Complex basicReal: -0.0 imaginary: -0.0) / (Complex basicReal: -0.0 imaginary: -0.0)) isComplexNaN.
]

{ #category : 'tests - arithmetic' }
ComplexTest >> testDivideFloatByZero [

	self assert: 1  / (Complex basicReal: 0.0 imaginary: 0.0) = Float infinity.
	self assert: 1  / (Complex basicReal: 0.0 imaginary: -0.0) = Float infinity.
	self assert: 1  / (Complex basicReal: -0.0 imaginary: 0.0) = Float infinity.
	self assert: 1  / (Complex basicReal: -0.0 imaginary: -0.0) = Float infinity.
	self assert: 1.0  / (Complex basicReal: 0.0 imaginary: 0.0) = Float infinity.
	self assert: 1.0  / (Complex basicReal: 0.0 imaginary: -0.0) = Float infinity.
	self assert: 1.0  / (Complex basicReal: -0.0 imaginary: 0.0) = Float infinity.
	self assert: 1.0  / (Complex basicReal: -0.0 imaginary: -0.0) = Float infinity.

	self assert: -1  / (Complex basicReal: 0.0 imaginary: 0.0) = Float negativeInfinity.
	self assert: -1  / (Complex basicReal: 0.0 imaginary: -0.0) = Float negativeInfinity.
	self assert: -1  / (Complex basicReal: -0.0 imaginary: 0.0) = Float negativeInfinity.
	self assert: -1  / (Complex basicReal: -0.0 imaginary: -0.0) = Float negativeInfinity.
	self assert: -1.0  / (Complex basicReal: 0.0 imaginary: 0.0) = Float negativeInfinity.
	self assert: -1.0  / (Complex basicReal: 0.0 imaginary: -0.0) = Float negativeInfinity.
	self assert: -1.0  / (Complex basicReal: -0.0 imaginary: 0.0) = Float negativeInfinity.
	self assert: -1.0  / (Complex basicReal: -0.0 imaginary: -0.0) = Float negativeInfinity.
]

{ #category : 'tests - arithmetic' }
ComplexTest >> testDivideFloatZeroByZero [

	self assert: (0 / (Complex basicReal: 0.0 imaginary: 0.0)) isNaN.
	self assert: (0 / (Complex basicReal: 0.0 imaginary: -0.0)) isNaN.
	self assert: (0 / (Complex basicReal: -0.0 imaginary: 0.0)) isNaN.
	self assert: (0 / (Complex basicReal: -0.0 imaginary: -0.0)) isNaN.
	self assert: (0.0 / (Complex basicReal: 0.0 imaginary: 0.0)) isNaN.
	self assert: (0.0 / (Complex basicReal: 0.0 imaginary: -0.0)) isNaN.
	self assert: (0.0 / (Complex basicReal: -0.0 imaginary: 0.0)) isNaN.
	self assert: (0.0 / (Complex basicReal: -0.0 imaginary: -0.0)) isNaN.
]

{ #category : 'tests - arithmetic' }
ComplexTest >> testDivideLarge [

	| c1 c2 quotient |
	c1 := 2e252 + 3e70 i.
	c2 := 2e252 + 3e70 i.
	quotient := c1 / c2.
	self assert: quotient = 1.

	c1 := 2e252 + 3e70 i.
	c2 := 2.0e252 + 3.0e70 i.
	quotient := c1 / c2.
	self assert: quotient = 1.

	c1 := 2.0e252 + 3.0e70 i.
	c2 := 2e252 + 3e70 i.
	quotient := c1 / c2.
	self assert: quotient abs = 1.

	c1 := 2.0e252 + 3.0e70 i.
	c2 := 2.0e252 + 3.0e70 i.
	quotient := c1 / c2.
	self assert: quotient = 1.
]

{ #category : 'tests - arithmetic' }
ComplexTest >> testDivideSmall [

	| c1 c2 quotient |
	c1 := 2e-252 + 3e-270 i.
	c2 := 2e-252 + 3e-270 i.
	quotient := c1 / c2.
	self assert: quotient = 1.

	c1 := 2e-252 + 3e-270 i.
	c2 := 2.0e-252 + 3.0e-270 i.
	quotient := c1 / c2.
	self assert: quotient = 1.

	c1 := 2.0e-252 + 3.0e-270 i.
	c2 := 2e-252 + 3e-270 i.
	quotient := c1 / c2.
	self assert: quotient abs = 1.

	c1 := 2.0e-252 + 3.0e-270 i.
	c2 := 2.0e-252 + 3.0e-270 i.
	quotient := c1 / c2.
	self assert: quotient = 1.
]

{ #category : 'tests - comparing' }
ComplexTest >> testEquality [
	
	self assert: 0i = 0.
	self assert: (2 - 5i) = ((1 -4 i) + (1 - 1i)).
	self assert: 0i isZero.
	self deny: (1 + 3 i) = 1.
	self deny: (1 + 3 i) = (1 + 2i).

"Some more stuff"
	self deny: (1 i) = nil.
	self deny: nil = (1 i).

	self deny: (1 i) = #(1 2 3).
	self deny: #(1 2 3) = (1 i).

	self deny: (1 i) = 0.
	self deny: 0 = (1 i).

	self assert:  (1 + 0 i) = 1.
	self assert:  1 = (1+ 0 i).

	self assert:  (1 + 0 i) = 1.0.
	self assert:  1.0 = (1+ 0 i).

	self assert:  (1/2 + 0 i) = (1/2).
	self assert:  (1/2) = (1/2+ 0 i).
]

{ #category : 'tests - mathematical functions' }
ComplexTest >> testFourthRoot [

	"SmallInteger"
	self verify: (-1 nthRoot: 4) isMagnitudeAndArgumentWithin: 1 floatsAwayFrom: 1.0 / 2.0 sqrt + (1.0 / 2.0 sqrt)i.

	"LargeNegativeInteger"
	self assert: (100 factorial negated nthRoot: 4) abs = (100 factorial nthRoot: 4).
	self assert: (100 factorial negated nthRoot: 4) arg = (Float pi / 4).

	"Fraction"
	self verify: (-1/4 nthRoot: 4) isMagnitudeAndArgumentWithin: 1 floatsAwayFrom: 1/2 + (1/2) i.

	"Float"
	self verify: (-1.0 nthRoot: 4) isMagnitudeAndArgumentWithin: 1 floatsAwayFrom: 1.0 / 2.0 sqrt + (1.0 / 2.0 sqrt)i.
	self verify: (-0.25 nthRoot: 4) isMagnitudeAndArgumentWithin: 1 floatsAwayFrom: 0.5 + 0.5 i.
]

{ #category : 'tests - mathematical functions' }
ComplexTest >> testLn [
	self assert: (Float e + 0 i) ln = Float e ln "See Bug 1815 on Mantis"
]

{ #category : 'tests - arithmetic' }
ComplexTest >> testMultiply [
	
	| c |
	c := (5 - 6 i).
	self assert: (c * 1i = c i)
]

{ #category : 'tests - arithmetic' }
ComplexTest >> testNegated [

	| c |
	c := (2 + 5 i) .
	self assert: c negated  = (-2 - 5i).
	
]

{ #category : 'tests - mathematical functions' }
ComplexTest >> testRaisedTo [
	
	| c c3 |
	c := (5 - 6 i).
	c3 := (c raisedTo: 0.2) raisedTo: 5.
	self verify: c3 isMagnitudeAndArgumentWithin: 7 floatsAwayFrom: c.
]

{ #category : 'tests - mathematical functions' }
ComplexTest >> testRaisedToInteger [
	
	| c c3 |
	c := (5 - 6 i).
	c3 := (c * c * c).
	self assert: (c3 = (c raisedToInteger: 3)).
	self assert: (c3 reciprocal = (c raisedToInteger: -3)).
]

{ #category : 'tests - mathematical functions' }
ComplexTest >> testRaisedToMinusOne [
	
	self assert: ((Complex basicReal: 0.0 imaginary: 0.0) raisedTo: -1) = Float infinity.
	self assert: ((Complex basicReal: 0.0 imaginary: 0.0) raisedTo: -1.0) = Float infinity.
]

{ #category : 'tests - mathematical functions' }
ComplexTest >> testRaisedToOneFourth [

	"SmallInteger"
	self verify: (-1 raisedTo: 1/4) isMagnitudeAndArgumentWithin: 1 floatsAwayFrom: 1.0 / 2.0 sqrt + (1.0 / 2.0 sqrt)i.

	"LargeNegativeInteger"
	self assert: (100 factorial negated raisedTo: 1/4) abs = (100 factorial nthRoot: 4).
	self assert: (100 factorial negated raisedTo: 1/4) arg = (Float pi / 4).

	"Fraction"
	self verify: (-1/4 raisedTo: 1/4) isMagnitudeAndArgumentWithin: 1 floatsAwayFrom: 1/2 + (1/2) i.

	"Float"
	self verify: (-1.0 raisedTo: 1/4) isMagnitudeAndArgumentWithin: 1 floatsAwayFrom: 1.0 / 2.0 sqrt + (1.0 / 2.0 sqrt)i.
	self verify: (-0.25 raisedTo: 1/4) isMagnitudeAndArgumentWithin: 1 floatsAwayFrom: 0.5 + 0.5 i.
]

{ #category : 'tests - mathematical functions' }
ComplexTest >> testRaisedToOneHalf [

	"SmallInteger"
	self assert: (-1 raisedTo: 1/2) equals: 1i.
	self assert: (-1 raisedTo: 1/2) imaginary isInteger.
	self assert: (-3 raisedTo: 1/2) imaginary isFloat.
	self assert: (-4 raisedTo: 3/2) equals: -8i.
	self assert: (-4 raisedTo: 3/2) imaginary isInteger.
	self assert: (-4 raisedTo: 5/2) equals: 32i.
	self assert: (-4 raisedTo: 5/2) imaginary isInteger.

	"LargeNegativeInteger"
	self assert: (100 factorial negated raisedTo: 1/2) imaginary = 100 factorial sqrt.

	"Fraction"
	self assert: ((-1/4) raisedTo: 1/2) = (1/2)i.
	self assert: ((-1/4) raisedTo: 3/2) = (-1/8)i.
	self assert: ((-1/4) raisedTo: 5/2) = (1/32)i.
	self assert: ((-100/101) raisedTo: 1/2) imaginary = (100/101) sqrt.

	"Float"
	self assert: (-1.0 raisedTo: 1/2) equals: 0 + 1.0i.
	self assert: (-1.0 raisedTo: 1/2) real isFloat.
	self assert: (-1.0 raisedTo: 1/2) imaginary isFloat.
	self assert: (-4.0 raisedTo: 1/2) equals: 0 + 2.0i.
	self assert: (-4.0 raisedTo: 1/2) real isFloat.
	self assert: (-4.0 raisedTo: 1/2) imaginary isFloat.
	self assert: (-0.25 raisedTo: 1/2) equals: 0 + 0.5i.
	self assert: (-0.25 raisedTo: 1/2) real isFloat.
	self assert: (-0.25 raisedTo: 1/2) imaginary isFloat.

	"Complex"
	self assert: ((Complex basicReal: -1 imaginary: 0) raisedTo: 1/2) equals: 1i.
	self assert: ((Complex basicReal: -1 imaginary: 0) raisedTo: 1/2) imaginary isInteger.
	self assert: ((Complex basicReal: -3 imaginary: 0) raisedTo: 1/2) imaginary isFloat.
	self verify: (1+1i raisedTo: 1/2 :: raisedTo: 2) isMagnitudeAndArgumentWithin: 3 floatsAwayFrom: 1.0 + 1.0 i.
]

{ #category : 'tests - mathematical functions' }
ComplexTest >> testRaisedToPointFive [

	"SmallInteger"
	self verify: (-1 raisedTo: 0.5) isMagnitudeAndArgumentWithin: 1 floatsAwayFrom: 1 i.

	"LargeNegativeInteger"
	self verify: (100 factorial negated raisedTo: 0.5) isMagnitudeAndArgumentWithin: 60 floatsAwayFrom: 100 factorial sqrt i.

	"Fraction"
	self verify: ((-1/4) raisedTo: 0.5) isMagnitudeAndArgumentWithin: 1 floatsAwayFrom: 0.5 i.
	self assert: ((-100/101) raisedTo: 0.5) imaginary = (100/101) sqrt.

	"Float"
	self verify: (-1.0 raisedTo: 0.5) isMagnitudeAndArgumentWithin: 1 floatsAwayFrom: 1 i.
	self verify: (-0.25 raisedTo: 0.5) isMagnitudeAndArgumentWithin: 1 floatsAwayFrom: 0.5 i.

	"Complex"
	self verify: ((Complex basicReal: -1.0 imaginary: 0.0) raisedTo: 0.5) isMagnitudeAndArgumentWithin: 1 floatsAwayFrom: 1 i.
	self verify: ((Complex basicReal: -0.25 imaginary: 0.0) raisedTo: 0.5) isMagnitudeAndArgumentWithin: 1 floatsAwayFrom: 0.5 i.
]

{ #category : 'tests - arithmetic' }
ComplexTest >> testReciprocal [
	
	| c |
	c := (2 + 5 i).
	self assert: c reciprocal  = ((2/29) - (5/29)i).
	
]

{ #category : 'tests - arithmetic' }
ComplexTest >> testReciprocalError [
	
	| c |
	c := (0 i).
	self should: [c reciprocal] raise: ZeroDivide
	
]

{ #category : 'tests - mathematical functions' }
ComplexTest >> testSecondRoot [

	"SmallInteger"
	self assert: (-1 nthRoot: 2) equals: 1i.
	self assert: (-1 nthRoot: 2) imaginary isInteger.
	self assert: (-3 nthRoot: 2) imaginary isFloat.

	"LargeNegativeInteger"
	self assert: (100 factorial negated nthRoot: 2) imaginary = 100 factorial sqrt.

	"Fraction"
	self assert: ((-1/4) nthRoot: 2) = (1/2)i.
	self assert: ((-100/101) nthRoot: 2) imaginary = (100/101) sqrt.

	"Float"
	self assert: (-1.0 nthRoot: 2) equals: 0.0 + 1.0i.
	self assert: (-1.0 nthRoot: 2) imaginary isFloat.
	self assert: (-0.25 nthRoot: 2) = (1/2)i.
	self assert: (-0.25 nthRoot: 2) imaginary isFloat.
]

{ #category : 'tests - mathematical functions' }
ComplexTest >> testSin [
	| c c2 |
	c := (2 + 0 i).
	self assert: c sin = c real sin. 
	c := 2 + 3 i.
	c2 := c i exp - c i negated exp / 2 i.
	self verify: c sin isTrigonometricallyEqualTo: c2.
]

{ #category : 'tests - mathematical functions' }
ComplexTest >> testSinh [
	| c c2 |
	c := (2 + 0 i).
	self assert: c sinh = c real sinh.
	c := 2 + 3 i.
	c := c cosh squared - c sinh squared.
	self verify: c isHyperbolicallyEqualTo: 1.0.
	c2 := c exp - c negated exp / 2.
	self verify: c sinh isHyperbolicallyEqualTo: c2.
	c2 := c i sin i negated.
	self verify: c sinh isHyperbolicallyEqualTo: c2.
]

{ #category : 'tests - mathematical functions' }
ComplexTest >> testSqrt [

	"SmallInteger"
	self assert: -1 sqrt equals: 1i.
	self assert: -1 sqrt imaginary isInteger.

	"LargeNegativeInteger"
	self assert: 100 factorial negated sqrt imaginary = 100 factorial sqrt.

	"Fraction"
	self assert: (-1/4) sqrt = (1/2)i.
	self assert: (-100/101) sqrt imaginary = (100/101) sqrt.
	self assert: ((1 << 1024 + 1) / (1 << 1024 + 3)) negated sqrt = (0 + 1.0i).

	"Float"
	self assert: -1.0 sqrt equals: 0.0 + 1.0i.
	self assert: -1.0 sqrt imaginary isFloat.
	self assert: -0.25 sqrt = (1/2)i.
	self assert: -0.25 sqrt imaginary isFloat.
	self assert: Float negativeInfinity sqrt = Float infinity i.
]

{ #category : 'tests - mathematical functions' }
ComplexTest >> testSquared [
	
	| c c2 |
	c := (6 - 6 i).
	c2 := (c squared).
	self assert: c2 imaginary = -72.
	self assert: c2 real = 0.
]

{ #category : 'tests - mathematical functions' }
ComplexTest >> testTan [
	| c c2 |
	c := (2 + 0 i).
	self assert: c tan = c real tan.
	c := 2 + 3 i.
	c2 := c sin / c cos.
	self verify: c2 isTrigonometricallyEqualTo: c tan.
]

{ #category : 'tests - mathematical functions' }
ComplexTest >> testTanh [
	| c c2 |
	c := (2 + 0 i).
	self assert: (c tanh real isWithin: 1 floatsFrom: c real tanh).
	c := 2 + 3 i.
	c2 := c sinh / c cosh.
	self verify: c2 isHyperbolicallyEqualTo: c tanh.
]

{ #category : 'helpers' }
ComplexTest >> trigonometricPrecision [

	^384
]

{ #category : 'helpers' }
ComplexTest >> verify: aComplex isHyperbolicallyEqualTo: anotherComplex [
	super verify: aComplex real asFloat isHyperbolicallyEqualTo: anotherComplex real asFloat.
	super verify: aComplex imaginary asFloat isHyperbolicallyEqualTo: anotherComplex imaginary asFloat.
]

{ #category : 'helpers' }
ComplexTest >> verify: aComplex isMagnitudeAndArgumentWithin: anInteger floatsAwayFrom: anotherComplex [
	self verify: aComplex magnitude asFloat isWithin: anInteger floatsAwayFrom: anotherComplex magnitude asFloat.
	self verify: aComplex argument asFloat isWithin: anInteger floatsAwayFrom: anotherComplex argument asFloat.
]

{ #category : 'helpers' }
ComplexTest >> verify: aComplex isTrigonometricallyEqualTo: anotherComplex [
	super verify: aComplex real asFloat isTrigonometricallyEqualTo: anotherComplex real asFloat.
	super verify: aComplex imaginary asFloat isTrigonometricallyEqualTo: anotherComplex imaginary asFloat.
]
