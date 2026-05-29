"
I am an association holding only weakly on my key.
"
Class {
	#name : 'WeakKeyAssociation',
	#superclass : 'Association',
	#category : 'WeakDictionaries',
	#package : 'WeakDictionaries'
}

{ #category : 'comparing' }
WeakKeyAssociation >> < aLookupKey  [
	"Refer to the comment in Magnitude|<."

	^self key < aLookupKey key
]

{ #category : 'comparing' }
WeakKeyAssociation >> = aLookupKey [
	self == aLookupKey ifTrue: [ ^ true ].

	self species == aLookupKey species
		ifFalse: [ ^ false ].

	^self key = aLookupKey key
]

{ #category : 'comparing' }
WeakKeyAssociation >> hash [
	"Hash is reimplemented because = is implemented."

	^self key hash
]

{ #category : 'accessing' }
WeakKeyAssociation >> key [
	^key ifNotNil: [ key at: 1]
]

{ #category : 'accessing' }
WeakKeyAssociation >> key: aKey [
	key := WeakArray with: aKey
]

{ #category : 'accessing' }
WeakKeyAssociation >> key: aKey value: anObject [
	key := WeakArray with: aKey.
	value := anObject.
]

{ #category : 'printing' }
WeakKeyAssociation >> storeOn: aStream [
	aStream 
		nextPut: $(;
		nextPutAll: self class name;
		nextPutAll:' key: '.
	self key storeOn: aStream.
	aStream nextPutAll: ' value: '.
	self value storeOn: aStream.
	aStream nextPut: $)
]
