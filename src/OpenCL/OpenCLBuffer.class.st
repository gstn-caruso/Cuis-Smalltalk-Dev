"
Encapsulates a CLMem that has been allocated as a buffer (as opposed to an image), and provides convenience methods for accessing its properties.  See the "buffer creation" methods in OpenCLContext.  

NOTE: we don't expose all of OpenCL's functionality for instantiating new buffers, in particular buffers allocated in host memory. But we do allow wrapping a Smalltalk object. For this, we pin the memory and unpin it on buffer destruction.
"
Class {
	#name : 'OpenCLBuffer',
	#superclass : 'OpenCLContextObject',
	#instVars : [
		'byteSize',
		'smalltalkObject'
	],
	#category : 'OpenCL',
	#package : 'OpenCL'
}

{ #category : 'accessing' }
OpenCLBuffer >> byteSize [
	"Answer the size of memory allocated for this buffer, in bytes."
	^byteSize
]

{ #category : 'initialize' }
OpenCLBuffer >> context: anOpenCLContext byteSize: sz [
	"Set the context that this buffer was created for, and it's size in bytes."
	context := anOpenCLContext.
	byteSize := sz.

]

{ #category : 'private' }
OpenCLBuffer >> privateDestroy [
	"If we were created on a Smalltalk object, it was pinned if needed.
	If so, unpin it, and don't reference it anymore so it can be collected.
	
	Note: Creating two different OpenCLBuffers on the same byte object is not supported wither by OpenCL or by this code"
	super privateDestroy.
	smalltalkObject notNil ifTrue: [
		smalltalkObject unpin.
		smalltalkObject  _ nil ].
]

{ #category : 'accessing' }
OpenCLBuffer >> smalltalkObject: bytes [
	smalltalkObject _ bytes
]
