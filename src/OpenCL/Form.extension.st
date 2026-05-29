Extension { #name : 'Form' }

{ #category : '*OpenCL' }
Form >> asOpenCLArg [
	"Pass pointer to our bitmap."
	^bits
]
