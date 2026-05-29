"
Private to the OpenCL framework; users of the framework will never directly touch one.

Keeps track of the reference-count of an OpenCLRefCountedObject.  The reason that this is a separate class is that it also acts as the executor for finalizing the object.

"
Class {
	#name : 'OpenCLRefCounter',
	#superclass : 'Object',
	#instVars : [
		'refCount',
		'id'
	],
	#category : 'OpenCL',
	#package : 'OpenCL'
}

{ #category : 'class initialization' }
OpenCLRefCounter class >> initialize [
	"This functionality is now consolidated in CL class."
	"OpenCLRefCounter initialize"
	Smalltalk removeFromStartUpList: self.
]

{ #category : 'accessing' }
OpenCLRefCounter >> count [
	^refCount
]

{ #category : 'finalization' }
OpenCLRefCounter >> finalize [
	"Decrement the ref-count until it is zero."
	[refCount = 0] whileFalse: [self release].
]

{ #category : 'initialize' }
OpenCLRefCounter >> id: anOpenCLOpaqueHandle [
	id := anOpenCLOpaqueHandle.
]

{ #category : 'initialize' }
OpenCLRefCounter >> initialize [
	refCount := 1. "OpenCL implicitly retains all newly-created objects."
]

{ #category : 'initialize' }
OpenCLRefCounter >> invalidateOnStartUp [
	"Squeak is starting up, so our ref-counted object is invalid.  Set 'refCount' to zero so that any subsequent #release won't trigger any cleanup-behavior."
	refCount := 0.

]

{ #category : 'printing' }
OpenCLRefCounter >> printOn: aStream [
	aStream nextPutAll: '[ref-count: '.
	refCount printOn: aStream.
	aStream nextPut: $]

]

{ #category : 'retain/release' }
OpenCLRefCounter >> release [
	"Decrement the ref-count."
	refCount = 0 ifTrue: [^self "already completely released"].
	refCount := refCount - 1.
	id release.

]

{ #category : 'retain/release' }
OpenCLRefCounter >> retain [
	"Increment the ref-count for this object so that OpenCL will not destroy it."
	refCount = 0 ifTrue: [^self "already completely released"].
	refCount := refCount + 1.
	id retain.
]
