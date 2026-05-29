"
Objects in the OpenCL Runtime layer are ref-counted (as opposed to platforms and devices in the Platform layer).  This class, along with OpenCLRefCounter, provides a framework for managing the ref-counts, as well as a finalization mechanism so that OpenCL resources are not leaked when these objects are garbage-collected while their ref-count is > 0.

"
Class {
	#name : 'OpenCLRefCountedObject',
	#superclass : 'OpenCLObject',
	#instVars : [
		'refCounter'
	],
	#category : 'OpenCL',
	#package : 'OpenCL'
}

{ #category : 'retain/release' }
OpenCLRefCountedObject >> destroy [
	"Call this if you *know* that this object will no longer be used.  See class comment."
	id ifNil: [^self "either we're already destroyed, or not initialized yet."].
	[refCounter count = 0] whileFalse: [refCounter release].
	id := nil.
	self privateDestroy.
	
]

{ #category : 'initialize' }
OpenCLRefCountedObject >> id: handle "an OpenCLOpaqueHandle" [
	super id: handle.
	refCounter id: handle.
]

{ #category : 'initialize' }
OpenCLRefCountedObject >> initialize [
	super initialize.
	refCounter := OpenCLRefCounter new.
	self registerForFinalization.
	
]

{ #category : 'initialize' }
OpenCLRefCountedObject >> invalidateOnStartUp [
	"Squeak is starting up, so we're invalid... perform the necessary clean-ups."
	super invalidateOnStartUp.
	self privateDestroy.

]

{ #category : 'private' }
OpenCLRefCountedObject >> privateDestroy [
	"Called when the reference count reaches zero.  Subclasses should use this to clean up references to other objects."
	self subclassResponsibility
]

{ #category : 'initialize' }
OpenCLRefCountedObject >> registerForFinalization [
	"Register our ref-counter as executor, so that it can clean up after we're garbage collected (we don't want to leak any OpenCL resources)."
	OpenCLPrimitiveInterface finalizationRegistry add: self executor: refCounter.
	
]

{ #category : 'retain/release' }
OpenCLRefCountedObject >> release [
	"Decrement the ref-count.  Once the count hits zero, it is no longer safe to use the object, so clear the ID."
	id ifNil: [^self "either we're already destroyed, or not initialized yet."].
	refCounter release.
	refCounter count = 0 ifTrue: [
		id := nil.
		self privateDestroy
	]
]

{ #category : 'retain/release' }
OpenCLRefCountedObject >> retain [
	"Increment the ref-count for this object so that OpenCL will not destroy it."
	id ifNil: [^self "either we're already destroyed, or not initialized yet."].
	refCounter retain.
	
]
