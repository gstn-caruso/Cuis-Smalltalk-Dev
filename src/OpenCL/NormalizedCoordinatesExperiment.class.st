"
Try evaluating:
	NormalizedCoordinatesExperiment go
"
Class {
	#name : 'NormalizedCoordinatesExperiment',
	#superclass : 'OpenCLExample',
	#instVars : [
		'kernel',
		'originalFrame',
		'processedFrame',
		'lastEvent'
	],
	#pools : [
		'OpenCLConstants'
	],
	#category : 'OpenCL-Examples',
	#package : 'OpenCL',
	#tag : 'Examples'
}

{ #category : 'example' }
NormalizedCoordinatesExperiment class >> go [
	"
	NormalizedCoordinatesExperiment go
	"
	| algoritm src dest value |
	algoritm _ self new.

	src _ GrayForm extent: 4@4.
	
	0 to: src width-1 do: [ :x |
		value _ (x * 255.0 / (src width-1)) rounded.
		value _ (x+0.5 * 255.0 / (src width)) rounded print.
		0 to: src height-1 do: [ :y |
			src pixelValueAt: x@y put: value.
			]].
	dest _ GrayForm extent: 300@1.
	algoritm process: src into: dest.
	dest displayAt: 0@0.

	{src. dest} explore.
	dest bits asByteArray print
]

{ #category : 'private' }
NormalizedCoordinatesExperiment >> downloadDataFromGPU: outputForm [
	"Block, because outputForm may be moved by GC before the data transfer occurs.  We could test to see if we're using an ExternalForm, and if so use a non-blocking command."
	lastEvent := queue
					readImage: processedFrame
					block: false
					origin: #(0 0 0)
					region: {outputForm width. outputForm height. 1}
					rowPitch: outputForm wordsPerLine * 4
					slicePitch: 0
					pointer: outputForm
					waitOn: lastEvent
]

{ #category : 'initialize' }
NormalizedCoordinatesExperiment >> initialize [

	"Set up context, queue, program, kernels, etc."
	super initialize.

	"Set up Kernels"
	kernel := program createKernel: 'the_kernel'
]

{ #category : 'actions' }
NormalizedCoordinatesExperiment >> process: inputForm into: outputForm [
	| localWorkSize globalWorkSize startTime |
	
	"Sanity check."
	inputForm depth = 8 ifFalse: [self error: 'input form depth must be 8'].
	outputForm depth = 8 ifFalse: [self error: 'output form depth must be 8'].

	self setupInputImage: inputForm.
	kernel argAt: 0 putPointer: originalFrame.
	self setupOutputImage: outputForm.
	kernel argAt: 1 putPointer: processedFrame.
	'---------------------' print.

	startTime := Time millisecondClockValue.
	"Upload image to the GPU so we can process it." 
	self uploadDataToGPU: inputForm.
	OpenCLEvent waitForEvents: lastEvent.
	((Time millisecondClockValue - startTime) printString, ' ms to Upload to GPU') print.
					
	"Compute work sizes."
	localWorkSize := #(256 1).  "should fit on most devices... see #maxWorkGroupSize. Minimum number that already gives max performance"
	globalWorkSize := {outputForm width. outputForm height}.

	startTime := Time millisecondClockValue.
	lastEvent := queue
					runKernel: kernel
					workDim: 2
					globalOffset: #(0 0)
					globalSize: globalWorkSize
					localSize: localWorkSize 
					waitOn: lastEvent.
	OpenCLEvent waitForEvents: lastEvent.
	((Time millisecondClockValue - startTime) printString, ' ms to Run Kernel') print.
					
	"Retrieve result image from the GPU."
	startTime := Time millisecondClockValue.
	self downloadDataFromGPU: outputForm.
	OpenCLEvent waitForEvents: lastEvent.
	((Time millisecondClockValue - startTime) printString, ' ms to Download from GPU') print.
]

{ #category : 'private' }
NormalizedCoordinatesExperiment >> setupInputImage: inputForm [
	"Create new OpenCL images to perform the blur, and assign them as arguments to both kernels.
	Use the OpenCL 1.2 api for this."
	| format description |

	"r8Norm para que en el kernel se pueda usar read_imagef() y write_imagef().
	Ver OpenCL reference '6.11.8.2 Built-in Image Functions'  p.192
	#r8Norm, #luminance8Norm, #intensity8Norm parecen dar lo mismo"
	format _ CLImageFormatStruct r8Norm.
"	format _ CLImageFormatStruct luminance8Norm."
"	format _ CLImageFormatStruct intensity8Norm."

	description _ CLImageDescStruct new.
	description  		"https://www.khronos.org/registry/cl/sdk/1.2/docs/man/xhtml/imageDescriptor.html"
		image_type: CL_MEM_OBJECT_IMAGE2D;
		image_width: inputForm width;
		image_height: inputForm height;
		image_depth: 0;				"Only used for 3d images"
		image_array_size: 0; 		"This is only used if the image is a 1D or 2D image array"
		image_row_pitch: 0;
		image_slice_pitch: 0;
		num_mip_levels: 0;
		num_samples: 0;
		buffer: 0.
	"Image creation the OpenCL 1.2 way"
	originalFrame _ context 
		newImage: CL_MEM_READ_ONLY
		format: format
		description: description
		hostPointer: nil
]

{ #category : 'private' }
NormalizedCoordinatesExperiment >> setupOutputImage: outputForm [
	"Create new OpenCL images to perform the blur, and assign them as arguments to both kernels.
	Use the OpenCL 1.2 api for this."
	| format description |

	"r8Norm para que en el kernel se pueda usar read_imagef() y write_imagef().
	Ver OpenCL reference '6.11.8.2 Built-in Image Functions'  p.192
	#r8Norm, #luminance8Norm, #intensity8Norm parecen dar lo mismo"
	format _ CLImageFormatStruct r8Norm.
"	format _ CLImageFormatStruct luminance8Norm."
"	format _ CLImageFormatStruct intensity8Norm."

	description _ CLImageDescStruct new.
	description  		"https://www.khronos.org/registry/cl/sdk/1.2/docs/man/xhtml/imageDescriptor.html"
		image_type: CL_MEM_OBJECT_IMAGE2D;
		image_width: outputForm width;
		image_height: outputForm height;
		image_depth: 0;				"Only used for 3d images"
		image_array_size: 0; 		"This is only used if the image is a 1D or 2D image array"
		image_row_pitch: 0;
		image_slice_pitch: 0;
		num_mip_levels: 0;
		num_samples: 0;
		buffer: 0.
	"Image creation the OpenCL 1.2 way"
	processedFrame _ context 
		newImage: CL_MEM_WRITE_ONLY 
		format: format
		description: description
		hostPointer: nil
]

{ #category : 'private' }
NormalizedCoordinatesExperiment >> sourceCode [
	"Answer the OpenCL source code for the program."
"	Todos los kernels juntos en cada linea.
	Si de casualidad le pego a la rerrida de OpenCL, entonces me queda en orden la recorrida de RAM"
^'

	//__constant sampler_t sampler = CLK_NORMALIZED_COORDS_TRUE | CLK_ADDRESS_NONE | CLK_FILTER_LINEAR;
	__constant sampler_t sampler = CLK_NORMALIZED_COORDS_TRUE | CLK_ADDRESS_CLAMP_TO_EDGE | CLK_FILTER_LINEAR;
	//__constant sampler_t sampler = CLK_NORMALIZED_COORDS_TRUE | CLK_ADDRESS_CLAMP | CLK_FILTER_LINEAR;
	//__constant sampler_t sampler = CLK_NORMALIZED_COORDS_TRUE | CLK_ADDRESS_REPEAT | CLK_FILTER_LINEAR;
	//__constant sampler_t sampler = CLK_NORMALIZED_COORDS_TRUE | CLK_ADDRESS_MIRRORED_REPEAT | CLK_FILTER_LINEAR;

	__kernel void the_kernel (
							__read_only image2d_t src_image,
							__write_only image2d_t dst_image)
	{

		float scaleH = 1.0 / get_image_width(dst_image);
		float scaleV = 1.0 / get_image_height(dst_image);

		float2 inputCoord = (float2)(get_global_id(0) * scaleH , get_global_id(1) * scaleV);
		int2 outputCoord = (int2)(get_global_id(0), get_global_id(1));

		float value = read_imagef(src_image, sampler, inputCoord).x;

		write_imagef(dst_image, outputCoord, (float4)(value,0,0,0));

	}'
]

{ #category : 'private' }
NormalizedCoordinatesExperiment >> uploadDataToGPU: inputForm [
	"Block, because inputForm may be moved by GC before the data transfer occurs.  We could test to see if we're using an ExternalForm, and if so use a non-blocking command."
	lastEvent := queue
					writeImage: originalFrame
					block: false
					origin: #(0 0 0)
					region: {inputForm width. inputForm height. 1}
					rowPitch: inputForm wordsPerLine * 4
					slicePitch: 0
					pointer: inputForm
					waitOn: lastEvent
]
