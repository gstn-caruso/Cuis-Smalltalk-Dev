Class {
	#name : 'SkipListNode',
	#superclass : 'Object',
	#instVars : [
		'pointers',
		'object'
	],
	#category : 'Goodies-Collections',
	#package : 'Goodies',
	#tag : 'Collections'
}

{ #category : 'instance creation' }
SkipListNode class >> new: maxLevel [
	^ super new initialize: maxLevel
]

{ #category : 'instance creation' }
SkipListNode class >> on: element level: maxLevel  [
	^ (self new: maxLevel)
		object: element
]

{ #category : 'instance creation' }
SkipListNode class >> tailOfLevel: n [
	^ self on: nil level: n
]

{ #category : 'accessing' }
SkipListNode >> atForward: i put: node [
	^ pointers at: i put: node
]

{ #category : 'accessing' }
SkipListNode >> forward: i  [
	^ pointers at: i
]

{ #category : 'initialization' }
SkipListNode >> initialize: maxLevel [
	pointers _ Array new: maxLevel
]

{ #category : 'accessing' }
SkipListNode >> level [
	^ pointers size
]

{ #category : 'accessing' }
SkipListNode >> next [
	^ pointers first
]

{ #category : 'accessing' }
SkipListNode >> object [
	^ object
]

{ #category : 'private' }
SkipListNode >> object: anObject [
	object _ anObject
]

{ #category : 'printing' }
SkipListNode >> printOn: aStream [
	| first |
	aStream
		nextPut: $[;
		nextPutAll: object printString;
		nextPutAll: ']-->('.
	first _ true.
	pointers do: [:node |
		first ifTrue: [first _ false] ifFalse: [aStream space].
		aStream nextPutAll: (node ifNil: ['*'] ifNotNil: [node object printString])].
	aStream nextPut: $)

]
