"
I represent an access mechanism for a sequencable collection re-ordering or filtering its elements.
"
Class {
	#name : 'MappedCollection',
	#superclass : 'SequenceableCollection',
	#instVars : [
		'domain',
		'map'
	],
	#category : 'Goodies-Collections',
	#package : 'Goodies',
	#tag : 'Collections'
}

{ #category : 'instance creation' }
MappedCollection class >> collection: aCollection map: aSequenceableCollection  [
	"Answer an instance of me that maps aCollection by 
	aSequenceableCollection."

	^self basicNew setCollection: aCollection map: aSequenceableCollection
]

{ #category : 'instance creation' }
MappedCollection class >> new [

	self error: 'MappedCollections must be created using the collection:map: message'
]

{ #category : 'instance creation' }
MappedCollection class >> newFrom: aCollection  [
	"Answer an instance of me containing the same elements as aCollection."

	^ self collection: aCollection map: (1 to: aCollection size)

"	MappedCollection newFrom: {1. 2. 3}
	{4. 3. 8} as: MappedCollection
"
]

{ #category : 'adding' }
MappedCollection >> add: newObject [

	self shouldNotImplement
]

{ #category : 'accessing' }
MappedCollection >> at: anIndex [

	^domain at: (map at: anIndex)
]

{ #category : 'accessing' }
MappedCollection >> at: anIndex put: anObject [

	^domain at: (map at: anIndex) put: anObject
]

{ #category : 'enumerating' }
MappedCollection >> collect: aBlock  [
	"Refer to the comment in Collection|collect:."

	| aStream |
	aStream _ WriteStream on: (self species new: self size).
	self do:
		[:domainValue | 
		aStream nextPut: (aBlock value: domainValue)].
	^aStream contents
]

{ #category : 'accessing' }
MappedCollection >> contents [
	"Answer the receiver's domain for mapping, a Dictionary or 
	SequenceableCollection."

	^map collect: [:mappedIndex | domain at: mappedIndex]
]

{ #category : 'enumerating' }
MappedCollection >> do: aBlock  [
	"Refer to the comment in Collection|do:."

	map do:
		[:mapValue | aBlock value: (domain at: mapValue)]
]

{ #category : 'enumerating' }
MappedCollection >> select: aBlock  [
	"Refer to the comment in Collection|select:."

	| aStream |
	aStream _ WriteStream on: (self species new: self size).
	self do:
		[:domainValue | 
		(aBlock value: domainValue)
			ifTrue: [aStream nextPut: domainValue]].
	^aStream contents
]

{ #category : 'private' }
MappedCollection >> setCollection: aCollection map: aDictionary [

	domain _ aCollection.
	map _ aDictionary
]

{ #category : 'accessing' }
MappedCollection >> size [

	^map size
]

{ #category : 'private' }
MappedCollection >> species [

	^domain species
]

{ #category : 'printing' }
MappedCollection >> storeOn: aStream [
	aStream
		nextPut: $(;
		nextPutAll: self class name;
		nextPutAll: ' collection: ';
		store: domain;
		nextPutAll: ' map: ';
		store: map;
		nextPut: $)
]
