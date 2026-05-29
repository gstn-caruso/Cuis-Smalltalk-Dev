Extension { #name : 'MessageNode' }

{ #category : '*TestDynamicCuisLibraries-monitorCompilerUsage' }
MessageNode class >> new [
	LogCompilerUse == true ifTrue: [
		LogCompilerUse := false.
		CompilerWasUsed := true.
		{'---'. self} print.
		thisContext printStack: 10 ].
	MacroSelectors ifNil: [ self initClassCachedState ].
	^super new
]
