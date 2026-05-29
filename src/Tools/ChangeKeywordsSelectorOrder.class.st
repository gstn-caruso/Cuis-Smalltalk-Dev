Class {
	#name : 'ChangeKeywordsSelectorOrder',
	#superclass : 'ChangeSelectorKeepingParameters',
	#instVars : [
		'changedOrder'
	],
	#category : 'Tools-Refactoring',
	#package : 'Tools',
	#tag : 'Refactoring'
}

{ #category : 'pre-conditions' }
ChangeKeywordsSelectorOrder class >> assertIsKeywordWithMoreThanOneParameter: anOldSelector [

	(anOldSelector isKeyword and: [ anOldSelector numArgs > 1 ]) ifFalse: [ self signalSelectorToChangeIsNotKeywordWithMoreThanOneParameter ]
]

{ #category : 'changed order' }
ChangeKeywordsSelectorOrder class >> changedOrderFrom: anOldSelector to: aNewSelector [

	| changedOrder newSelectorKeywords |

	changedOrder := Dictionary new.
	newSelectorKeywords := aNewSelector keywords.
	anOldSelector keywords withIndexDo: [ :keyword :index |
		changedOrder
			at: (newSelectorKeywords indexOf: keyword ifAbsent: [ self signalNewSelectorDoesNotIncludeOldSelectorKeywords ])
			put: index ].

	^changedOrder 
]

{ #category : 'instance creation' }
ChangeKeywordsSelectorOrder class >> from: anOldSelector to: aNewSelector implementors: aCollectionOfImplementors senders: aCollectionOfSenders [

	| changedOrder |

	self assertIsKeywordWithMoreThanOneParameter: anOldSelector.
	changedOrder := self changedOrderFrom: anOldSelector to: aNewSelector.

	^ (super from: anOldSelector to: aNewSelector implementors: aCollectionOfImplementors senders: aCollectionOfSenders)
		initializeChangedOrder: changedOrder

]

{ #category : 'exceptions' }
ChangeKeywordsSelectorOrder class >> newSelectorDoesNotIncludeOldSelectorKeywordsErrorMessage [

	^'New selector keywords do not include old selector keywords'
]

{ #category : 'exceptions' }
ChangeKeywordsSelectorOrder class >> selectorToChangeIsNotKeywordWithMoreThanOneParameterErrorMessage [

	^'Can only change a selector order for keyword messages with more that one parameter'
]

{ #category : 'exceptions' }
ChangeKeywordsSelectorOrder class >> signalNewSelectorDoesNotIncludeOldSelectorKeywords [

	self refactoringError: self newSelectorDoesNotIncludeOldSelectorKeywordsErrorMessage
]

{ #category : 'exceptions' }
ChangeKeywordsSelectorOrder class >> signalSelectorToChangeIsNotKeywordWithMoreThanOneParameter [

	self refactoringError: self selectorToChangeIsNotKeywordWithMoreThanOneParameterErrorMessage
]

{ #category : 'rename senders - private' }
ChangeKeywordsSelectorOrder >> addBlanksOf: oldArgument to: newArgument [

	| blanksPrefix blanksSuffix |

	"At least one blank must exist at the beginning and at the end. Otherwise, is part of the keyword 
	and not part of the argument"
	blanksPrefix := oldArgument copyFrom: 1 to: oldArgument firstNonSeparator - 1.
	blanksSuffix := oldArgument copyFrom: oldArgument lastNonSeparator + 1 to: oldArgument size.
	^ blanksPrefix , newArgument withBlanksTrimmed , blanksSuffix
]

{ #category : 'create new implementors - private' }
ChangeKeywordsSelectorOrder >> addImplementorSelectorRanges: aKeywordRange at: index to: rangesToNewKeywords [

	rangesToNewKeywords add: aKeywordRange -> (newSelectorKeywords at: index).
	rangesToNewKeywords add:
		(currentImplementorMethodNode parameterDefinitionPositionAt: index) ->
		(currentImplementorMethodNode argumentNames at: (changedOrder at: index))
]

{ #category : 'rename senders - private' }
ChangeKeywordsSelectorOrder >> addNewRangesToArgumentsOf: originalRangesToArguments to: rangesToNewStrings [

	originalRangesToArguments withIndexDo: [ :rangeToArgument :index | 
		| newArgument newArgumentIndex |

		newArgumentIndex := changedOrder at: index.
		
		"Adds the same blanks as the argument in that position had"
		newArgument :=  self 
			addBlanksOf: rangeToArgument value 
			to: (originalRangesToArguments at: newArgumentIndex) value.
		
		rangesToNewStrings add: (rangeToArgument key ->  newArgument) ]
]

{ #category : 'rename senders - private' }
ChangeKeywordsSelectorOrder >> addRangesToArgumentsOf: sourceCodeToEdit to: rangesToNewStrings using: aMethodNode [

	| originalRangesToArguments |

	originalRangesToArguments := self 
		originalRangesToArgumentsOf: sourceCodeToEdit 
		using: rangesToNewStrings
		and: aMethodNode.
	self addNewRangesToArgumentsOf: originalRangesToArguments to: rangesToNewStrings.
]

{ #category : 'initialization' }
ChangeKeywordsSelectorOrder >> initializeChangedOrder: aChangeOrder [

	changedOrder := aChangeOrder 
]

{ #category : 'rename senders - private' }
ChangeKeywordsSelectorOrder >> originalRangesToArgumentsOf: sourceCodeToEdit using: rangesToNewStrings and: aMethodNode [

	| originalRangesToArguments parseNodeInterval |

	originalRangesToArguments := SortedCollection sortBlock: [ :left :right | left key first < right key first ].
	parseNodeInterval := aMethodNode 
		parseNodeIntervalIncluding: rangesToNewStrings first key first 
		ifAbsent: [ self shouldNotHappen ].
	
	rangesToNewStrings withNextDo: [ :rangeToKeyword :prevRangeToKeyword |  
		| range argumentRange |
		
		range := rangeToKeyword key.
		argumentRange := prevRangeToKeyword
			ifNil: [ range last + 1 to: parseNodeInterval last ]
			ifNotNil: [ range last + 1 to: prevRangeToKeyword key first - 1 ].
			
		originalRangesToArguments add: argumentRange -> (sourceCodeToEdit atAll: argumentRange) ].
	
	^ originalRangesToArguments 
]

{ #category : 'rename senders - private' }
ChangeKeywordsSelectorOrder >> rangesToKeywordsUsing: messageSendSelectorKeywordRanges [

	| rangesToKeywords |

	rangesToKeywords := SortedCollection sortBlock: [ :left :right | left key first < right key first ].
	
	"This is needed because this message expects an OrderedCollection of a Collection"
	self 
		addRangesOf: (OrderedCollection new add: messageSendSelectorKeywordRanges; yourself) 
		to: rangesToKeywords.
	
	^ rangesToKeywords
]

{ #category : 'rename senders - private' }
ChangeKeywordsSelectorOrder >> renameSendersIn: aMethod [

	| sourceCodeToEdit |

	sourceCodeToEdit := self sourceCodeWithRenamedSendersOf: aMethod notOptimizedMethodNode.
	aMethod methodClass compile: sourceCodeToEdit.

	^changes add: (MethodReference method: aMethod)
]

{ #category : 'rename senders - private' }
ChangeKeywordsSelectorOrder >> sourceCodeWithRenamedSendersOf: aMethodNode [

	| sendSelectorPositions sourceCodeToEdit |

	sendSelectorPositions := self messageSendSelectorKeywordPositionsIn: aMethodNode.
	sourceCodeToEdit := aMethodNode sourceText.

	"sendSelectorPositions is ordered taking the first value of the first interval. The problem using that
	is that a method collaboration could be an argument of itself. Therefore, iterating the other way around
	will replace the collaborations inside of another collaborations of same method if any."
	sendSelectorPositions reverseDo: [ :messageSendSelectorKeywordRanges | | rangesToNewStrings |
		rangesToNewStrings := self rangesToKeywordsUsing: messageSendSelectorKeywordRanges.
		self addRangesToArgumentsOf: sourceCodeToEdit to: rangesToNewStrings using: aMethodNode.
		sourceCodeToEdit := sourceCodeToEdit copyReplacing: rangesToNewStrings ].

	^ sourceCodeToEdit
]
