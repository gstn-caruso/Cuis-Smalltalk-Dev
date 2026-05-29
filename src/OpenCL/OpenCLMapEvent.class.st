"
The commands to map images and buffers return a pointer.  However, this pointer is not valid until the mapping is complete.  Therefore, we encapsulate the pointer within a special event-type; the pointer is not made available until the event's enqueued command has completed.
"
Class {
	#name : 'OpenCLMapEvent',
	#superclass : 'OpenCLEvent',
	#instVars : [
		'pointer',
		'rowPitch',
		'slicePitch'
	],
	#category : 'OpenCL',
	#package : 'OpenCL'
}

{ #category : 'accessing' }
OpenCLMapEvent >> pointer [
	"TODO: raise error if event's command isn't finished executing."
	^pointer
]

{ #category : 'initialize' }
OpenCLMapEvent >> pointer: externalData [
	pointer := externalData
]

{ #category : 'accessing' }
OpenCLMapEvent >> rowPitch [
	"Only used for images (nil for buffers)."
	^rowPitch
]

{ #category : 'initialize' }
OpenCLMapEvent >> rowPitch: pitch [
	rowPitch := pitch
]

{ #category : 'accessing' }
OpenCLMapEvent >> slicePitch [
	"Only used for images (nil for buffers)."
	^slicePitch
]

{ #category : 'initialize' }
OpenCLMapEvent >> slicePitch: pitch [
	slicePitch := pitch
]
