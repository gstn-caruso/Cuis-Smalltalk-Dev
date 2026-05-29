"
This class includes ivars that any (all?) OpenCL examples should have.
Limitations:
- Handle just one device (it is possible to have a single program use several devices)

	device 	-> 		GPU or CPU
	context 	-> 		Instance of OpenCLContext. Built for our device.
	queue 	-> 		Instance of OpenCLCommandQueue. There is a queue for each device. Just one here.
	program 	-> 		Instance of OpenCLProgram. Holds source code, creates kernels.
"
Class {
	#name : 'OpenCLExample',
	#superclass : 'Object',
	#instVars : [
		'device',
		'context',
		'queue',
		'program'
	],
	#pools : [
		'OpenCLConstants'
	],
	#category : 'OpenCL-Examples',
	#package : 'OpenCL',
	#tag : 'Examples'
}

{ #category : 'accessing' }
OpenCLExample >> context [
	"Answer the OpenCL context."
	^context
]

{ #category : 'initialize' }
OpenCLExample >> destroy [
	"Release any resources used by this example."
	device ifNotNil: [device := nil].
	context ifNotNil: [:obj |
		context := nil.
		obj destroy
	].
	queue ifNotNil: [:obj |
		queue := nil.
		obj destroy
	].
	program ifNotNil: [:obj |
		program := nil.
		obj destroy
	].
	
]

{ #category : 'initialize' }
OpenCLExample >> initialize [
	self destroy. "reset to initial state"
	device := OpenCLPlatform preferredDevice.
	context := OpenCLContext newForDevices: {device}.
	queue := context commandQueueOn: device.
	program := context programWithSource: self sourceCode.
	program build
]
