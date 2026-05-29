"
typedef struct _cl_context *        cl_context;
"
Class {
	#name : 'CLContext',
	#superclass : 'OpenCLOpaqueHandle',
	#category : 'OpenCL-FFI',
	#package : 'OpenCL',
	#tag : 'FFI'
}

{ #category : 'retain/release' }
CLContext >> release [
	"Called only by OpenCLRefCount."
	OpenCLError check: (OpenCLPrimitiveInterface current clReleaseContext__cl_context: self)
]

{ #category : 'retain/release' }
CLContext >> retain [
	"Called only by OpenCLRefCount."
	OpenCLError check: (OpenCLPrimitiveInterface current clRetainContext__cl_context: self)
]
