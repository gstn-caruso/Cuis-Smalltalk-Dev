"
"
---EXPERIMENTAL!---

As in https://developer.apple.com/library/mac/documentation/Performance/Conceptual/OpenCL_MacProgGuide/TuningPerformanceOntheGPU/TuningPerformanceOntheGPU.html#//apple_ref/doc/uid/TP40008312-CH22-SW11 "

| lena bench result |
lena _ FloatImage lena scaledBy: 4.005.
bench _ AppleCopyBenchmark new.
	bench input: lena.
AndreasSystemProfiler spyOn: [
	100 timesRepeat: [
		bench run ]
].
	result _ bench result.
result display
"
Class {
	#name : 'AppleCopyBenchmark',
	#superclass : 'OpenCLExample',
	#instVars : [
		'kernel',
		'inputBuffer',
		'outputBuffer',
		'lastEvent',
		'outputMatrix'
	],
	#pools : [
		'OpenCLConstants'
	],
	#category : 'OpenCL-Examples',
	#package : 'OpenCL',
	#tag : 'Examples'
}

{ #category : 'accessing' }
AppleCopyBenchmark >> input: aFloatMatrix [

	outputMatrix _ aFloatMatrix appropriateResultClass extent: aFloatMatrix extent.

	"Set up Kernels"
	kernel := program createKernel: 'copy'.
	inputBuffer := context readOnlyBufferOfSize: aFloatMatrix elements byteSize.
	outputBuffer := context writeOnlyBufferOfSize: outputMatrix elements byteSize.

	lastEvent := queue 
					writeBuffer: inputBuffer
					from: aFloatMatrix elements
					waitOn: lastEvent.

	kernel argAt: 0 putPointer: inputBuffer.
	kernel argAt: 1 putPointer: outputBuffer.
	kernel argAt: 2 putInt: outputMatrix width.
	kernel argAt: 3 putInt: outputMatrix height
]

{ #category : 'accessing' }
AppleCopyBenchmark >> result [

	queue readBuffer: outputBuffer into: outputMatrix elements waitOn: lastEvent.
	^outputMatrix
]

{ #category : 'actions' }
AppleCopyBenchmark >> run [

	lastEvent := queue 
			runKernel: kernel
			workDim: 2
			globalOffset: #(0 0)
			globalSize: {outputMatrix width. outputMatrix height}
			localSize: #(32 8)
			waitOn: lastEvent.
]

{ #category : 'private' }
AppleCopyBenchmark >> sourceCode [
	"Answer the OpenCL source code for this example."
	"Copy from / to global memory"
	^'
__kernel void copy(global const float * in, global float * out, int w, int h) {

	int x = get_global_id(0); 		// (x,y) = pixel to process
	int y = get_global_id(1); 		// in this work item

	out[x+y*w] = in[x+y*w]; 		// Load and Store

//	out[x+y*w] = 100*y+x;	
}
'
]
