"
A very stupid example that fills a 256-element array with the values 0... 255.  This was done as a sanity check (I later discovered that I was sane, and that the Nvidia OpenCL can't yet have a kernel write to an image).

OpenCLFill256 new run1d
OpenCLFill256 new run2d
"
Class {
	#name : 'OpenCLFill256',
	#superclass : 'Object',
	#instVars : [
		'device',
		'context',
		'queue',
		'program',
		'kernel1d',
		'kernel2d',
		'lastEvent',
		'buffer'
	],
	#pools : [
		'OpenCLConstants'
	],
	#category : 'OpenCL-Examples',
	#package : 'OpenCL',
	#tag : 'Examples'
}

{ #category : 'initialize' }
OpenCLFill256 >> initialize [
	device := OpenCLPlatform preferredDevice.
	context := OpenCLContext newForDevices: {device}.
	queue := context commandQueueOn: device.
	program := context programWithSource: self sourceCode.
	program build.
	buffer := context readWriteBufferOfSize: 256*4.  "256 integers"
	kernel1d := program createKernel: 'fill256_1d'.
	kernel1d argAt: 0 putPointer: buffer.
	kernel2d := program createKernel: 'fill256_2d'.
	kernel2d argAt: 0 putPointer: buffer
]

{ #category : 'actions' }
OpenCLFill256 >> run1d [
	| evt output |
	evt := queue 
			runKernel: kernel1d
			workDim: 1
			globalOffset: #(0)
			globalSize: #(256)
			localSize: #(16)
			waitOn: nil.
	output := IntegerArray new: 256.
	queue readBuffer: buffer into: output waitOn: evt.
	^output
]

{ #category : 'actions' }
OpenCLFill256 >> run2d [
	| evt output |
	evt := queue 
			runKernel: kernel2d
			workDim: 2
			globalOffset: #(0 0)
			globalSize: #(16 16)
			localSize: #(4 4)
			waitOn: nil.
	output := IntegerArray new: 256.
	queue readBuffer: buffer into: output waitOn: evt.
	^output
]

{ #category : 'private' }
OpenCLFill256 >> sourceCode [
	"Answer the OpenCL source code for this example."
^'
	__kernel void
	fill256_1d(__global int* target)
	{
		int index = get_global_id(0);
		target[index] = index;
	}
	
	__kernel void
	fill256_2d(__global int* target)
	{
		int x = get_global_id(0);
		int y = get_global_id(1);
		int index = x*16 + y;
		target[index] = index;
	}'
]
