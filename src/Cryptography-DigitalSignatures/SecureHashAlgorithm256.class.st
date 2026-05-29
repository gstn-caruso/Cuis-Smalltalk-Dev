"
Implements the SHA-256 hash algorithm as defined in https://tools.ietf.org/html/rfc6234
"
Class {
	#name : 'SecureHashAlgorithm256',
	#superclass : 'Object',
	#instVars : [
		'totals',
		'totalA',
		'totalB',
		'totalC',
		'totalD',
		'totalE',
		'totalF',
		'totalG',
		'totalH'
	],
	#classVars : [
		'HashValues',
		'RoundConstants'
	],
	#category : 'Cryptography-DigitalSignatures',
	#package : 'Cryptography',
	#tag : 'DigitalSignatures'
}

{ #category : 'as yet unclassified' }
SecureHashAlgorithm256 class >> initialize [
	HashValues _ self makeHashValuesArray.
	RoundConstants _ self makeRoundConstantsArray.
]

{ #category : 'as yet unclassified' }
SecureHashAlgorithm256 class >> makeHashValuesArray [
	| constants |
	constants _ #(
		16r6A09E667 16rBB67AE85 16r3C6EF372 16rA54FF53A
		16r510E527F 16r9B05688C 16r1F83D9AB 16r5BE0CD19
	).
	^constants collect: [:const| ThirtyTwoBitRegister fromInteger: const ]
]

{ #category : 'as yet unclassified' }
SecureHashAlgorithm256 class >> makeRoundConstantsArray [
	| constants |
	constants _ #(
		16r428A2F98 16r71374491 16rB5C0FBCF 16rE9B5DBA5 16r3956C25B
 		16r59F111F1 16r923F82A4 16rAB1C5ED5  16rD807AA98 16r12835B01
		16r243185BE 16r550C7DC3 16r72BE5D74 16r80DEB1FE 16r9BDC06A7
		16rC19BF174 16rE49B69C1 16rEFBE4786 16r0FC19DC6 16r240CA1CC
		16r2DE92C6F 16r4A7484AA 16r5CB0A9DC 16r76F988DA 16r983E5152
		16rA831C66D 16rB00327C8 16rBF597FC7 16rC6E00BF3 16rD5A79147
		16r06CA6351 16r14292967  16r27B70A85 16r2E1B2138 16r4D2C6DFC
		16r53380D13 16r650A7354 16r766A0ABB 16r81C2C92E 16r92722C85
		16rA2BFE8A1 16rA81A664B 16rC24B8B70 16rC76C51A3 16rD192E819
		16rD6990624 16rF40E3585 16r106AA070 16r19A4C116 16r1E376C08
		16r2748774C 16r34B0BCB5 16r391C0CB3 16r4ED8AA4A 16r5B9CCA4F
		16r682E6FF3  16r748F82EE 16r78A5636F 16r84C87814 16r8CC70208
		16r90BEFFFA 16rA4506CEB 16rBEF9A3F7 16rC67178F2
	).
	^constants collect: [:const | ThirtyTwoBitRegister fromInteger: const ].
]

{ #category : 'as yet unclassified' }
SecureHashAlgorithm256 >> expandedBlock: aByteArray [
	"Convert the given 64 byte buffer into 64 32-bit registers and answer the result." 
	| out src |
	out _ Array new: 64.
	src _ 1.
	
	1 to: 16 do: [:i |
		out at: i put: (ThirtyTwoBitRegister fromByteArray: aByteArray at: src).
		src _ src + 4].

	17 to: 64 do: [:t |
		| v1 v2 v3 v4 result |
		"SSIG0(x) = ROTR^7(x) XOR ROTR^18(x) XOR SHR^3(x)"
		"SSIG1(x) = ROTR^17(x) XOR ROTR^19(x) XOR SHR^10(x)"
		"Wt = SSIG1(W(t-2)) + W(t-7) + SSIG0(w(t-15)) + W(t-16)"
		v1 _ (out at: t - 2) copy.
		v2 _ (out at: t - 7) copy.
		v3 _ (out at: t - 15) copy.
		v4 _ (out at: t - 16) copy.
		
		result _ self smallSigmaOne: v1.
		result += v2.
		result += (self smallSigmaZero: v3).
		result += v4.
		
		out at: t put: result ].
	
	^ out

]

{ #category : 'as yet unclassified' }
SecureHashAlgorithm256 >> finalHash [
	"Concatenate the final totals to build the 256-bit integer result."

	^ (totalA asInteger bitShift: 224) +
	   (totalB asInteger bitShift: 192) +
	   (totalC asInteger bitShift: 160) +
	   (totalD asInteger bitShift: 128) +
	   (totalE asInteger bitShift:  96) +
	   (totalF asInteger bitShift: 64) +
	   (totalG asInteger bitShift: 32) +
	   (totalH asInteger)
]

{ #category : 'as yet unclassified' }
SecureHashAlgorithm256 >> findConstantBy: aSmallInteger  [
	^(RoundConstants at: aSmallInteger) copy
]

{ #category : 'as yet unclassified' }
SecureHashAlgorithm256 >> hash1With: register1 with: register2 with: register3  [
	 "BSIG1(e) + CH(e,f,g) "
	| result chResult |
	result _ register1 copy.
	
	"BSIG1(x) = ROTR^6(x) XOR ROTR^11(x) XOR ROTR^25(x)"
	result rightRotateBy: 6.
	result bitXor: (register1 copy rightRotateBy: 11).
	result bitXor: (register1 copy rightRotateBy: 25).
	
	"CH( x, y, z) = (x AND y) XOR ( (NOT x) AND z)"
	chResult _ register1 copy.
	chResult bitAnd: register2.
	chResult bitXor: (register1 copy bitInvert bitAnd: register3).
	
	result += chResult.
	
	^result.
]

{ #category : 'as yet unclassified' }
SecureHashAlgorithm256 >> hash2With: register1 with: register2 with: register3 [
	| result majResult |

	"BSIG0(a) + MAJ(a,b,c)" 
	result _ register1 copy.

	"BSIG0(x) = ROTR^2(x) XOR ROTR^13(x) XOR ROTR^22(x)"
	result rightRotateBy: 2.
	result bitXor: (register1 copy rightRotateBy: 13).
	result bitXor: (register1 copy rightRotateBy: 22).
	
	"MAJ( x, y, z) = (x AND y) XOR (x AND z) XOR (y AND z)"
	majResult _ register1 copy.
	majResult bitAnd: register2.
	majResult bitXor: (register1 copy bitAnd: register3).
	majResult bitXor: (register2 copy bitAnd: register3).
	
	result += majResult.
	
	^result
]

{ #category : 'as yet unclassified' }
SecureHashAlgorithm256 >> hashMessage: aStringOrByteArray [
	"Hash the given message using the Secure Hash Algorithm 256."

	^ self hashStream: (ReadStream on: aStringOrByteArray asByteArray)

]

{ #category : 'as yet unclassified' }
SecureHashAlgorithm256 >> hashStream: aPositionableStream [
	| startPosition buf bitLength |
	self initializeTotals.

	aPositionableStream atEnd ifTrue: [self processFinalBuffer: #() bitLength: 0].

	startPosition _ aPositionableStream position.
	[aPositionableStream atEnd] whileFalse: [
		buf _ aPositionableStream next: 64.
		(aPositionableStream atEnd not and: [buf size = 64])
			ifTrue: [self processBuffer: buf]
			ifFalse: [
				bitLength _ (aPositionableStream position - startPosition) * 8.
				self processFinalBuffer: buf bitLength: bitLength]].

	^ self finalHash

]

{ #category : 'as yet unclassified' }
SecureHashAlgorithm256 >> initializeTotals [
	| initialValues |
	initialValues _ self class makeHashValuesArray.
	
	totalA _ initialValues at: 1.
	totalB _ initialValues at: 2.
	totalC _ initialValues at: 3.
	totalD _ initialValues at: 4.
	totalE _ initialValues at: 5.
	totalF _ initialValues at: 6.
	totalG _ initialValues at: 7.
	totalH _ initialValues at: 8.
	
]

{ #category : 'as yet unclassified' }
SecureHashAlgorithm256 >> processBuffer: aByteArray [
	"Process given 64-byte buffer, accumulating the results in totalA through totalE."
	| a b c d e f g h w tmp1 tmp2 |

	"initialize registers a through e from the current totals" 
	a _ totalA copy.
	b _ totalB copy.
	c _ totalC copy.
	d _ totalD copy.
	e _ totalE copy.
	f _ totalF copy. 
	g _ totalG copy.
	h _ totalH copy.

	"expand and process the buffer"
	w _ self expandedBlock: aByteArray.
	1 to: 64 do: [:i |
		tmp1 _ h copy.
		tmp1 += (self hash1With: e with: f with: g). "T1 = h + BSIG1(e) + CH(e,f,g) + Kt + Wt"
		tmp1 += (self findConstantBy: i).
		tmp1 += (w at: i).
		
		tmp2 _ self hash2With: a with: b with: c. "T2 = BSIG0(a) + MAJ(a,b,c)"
			
		h _ g.
		g _ f.
           f _ e.
           e _ d copy += tmp1.
           d _ c.
           c _ b.
           b _ a.
		a _ tmp1 copy += tmp2.
	 ].

	"add a through e into total accumulators"
	totalA  += a.
	totalB += b.
	totalC += c.
	totalD += d.
	totalE += e.
	totalF += f.
	totalG += g.
	totalH += h.

]

{ #category : 'as yet unclassified' }
SecureHashAlgorithm256 >> processFinalBuffer: buffer bitLength: bitLength  [
	"Process given buffer, whose length may be <= 64 bytes, accumulating the results in totalA through totalE. Also process the final padding bits and length."

	| out |
	out _ ByteArray new: 64.
	out replaceFrom: 1 to: buffer size with: buffer startingAt: 1.

	buffer size < 56 ifTrue: [  "padding and length fit in last data block"
		out at: buffer size + 1 put: 128.  "trailing one bit"
		self storeLength: bitLength in: out.  "end with length"
		self processBuffer: out.
		^ self].

	"process the final data block"
	buffer size < 64 ifTrue: [
		out at: buffer size + 1 put: 128].  "trailing one bit"

	self processBuffer: out.

	"process one additional block of padding ending with the length"
	out _ ByteArray new: 64.  "filled with zeros"
	buffer size = 64 ifTrue: [
		"add trailing one bit that didn't fit in final data block"
		out at: 1 put: 128].
	
	self storeLength: bitLength in: out.
	self processBuffer: out.

]

{ #category : 'as yet unclassified' }
SecureHashAlgorithm256 >> smallSigmaOne: register [
	"SSIG1(x) = ROTR^17(x) XOR ROTR^19(x) XOR SHR^10(x)"
	| result v1 v2 |
	result _ register copy.
	v1 _ register copy.
	v2 _ register copy.
	
	result rightRotateBy: 17.
	v1 rightRotateBy: 19.
	v2 >> 10.
	
	result bitXor: v1.
	result bitXor: v2.

	^result
	
]

{ #category : 'as yet unclassified' }
SecureHashAlgorithm256 >> smallSigmaZero: register [
	"SSIG0(x) = ROTR^7(x) XOR ROTR^18(x) XOR SHR^3(x)"
	| result v1 v2 |
	result _ register copy.
	v1 _ register copy.
	v2 _ register copy.
	
	result rightRotateBy: 7.
	v1 rightRotateBy: 18.
	v2 >> 3.
	
	result bitXor: v1.
	result bitXor: v2.
	
	^result
]

{ #category : 'as yet unclassified' }
SecureHashAlgorithm256 >> storeLength: bitLength in: aByteArray [
	"Fill in the final 8 bytes of the given ByteArray with a 64-bit big-endian representation of the original message length in bits."

	| n i |
	n _ bitLength.
	i _ aByteArray size.
	
	[n > 0] whileTrue: [
		aByteArray at: i put: (n bitAnd: 16rFF).
		n _ n bitShift: -8.
		i _ i - 1].

]
