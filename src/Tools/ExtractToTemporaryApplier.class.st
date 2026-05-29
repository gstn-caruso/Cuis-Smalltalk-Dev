Class {
	#name : 'ExtractToTemporaryApplier',
	#superclass : 'RefactoringApplier',
	#instVars : [
		'intervalToExtract',
		'methodToExtractCodeFrom',
		'newVariable',
		'codeProvider',
		'finder'
	],
	#category : 'Tools-Refactoring',
	#package : 'Tools',
	#tag : 'Refactoring'
}

{ #category : 'pre-conditions' }
ExtractToTemporaryApplier class >> assertCanApplyRefactoringOn: aMethodToRefactor at: anIntervalToExtract [

	ExtractToTemporary
		assertCanApplyRefactoringOn: aMethodToRefactor
		at: anIntervalToExtract
]

{ #category : 'instance creation' }
ExtractToTemporaryApplier class >> on: aCodeProvider for: anIntervalToExtract of: aMethodToExtractCodeFrom [

	| trimmedIntervalToExtract sourceCode |
	
	sourceCode := aMethodToExtractCodeFrom sourceCode.
	trimmedIntervalToExtract := anIntervalToExtract trimToMatchExpressionOn: sourceCode.

	self assertCanApplyRefactoringOn: aMethodToExtractCodeFrom at: trimmedIntervalToExtract.

	^ self new initializeOn: aCodeProvider for: trimmedIntervalToExtract of: aMethodToExtractCodeFrom
]

{ #category : 'refactoring - parameters request' }
ExtractToTemporaryApplier >> askNewVariableName [

	newVariable := (self request: 'Enter new temp name:' initialAnswer: '') withBlanksTrimmed
]

{ #category : 'refactoring - creation' }
ExtractToTemporaryApplier >> createRefactoring [

	| intervals |

	intervals := finder replacements.
	^ self refactoringClass
		named: newVariable
		intervals: intervals 
		from: methodToExtractCodeFrom
]

{ #category : 'refactoring - creation' }
ExtractToTemporaryApplier >> createRefactoringForOriginalSelection [

	^ self refactoringClass
		named: newVariable
		at: finder originalSelectionReplacement 
		from: methodToExtractCodeFrom
]

{ #category : 'refactoring - parameters request' }
ExtractToTemporaryApplier >> findReplacementsInMethod [

	finder := ExtractToTemporaryReplacementsFinder
		named: newVariable 
		at: intervalToExtract 
		from: methodToExtractCodeFrom.
	finder value.
]

{ #category : 'initialization' }
ExtractToTemporaryApplier >> initializeOn: aCodeProvider for: anIntervalToExtract of: aMethodToExtractCodeFrom [

	codeProvider := aCodeProvider.
	intervalToExtract := anIntervalToExtract.
	methodToExtractCodeFrom := MethodReference method: aMethodToExtractCodeFrom.
]

{ #category : 'refactoring - creation' }
ExtractToTemporaryApplier >> refactoringClass [

	^ ExtractToTemporary
]

{ #category : 'refactoring - parameters request' }
ExtractToTemporaryApplier >> requestRefactoringParameters [

	self askNewVariableName.
	self findReplacementsInMethod.

	finder hasOneReplacement 
		ifTrue: [ self valueWithAllReplacements ]
		ifFalse: [ ExtractRepeatedCodeWindow openFrom: self with: finder multimethod: false ]
]

{ #category : 'refactoring - changes' }
ExtractToTemporaryApplier >> showChanges [

	codeProvider currentMethodRefactored
]

{ #category : 'evaluating' }
ExtractToTemporaryApplier >> value [

	requestExitBlock := [ ^self ].
	
	self requestRefactoringParametersHandlingRefactoringExceptions
]

{ #category : 'evaluating' }
ExtractToTemporaryApplier >> valueCreatingWith: aRefactoringCreationBlock [

	self 
		createAndSetRefactoringHandlingRefactoringExceptions: aRefactoringCreationBlock;
		applyRefactoring;
		showChanges
]

{ #category : 'evaluating' }
ExtractToTemporaryApplier >> valueWithAllReplacements [

	self valueCreatingWith: [ self createRefactoring ]
]

{ #category : 'evaluating' }
ExtractToTemporaryApplier >> valueWithOriginalSelection [
	
	self valueCreatingWith: [ self createRefactoringForOriginalSelection ]
]
