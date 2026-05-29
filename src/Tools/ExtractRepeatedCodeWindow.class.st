Class {
	#name : 'ExtractRepeatedCodeWindow',
	#superclass : 'MethodSetWindow',
	#instVars : [
		'applier',
		'finder',
		'multimethod'
	],
	#category : 'Tools-Refactoring',
	#package : 'Tools',
	#tag : 'Refactoring'
}

{ #category : 'instance creation' }
ExtractRepeatedCodeWindow class >> openFrom: anExtractMethodApplier with: aFinder multimethod: aBoolean  [

	| window messageSet |

	messageSet := RepeatedCodeMessageSet finder: aFinder multimethod: aBoolean.
	"I have to set a autoSelectString even if I do not use it because if not the 
	autoSelect event is not triggered - Hernan"
	messageSet autoHighlightString: aFinder sourceCodeToExtract allOccurrences: false.
	
	window := self open: messageSet label: 'Select replacements'. 
	window initializeFrom: anExtractMethodApplier with: aFinder.
	
	^window 


]

{ #category : 'GUI building' }
ExtractRepeatedCodeWindow >> addButton: button to: row color: buttonColor [

	button color: buttonColor.
	row addMorph: button proportionalWidth: 10
]

{ #category : 'GUI building' }
ExtractRepeatedCodeWindow >> addButtonsTo: row color: buttonColor [

	self 
		addButton: self createRemoveButton to: row color: buttonColor;
		addButton: self createRefactorButton to: row color: buttonColor;
		addButton: self createExtractSelectionOnlyButton to: row color: buttonColor.
	
	model isMultimethod ifTrue: [ 
		self 
			addButton: self createExtractInMethodOnlyButton to: row color: buttonColor;
			addButton: self createExtractAllInClassButton to: row color: buttonColor ].
		
	self addButton: self createCancelButton to: row color: buttonColor.

]

{ #category : 'GUI building' }
ExtractRepeatedCodeWindow >> buildLowerPanes [

	| codeAndButtons  |
	
	codeAndButtons := LinearLayoutMorph newColumn.
	codeAndButtons
		addMorph: self buttonsRow fixedHeight: self defaultButtonPaneHeight;
		addAdjusterMorph;
		addMorph: self buildMorphicCodePane proportionalHeight: 1.0.
	
	^codeAndButtons 
]

{ #category : 'GUI building' }
ExtractRepeatedCodeWindow >> buttonsRow [

	| buttonColor row |

	buttonColor := self buttonColor.
	row := LinearLayoutMorph newRow.
	row doAdoptWidgetsColor.
	row color: buttonColor.

	self addButtonsTo: row color: buttonColor.
	
	^row
	
	
]

{ #category : 'actions' }
ExtractRepeatedCodeWindow >> closeAfter: aBlock [

	model doNotRefreshSelection.
	aBlock value.
	self whenUIinSafeState: [ self delete ].
	
]

{ #category : 'button creation' }
ExtractRepeatedCodeWindow >> createCancelButton [
	
	^RefactoringApplier createCancelButtonOn: self
]

{ #category : 'as yet unclassified' }
ExtractRepeatedCodeWindow >> createCodePaneMorph [

	^super createCodePaneMorph
		disableEditing;
		yourself
]

{ #category : 'button creation' }
ExtractRepeatedCodeWindow >> createExtractAllInClassButton [

	^PluggableButtonMorph 
		model: self
		stateGetter: nil
		action: #extractAllInClass
		label: 'In Class'
		balloonText: 'Applies the refactoring to all methods defined in the class'

]

{ #category : 'button creation' }
ExtractRepeatedCodeWindow >> createExtractInMethodOnlyButton [

	^PluggableButtonMorph 
		model: self
		stateGetter: nil
		action: #extractInMethodOnly
		label: 'In Method'
		balloonText: 'Applies the refactoring to all repetitions in the source method'

]

{ #category : 'button creation' }
ExtractRepeatedCodeWindow >> createExtractSelectionOnlyButton [

	^PluggableButtonMorph 
		model: self
		stateGetter: nil
		action: #extractOriginalSelection
		label: 'Original Selection'
		balloonText: 'Applies the refactoring to the original selected code only'

]

{ #category : 'button creation' }
ExtractRepeatedCodeWindow >> createRefactorButton [

	^PluggableButtonMorph 
		model: self
		stateGetter: nil
		action: #refactor
		label: 'Refactor'
		balloonText: 'Applies the refactoring to all places without showing the changes'
]

{ #category : 'button creation' }
ExtractRepeatedCodeWindow >> createRemoveButton [
	
	^RefactoringApplier createRemoveButtonOn: self
]

{ #category : 'actions' }
ExtractRepeatedCodeWindow >> extractAllInClass [
	
	self closeAfter: [ applier valueWithMethodsInClass ].
	
]

{ #category : 'actions' }
ExtractRepeatedCodeWindow >> extractInMethodOnly [

	self closeAfter: [ applier valueWithSourceMethod ].
	
]

{ #category : 'actions' }
ExtractRepeatedCodeWindow >> extractOriginalSelection [
	
	self closeAfter: [ applier valueWithOriginalSelection ].
	
]

{ #category : 'initialization' }
ExtractRepeatedCodeWindow >> initializeFrom: anExtractMethodApplier with: aFinder  [

	applier := anExtractMethodApplier.
	finder := aFinder.

]

{ #category : 'actions' }
ExtractRepeatedCodeWindow >> refactor [
	
	self closeAfter: [ applier valueWithAllReplacements ].
	
]

{ #category : 'actions' }
ExtractRepeatedCodeWindow >> remove [
	
	model removeMessageFromBrowserKeepingLabel
]
