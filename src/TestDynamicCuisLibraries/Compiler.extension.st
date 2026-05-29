Extension { #name : 'Compiler' }

{ #category : '*TestDynamicCuisLibraries-monitorCompilerUsage' }
Compiler class >> new [
	LogCompilerUse == true ifTrue: [
		LogCompilerUse := false.
		CompilerWasUsed := true.
		{'---'. self} print.
		thisContext printStack: 15 ].
	^ super new parser: self parserClass new.
]
