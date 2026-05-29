"
ZipEncoderTree represents a huffman tree for encoding ZipStreams.

Instance variables:
	bitLengths	<WordArray>	 - Bit lengths of each generated code
	codes		<WordArray>	 - Codes for each value
	maxCode		<Integer>	- Maximum value with non-zero frequency
"
Class {
	#name : 'ZipEncoderTree',
	#superclass : 'Object',
	#instVars : [
		'bitLengths',
		'codes',
		'maxCode'
	],
	#category : 'Compression-System',
	#package : 'Compression',
	#tag : 'System'
}

{ #category : 'instance creation' }
ZipEncoderTree class >> buildTreeFrom: frequencies maxDepth: depth [
	^self new buildTreeFrom: frequencies maxDepth: depth
]

{ #category : 'accessing' }
ZipEncoderTree >> bitLengthAt: index [
	^bitLengths at: index+1
]

{ #category : 'accessing' }
ZipEncoderTree >> bitLengths [
	"Return an array of all bitLength values for valid codes"
	^bitLengths
]

{ #category : 'private' }
ZipEncoderTree >> bitLengths: blArray codes: codeArray [
	bitLengths _ blArray as: WordArray.
	codes _ codeArray as: WordArray.
	self assert:[(self bitLengthAt: maxCode) > 0].
]

{ #category : 'encoding' }
ZipEncoderTree >> buildCodes: nodeList counts: blCounts maxDepth: depth [
	"Build the codes for all nodes"
	| nextCode code node length |
	nextCode _ WordArray new: depth+1.
	code _ 0.
	1 to: depth do:[:bits|
		code _ (code + (blCounts at: bits)) << 1.
		nextCode at: bits+1 put: code].
	self assert:[(code + (blCounts at: depth+1) - 1) = (1 << depth - 1)].
	0 to: maxCode do:[:n|
		node _ nodeList at: n+1.
		length _ node bitLength.
		length = 0 ifFalse:[
			code _ nextCode at: length+1.
			node code: (self reverseBits: code length: length).
			nextCode at: length+1 put: code+1.
		].
	].
]

{ #category : 'encoding' }
ZipEncoderTree >> buildHierarchyFrom: aHeap [
	"Build the node hierarchy based on the leafs in aHeap"
	| left right parent |
	[aHeap size > 1] whileTrue:[
		left _ aHeap removeFirst.
		right _ aHeap removeFirst.
		parent _ ZipEncoderNode value: -1 
			frequency: (left frequency + right frequency)
			height: (left height max: right height) + 1.
		left parent: parent.
		right parent: parent.
		parent left: left.
		parent right: right.
		aHeap add: parent].
	^aHeap removeFirst

]

{ #category : 'encoding' }
ZipEncoderTree >> buildTree: nodeList maxDepth: depth [
	"Build either the literal or the distance tree"
	| heap rootNode blCounts |
	heap := Heap new.
	heap sortBlock: self nodeSortBlock.
	"Find all nodes with non-zero frequency and add to heap"
	maxCode := 0.
	nodeList do:[:dNode|
		dNode frequency = 0 ifFalse:[
			maxCode := dNode value.
			heap add: dNode]].
	"The pkzip format requires that at least one distance code exists,
	and that at least one bit should be sent even if there is only one
	possible code. So to avoid special checks later on we force at least
	two codes of non zero frequency."
	heap size = 0 ifTrue:[
		self assert:[maxCode = 0].
		heap add: nodeList first.
		heap add: nodeList second.
		maxCode := 1].
	heap size = 1 ifTrue:[
		nodeList first frequency = 0
			ifTrue:[heap add: nodeList first]
			ifFalse:[heap add: nodeList second].
		maxCode := maxCode max: 1].
	rootNode := self buildHierarchyFrom: heap.
	rootNode height > depth ifTrue:[
		rootNode := rootNode rotateToHeight: depth.
		rootNode height > depth ifTrue:[self error:'Cannot encode tree']].
	blCounts := WordArray new: depth+1.
	rootNode encodeBitLength: blCounts from: self.
	self buildCodes: nodeList counts: blCounts maxDepth: depth.
	self setValuesFrom: nodeList.
]

{ #category : 'encoding' }
ZipEncoderTree >> buildTreeFrom: frequencies maxDepth: depth [
	"Build the receiver from the given frequency values"
	| nodeList |
	nodeList _ Array new: frequencies size.
	1 to: frequencies size do:[:i|
		nodeList at: i put: (ZipEncoderNode value: i-1 frequency: (frequencies at: i) height: 0)
	].
	self buildTree: nodeList maxDepth: depth.
]

{ #category : 'accessing' }
ZipEncoderTree >> codeAt: index [
	^codes at: index+1
]

{ #category : 'accessing' }
ZipEncoderTree >> codes [
	"Return an array of all valid codes"
	^codes
]

{ #category : 'accessing' }
ZipEncoderTree >> maxCode [
	^maxCode
]

{ #category : 'accessing' }
ZipEncoderTree >> maxCode: aNumber [
	maxCode _ aNumber.
]

{ #category : 'encoding' }
ZipEncoderTree >> nodeSortBlock [
	^[:n1 :n2|
		n1 frequency = n2 frequency
			ifTrue:[n1 height <= n2 height]
			ifFalse:[n1 frequency <= n2 frequency]].
]

{ #category : 'private' }
ZipEncoderTree >> reverseBits: code length: length [
	"Bit reverse the given code"
	| result bit bits |
	result _ 0.
	bits _ code.
	1 to: length do:[:i|
		bit _ bits bitAnd: 1.
		result _ result << 1 bitOr: bit.
		bits _ bits >> 1].
	^result
]

{ #category : 'private' }
ZipEncoderTree >> setValuesFrom: nodeList [
	self bitLengths: (nodeList collect:[:n| n bitLength] from: 1 to: maxCode+1)
		codes: (nodeList collect:[:n| n code] from: 1 to: maxCode+1).
]
