Extension { #name : 'ParseNode' }

{ #category : '*TestDynamicCuisLibraries-monitorCompilerUsage' }
ParseNode class >> new [
	LogCompilerUse == true ifTrue: [
		LogCompilerUse := false.
		CompilerWasUsed := true.
		{'---'. self} print.
		thisContext printStack: 10 ].
	LdInstType ifNil: [
		ParseNode initClassCachedState.
		VariableNode initClassCachedState ].
	^super new
]
