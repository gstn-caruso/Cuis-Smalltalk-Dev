Class {
	#name : 'CommonScopeNodeFinder',
	#superclass : 'ParseNodeVisitor',
	#instVars : [
		'parseNodesToFindCommonScope',
		'scopesCollection',
		'nodesWithScopeFound',
		'methodNode',
		'actualScopeIndex'
	],
	#category : 'Compiler-Support',
	#package : 'Compiler',
	#tag : 'Support'
}

{ #category : 'error messages' }
CommonScopeNodeFinder class >> couldNotFindANodeErrorMessage [

	^ 'Could not find a node in the AST'
]

{ #category : 'instance creation' }
CommonScopeNodeFinder class >> forAll: aCollectionOfNodes in: aMethodNode [

	^self new initializeForAll: aCollectionOfNodes in: aMethodNode
]

{ #category : 'private - visiting' }
CommonScopeNodeFinder >> actualScope [

	^ scopesCollection at: actualScopeIndex
]

{ #category : 'private - visiting' }
CommonScopeNodeFinder >> addNodeIfFound: aNode [

	| nodeFound |

	self detectNodeToFind: aNode
		ifFound: [ :aNodeFound | nodeFound := aNodeFound ]
		ifNone: [ ^ false ].

	nodesWithScopeFound add: aNode.
	self actualScope addFoundNodeInScope: aNode.
	parseNodesToFindCommonScope remove: nodeFound.
	
	^ true
]

{ #category : 'private - visiting' }
CommonScopeNodeFinder >> addToScopeList: aNode [

	scopesCollection add: (ScopeNode node: aNode range: (self nodeRangeOf: aNode)).
	
	actualScopeIndex := scopesCollection size
]

{ #category : 'assertions' }
CommonScopeNodeFinder >> assertHasFoundAllNodes [

	parseNodesToFindCommonScope 
		ifNotEmpty: [ self error: self class couldNotFindANodeErrorMessage ]
]

{ #category : 'accessing' }
CommonScopeNodeFinder >> commonScopeNode [

	| scopeToReturn nonEmptyScopes |
	
	self assertHasFoundAllNodes.
	
	"The MethodNode is the first one"
	scopeToReturn := scopesCollection first.

	nonEmptyScopes := scopesCollection select: [ :scope | scope haveNodesFound ].
	
	nonEmptyScopes
		ifNotEmpty: [
			(self scopesOf: nonEmptyScopes)
				 ifNotEmpty: [ :scopesOfNonEmptyScopes |
					| minVal |
					
					minVal := scopesOfNonEmptyScopes min: [ :scope | scope rangeSize ].
					(minVal < scopeToReturn rangeSize)
						ifTrue: [ scopeToReturn := scopesOfNonEmptyScopes detect: [ :scope | scope rangeSize = minVal ] ] ] ].

	^ scopeToReturn parseNode
]

{ #category : 'private - visiting' }
CommonScopeNodeFinder >> completeSourceRangesOf: aNode [

	^ (methodNode 
		completeSourceRangesOf: aNode 
		ifAbsent: [ self shouldNotHappen ])
		asSortedCollection: [ :leftRange :rightRange | leftRange first < rightRange first ]
]

{ #category : 'private - visiting' }
CommonScopeNodeFinder >> detectNodeToFind: aNode ifFound: aFoundBlock ifNone: aNoneBlock [

	^ parseNodesToFindCommonScope 
		detect: [ :nodeToFind | (nodeToFind key equivalentTo: aNode) 
			and: [ self includesActualScopeRangeAllOf: nodeToFind value ]]
		ifFound: aFoundBlock
		ifNone: aNoneBlock
]

{ #category : 'private - visiting' }
CommonScopeNodeFinder >> includesActualScopeRangeAllOf: anInterval [

	^ self actualScope rangeIncludesAllOf: anInterval
]

{ #category : 'initialization' }
CommonScopeNodeFinder >> initializeForAll: aCollectionOfNodes in: aMethodNode [

	parseNodesToFindCommonScope := self sortByIntervalPositions: aCollectionOfNodes.
	methodNode := aMethodNode.
	actualScopeIndex := 0.
	nodesWithScopeFound := OrderedCollection new.
	scopesCollection := OrderedCollection new
]

{ #category : 'private - visiting' }
CommonScopeNodeFinder >> isNodeToFind: aNode [

	^ self detectNodeToFind: aNode
		ifFound: [ :nodeFound | true ]
		ifNone: [ false ]
]

{ #category : 'private - visiting' }
CommonScopeNodeFinder >> isScopeAddedWithRange: sourceRange [

	^ scopesCollection anySatisfy: [ :scope | scope hasRange: sourceRange ]
]

{ #category : 'private - visiting' }
CommonScopeNodeFinder >> nodeRangeOf: aNode  [

	^ aNode isMethodNode 
		ifTrue: [ 1 to: aNode sourceText size ]
		ifFalse: [
			| sourceRanges |
			
			sourceRanges := self completeSourceRangesOf: aNode.
			sourceRanges
				detect: [ :sourceRange | (self isScopeAddedWithRange: sourceRange) not ]
				ifNone: [ self shouldNotHappen ] ]
]

{ #category : 'private - visiting' }
CommonScopeNodeFinder >> scopesOf: nonEmptyScopes  [

	^ scopesCollection allButFirst select: [ :scope | 
		nonEmptyScopes allSatisfy: [ :scopeWithNodesFound | scopeWithNodesFound isIncludedIn: scope ]  ]
]

{ #category : 'initialization' }
CommonScopeNodeFinder >> sortByIntervalPositions: aCollectionOfNodes  [

	^ aCollectionOfNodes asSortedCollection: [ :leftParseNode :rightParseNode | 
		leftParseNode value first < rightParseNode value first ]
]

{ #category : 'visiting' }
CommonScopeNodeFinder >> visitAssignmentNode: anAssignmentNode [

	self addNodeIfFound: anAssignmentNode.
	
	super visitAssignmentNode: anAssignmentNode
]

{ #category : 'visiting' }
CommonScopeNodeFinder >> visitBacktickNode: aBacktickNode [

	self addNodeIfFound: aBacktickNode.
	
	super visitBacktickNode: aBacktickNode
]

{ #category : 'visiting' }
CommonScopeNodeFinder >> visitBlockNode: aBlockNode  [

	self addNodeIfFound: aBlockNode.
	
	self visitBlockNodeWithUpdatedScope: aBlockNode.
]

{ #category : 'private - visiting' }
CommonScopeNodeFinder >> visitBlockNodeWithUpdatedScope: aBlockNode  [

	| oldScope |
	
	oldScope := actualScopeIndex.
	self addToScopeList: aBlockNode.
	
	super visitBlockNode: aBlockNode.
		
	actualScopeIndex := oldScope.
]

{ #category : 'visiting' }
CommonScopeNodeFinder >> visitBraceNode: aBraceNode [

	self addNodeIfFound: aBraceNode.
	
	super visitBraceNode: aBraceNode
]

{ #category : 'visiting' }
CommonScopeNodeFinder >> visitCascadeNode: aCascadeNode [

	self addNodeIfFound: aCascadeNode.
	
	super visitCascadeNode: aCascadeNode
]

{ #category : 'visiting' }
CommonScopeNodeFinder >> visitInstanceVariableNode: anInstanceVariableNode [

	self addNodeIfFound: anInstanceVariableNode.
	
	super visitInstanceVariableNode: anInstanceVariableNode
]

{ #category : 'visiting' }
CommonScopeNodeFinder >> visitLiteralNode: aLiteralNode [

	self addNodeIfFound: aLiteralNode.
	
	super visitLiteralNode: aLiteralNode
]

{ #category : 'visiting' }
CommonScopeNodeFinder >> visitLiteralVariableNode: aLiteralVariableNode [

	self addNodeIfFound: aLiteralVariableNode.
	
	super visitLiteralVariableNode: aLiteralVariableNode
]

{ #category : 'visiting' }
CommonScopeNodeFinder >> visitMessageNode: aMessageNode [

	self addNodeIfFound: aMessageNode.
	
	super visitMessageNode: aMessageNode
]

{ #category : 'visiting' }
CommonScopeNodeFinder >> visitMessageNodeInCascade: aMessageNode [
	
	self addNodeIfFound: aMessageNode.
	
	super visitMessageNodeInCascade: aMessageNode
]

{ #category : 'visiting' }
CommonScopeNodeFinder >> visitMethodNode: aMethodNode  [

	self addToScopeList: aMethodNode.
	self addNodeIfFound: aMethodNode.
	
	self visitIfNotNil: aMethodNode temporariesDeclaration.
	
	"This is because all MethodNodes have a BlockNode but the scope node here must be the MethodNode"
	self visitMethodNodeBlockOf: aMethodNode
]

{ #category : 'private - visiting' }
CommonScopeNodeFinder >> visitMethodNodeBlockOf: aMethodNode  [

	| methodNodeBlock |

	methodNodeBlock := aMethodNode block.	
	self addNodeIfFound: methodNodeBlock.

	methodNodeBlock 
		statementsDo: [ :aStatement | aStatement accept: self ]
]

{ #category : 'visiting' }
CommonScopeNodeFinder >> visitNewArrayNode: aNewArrayNode [

	"This node is for #genPushNewArray: opcode only. See NewArrayNode.
	This is not tested due to its difficulty, but it is included for completeness."

	self addNodeIfFound: aNewArrayNode.
	
	super visitNewArrayNode: aNewArrayNode
]

{ #category : 'visiting' }
CommonScopeNodeFinder >> visitRemoteTempVectorNode: aRemoteTempVectorNode [

	"This is for visiting RemoteTempVectorNodes.
	
	There are two uses for this kind of nodes:
		- sending #analyseTempsWithin:rootNode:assignmentPools: that is implemented by several ParseNodes but
		there are no senders up to know of this message.
		- when decompiling (DecompilerConstructor>>#codeRemoteTemp:remoteTemps:), but the decompiled
		methodNode does not have the completeSourceRanges so this visitor cannot be used by it.
	
	This is not tested due to its difficulty, but it is included for completeness"

	self addNodeIfFound: aRemoteTempVectorNode.
	
	super visitRemoteTempVectorNode: aRemoteTempVectorNode
]

{ #category : 'visiting' }
CommonScopeNodeFinder >> visitReturnNode: aReturnNode [

	self addNodeIfFound: aReturnNode.

	super visitReturnNode: aReturnNode
]

{ #category : 'visiting' }
CommonScopeNodeFinder >> visitSelectorNode: aSelectorNode [

	self addNodeIfFound: aSelectorNode.

	super visitSelectorNode: aSelectorNode
]

{ #category : 'visiting' }
CommonScopeNodeFinder >> visitTempVariableNode: aTempVariableNode [

	self addNodeIfFound: aTempVariableNode.
	
	super visitTempVariableNode: aTempVariableNode
]

{ #category : 'visiting' }
CommonScopeNodeFinder >> visitTemporariesDeclarationNode: aTemporariesDeclarationNode [

	self addNodeIfFound: aTemporariesDeclarationNode.
	
	super visitTemporariesDeclarationNode: aTemporariesDeclarationNode
]

{ #category : 'visiting' }
CommonScopeNodeFinder >> visitTemporaryDeclarationNode: aTemporaryDeclarationNode [

	self addNodeIfFound: aTemporaryDeclarationNode.
	
	super visitTemporaryDeclarationNode: aTemporaryDeclarationNode
]

{ #category : 'visiting' }
CommonScopeNodeFinder >> visitUndeclaredVariableNode: aVariableNode [

	"These kind of nodes are only used by the Parser and not outside that context.
	The Encoder changes these nodes to LiteralVariableNodes.
	See Encoder>>#undeclared:. Eventually, it sends Encoder>>#global:name:, where the node is going to 
	be taken as LiteralVariableNode.
	
	This is not tested due to its difficulty, but it is included for completeness"

	self addNodeIfFound: aVariableNode.
	
	super visitUndeclaredVariableNode: aVariableNode
]

{ #category : 'visiting' }
CommonScopeNodeFinder >> visitVariableNode: aVariableNode [

	self addNodeIfFound: aVariableNode.
	
	super visitVariableNode: aVariableNode
]
