Class {
	#name : 'PrintfFormatStringTest',
	#superclass : 'TestCase',
	#category : 'Printf',
	#package : 'Printf'
}

{ #category : 'as yet unclassified' }
PrintfFormatStringTest >> test100_ThousandSeparator [
       ". small numbers are ignored "
	self assert: (('%_d' printf: {123}) = '123' ) .
	self assert: (('%_d' printf: {1234}) = '1_234' ) .
	self assert: (('%_d' printf: {12345678}) = '12_345_678' ) .
	". very large numbers must be ok "
	self assert: (('%_d' printf: {123456789123456789}) = '123_456_789_123_456_789' ) .   
	
	
]

{ #category : 'as yet unclassified' }
PrintfFormatStringTest >> test101_LargeFloat [
       ". this test was added to remember there is an ugly bug here "
	self assert: ('%.2f' printf: {1.1}) = '1.10' .  
	self assert: ('%.2f' printf: {12.1}) = '12.10' .  
	self assert: ('%.2f' printf: {123.1}) = '123.10' . 
       self assert: ('%.2f' printf: {1234.1}) = '1234.10' .	  
	self assert: ('%.2f' printf: {12345.1}) = '12345.10' . 
	self assert: ('%.2f' printf: {123456.1}) = '123456.10' .  
	". from here on it is broken " 
	self assert: ('%.2f' printf: {1234567.1}) = '1234567.10'.     ". gives wrongly 1.23"
	self assert: ('%.2f' printf: {12345678.1}) = '12345678.10'.  ". gives wrongly 1.23"

	
]

{ #category : 'as yet unclassified' }
PrintfFormatStringTest >> test102_FloatsWithThousandSeparator [
       ". Testing the print of floating points with thousand separator "
	self assert: (('%_0.2f' printf: {1234}) = '1_234.00' ) .
	self assert: (('%_0.2f' printf: {1234.1}) = '1_234.10' ) .
	self assert: (('%_0.2f' printf: {1234.12}) = '1_234.12' ) .
	self assert: (('%_0.2f' printf: {1234.123}) = '1_234.12' ) .
	". digit limiting is by trucation "
	self assert: (('%_0.2f' printf: {1234.123}) = '1_234.12' ) .
	self assert: (('%_0.2f' printf: {1234.127}) = '1_234.12' ) .
]

{ #category : 'as yet unclassified' }
PrintfFormatStringTest >> test103_UserDefinedThousandAndDecimals [
       ". If the user set nothing number are formatted like this "
	self assert: (('%_0.2f' printf: {1234.567}) = '1_234.56'  ). 
	". the underscore may not be liked but it can be userful to re-parse the number,
	  Perl, Ruby, and recently Python recognize '123_123.12' numbers literals 
	. here we format the number in the US standard way.
	"
	PrintfNumberFormatDescriptor setUserThousandSeparatorTo: $, .
	self assert: (('%_0.2f' printf: {1234.567}) = '1,234.56'  ).
	". now let's print the number in the way it is considered 'normal' in Italy, for example " 
	PrintfNumberFormatDescriptor setUserThousandSeparatorTo: $. .
	PrintfNumberFormatDescriptor setUserDecimalSeparatorTo: $, .
	self assert: (('%_0.2f' printf: {1234.567}) = '1.234,56'  ).
	". and let's put back the default configuaration, since the other test expect that " 
	PrintfNumberFormatDescriptor setUserThousandSeparatorTo: nil .
	PrintfNumberFormatDescriptor setUserDecimalSeparatorTo: nil .
	self assert: (('%_0.2f' printf: {1234.567}) = '1_234.56'  ). 
	
]

{ #category : 'as yet unclassified' }
PrintfFormatStringTest >> testFprintf [
	| stream expected |
	stream := String new writeStream.
	expected := 'Here is a long string "hello world" and the same shortened "hello w       " with left flush.\The new line has a number "42.0"\and a 0-padded limited precision one "0000042.12345".' withNewLines.
	self assert: expected size equals: (stream f: 'Here is a %s string "%s" and the same shortened "%-14.7s" with left flush.\nThe new line has a number "%e"
and a 0-padded limited precision one "%013.5e".'
		printf: #('long' 'hello world' 'hello world' 42.0 42.1234567)).
	self assert: expected equals: stream contents
	
]

{ #category : 'as yet unclassified' }
PrintfFormatStringTest >> testManyArguments [

	self assert: 'Here is a long string "hello world" and the same shortened "hello w       " with left flush.
The new line has a number "42.0" and a 0-padded limited precision one "0000042.12345".' equals: ('Here is a %s string "%s" and the same shortened "%-14.7s" with left flush.\nThe new line has a number "%e" and a 0-padded limited precision one "%013.5e".'
		printf: #('long' 'hello world' 'hello world' 42.0 42.1234567))
		
]

{ #category : 'as yet unclassified' }
PrintfFormatStringTest >> testOneExponent [

	self assert: 'Here is a number "42.0".' equals: ('Here is a number "%e".' printf: 42.0).
	
]

{ #category : 'as yet unclassified' }
PrintfFormatStringTest >> testOneExponentAndOneInteger [

	self assert: 'Here is a float "42.0" and an integer "42".' equals: ('Here is a float "%e" and an integer "%d".' printf: #(42.0 42)).
	
]

{ #category : 'as yet unclassified' }
PrintfFormatStringTest >> testOneExponentWithLength [

	self assert: 'Here is a string "0000042.12345".' equals: ('Here is a string "%013.5e".' printf: 42.1234567).
	
]

{ #category : 'as yet unclassified' }
PrintfFormatStringTest >> testOneInteger [

	self assert: 'Here is a number "42".' equals: ('Here is a number "%d".' printf: 42).
	
]

{ #category : 'as yet unclassified' }
PrintfFormatStringTest >> testOneIntegerWithLength [

	self assert: 'Here is a string "0000042".' equals: ('Here is a string "%07.7d".' printf: 42).
	
]

{ #category : 'as yet unclassified' }
PrintfFormatStringTest >> testOnePrintPointer [

	self assert: 'Here is a pointer "0x12345678".' equals: ('Here is a pointer "%p".' printf: 16r12345678)
	
]

{ #category : 'as yet unclassified' }
PrintfFormatStringTest >> testOnePrintString [

	self assert: 'Here is a point "3@4".' equals: ('Here is a point "%P".' printf: 3@4)
	
]

{ #category : 'as yet unclassified' }
PrintfFormatStringTest >> testOneString [

	self assert: 'Here is a string "hello world".' equals: ('Here is a string "%s".' printf: 'hello world')
	
]

{ #category : 'as yet unclassified' }
PrintfFormatStringTest >> testOneStringWithLength [

	self assert:  'Here is a string "hello world" and another shortened "hello w       ".' equals: ('Here is a string "%s" and another shortened "%-14.7s".' printf: #('hello world' 'hello world'))
	
]

{ #category : 'as yet unclassified' }
PrintfFormatStringTest >> testReturnValue [

	self assert: 6+8 equals: ((PrintfFormatString new setFormat: 'hello %ld') printf: {12345678})
	
]
