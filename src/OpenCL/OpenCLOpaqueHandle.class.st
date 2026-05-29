"
Private to the OpenCL framework; users of the framework will never directly touch one.

OpenCL uses several pointer-to-undefined-struct typedefs.  This is the base-class for corresponding FFI types.
"
Class {
	#name : 'OpenCLOpaqueHandle',
	#superclass : 'ExternalStructure',
	#category : 'OpenCL-FFI',
	#package : 'OpenCL',
	#tag : 'FFI'
}

{ #category : 'field definition' }
OpenCLOpaqueHandle class >> fields [
	"OpenCLOpaqueHandle allSubclassesDo: [:cls | cls defineFields]"
	^#( nil 'void*' )
]

{ #category : 'retain/release' }
OpenCLOpaqueHandle >> release [
	self subclassResponsibility
]

{ #category : 'retain/release' }
OpenCLOpaqueHandle >> retain [
	self subclassResponsibility
]
