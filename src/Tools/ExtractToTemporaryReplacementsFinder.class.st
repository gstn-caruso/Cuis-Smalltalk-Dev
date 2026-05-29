Class {
	#name : 'ExtractToTemporaryReplacementsFinder',
	#superclass : 'ReplacementsFinder',
	#instVars : [
		'newVariable'
	],
	#category : 'Tools-Refactoring',
	#package : 'Tools',
	#tag : 'Refactoring'
}

{ #category : 'instance creation' }
ExtractToTemporaryReplacementsFinder class >> named: aNewVariable at: anIntervalToExtract from: aMethodToRefactor [

	^ self new initializeNamed: aNewVariable at: anIntervalToExtract from: aMethodToRefactor
]

{ #category : 'replacements' }
ExtractToTemporaryReplacementsFinder >> createReplacementAt: foundIntervalToExtract in: aMethod [
	
	SourceCodeOfTemporaryToBeExtractedPrecondition valueFor: foundIntervalToExtract of: aMethod.
	
	^ foundIntervalToExtract asSourceCodeInterval
]

{ #category : 'private-replacement finding' }
ExtractToTemporaryReplacementsFinder >> find [

	findingStrategy value: sourceMethod compiledMethod.
]

{ #category : 'initialization' }
ExtractToTemporaryReplacementsFinder >> initializeNamed: aNewVariable at: anIntervalToExtract from: aMethodToRefactor [

	newVariable := aNewVariable.
	sourceMethod := aMethodToRefactor.
	intervalToExtract := anIntervalToExtract.
]

{ #category : 'replacements' }
ExtractToTemporaryReplacementsFinder >> methodsToReplace [

	"Is the same method for all replacements"

	^ replacements collect: [ :aReplacement | sourceMethod ]
]

{ #category : 'replacements' }
ExtractToTemporaryReplacementsFinder >> originalSelectionReplacement [

	^ intervalToExtract
]
