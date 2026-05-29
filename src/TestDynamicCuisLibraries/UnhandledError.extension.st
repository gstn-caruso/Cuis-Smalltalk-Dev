Extension { #name : 'UnhandledError' }

{ #category : '*TestDynamicCuisLibraries-monitorCompilerUsage' }
UnhandledError >> devDefaultAction [

	LogCompilerUse := false.
	Processor activeProcess
		debugContext: exception signalerContext
		title: exception description.
]
