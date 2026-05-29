Extension { #name : 'Scanner' }

{ #category : '*TestDynamicCuisLibraries-monitorCompilerUsage' }
Scanner class >> new [
	LogCompilerUse == true ifTrue: [
		LogCompilerUse := false.
		CompilerWasUsed := true.
		{'---'. self} print.
		thisContext printStack: 10 ].
	^self basicNew initScanner
]
