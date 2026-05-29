"
typedef struct _cl_sampler *        cl_sampler;
"
Class {
	#name : 'CLSampler',
	#superclass : 'OpenCLOpaqueHandle',
	#category : 'OpenCL-FFI',
	#package : 'OpenCL',
	#tag : 'FFI'
}

{ #category : 'retain/release' }
CLSampler >> release [
	"Called only by OpenCLRefCount."
	OpenCLError check: (OpenCLPrimitiveInterface current clReleaseSampler__cl_sampler: self)
]

{ #category : 'retain/release' }
CLSampler >> retain [
	"Called only by OpenCLRefCount."
	OpenCLError check: (OpenCLPrimitiveInterface current clRetainSampler__cl_sampler: self)
]
