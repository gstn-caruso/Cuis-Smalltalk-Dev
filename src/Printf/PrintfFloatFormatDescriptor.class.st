Class {
	#name : 'PrintfFloatFormatDescriptor',
	#superclass : 'PrintfNumberFormatDescriptor',
	#category : 'Printf',
	#package : 'Printf'
}

{ #category : 'as yet unclassified' }
PrintfFloatFormatDescriptor class >> newFrom: descriptor [
	descriptor class == self ifTrue: [^ descriptor].
	^ ((super newFrom: descriptor) setPadding: descriptor padding) initializeThousandSeparatorFrom: descriptor 

	
]

{ #category : 'rendering' }
PrintfFloatFormatDescriptor >> addThousandSeparator: numberString [
	". receives in input an integer numberString e.g. '12345.1233123'
	. returns in output a thousand separated string e.g. '12_345.1233123' 
	. '_' is the value lf 'thousandSeparator' 
	. if 'base' is not is not 10 returns just 'numberString', since a separation by 3 digits blocks
	 would not mean what 'thousand' says; in that case also print a warning in the Transcript'. 
	"
	|integerPart decimalPart tokens out |
	". TODO. CHECK. we suppose the base is 10 for floats " 
	"(self base ~= 10) ifTrue:  [ 
		Transcript log: 'Error. Printf. thousand separation is not defined for non base 10 numbers.' . 
		^ numberString . 
		]."
	". if we arrived here the base is 10 " 
	tokens _ numberString findTokens: '.' . 
	integerPart _ tokens first.
	decimalPart _ tokens second. 
	". build the default thousand separated numeric string "
	out _ (integerPart asNumber printStringWithCommas :: 
		copyReplaceAll: ',' with: (self thousandSeparator asString) ), '.' , decimalPart .
	". apply user preferences regarding who are thousand and decimal separators "
	^ self formatWithUserPreferences: out . 	
	
]

{ #category : 'rendering' }
PrintfFloatFormatDescriptor >> applyOperator: object  [
	"Number is the only valid class"
	| string out |
	string := self zeroPaddedStringOfBase: (('aA' includes: operator)
												ifTrue: [16]
												ifFalse: [10])
				forFloat: object asNumber .
	string := string copyFrom: 1 to: ((string indexOf: $.) + (precision = 0
						ifTrue: [-1]
						ifFalse: [self precision]) min: string size).
	(Cased includes: operator) ifTrue:
		[string := operator isLowercase
					ifTrue: [string asLowercase]
					ifFalse: [string asUppercase]].
	(space and: [object asFloat >= 0]) ifTrue:
		[string := ' ' , string].
	out _ (width ~= 0 and: [string size > width])
			ifTrue: [String new: width withAll: $*]
			ifFalse: [string].
	" . add thousand separators, if needed " 
	"Transcript show: 'DBG --- applyOperator for FLoat numbers '. "
	thousandSeparate 
		ifTrue: [
			"Transcript show: 'DBG --- thousand sep is ON'. "
			out _ self addThousandSeparator: out. 
			] 
		ifFalse: [
			"Transcript show: 'DBG --- thousand sep is OFF' "
			] . 
	^ out 		
			
		
]

{ #category : 'private' }
PrintfFloatFormatDescriptor >> digits [
	^ width == 0 ifTrue: [7] ifFalse: [width]
	
]

{ #category : 'rendering' }
PrintfFloatFormatDescriptor >> initializeThousandSeparatorFrom: descriptor  [
	(descriptor class = PrintfNumberFormatDescriptor) ifTrue: [
		thousandSeparate  _ (descriptor thousandSeparate ).
		].
	^ self 
]

{ #category : 'private' }
PrintfFloatFormatDescriptor >> precision [
	^ precision isNil ifTrue: [1] ifFalse: [precision]
	
]

{ #category : 'private' }
PrintfFloatFormatDescriptor >> stringLength [
	^ width
	
]

{ #category : 'rendering' }
PrintfFloatFormatDescriptor >> zeroPaddedStringOfBase: base forFloat: aFloat  [
	| stream |
	stream := String new writeStream.
	aFloat printOn: stream base: base.
	stream next: self precision-1 put: $0.
	^stream contents
	
]
