Extension { #name : 'ChangeSelector' }

{ #category : '*ExtractParameterObject-create new implementors - private' }
ChangeSelector >> createNewImplementorOf: anImplementor [

	| newImplementor |

	self compileNewImplementorOf: anImplementor.
	newImplementor := anImplementor methodClass compiledMethodAt: newSelector.
	self addToSendersIfOldSelectorIsSentIn: newImplementor.
	
	^ changes add: newImplementor methodReference.
	
	
]

{ #category : '*ExtractParameterObject-rename senders - private' }
ChangeSelector >> renameSendersIn: aMethod [

	| newSource rangesToNewStrings |

	rangesToNewStrings := self rangesToKeywordsOf: aMethod.
	newSource := aMethod sourceCode copyReplacing: rangesToNewStrings.
	aMethod methodClass compile: newSource.

	^changes add: (MethodReference method: aMethod)
]
