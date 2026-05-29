Extension { #name : 'ExternalObject' }

{ #category : '*OpenCL' }
ExternalObject >> asOpenCLArg [
	"Pass pointer to external memory (or potentially, a ByteArray) as an argument to a kernel or other function."
	^self getHandle
]
