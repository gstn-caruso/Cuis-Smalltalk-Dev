Extension { #name : 'SmallInteger' }

{ #category : '*OpenCL' }
SmallInteger >> asOpenCLArg [
	"Assume we fit in 32 bits"
	^IntegerArray with: self
]

{ #category : '*OpenCL' }
SmallInteger >> asOpenCLBoolean [
	"Assume that we're already CLTrue or CLFalse (if not, there will be an error anyway)."
	^self
]
