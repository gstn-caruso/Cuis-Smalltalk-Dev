Class {
	#name : 'NegativePowerError',
	#superclass : 'ArithmeticMessageError',
	#category : 'Exceptions-Kernel',
	#package : 'Exceptions',
	#tag : 'Kernel'
}

{ #category : 'signaling' }
NegativePowerError >> floatErrorValue [
	^ receiver class nan
]
