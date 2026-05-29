"
Represents an object that is associated with a particular OpenCL context.  When destroyed, the reference to the context is released.
"
Class {
	#name : 'OpenCLContextObject',
	#superclass : 'OpenCLRefCountedObject',
	#instVars : [
		'context'
	],
	#category : 'OpenCL',
	#package : 'OpenCL'
}

{ #category : 'accessing' }
OpenCLContextObject >> context [
	"Answer the OpenCLContext that this object is associated with."
	^context
]

{ #category : 'private' }
OpenCLContextObject >> privateDestroy [
	"Subclasses may extend this method, but must ensure that 'context' is set to nil."
	context := nil.
]
