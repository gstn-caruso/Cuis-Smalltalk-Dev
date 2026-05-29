"
Subclasses wrap an instance of the corresponding OpenCLOpaqueHandle type.  Provides convenience methods for calling FFI functions on the handle.
"
Class {
	#name : 'OpenCLObject',
	#superclass : 'Object',
	#instVars : [
		'id'
	],
	#pools : [
		'OpenCLConstants'
	],
	#category : 'OpenCL',
	#package : 'OpenCL'
}

{ #category : 'class initialization' }
OpenCLObject class >> initialize [
	"This functionality is now consolidated in CL class."
	"OpenCLObject initialize"
	Smalltalk removeFromStartUpList: self.
]

{ #category : 'instance creation' }
OpenCLObject class >> new [
	self shouldNotImplement
]

{ #category : 'private' }
OpenCLObject class >> wrappingHandle: anOpenCLOpaqueHandle "of the appropriate subclass" [
	"Users of the OpenCL framework should never call this directly."
	^self basicNew
		initialize;
		id: anOpenCLOpaqueHandle;
		yourself
]

{ #category : 'converting' }
OpenCLObject >> asOpenCLArg [
	^id asOpenCLArg
]

{ #category : 'accessing' }
OpenCLObject >> id [
	"Answer a reference to the OpenCLOpaqueHandle sub-instance that can be passed directly as an FFI argument."
	^id
]

{ #category : 'initialize' }
OpenCLObject >> id: anOpenCLOpaqueHandle [
	id := anOpenCLOpaqueHandle
]

{ #category : 'initialize' }
OpenCLObject >> invalidateOnStartUp [
	"Squeak is starting up, so release our ID... it's invalid anyway, and would cause crashes if we tried to use it."
	id := nil.
]

{ #category : 'testing' }
OpenCLObject >> isDestroyed [
	^id isNil
]
