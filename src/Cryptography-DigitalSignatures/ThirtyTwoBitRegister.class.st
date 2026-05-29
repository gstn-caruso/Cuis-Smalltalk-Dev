"
I represent a 32-bit register. An instance of me can hold any non-negative integer in the range [0..(2^32 - 1)]. Operations are performed on my contents in place, like a hardware register, and results are always modulo 2^32. All operations avoid LargeInteger arithmetic as much as possible.

I'm mainly used by the SecureHashAlgorithm class, but I can be used for implementing other algorithms designed for 32-bit arithmetic. For examble George Marsaglia's Xorshift PRNG from http://www.jstatsoft.org/v08/i14/paper :

"Internal state."
x := ThirtyTwoBitRegister fromInteger: 123456789.
y := ThirtyTwoBitRegister fromInteger: 362436069.
z := ThirtyTwoBitRegister fromInteger: 521288629.
w := ThirtyTwoBitRegister fromInteger: 88675123.
"Temporaries."
t := ThirtyTwoBitRegister new.
temp := nil.
"The algorithm: t=(x^(x<<11));x=y;y=z;z=w; return( w=(w^(w>>19))ˆ(t^(t>>8)) );"
xorShift128 := [
	"t=(x^(x<<11));"
	t
		loadFrom: x;
		<< 11;
		bitXor: x.
	"x=y;y=z;z=w;"
	temp := x.
	x := y.
	y := z.
	z := w.
	"w=(w^(w>>19))ˆ(t^(t>>8))"
	w := temp.
	w
		loadFrom: z;
		>> 19;
		bitXor: z;
		bitXor: t.
	t >> 8.
	w bitXor: t.
	"Truncate to 30 bits."
	(w hi bitShift: 14) bitXor: w low ].

The code is about 9.5x faster than an implementation using LargeIntegers:

"Implementation using LargeIntegers."
x := 123456789.
y := 362436069.
z := 521288629.
w := 88675123.
largeIntegerXorShift128 := [
	| t |
	t := ((x bitAnd: 16r1FFFFF) bitShift: 11) bitXor: x.
	x := y.
	y := z.
	z := w.
	w := (((w bitShift: -19) bitXor: w) bitXor: t) bitXor: (t bitShift: -8) ].

xorShift128 bench. '4,990,000 per second. 201 nanoseconds per run.'.
largeIntegerXorShift128 bench. '529,000 per second. 1.89 microseconds per run.'.
"
Class {
	#name : 'ThirtyTwoBitRegister',
	#superclass : 'Object',
	#instVars : [
		'hi',
		'low'
	],
	#category : 'Cryptography-DigitalSignatures',
	#package : 'Cryptography',
	#tag : 'DigitalSignatures'
}

