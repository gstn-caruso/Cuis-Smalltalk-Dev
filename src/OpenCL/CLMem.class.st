"
typedef struct _cl_mem *            cl_mem;
"
Class {
	#name : 'CLMem',
	#superclass : 'OpenCLOpaqueHandle',
	#category : 'OpenCL-FFI',
	#package : 'OpenCL',
	#tag : 'FFI'
}

{ #category : 'retain/release' }
CLMem >> release [
	"Called only by OpenCLRefCount."
	OpenCLError check: (OpenCLPrimitiveInterface current clReleaseMemObject__cl_mem: self)
]

{ #category : 'retain/release' }
CLMem >> retain [
	"Called only by OpenCLRefCount."
	OpenCLError check: (OpenCLPrimitiveInterface current clRetainMemObject__cl_mem: self)
]
