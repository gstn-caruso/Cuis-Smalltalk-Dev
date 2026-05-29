Extension { #name : 'NegativePowerError' }

{ #category : '*Complex' }
NegativePowerError >> defaultAction [

	^(Complex basicReal: receiver imaginary: 0) perform: selector withArguments: arguments
]