{ #category : 'instance creation' }
ThirtyTwoBitRegister class >> fromByteArray: aByteArray at: startIndex [
	"Answer a new instance whose initial contents is copied from next four bytes from aByteArray starting at startIndex..
	Convention is Most Significant Byte first (aka big endian)."

	^ self basicNew loadFrom: aByteArray at: startIndex

]

{ #category : 'instance creation' }
ThirtyTwoBitRegister class >> fromInteger: aPositiveInteger [
	"Answer a new instance whose initial contents is copied from aPositiveInteger.
	It is required that aPositiveInteger has no more than 32 bits."

	^ self basicNew load: aPositiveInteger

]

{ #category : 'instance creation' }
ThirtyTwoBitRegister class >> new [
	"Answer a new instance whose initial contents is zero."

	^ super new load: 0

]

{ #category : 'accumulator ops' }
ThirtyTwoBitRegister >> *= aThirtTwoBitRegister [
	"Replace my contents with the product of the given register and my current contents."

	| otherLow otherHi mul newLow newHi |
	otherLow := aThirtTwoBitRegister low.
	otherHi := aThirtTwoBitRegister hi.
	"Multiply low with otherLow. Process the two highest bits of low separately if necessary to avoid LargeInteger operations."
	(low bitShift: -8) * (otherLow bitShift: -8) > 16r3FFF
		ifTrue: [ 
			mul := (low bitAnd: 16r3FFF) * otherLow. "Without the two most significant bits of low."
			newLow := (mul bitAnd: 16rFFFF).
			newHi := (mul bitShift: -16).
			mul := (low bitShift: -14) * otherLow. "The two most significant bits of low"
			newLow := newLow + ((mul bitAnd: 16r3) bitShift: 14).
			newHi := newHi + (mul bitShift: -2) + (newLow bitShift: -16) "Carry from newLow" ]
		ifFalse: [
			newLow := low * otherLow. "We'll trim newLow at the end of the method."
			newHi := newLow bitShift: -16 ].
	"Multiply hi with otherLow."
	(hi bitShift: -8) * (otherLow bitShift: -8) > 16r3FFF
		ifTrue: [
			newHi := newHi + 
				((hi bitAnd: 16r3FFF) * otherLow bitAnd: 16rFFFF) +
				(((hi bitShift: -14) * otherLow bitAnd: 16r3) bitShift: 14) ]
		ifFalse: [ newHi := newHi + (hi * otherLow bitAnd: 16rFFFF) ].
	"Multiply low with otherHi."
	(low bitShift: -8) * (otherHi bitShift: -8) > 16r3FFF
		ifTrue: [
			newHi := newHi + 
				((low bitAnd: 16r3FFF) * otherHi bitAnd: 16rFFFF) +
				(((low bitShift: -14) * otherHi bitAnd: 16r3) bitShift: 14) ]
		ifFalse: [ newHi := newHi + (low * otherHi bitAnd: 16rFFFF) ].
	"Truncate and store the results."
	hi := newHi bitAnd: 16rFFFF.
	low := newLow bitAnd: 16rFFFF 

]

{ #category : 'accumulator ops' }
ThirtyTwoBitRegister >> += aThirtTwoBitRegister [
	"Replace my contents with the sum of the given register and my current contents."

	| lowSum |
	lowSum := low + aThirtTwoBitRegister low.
	hi := (hi + aThirtTwoBitRegister hi + (lowSum bitShift: -16)) bitAnd: 16rFFFF.
	low := lowSum bitAnd: 16rFFFF.

]

{ #category : 'comparing' }
ThirtyTwoBitRegister >> < aThirtyTwoBitRegister [

	^hi < aThirtyTwoBitRegister hi or: [
		hi = aThirtyTwoBitRegister hi and: [
			low < aThirtyTwoBitRegister low ] ]
]

{ #category : 'accumulator ops' }
ThirtyTwoBitRegister >> << anInteger [
	"Unsigned left shift."

	| bitCount |
	bitCount := anInteger.
	bitCount >= 32 ifTrue: [
		hi := low := 0.
		^self ].
	bitCount >= 16 ifTrue: [
		hi := low.
		low := 0.
		bitCount := bitCount - 16 ].
	bitCount >= 15 ifTrue: [
		hi := ((hi bitAnd: 1) bitShift: 15) bitOr: (low bitShift: -1).
		low := (low bitAnd: 1) bitShift: 15.
		^self ].
	bitCount >= 1 ifTrue: [
		hi := ((hi bitShift: bitCount) bitAnd: 16rFFFF) bitOr: (low bitShift: bitCount - 16).
		low := (low bitShift: bitCount) bitAnd: 16rFFFF ]
]

{ #category : 'comparing' }
ThirtyTwoBitRegister >> <= aThirtyTwoBitRegister [

	^hi < aThirtyTwoBitRegister hi or: [
		hi = aThirtyTwoBitRegister hi and: [
			low <= aThirtyTwoBitRegister low ] ]
]

{ #category : 'comparing' }
ThirtyTwoBitRegister >> = anObject [

	^self class == anObject class
		and: [ anObject low = low
		and: [ anObject hi = hi ] ]
]

{ #category : 'comparing' }
ThirtyTwoBitRegister >> > aThirtyTwoBitRegister [

	^hi > aThirtyTwoBitRegister hi or: [
		hi = aThirtyTwoBitRegister hi and: [
			low > aThirtyTwoBitRegister low ] ]
]

{ #category : 'comparing' }
ThirtyTwoBitRegister >> >= aThirtyTwoBitRegister [

	^hi > aThirtyTwoBitRegister hi or: [
		hi = aThirtyTwoBitRegister hi and: [
			low >= aThirtyTwoBitRegister low ] ]
]

{ #category : 'accumulator ops' }
ThirtyTwoBitRegister >> >> anInteger [
	"Unsigned right shift."

	| bitCount shift |
	bitCount := anInteger.
	bitCount >= 32 ifTrue: [
		hi := low := 0.
		^self ].
	bitCount >= 16 ifTrue: [
		low := hi.
		hi := 0.
		bitCount := bitCount - 16 ].
	bitCount >= 2 ifTrue: [
		shift := 0 - bitCount.
		low := (low bitShift: shift) bitOr: ((hi bitShift: shift + 16) bitAnd: 16rFFFF).
		hi := hi bitShift: shift.
		^self ].
	bitCount >= 1 ifTrue: [
		low := (low bitShift: -1) bitOr: ((hi bitAnd: 16r1) bitShift: 15).
		hi := hi bitShift: -1 ]
]

{ #category : 'converting' }
ThirtyTwoBitRegister >> asInteger [
	"Answer the integer value of my current contents."

	^ (hi bitShift: 16) + low

]

{ #category : 'converting' }
ThirtyTwoBitRegister >> asSignedInteger [
	"Answer the signed integer value of my current contents."

	hi >= 16r8000 ifFalse: [ ^(hi bitShift: 16) + low ].
	^-1 - (low bitXor: 16rFFFF) - ((hi bitXor: 16rFFFF) bitShift: 16)



]

{ #category : 'accumulator ops' }
ThirtyTwoBitRegister >> bitAnd: aThirtTwoBitRegister [
	"Replace my contents with the bitwise AND of the given register and my current contents."

	hi := hi bitAnd: aThirtTwoBitRegister hi.
	low := low bitAnd: aThirtTwoBitRegister low.

]

{ #category : 'accumulator ops' }
ThirtyTwoBitRegister >> bitInvert [
	"Replace my contents with the bitwise inverse my current contents."

	hi := hi bitXor: 16rFFFF.
	low := low bitXor: 16rFFFF.

]

{ #category : 'accumulator ops' }
ThirtyTwoBitRegister >> bitOr: aThirtTwoBitRegister [
	"Replace my contents with the bitwise OR of the given register and my current contents."

	hi := hi bitOr: aThirtTwoBitRegister hi.
	low := low bitOr: aThirtTwoBitRegister low.

]

{ #category : 'accumulator ops' }
ThirtyTwoBitRegister >> bitXor: aThirtTwoBitRegister [
	"Replace my contents with the bitwise exclusive OR of the given register and my current contents."

	hi := hi bitXor: aThirtTwoBitRegister hi.
	low := low bitXor: aThirtTwoBitRegister low.

]

{ #category : 'copying' }
ThirtyTwoBitRegister >> copy [
	"Use the clone primitive for speed."

	<primitive: 148>
	^ super copy

]

{ #category : 'comparing' }
ThirtyTwoBitRegister >> hash [

	^((hi bitShift: 14) bitXor: low) hashMultiply
]

{ #category : 'accessing' }
ThirtyTwoBitRegister >> hi [

	^ hi

]

{ #category : 'accumulator ops' }
ThirtyTwoBitRegister >> leftRotateBy: bits [
	"Rotate my contents left by the given number of bits, retaining exactly 32 bits."
	"Details: Perform this operation with no LargeInteger arithmetic."

	| bitCount newHi |
	bitCount := bits.
	bitCount >= 32 ifTrue: [ bitCount := bitCount \\ 32 ].
	bitCount >= 16 ifTrue: [
		newHi := low.
		low := hi.
		hi := newHi.
		bitCount := bitCount - 16 ].
	bitCount >= 15 ifTrue: [
		newHi := ((hi bitAnd: 16r1) bitShift: 15) bitOr: (low bitShift: -1).
		low := ((low bitAnd: 16r1) bitShift: 15) bitOr: (hi bitShift: -1).
		hi := newHi.
		^self ].
	bitCount >= 1 ifTrue: [
		| shift |
		shift := bitCount - 16.
		newHi := ((hi bitShift: bitCount) bitAnd: 16rFFFF) bitOr: (low bitShift: shift).
		low := ((low bitShift: bitCount) bitAnd: 16rFFFF) bitOr: (hi bitShift: shift).
		hi := newHi ]
]

{ #category : 'accessing' }
ThirtyTwoBitRegister >> load: anInteger [
	"Set my contents to the value of given integer."

	(anInteger positive and: [anInteger digitLength <= 4])
		ifFalse: [self error: 'out of range: ', anInteger printString].
	low := anInteger bitAnd: 16rFFFF.
	hi := (anInteger bitShift: -16) bitAnd: 16rFFFF

]

{ #category : 'accessing' }
ThirtyTwoBitRegister >> loadFrom: aThirtyTwoBitRegister [
	"Set my contents from the given ThirtyTwoBitRegister."

	hi := aThirtyTwoBitRegister hi.
	low := aThirtyTwoBitRegister low

]

{ #category : 'accessing' }
ThirtyTwoBitRegister >> loadFrom: aByteArray at: index [
	"Load my 32-bit value from the four bytes of the given ByteArray starting at the given index. Consider the first byte to contain the most significant bits of the word (i.e., use big-endian byte ordering)."

	hi := ((aByteArray at: index) bitShift: 8) + ( aByteArray at: index + 1).
	low := ((aByteArray at: index + 2) bitShift: 8) + ( aByteArray at: index + 3).

]

{ #category : 'accessing' }
ThirtyTwoBitRegister >> low [

	^ low
]

{ #category : 'printing' }
ThirtyTwoBitRegister >> printOn: aStream [
	"Print my contents in hex with a leading 'R' to show that it is a register object being printed."

	aStream nextPutAll: 'R:'.
	self asInteger storeOn: aStream base: 16.

]

{ #category : 'accumulator ops' }
ThirtyTwoBitRegister >> rightRotateBy: bits [
	"Rotate my contents right by the given number of bits, retaining exactly 32 bits."
	"Details: Perform this operation with no LargeInteger arithmetic."
	| bitCount newLow |
	
	bitCount _ bits.
	bitCount >= 32 ifTrue: [ bitCount _ bitCount \\ 32 ].
	bitCount >= 16 ifTrue: [
		newLow _ hi.
		hi _ low.
		low _ newLow.
		bitCount _ bitCount - 16 ].

	bitCount >= 15 ifTrue: [
		newLow _ ((low bitAnd: 16r8000) bitShift: -15) bitOr: (hi << 1 bitAnd: 16rFFFF).
		hi _ ((hi bitAnd: 16r8000) bitShift: -15) bitOr: (low << 1 bitAnd: 16rFFFF).
		low _ newLow.
		^self ].
	
	bitCount >= 1 ifTrue: [
		| shift |
		shift _ 16 - bitCount .
		newLow _ ((hi bitShift: shift) bitAnd: 16rFFFF) bitOr: low >> bitCount.
		hi _ ((low bitShift: shift) bitAnd: 16rFFFF) bitOr: hi >> bitCount.
		low _ newLow ]
]
