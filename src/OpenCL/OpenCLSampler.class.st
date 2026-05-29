Class {
	#name : 'OpenCLSampler',
	#superclass : 'OpenCLContextObject',
	#instVars : [
		'useNormalizedCoords',
		'addressingMode',
		'filterMode'
	],
	#category : 'OpenCL',
	#package : 'OpenCL'
}

{ #category : 'accessing' }
OpenCLSampler >> addressingMode [
	^addressingMode
]

{ #category : 'initialize' }
OpenCLSampler >> context: anOpenCLContext normalized: normalized "boolean" addressing: aMode "cl_addressing_mode enum" filter: fMode "cl_filter_mode enum" [
	"Set the context and paramters that this sampler was created with." 
	context := anOpenCLContext.
	useNormalizedCoords := normalized.
	addressingMode := aMode.
	filterMode := fMode.
]

{ #category : 'accessing' }
OpenCLSampler >> filterMode [
	^filterMode
]

{ #category : 'accessing' }
OpenCLSampler >> useNormalizedCoords [
	^useNormalizedCoords
]
