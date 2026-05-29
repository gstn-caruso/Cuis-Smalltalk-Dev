"
I am a dictionary holding only weakly on my values. Clients may expect to get a nil value for any object they request.
"
Class {
	#name : 'WeakValueDictionary',
	#superclass : 'Dictionary',
	#category : 'WeakDictionaries',
	#package : 'WeakDictionaries'
}

{ #category : 'adding' }
WeakValueDictionary >> add: anAssociation [
	self at: anAssociation key put: anAssociation value.
	^ anAssociation
]

{ #category : 'accessing' }
WeakValueDictionary >> associationClass [

	^WeakValueAssociation
]

{ #category : 'accessing' }
WeakValueDictionary >> at: key ifAbsentOrNil: aBlock [
	"In a WeakValueDictionary, normally nil values (i.e. collected values) are considered the same as if the key/value was never added. Hence, this convenience method."
	
	| assoc |
	assoc := array at: (self findElementOrNil: key).
	assoc ifNil: [ ^ aBlock value ].
	^ assoc value ifNil: [ aBlock value ]
]

{ #category : 'accessing' }
WeakValueDictionary >> at: key ifAbsentOrNilPut: aBlock  [
	"Return the value at the given key.
	If key is not included in the receiver store the result
	of evaluating aBlock as new value."
	^self at: key ifAbsentOrNil: [self at: key put: aBlock value]
]
