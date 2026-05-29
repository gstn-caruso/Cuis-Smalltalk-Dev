Extension { #name : 'InstructionPrinter' }

{ #category : '*BytecodeSets-SistaV1-decoding' }
InstructionPrinter >> branchIfInstanceOf: behaviorOrArrayOfBehavior distance: distance [
	"If the object on top of stack has the type -or one of the type- present in the literal
	 (the literal is a behavior or an array of behavior), then pop it. Else jumps by the distance."
	self print: 'branchIfInstanceOf: ', behaviorOrArrayOfBehavior printString, ' distance: ', distance printString
]

{ #category : '*BytecodeSets-SistaV1-decoding' }
InstructionPrinter >> branchIfNotInstanceOf: behaviorOrArrayOfBehavior distance: distance [
	"If the object on top of stack has the type -or one of the type- present in the literal
	 (the literal is a behavior or an array of behavior), then pop it. Else jumps by the distance."
	self print: 'branchIfNotInstanceOf: ', behaviorOrArrayOfBehavior printString, ' distance: ', distance printString
]

{ #category : '*BytecodeSets-instruction decoding' }
InstructionPrinter >> callInlinePrimitive: index [
	"Print the callInlinePrimitive: bytecode.  This is the m = 1, ss = 0 case in SistaV1:	**	248 below.

	SistaV1:	**	248	(2)	11111000 	iiiiiiii		mssjjjjj		Call Primitive #iiiiiiii + (jjjjj * 256) 
								m=1 means inlined primitive, no hard return after execution. 
								ss defines the unsafe operation set used to encode the operations. 
								(ss = 0 means sista unsafe operations, ss = 01 means lowcode operations, other numbers are as yet used)
	 V3/Spur:		139		10001011	i i i i i i i i	jjjjjjjj		Call Primitive #iiiiiiii + (jjjjjjjj * 256)"

	self print: 'callInlinePrimitive: ' , ((#((1000 ' class')
										(1001 ' pointer numSlots')
										(1002 ' pointer basicSize')
										(1003 ' byte8Type format numBytes')
										(1004 ' short16Type format numSho')
										(1005 ' word32Type format numWord')
										(1006 ' doubleWord64Type format n')

										(1010 ' ensure number of bytes available')
										(1011 ' fixed pointer basicNew')

										(1020 ' identityHash (non-immediate, non-Behavior, has hash)')
										(1021 ' identityHash (SmallInteger)')
										(1022 ' identityHash (Character)')
										(1023 ' identityHash (SmallFloat64)')
										(1024 ' identityHash (Behavior, has hash?)')

										(1030 ' immediateAsInteger (Character)')
										(1031 ' immediateAsInteger (SmallFloat64)')

										(2000 ' SmallInteger #+')
										(2001 ' SmallInteger #-')
										(2002 ' SmallInteger #*')
										(2003 ' SmallInteger #/')
										(2004 ' SmallInteger #//')
										(2005 ' SmallInteger #\\')
										(2006 ' SmallInteger #quo:')

										(2011 ' Variable-sized pointers new (new:). Array, etc')
										(2012 ' Variable-sized byte new (new:). ByteArray, ByteString, etc')
										(2013 ' Variable-sized 16-bit new (new:). DoubleByteArray, etc')
										(2014 ' Variable-sized 32-bit new (new:). Bitmap, FloatArray, etc')
										(2015 ' Variable-sized 64-bit new (new:). DoubleWordArray, etc')

										(2016 ' SmallInteger #bitAnd:')
										(2017 ' SmallInteger #bitOr:')
										(2018 ' SmallInteger #bitXor:')
										(2019 ' SmallInteger #bitShiftLeft:')
										(2019 ' SmallInteger #bitShiftRight:')

										(2032 ' SmallInteger #>')
										(2033 ' SmallInteger #<')
										(2034 ' SmallInteger #>=')
										(2035 ' SmallInteger #<=')
										(2036 ' SmallInteger #=')
										(2037 ' SmallInteger #~=')

										(2064 ' Pointer Object>>at:')
										(2065 ' Byte Object>>at:')
										(2066 ' 16-bit Word Object>>at:')
										(2067 ' Word Object>>at:')
										(2068 ' DoubleWord Object>>at:')
										(2069 ' QuadWord Object>>at:')

										(3000 ' Pointer Object>>at:put:')
										(3001 ' Byte Object>>at:put:')
										(3002 ' Word Object>>at:put:')
										(3003 ' DoubleWord Object>>at:put')
										(3004 ' QuadWord Object>>at:put:'))
											detect: [:tuple| tuple first = index]
											ifNone: [{index printString}]) last)
]
