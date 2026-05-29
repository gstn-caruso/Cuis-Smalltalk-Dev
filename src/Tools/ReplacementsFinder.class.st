Class {
	#name : 'ReplacementsFinder',
	#superclass : 'Object',
	#instVars : [
		'intervalToExtract',
		'sourceMethod',
		'replacements',
		'sourceCodeToExtract',
		'nodesToExtract',
		'findingStrategy'
	],
	#category : 'Tools-Refactoring',
	#package : 'Tools',
	#tag : 'Refactoring'
}

{ #category : 'private-replacement finding' }
ReplacementsFinder >> addReplacementAt: foundIntervalToExtract in: aMethod [
	
	"If there is an error creating the refactoring, then the found text is not extractable and 
	therefore should not be replaced - Hernan"
	[ replacements add: (self createReplacementAt: foundIntervalToExtract in: aMethod) ] 
		on: RefactoringError 
		do: [ :anError | ].
]

{ #category : 'private-replacement finding' }
ReplacementsFinder >> createReplacementAt: foundIntervalToExtract in: aMethod [

	self subclassResponsibility
]

{ #category : 'private-replacement finding' }
ReplacementsFinder >> defineFindingStrategy [
	
	| useStringEquality |
	
	"Sadly, finding the right ranges when extracting literal nodes is almost imposible becuase literal nodes can have many
	ranges. An alternative algorithm could be to create an 'expanded AST' without reused nodes and each node with its own
	source range. Nodes of that AST could be a polimorphic proxy of the real node, adding only the source range, something
	to try ...
	For the moment, if the selection to extract has only literal nodes, uses string comparison - Hernan"
	useStringEquality := nodesToExtract allSatisfy: [ :aNode | aNode isLiteralNode ].
	
	^useStringEquality 
		ifTrue: [ [ :aMethod | self findReplacementsUsingStringEqualityIn: aMethod ]]
		ifFalse: [ [ :aMethod | self findReplacementsUsingNodeEquivalenceIn: aMethod ]]
]

{ #category : 'private-replacement finding' }
ReplacementsFinder >> find [

	self subclassResponsibility 
]

{ #category : 'private-replacement finding' }
ReplacementsFinder >> findReplacementsUsingNodeEquivalenceIn: aMethod [

	| rangesToExtract |
		
	rangesToExtract := sourceMethod compiledMethod = aMethod
		ifTrue: [  aMethod sourceRangesOfNodesEquivalentTo: nodesToExtract keepingSelection: intervalToExtract ]	
		ifFalse: [ aMethod sourceRangesOfNodesEquivalentTo: nodesToExtract ].
		
	rangesToExtract do: [ :sourceRangeToExtract | self addReplacementAt: sourceRangeToExtract in: aMethod ].
]

{ #category : 'private-replacement finding' }
ReplacementsFinder >> findReplacementsUsingStringEqualityIn: aMethod [

	| sourceCode foundIntervalToExtract sourceCodeToExtractStart theSizeToExtract |
	
	sourceCode := aMethod sourceCode.
	theSizeToExtract := intervalToExtract size - 1.
	"This is to avoid finding strings in the selector"
	sourceCodeToExtractStart := aMethod methodNode selectorLastPosition + 1.
	
	[ sourceCodeToExtractStart := sourceCode indexOfSubCollection: sourceCodeToExtract startingAt: sourceCodeToExtractStart.
	sourceCodeToExtractStart ~= 0 ] whileTrue: [ 
		foundIntervalToExtract := sourceCodeToExtractStart to: sourceCodeToExtractStart + theSizeToExtract.
		self addReplacementAt: foundIntervalToExtract in: aMethod.
		sourceCodeToExtractStart := foundIntervalToExtract last + 1 ] 
		
	 
]

{ #category : 'testing' }
ReplacementsFinder >> hasOneReplacement [
	
	^replacements size = 1
]

{ #category : 'replacements' }
ReplacementsFinder >> inClassReplacements [
	
	^replacements select: [ :aReplacement | aReplacement isAt: sourceMethod methodClass ]
]

{ #category : 'private-replacement finding' }
ReplacementsFinder >> initializeFinding [

	sourceCodeToExtract := sourceMethod sourceCode copyFrom: intervalToExtract first to: intervalToExtract last.
	nodesToExtract := self nodesToExtract.
	replacements := OrderedCollection new.
	findingStrategy := self defineFindingStrategy
]

{ #category : 'private-replacement finding' }
ReplacementsFinder >> nodesToExtract [

	^(NodesInRangeFinder in: sourceMethod for: intervalToExtract) value
]

{ #category : 'replacements' }
ReplacementsFinder >> removeReplacementAt: anIndex [

	^replacements removeAt: anIndex 
]

{ #category : 'replacements' }
ReplacementsFinder >> replacements [
	
	^replacements 
]

{ #category : 'replacements' }
ReplacementsFinder >> replacementsAt: anIndex ifAbsent: ifAbsentBlock [
 
	^replacements at: anIndex ifAbsent: ifAbsentBlock 
]

{ #category : 'source code' }
ReplacementsFinder >> sourceCodeToExtract [
	
	^sourceCodeToExtract
]

{ #category : 'replacements' }
ReplacementsFinder >> sourceMethodReplacements [
	
	^replacements select: [:aReplacement | aReplacement isOf: sourceMethod ]
]

{ #category : 'evaluating' }
ReplacementsFinder >> value [

	self 
		initializeFinding;
		find.
]
