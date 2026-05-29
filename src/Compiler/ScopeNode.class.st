Class {
	#name : 'ScopeNode',
	#superclass : 'Object',
	#instVars : [
		'node',
		'nodeRange',
		'foundNodesInScope'
	],
	#category : 'Compiler-Support',
	#package : 'Compiler',
	#tag : 'Support'
}

{ #category : 'instance creation' }
ScopeNode class >> node: aNode range: aNodeRange  [

	^self new initializeNode: aNode range: aNodeRange 
]

{ #category : 'accessing' }
ScopeNode >> addFoundNodeInScope: aFoundNode  [

	foundNodesInScope add: aFoundNode
]

{ #category : 'testing' }
ScopeNode >> hasRange: sourceRange  [

	^ nodeRange = sourceRange
]

{ #category : 'testing' }
ScopeNode >> haveNodesFound [

	^ foundNodesInScope notEmpty
]

{ #category : 'initialization' }
ScopeNode >> initializeNode: aNode range: aNodeRange  [

	node := aNode.
	nodeRange := aNodeRange.
	foundNodesInScope := OrderedCollection new.
]

{ #category : 'testing' }
ScopeNode >> isIncludedIn: scope  [

	^ scope rangeIncludesAllOf: nodeRange 
]

{ #category : 'accessing' }
ScopeNode >> parseNode [

	^ node -> nodeRange
]

{ #category : 'printing' }
ScopeNode >> printOn: aStream [

	super printOn: aStream.
	
	aStream nextPut: $(.
	
	node printOn: aStream.
	
	aStream space; nextPutAll: '->'; space.
	
	nodeRange printOn: aStream.
	
	aStream nextPut: $). 
]

{ #category : 'testing' }
ScopeNode >> rangeIncludesAllOf: anInterval  [

	^ nodeRange includesAllOf: anInterval
]

{ #category : 'accessing' }
ScopeNode >> rangeSize [

	^ nodeRange size
]
