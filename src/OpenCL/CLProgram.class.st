"
typedef struct _cl_program *        cl_program;
"
Class {
	#name : 'CLProgram',
	#superclass : 'OpenCLOpaqueHandle',
	#category : 'OpenCL-FFI',
	#package : 'OpenCL',
	#tag : 'FFI'
}

{ #category : 'retain/release' }
CLProgram >> release [
	"Called only by OpenCLRefCount."
	OpenCLError check: (OpenCLPrimitiveInterface current clReleaseProgram__cl_program: self)
]

{ #category : 'retain/release' }
CLProgram >> retain [
	"Called only by OpenCLRefCount."
	OpenCLError check: (OpenCLPrimitiveInterface current clRetainProgram__cl_program: self)
]
