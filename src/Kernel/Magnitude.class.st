"
I'm the abstract class Magnitude that provides common protocol for objects that have
the ability to be compared along a linear dimension, such as dates or times.
Subclasses of Magnitude include Date, ArithmeticValue, and Time, as well as LookupKey.
 
 
My subclasses should implement
  < aMagnitude 
  = aMagnitude 
  hash

Here are some example of my protocol:
     3 > 4
     5 = 6
     100 max: 9
	7 between: 5 and: 10 

"
Class {
	#name : 'Magnitude',
	#superclass : 'Object',
	#category : 'Kernel-Objects',
	#package : 'Kernel',
	#tag : 'Objects'
}

{ #category : '[mk] comparing' }
Magnitude >> < aMagnitude  [
	"Compare the receiver with the argument and answer with true if the 
	receiver is less than the argument. Otherwise answer false."

	^self subclassResponsibility
]

{ #category : '[mk] comparing' }
Magnitude >> <= aMagnitude  [
	"Compare the receiver with the argument and answer with true if the 
	receiver is less than or equal to the argument. Otherwise answer false."

	^(self > aMagnitude) not
]

{ #category : '[mk] comparing' }
Magnitude >> = aMagnitude  [
	"Compare the receiver with the argument and answer with true if the 
	receiver is equal to the argument. Otherwise answer false."

	^self subclassResponsibility
]

{ #category : '[mk] comparing' }
Magnitude >> > aMagnitude  [
	"Compare the receiver with the argument and answer with true if the 
	receiver is greater than the argument. Otherwise answer false."

	^aMagnitude < self
]

{ #category : 'comparing' }
Magnitude >> >= aMagnitude  [
	"Answer whether the receiver is greater than or equal to the argument."

	^aMagnitude <= self
]

{ #category : '[mk] comparing' }
Magnitude >> between: min and: max  [
	"Answer whether the receiver is less than or equal to the argument, max,
	and greater than or equal to the argument, min."

	^self >= min and: [self <= max]
]

{ #category : '[mk] comparing' }
Magnitude >> hash [
	"Hash must be redefined whenever = is redefined."

	^self subclassResponsibility
]

{ #category : '[mk] comparing' }
Magnitude >> max: aMagnitude  [
	"Answer the receiver or the argument, whichever has the greater magnitude."

	self > aMagnitude
		ifTrue: [^self]
		ifFalse: [^aMagnitude]
]

{ #category : '[mk] comparing' }
Magnitude >> min: aMagnitude  [
	"Answer the receiver or the argument, whichever has the lesser magnitude."

	self < aMagnitude
		ifTrue: [^self]
		ifFalse: [^aMagnitude]
]

{ #category : 'comparing' }
Magnitude >> min: aMin max: aMax  [

	^ (self min: aMin) max: aMax
]

{ #category : '*Network-Kernel' }
Magnitude >> putOn: aStream [

	(aStream isBinary ifTrue: [ self asByteArray ] ifFalse: [ self asString]) putOn: aStream
	
 
]
