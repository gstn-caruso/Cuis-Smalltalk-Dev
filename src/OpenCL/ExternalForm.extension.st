Extension { #name : 'ExternalForm' }

{ #category : '*OpenCL' }
ExternalForm >> asOpenCLArg [
	"Pass pointer to our pixels."
	^pointer ifNil: [self error: 'pointer is nil'].
]
