"
From "Skip Lists: A Probabilistic Alternative to Balanced Trees" by William Pugh ( http://epaperpress.com/sortsearch/download/skiplist.pdf ):

"Skip lists are a data structure that can be used in place of balanced trees.  Skip lists use probabilistic balancing rather than strictly enforcing balancing and as a result the algorithms for insertion and deletion in skip lists are much simpler and significantly faster than equivalent algorithms for balanced trees."

Notes:

The elements of the skip list must implement #< or you must provide a sort block.


"
Class {
	#name : 'SkipList',
	#superclass : 'Collection',
	#instVars : [
		'sortBlock',
		'pointers',
		'numElements',
		'level',
		'splice'
	],
	#classVars : [
		'Rand'
	],
	#category : 'Goodies-Collections',
	#package : 'Goodies',
	#tag : 'Collections'
}

{ #category : 'instance creation' }
SkipList class >> maxLevel: maxLevel [
	"
	SkipList maxLevel: 5
	"
	^ super new initialize: maxLevel
]

{ #category : 'instance creation' }
SkipList class >> maxLevel: anInteger sortBlock: aBlock [
	^ (self maxLevel: anInteger) sortBlock: aBlock
]

{ #category : 'instance creation' }
SkipList class >> new [
	"
	SkipList new
	"
	^ super new initialize: 10
]

{ #category : 'instance creation' }
SkipList class >> new: anInteger [
	^ self maxLevel: (anInteger log: 2) ceiling
]

{ #category : 'instance creation' }
SkipList class >> new: anInteger sortBlock: aBlock [
	^ (self new: anInteger) sortBlock: aBlock
]

{ #category : 'instance creation' }
SkipList class >> sortBlock: aBlock [
	^ self new sortBlock: aBlock
]

{ #category : 'adding' }
SkipList >> add: element  [
	self add: element ifPresent: nil.
	^ element
]

{ #category : 'adding' }
SkipList >> add: element ifPresent: aBlock [
	| node lvl s |
	node _ self search: element updating: splice.
	node ifNotNil: [aBlock ifNotNil: [^ aBlock value: node]].
	lvl _ self randomLevel.
	node _ SkipListNode on: element level: lvl.
	level + 1 to: lvl do: [:i | splice at: i put: self].
	1 to: lvl do: [:i |
				s _ splice at: i.
				node atForward: i put: (s forward: i).
				s atForward: i put: node].
	numElements _ numElements + 1.
	splice atAllPut: nil.
	^ element

]

{ #category : 'private' }
SkipList >> atForward: i put: node [
	level _ node
		ifNil: [pointers findLast: [:n | n notNil]]
		ifNotNil: [level max: i].
	^ pointers at: i put: node
]

{ #category : 'enumerating' }
SkipList >> do: aBlock [
	self nodesDo: [:node | aBlock value: node object]
]

{ #category : 'private' }
SkipList >> forward: i  [
	^ pointers at: i
]

{ #category : 'testing' }
SkipList >> includes: element [
	^ (self search: element updating: nil) notNil
]

{ #category : 'initialization' }
SkipList >> initialize: maxLevel [
	pointers _ Array new: maxLevel.
	splice _ Array new: maxLevel.
	numElements _ 0.
	level _ 0.
	Rand ifNil: [Rand _ Random new]
]

{ #category : 'private' }
SkipList >> is: node before: element  [
	| object |
	node ifNil: [^ false].
	object _ node object.
	^ sortBlock
		ifNil: [object < element]
		ifNotNil: [(self is: object equalTo: element) ifTrue: [^ false].
			sortBlock value: object value: element]
]

{ #category : 'element comparison' }
SkipList >> is: element1 equalTo: element2 [
	^ element1 = element2
]

{ #category : 'private' }
SkipList >> is: node theNodeFor: element  [
	node ifNil: [^ false].
	node == self ifTrue: [^ false].
	^ self is: node object equalTo: element
]

{ #category : 'testing' }
SkipList >> isEmpty [
	^ numElements = 0
]

{ #category : 'accessing' }
SkipList >> level [
	^ level
]

{ #category : 'accessing' }
SkipList >> maxLevel [
	^ pointers size
]

{ #category : 'accessing' }
SkipList >> maxLevel: n [
	| newLevel oldPointers |
	newLevel _ n max: level.
	oldPointers _ pointers.
	pointers _ Array new: newLevel.
	splice _ Array new: newLevel.
	1 to: level do: [:i | pointers at: i put: (oldPointers at: i)]

]

{ #category : 'private' }
SkipList >> next [
	^ pointers first
]

{ #category : 'node enumeration' }
SkipList >> nodesDo: aBlock [
	| node |
	node _ pointers first.
	[node notNil]
		whileTrue:
			[aBlock value: node.
			node _ node next]
]

{ #category : 'private' }
SkipList >> randomLevel [
	| p answer max |
	p _ 0.5.
	answer _ 1.
	max _ self maxLevel.
	[Rand next < p and: [answer < max]]
		whileTrue: [answer _ answer + 1].
	^ answer
]

{ #category : 'removing' }
SkipList >> remove: element ifAbsent: aBlock [
	| node i s |
	node _ self search: element updating: splice.
	node ifNil: [^ aBlock value].
	i _ 1.
	[s _ splice at: i.
	i <= level and: [(s forward: i) == node]]
				whileTrue:
					[s atForward: i put: (node forward: i).
					i _ i + 1].
	numElements _ numElements - 1.
	splice atAllPut: nil.
	^ node object

]

{ #category : 'removing' }
SkipList >> removeAll [
	pointers atAllPut: nil.
	splice atAllPut: nil.
	numElements _ 0.
	level _ 0.
]

{ #category : 'private' }
SkipList >> search: element updating: array [
	| node forward |
	node _ self.
	level to: 1 by: -1 do: [:i |
			[forward _ node forward: i.
			self is: forward before: element] whileTrue: [node _ forward].
			"At this point: node < element <= forward"
			array ifNotNil: [array at: i put: node]].
	node _ node next.
	^ (self is: node theNodeFor: element) ifTrue: [node]
]

{ #category : 'accessing' }
SkipList >> size [
	^ numElements
]

{ #category : 'accessing' }
SkipList >> sortBlock [
	^ sortBlock
]

{ #category : 'accessing' }
SkipList >> sortBlock: aBlock [
	sortBlock _ aBlock
]
