"
typedef struct _cl_kernel *         cl_kernel;
"
Class {
	#name : 'CLKernel',
	#superclass : 'OpenCLOpaqueHandle',
	#category : 'OpenCL-FFI',
	#package : 'OpenCL',
	#tag : 'FFI'
}

{ #category : 'retain/release' }
CLKernel >> release [
	"Called only by OpenCLRefCount."
	OpenCLError check: (OpenCLPrimitiveInterface current clReleaseKernel__cl_kernel: self)
]

{ #category : 'retain/release' }
CLKernel >> retain [
	"Called only by OpenCLRefCount."
	OpenCLError check: (OpenCLPrimitiveInterface current clRetainKernel__cl_kernel: self)
]
