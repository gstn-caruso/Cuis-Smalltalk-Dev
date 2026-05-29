"
typedef struct _cl_command_queue *  cl_command_queue;
"
Class {
	#name : 'CLCommandQueue',
	#superclass : 'OpenCLOpaqueHandle',
	#category : 'OpenCL-FFI',
	#package : 'OpenCL',
	#tag : 'FFI'
}

{ #category : 'retain/release' }
CLCommandQueue >> release [
	"Called only by OpenCLRefCount."
	OpenCLError check: (OpenCLPrimitiveInterface current clReleaseCommandQueue__cl_command_queue: self)
]

{ #category : 'retain/release' }
CLCommandQueue >> retain [
	"Called only by OpenCLRefCount."
	OpenCLError check: (OpenCLPrimitiveInterface current clRetainCommandQueue__cl_command_queue: self)
]
