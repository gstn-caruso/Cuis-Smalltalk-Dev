Class {
	#name : 'ExtractMultipleToTemporary',
	#superclass : 'ExtractToTemporary',
	#instVars : [
		'collectionOfIntervalsToExtract'
	],
	#category : 'Tools-Refactoring',
	#package : 'Tools',
	#tag : 'Refactoring'
}

{ #category : 'preconditions' }
ExtractMultipleToTemporary class >> applyPreconditionsOn: codeNodesForNewVariable named: trimmedNewVariable in: methodNodeToRefactor [

	codeNodesForNewVariable do: [ :codeNodeForNewVariable |
		self newTemporaryPreconditionClass 
			valueFor: trimmedNewVariable 
			in: codeNodeForNewVariable 
			of: methodNodeToRefactor ]
]

{ #category : 'preconditions' }
ExtractMultipleToTemporary class >> assertCanApplyRefactoringOn: aMethodToRefactor atAll: intervalsToExtract  [

	| methodNode firstNode |
    	
    	methodNode := aMethodToRefactor methodNode.
    	firstNode := nil.
    
    	intervalsToExtract do: [ :anIntervalToExtract |
    		| parseNodes parseNode |
    		
    		self assertCanApplyRefactoringOn: aMethodToRefactor at: anIntervalToExtract asSourceCodeInterval.
    		
    		parseNodes := methodNode 
    			parseNodesPathAt: anIntervalToExtract first 
    			ifAbsent: [ self shouldNotHappen ].
    		parseNode := parseNodes first.
    		
    		firstNode 
			ifNil: [ firstNode := parseNode key ]
			ifNotNil: [ (firstNode equivalentTo: parseNode key) ifFalse: [ self signalExtractingDifferentPiecesOfCodeError ]]]
]

{ #category : 'private' }
ExtractMultipleToTemporary class >> codeNodesOf: intervalsToExtract in: methodNodeToRefactor [

	^ intervalsToExtract collect: [ :interval | 
			self methodOrBlockNodeIncluding: interval in: methodNodeToRefactor ]
]

{ #category : 'instance creation' }
ExtractMultipleToTemporary class >> named: aNewVariable intervals: intervalsToExtract from: aMethodToRefactor  [

	|  methodNodeToRefactor trimmedNewVariable trimmedIntervalsToExtract codeNodesForNewVariable nodeToDeclareNewVariable |

	self assertCanApplyRefactoringOn: aMethodToRefactor atAll: intervalsToExtract.
	
	methodNodeToRefactor := aMethodToRefactor notOptimizedMethodNode.
	trimmedNewVariable := aNewVariable withBlanksTrimmed.
	trimmedIntervalsToExtract := self trimmedIntervalsOf: intervalsToExtract in: aMethodToRefactor.
	codeNodesForNewVariable := self codeNodesOf: intervalsToExtract in: methodNodeToRefactor.
	nodeToDeclareNewVariable := self 
		methodOrBlockNodeIncludingAll: intervalsToExtract 
		in: methodNodeToRefactor.

	"There is no need to check the new temporary preconditions for every piece of code, 
	because the validation already ensures that the new temporary is valid both in the method and in the class.
	Please see NewTemporaryPrecondition>>#value."
	self newTemporaryPreconditionClass 
		valueFor: trimmedNewVariable 
		in: codeNodesForNewVariable first 
		of: methodNodeToRefactor.

	^ self new
		initializeNamed: trimmedNewVariable
		extractingCodeAt: trimmedIntervalsToExtract
		from: aMethodToRefactor
		methodNode: methodNodeToRefactor
		declaringTempIn: nodeToDeclareNewVariable
]

{ #category : 'exceptions' }
ExtractMultipleToTemporary class >> signalExtractingDifferentPiecesOfCodeError [

	self refactoringError: self extractingDifferentPiecesOfCodeErrorMessage
]

{ #category : 'private' }
ExtractMultipleToTemporary class >> trimmedIntervalsOf: intervalsToExtract in: aMethodToRefactor [

	^ intervalsToExtract collect: [ :interval | interval trimToMatchExpressionOn: aMethodToRefactor sourceCode ]
]

{ #category : 'initialization' }
ExtractMultipleToTemporary >> initializeNamed: aNewVariableName extractingCodeAt: aCollectionOfIntervalsToExtract from: aMethodToRefactor methodNode: aMethodNodeToRefactor declaringTempIn: blockNodeOfNewVariable [

	| anIntervalToExtract |

	newVariableName := aNewVariableName.
	collectionOfIntervalsToExtract := aCollectionOfIntervalsToExtract sort: [ :a :b | a last < b first ] .
	methodToRefactor := aMethodToRefactor.
	methodNodeToRefactor := aMethodNodeToRefactor.
	updatedSourceCode := aMethodToRefactor sourceCode.
	anIntervalToExtract := collectionOfIntervalsToExtract first.
	sourceCodeToExtract := updatedSourceCode copyFrom: anIntervalToExtract first to: anIntervalToExtract last.
	completeSourceRanges := methodNodeToRefactor completeSourceRanges.
	parseNodeWithNewVariableScope := blockNodeOfNewVariable.
	
	"This is for convenience, i keep the first interval to extract in this inst var"
	intervalToExtract := collectionOfIntervalsToExtract first.
]

{ #category : 'private - applying steps' }
ExtractMultipleToTemporary >> replaceAllCodeIntervalsWithNewVariable [

	updatedSourceCode := updatedSourceCode 
		copyReplacing: collectionOfIntervalsToExtract 
		with: newVariableName
]

{ #category : 'private - applying steps' }
ExtractMultipleToTemporary >> resolveNewVariableAssignment [

	self replaceAllCodeIntervalsWithNewVariable.
	self writeAssignmentStatementOfNewTemporaryVariable.
]
