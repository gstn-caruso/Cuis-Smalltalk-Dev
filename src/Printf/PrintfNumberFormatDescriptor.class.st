Class {
	#name : 'PrintfNumberFormatDescriptor',
	#superclass : 'PrintfFormatDescriptor',
	#instVars : [
		'operator',
		'padding',
		'radix',
		'space',
		'thousandSeparate'
	],
	#classVars : [
		'Base',
		'Cased',
		'DecimalSeparator',
		'Radix',
		'ThousandSeparator',
		'UserDecimalSeparator',
		'UserThousandSeparator'
	],
	#category : 'Printf',
	#package : 'Printf'
}

{ #category : 'settings' }
PrintfNumberFormatDescriptor class >> getDecimalSeparator [
	^ DecimalSeparator  
	
]

{ #category : 'settings' }
PrintfNumberFormatDescriptor class >> getThousandSeparator [
	^ ThousandSeparator  
	
]

{ #category : 'settings' }
PrintfNumberFormatDescriptor class >> getUserDecimalSeparator [
	^ UserDecimalSeparator  
	
]

{ #category : 'settings' }
PrintfNumberFormatDescriptor class >> getUserThousandSeparator [
	^ UserThousandSeparator  
	
]

{ #category : 'class initialization' }
PrintfNumberFormatDescriptor class >> initialize [
	"PrintfNumberFormatDescriptor initialize"
	Base := Dictionary newFromPairs: #(	$d 10
											$o 8
											$p 16
											$u 10
											$x 16
											$X 16).

	Radix := Dictionary newFromPairs: #(	$d ''
											$o '0'
											$p '0x'
											$u ''
											$x '0x'
											$X '0X').

	Cased := 'AaEeFfGgXx' . 
	
	". default values, don't modify these, test code use them.  "
	DecimalSeparator _ $.  .
	ThousandSeparator _ $_ . 
	". user modifiable values, for example to print numerics in agreement with some locale
	 . if these values are 'nil' they are ignored. If only one is 'nil' the other is taken from the default values above. 
	 " 
	UserDecimalSeparator _ nil. 
	UserThousandSeparator _ nil. 
	
	
]

{ #category : 'instance creation' }
PrintfNumberFormatDescriptor class >> newFrom: desc [
	desc class == self ifTrue: [^ desc].
	^ (super newFrom: desc) setPadding: desc padding
	
]

{ #category : 'settings' }
PrintfNumberFormatDescriptor class >> setUserDecimalSeparatorTo: aCharacter [
	UserDecimalSeparator _ aCharacter . 
]

{ #category : 'settings' }
PrintfNumberFormatDescriptor class >> setUserThousandSeparatorTo: aCharacter [
	UserThousandSeparator _ aCharacter . 
	
]

{ #category : 'rendering' }
PrintfNumberFormatDescriptor >> addThousandSeparator: numberString [
	". receives in input an integer numberString e.g. '12345'
	. returns in output a thousand separated string e.g. '12_345' 
	. '_' is the value lf 'thousandSeparator' 
	. if 'base' is not is not 10 returns just 'numberString', since a separation by 3 digits blocks
	 would not mean what 'thousand' says; in that case also print a warning in the Transcript'. 
	"
	(self base ~= 10) ifTrue:  [ 
		Transcript log: 'Error. Printf. thousand separation is not defined for non base 10 numbers.' . 
		^ numberString . 
		].
	". if we arrived here the base is 10 " 
	^ self formatWithUserPreferences: ( 
		(numberString asNumber printStringWithCommas) 
			copyReplaceAll: ',' with: (self thousandSeparator asString) ) 
 	
	
]

{ #category : 'rendering' }
PrintfNumberFormatDescriptor >> applyOperator: object  [
	"Character and Number are the only valid classes"

	| number string |
	object ifNil: [^'-'].
	number := object asInteger.
	
	string := number printStringBase: self base.
	". apply thousand separation, if reasonable "
	thousandSeparate ifTrue: [ string _ self addThousandSeparator: string ] . 
	(radix or: [operator == $p]) ifTrue: [string := self radixString , string].
	(Cased includes: operator) ifTrue:
		[string := operator isLowercase
					ifTrue: [string asLowercase]
					ifFalse: [string asUppercase]].
	(space and: [operator == $d and: [number < 0]]) ifTrue:
		[string := ' ' , string].
	^ (width ~= 0 and: [string size > self stringLength])
		ifTrue: [String new: width withAll: $*]
		ifFalse: [string]
		
]

{ #category : 'private' }
PrintfNumberFormatDescriptor >> base [
	^ Base at: operator
	
]

{ #category : 'rendering' }
PrintfNumberFormatDescriptor >> formatWithUserPreferences: numString [
	". numString is a string representing a number of the kind: 123_456.123.
	. according to the values in the class variables UserDecimalSeparator and UserThousandSeparator
	 a string like the following is returned, for example: 123.456,123, which would be appropriate 
	 for a user in Italy.  
	" 
	|userDec userThou tmp|
	userDec _ self class getUserDecimalSeparator . 
	userThou _ self class getUserThousandSeparator .
	". if there aren't user preferences set, then quit and use the default form string. "  
	((userDec isNil) and: (userThou isNil)) ifTrue: [ ^ numString ].
	". if any of the user preferences is undefined set it to the default valued " 
	(userDec isNil) ifTrue: [userDec _ self class getDecimalSeparator ].
	(userThou isNil) ifTrue: [userThou _ self class getThousandSeparator  ] . 
	". do the change and return the new formatted string " 
	tmp _ numString copyReplaceAll: '_' with: 'THO' . 
	tmp _ tmp copyReplaceAll: '.' with: 'DEC'. 
	tmp _ tmp copyReplaceAll: 'DEC' with: (userDec asString) . 
	tmp _ tmp copyReplaceAll: 'THO' with: (userThou asString) . 
	^ tmp 	
]

{ #category : 'initialize-release' }
PrintfNumberFormatDescriptor >> initialize [
	super initialize.
	padding := $ .
	radix := false.
	space := false.
	thousandSeparate := false .
	" . TODO temporary value, we should by default set $, if decimal separator is $. and viceversa. "
	thousandSeparator := $_ .
	". to permit print in the debugger " 
	operator _ $? . 
]

{ #category : 'private' }
PrintfNumberFormatDescriptor >> padding [
	^ padding
	
]

{ #category : 'printing' }
PrintfNumberFormatDescriptor >> printOn: aStream [
	Transcript log: '---> called NumFormDescriptor >> printOn: '.
	super printOn: aStream.
	thousandSeparate ifTrue: [ aStream nextPut: $_ ]. 
	padding == $0 ifTrue: [aStream nextPut: $0].
	radix ifTrue: [aStream nextPut: $#].
	space ifTrue: [aStream nextPut: $ ].
	self printWidthOn: aStream.
	aStream nextPut: operator
	
]

{ #category : 'scanning' }
PrintfNumberFormatDescriptor >> radix [
	radix := true
	
]

{ #category : 'private' }
PrintfNumberFormatDescriptor >> radixString [
	^ Radix at: operator
	
]

{ #category : 'private' }
PrintfNumberFormatDescriptor >> setOperator: char [
	operator := char
	
]

{ #category : 'private' }
PrintfNumberFormatDescriptor >> setPadding: paddingChar [
	padding := paddingChar
	
]

{ #category : 'scanning' }
PrintfNumberFormatDescriptor >> space [
	space := true
	
]

{ #category : 'private' }
PrintfNumberFormatDescriptor >> stringLength [
	^precision isNil
		ifTrue: [SmallInteger maxVal]
		ifFalse: [precision]
		
]

{ #category : 'scanning' }
PrintfNumberFormatDescriptor >> thousandSeparate [
	^ thousandSeparate  
]

{ #category : 'scanning' }
PrintfNumberFormatDescriptor >> thousandSeparate: aBoolean [
	thousandSeparate _ aBoolean .

]

{ #category : 'scanning' }
PrintfNumberFormatDescriptor >> thousandSeparator [
	^ self class getThousandSeparator 
	
]

{ #category : 'scanning' }
PrintfNumberFormatDescriptor >> zero [
	padding := $0
	
]
