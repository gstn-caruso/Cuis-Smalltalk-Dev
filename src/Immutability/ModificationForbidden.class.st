Class {
	#name : 'ModificationForbidden',
	#superclass : 'Error',
	#instVars : [
		'object',
		'retrySelector',
		'fieldIndex',
		'newValue'
	],
	#category : 'Immutability',
	#package : 'Immutability'
}

{ #category : 'instance creation' }
ModificationForbidden class >> for: anObject at: anIndex with: aValue retrySelector: aSelector [

	^self new initializeFor: anObject at: anIndex with: aValue retrySelector: aSelector
]

{ #category : 'error message' }
ModificationForbidden class >> messageText [
	
	^'Attempt to modify an immutable object'
]

{ #category : 'signaling' }
ModificationForbidden class >> signalFor: anObject at: anIndex with: aValue retrySelector: aSelector [

	^(self for: anObject at: anIndex with: aValue retrySelector: aSelector) signal
]

{ #category : 'accessing' }
ModificationForbidden >> fieldIndex [
	
	^fieldIndex 
]

{ #category : 'initialization' }
ModificationForbidden >> initializeFor: anObject at: anIndex with: aValue retrySelector: aSelector [

	object := anObject.
	fieldIndex := anIndex.
	newValue := aValue.
	retrySelector := aSelector 
]

{ #category : 'exceptionDescription' }
ModificationForbidden >> messageText [

	^self class messageText 
]

{ #category : 'accessing' }
ModificationForbidden >> newValue [
	
	^newValue 
]

{ #category : 'accessing' }
ModificationForbidden >> object [
	
	^object
]

{ #category : 'retrying' }
ModificationForbidden >> retryModification [

	object perform: retrySelector with: fieldIndex with: newValue.
		
	self resumeUnchecked: newValue
]

{ #category : 'accessing' }
ModificationForbidden >> retrySelector [
	
	^retrySelector
]
