"
typedef struct _cl_event *          cl_event;
"
Class {
	#name : 'CLEvent',
	#superclass : 'OpenCLOpaqueHandle',
	#category : 'OpenCL-FFI',
	#package : 'OpenCL',
	#tag : 'FFI'
}

{ #category : 'retain/release' }
CLEvent >> release [
	"Called only by OpenCLRefCount."
	OpenCLError check: (OpenCLPrimitiveInterface current clReleaseEvent__cl_event: self)
]

{ #category : 'retain/release' }
CLEvent >> retain [
	"Called only by OpenCLRefCount."
	OpenCLError check: (OpenCLPrimitiveInterface current clRetainEvent__cl_event: self)
]
