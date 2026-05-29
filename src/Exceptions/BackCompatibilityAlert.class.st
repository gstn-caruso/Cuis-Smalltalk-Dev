"
BackCompatibilityAlert is the exception signaled when some behavior in Cuis has recently changed creating back compatibility issues.
It is only raised when the new answer is different from the old one, and its purpose is to direct developers attention to the code that needs fixing.
"
Class {
	#name : 'BackCompatibilityAlert',
	#superclass : 'Exception',
	#category : 'Exceptions-Extensions',
	#package : 'Exceptions',
	#tag : 'Extensions'
}

{ #category : 'services' }
BackCompatibilityAlert class >> checkOldAnswer: oldAnswer newAnswer: newAnswer [
	"For an example of usage check Cuis update #7828, but not after #7848, as in #7848 this use case
	(reading Date and Month from a String stream) the old code was removed together with the Alert."
	| message lines |
	newAnswer = oldAnswer ifFalse: [
		message := thisContext sender printString, ' has changed behavior. Old answer was: ', oldAnswer printString,
			'. New answer is: ', newAnswer printString, '. You need to adjust calling code.'.
		lines := message substringsSeparatedBy: $..
		'' print.
		('=== BackCompatibilityAlert: ', lines first) print.
		2 to: lines size-1 do: [ :i | (lines at: i) print ].
		'-----' print.
		thisContext printStack: 3.
		BackCompatibilityAlert signal: message.
		].
]

{ #category : 'priv handling' }
BackCompatibilityAlert >> defaultAction [

	self noHandler
]

{ #category : 'description' }
BackCompatibilityAlert >> isResumable [

	^true
]
