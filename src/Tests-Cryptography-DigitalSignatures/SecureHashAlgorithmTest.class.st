"
This is the unit test for the class SecureHashAlgorithm. Unit tests are a good way to exercise the functionality of your system in a repeatable and automatic manner. They are therefore recommended if you plan to release anything. For more information, see: 
	- http://www.c2.com/cgi/wiki?UnitTest
	- http://minnow.cc.gatech.edu/squeak/1547
	- the sunit class category
"
Class {
	#name : 'SecureHashAlgorithmTest',
	#superclass : 'TestCase',
	#instVars : [
		'hash'
	],
	#category : 'Tests-Cryptography-DigitalSignatures',
	#package : 'Tests',
	#tag : 'Cryptography-DigitalSignatures'
}

{ #category : 'testing - examples' }
SecureHashAlgorithmTest >> testEmptyInput [
	self assert: ((SecureHashAlgorithm new hashMessage: '') printStringBase: 16)
			= 'DA39A3EE5E6B4B0D3255BFEF95601890AFD80709'
]

{ #category : 'testing - examples' }
SecureHashAlgorithmTest >> testExample1 [

	"This is the first example from the specification document (FIPS PUB 180-1)"

	hash := SecureHashAlgorithm new hashMessage: 'abc'.
	self assert: (hash = 16rA9993E364706816ABA3E25717850C26C9CD0D89D).
		
]

{ #category : 'testing - examples' }
SecureHashAlgorithmTest >> testExample2 [

	"This is the second example from the specification document (FIPS PUB 180-1)"

	hash := SecureHashAlgorithm new hashMessage:
		'abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq'.
	self assert: (hash = 16r84983E441C3BD26EBAAE4AA1F95129E5E54670F1).
]

{ #category : 'testing - examples' }
SecureHashAlgorithmTest >> testExample3 [

	"This is the third example from the specification document (FIPS PUB 180-1). 
	This example may take several minutes."

	hash := SecureHashAlgorithm new hashMessage: (String new: 1000000 withAll: $a).
	self assert: (hash = 16r34AA973CD4C4DAA4F61EEB2BDBAD27316534016F).
]
