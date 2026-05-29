Extension { #name : 'Float' }

{ #category : '*OpenCL' }
Float >> asOpenCLArg [
	"To be used with OpenCL arguments declared as 'double'"
	^Float64Array with: self
]
