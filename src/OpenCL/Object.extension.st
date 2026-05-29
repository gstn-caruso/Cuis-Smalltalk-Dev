Extension { #name : 'Object' }

{ #category : '*OpenCL' }
Object >> asOpenCLArg [
	"Default is to pass self as arg to FFI call."
	^self
]
