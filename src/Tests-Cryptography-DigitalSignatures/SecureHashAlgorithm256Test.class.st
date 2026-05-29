Class {
	#name : 'SecureHashAlgorithm256Test',
	#superclass : 'TestCase',
	#instVars : [
		'hash',
		'usedClass'
	],
	#category : 'Tests-Cryptography-DigitalSignatures',
	#package : 'Tests',
	#tag : 'Cryptography-DigitalSignatures'
}

{ #category : 'as yet unclassified' }
SecureHashAlgorithm256Test >> setUp [
	usedClass _ SecureHashAlgorithm256 
]

{ #category : 'as yet unclassified' }
SecureHashAlgorithm256Test >> testEmptyInput [
	self assert: 'E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855'
		equals: ((usedClass new hashMessage: '') printStringBase: 16).
]

{ #category : 'as yet unclassified' }
SecureHashAlgorithm256Test >> testFoobar2Input [
	| message |
	message _ #[16r66 16r6F 16r6F 16r62 16r61 16r72]. "foobar"
	
	self assert: 'C3AB8FF13720E8AD9047DD39466B3C8974E592C2FA383D4A3960714CAEF0C4F2' 
		equals: ((usedClass new hashMessage: message) printStringBase: 16).
]

{ #category : 'as yet unclassified' }
SecureHashAlgorithm256Test >> testFoobarInput [
	| message |
	message _ #[16r66 16r6F 16r6F 16r62 16r61 16r72 16r0A]. "foobar\n"
	
	self assert:  'AEC070645FE53EE3B3763059376134F058CC337247C978ADD178B6CCDFB0019F' 
		equals: ((usedClass new hashMessage: message) printStringBase: 16).
]

{ #category : 'as yet unclassified' }
SecureHashAlgorithm256Test >> testUsingTestVector1 [
	"Source : https://www.di-mgt.com.au/sha_testvectors.html"
	| message |
	message _ 'abc'.
	
	self assert: 'BA7816BF8F01CFEA414140DE5DAE2223B00361A396177A9CB410FF61F20015AD'
		equals: ((usedClass new hashMessage: message) printStringBase: 16).
]

{ #category : 'as yet unclassified' }
SecureHashAlgorithm256Test >> testUsingTestVector3 [
	"Source : https://www.di-mgt.com.au/sha_testvectors.html"
	| message |
	message _ 'abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq'.
	
	self assert: '248D6A61D20638B8E5C026930C3E6039A33CE45964FF2167F6ECEDD419DB06C1'
		equals: ((usedClass new hashMessage: message) printStringBase: 16).
]

{ #category : 'as yet unclassified' }
SecureHashAlgorithm256Test >> testUsingTestVector4 [
	"Source : https://www.di-mgt.com.au/sha_testvectors.html"
	| message |
	message _ 'abcdefghbcdefghicdefghijdefghijkefghijklfghijklmghijklmnhijklmnoijklmnopjklmnopqklmnopqrlmnopqrsmnopqrstnopqrstu'.
	
	self assert: 'CF5B16A778AF8380036CE59E7B0492370B249B11E8F07A51AFAC45037AFEE9D1'
		equals: ((usedClass new hashMessage: message) printStringBase: 16).
]
