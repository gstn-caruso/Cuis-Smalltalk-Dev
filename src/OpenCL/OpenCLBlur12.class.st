"
Pretty much the simplest thing you can do with OpenCL: a separable Gaussian blur.
Adapted to OpenCL 1.2. The only change is in #setupImages:, use clCreateImage() and not the (now deprecated) clCreateImage2D()

Try evaluating:
	OpenCLBlur12 blurDisplay
"
Class {
	#name : 'OpenCLBlur12',
	#superclass : 'OpenCLExample',
	#instVars : [
		'horizontalKernel',
		'verticalKernel',
		'filterWeights',
		'filterWeightsBuffer',
		'imageExtent',
		'inputOutputImage',
		'tempImage',
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
OpenCLBlur12 class >> blurDisplay [
	"
	OpenCLBlur12 blurDisplay
	"
	| blur src dest |
	blur := self new.
	
	dest := ExternalForm extent: Display extent nativeDepthFrom: 32.
	dest allocateSpace.
	src := ExternalForm extent: Display extent nativeDepthFrom: 32.
	src allocateSpace.
	Display displayOn: src.
		
	((1 to: 20), (19 to: 1 by: -1)) do: [:radius |
		| evt startTime queuedTime finishTime |
		startTime := Time millisecondClockValue.
		evt := blur blur: src into: dest radius: radius.
		queuedTime := Time millisecondClockValue - startTime.
		OpenCLEvent waitForEvents: evt.
		finishTime := Time millisecondClockValue - startTime.
		('   QUEUED COMMANDS IN: ', queuedTime printString, 'msecs     ') print.
		('   FINISHED COMMANDS IN: ', finishTime printString, 'msecs     ') print.
		'   QUEUED COMMANDS IN: ', queuedTime printString, 'msecs     ' displayOn: dest at: 20@20.
		'   FINISHED COMMANDS IN: ', finishTime printString, 'msecs     ' displayOn: dest at: 20@40.
		dest displayAt: 0@0.

		(Delay forMilliseconds: 20) wait.
	].
	src displayAt: 0@0.

]

{ #category : 'actions' }
OpenCLBlur12 >> blur: inputForm into: outputForm radius: filterRadius [
	| localWorkSize globalWorkSize |
	
	"Sanity check."
	inputForm extent = outputForm extent ifFalse: [self error: 'image sizes do not match'].
	inputForm depth = 32 ifFalse: [self error: 'input form depth must be 32'].
	outputForm depth = 32 ifFalse: [self error: 'output form depth must be 32'].

	inputForm extent = imageExtent ifFalse: [
		"Need to allocate new images."
		self setupImages: (imageExtent := inputForm extent).
	].

	(filterWeights size - 1) = filterRadius ifFalse: [
		"Need to compute and set-up new filter weights."
		self setupWeightsForRadius: filterRadius.
	].
	
	"Upload image to the GPU so we can blur it." 
	self uploadDataToGPU: inputForm.
					
	"Compute work sizes."
	localWorkSize := #(16 16).  "should fit on most devices... see #maxWorkGroupSize"
	localWorkSize := #(128 1).  "Largest that works on tests done on MacOS with no GPU."
	globalWorkSize := {imageExtent x. imageExtent y}.
	globalWorkSize := globalWorkSize 
							with: localWorkSize 
							collect: [:global :local | global roundUpTo: local].		
					
	"Run the two kernels to blur the image first horizontally, then vertically."
	lastEvent := queue
					runKernel: horizontalKernel
					workDim: 2
					globalOffset: #(0 0)
					globalSize: globalWorkSize
					localSize: localWorkSize 
					waitOn: lastEvent.
	lastEvent := queue
					runKernel: verticalKernel
					workDim: 2
					globalOffset: #(0 0)
					globalSize: globalWorkSize
					localSize: localWorkSize 
					waitOn: lastEvent.
					
	"Retrieve blurred image from the GPU."				
	self downloadDataFromGPU: outputForm.
	
	"When this event is finished, 'outputForm' will have its new contents.  Yay!"				
	^lastEvent 
]

{ #category : 'actions' }
OpenCLBlur12 >> blur: inputAndOutputForm radius: filterRadius [
	"Input and output image are the same."
	^self blur: inputAndOutputForm into: inputAndOutputForm radius: filterRadius
	
]

{ #category : 'private' }
OpenCLBlur12 >> downloadDataFromGPU: outputForm [
	"Block, because outputForm may be moved by GC before the data transfer occurs.  We could test to see if we're using an ExternalForm, and if so use a non-blocking command."
	lastEvent := queue
					readImage: inputOutputImage
					block: false
					origin: #(0 0 0)
					region: {imageExtent x. imageExtent y. 1}
					rowPitch: outputForm wordsPerLine * 4
					slicePitch: 0
					pointer: outputForm
					waitOn: lastEvent
]

{ #category : 'initialize' }
OpenCLBlur12 >> initialize [

	"Set up context, queue, program, kernels, etc."
	super initialize.

	"Set up Kernels"
	horizontalKernel := program createKernel: 'image_filter_horizontal'.
	verticalKernel := program createKernel: 'image_filter_vertical'.
	
	"Create a buffer for the filter weights, big enough for a blur-radius of 100 pixels."
	filterWeights := Float32Array new: 0.  "will be replaced when the blur-radius is set"
	filterWeightsBuffer := context readOnlyBufferOfSize: 101 * 4.
	horizontalKernel argAt: 1 putPointer: filterWeightsBuffer.
	verticalKernel argAt: 1 putPointer: filterWeightsBuffer
]

{ #category : 'private' }
OpenCLBlur12 >> setupImages: extent [
	"Create new OpenCL images to perform the blur, and assign them as arguments to both kernels.
	Use the OpenCL 1.2 api for this."
	| format description |
	format _ CLImageFormatStruct bgra8888norm.
	description _ CLImageDescStruct new.
	description  		"https://www.khronos.org/registry/cl/sdk/1.2/docs/man/xhtml/imageDescriptor.html"
		image_type: CL_MEM_OBJECT_IMAGE2D;
		image_width: extent x;
		image_height: extent y;
		image_depth: 0;				"Only used for 3d images"
		image_array_size: 0; 		"This is only used if the image is a 1D or 2D image array"
		image_row_pitch: 0;
		image_slice_pitch: 0;
		num_mip_levels: 0;
		num_samples: 0;
		buffer: 0.
	"Image creation the OpenCL 1.2 way"
	inputOutputImage := context 
							newImage: CL_MEM_READ_WRITE
							format: format
							description: description
							hostPointer: nil.
	tempImage := context 
							newImage: CL_MEM_READ_WRITE
							format: format
							description: description
							hostPointer: nil.
	
	"Horizontal kernel runs first, storing the horizontally-blurred image into 'tempImage'."						
	horizontalKernel argAt: 2 putPointer: inputOutputImage.
	horizontalKernel argAt: 3 putPointer: tempImage.
	
	"Vertical kernel runs next, using the partly-blurred image in 'tempImage' as the source."
	verticalKernel argAt: 2 putPointer: tempImage.
	verticalKernel argAt: 3 putPointer: inputOutputImage
]

{ #category : 'private' }
OpenCLBlur12 >> setupWeightsForRadius: filterRadius [
	| sigma sum |
	
	filterRadius isInteger ifFalse: [self error: 'filter radius must be an integer'].
	filterRadius > 100 ifTrue: [
		"In #initialize, we only allocated enough space for 101 filter weights."
		self error: 'filter radius must be <= 100 pixels'.
	].

	"If the radius is zero, there is no blurring."
	filterRadius = 0 ifTrue: [
		filterWeights := Float32Array with: 1.0.
		^self.
	].
	
	filterWeights := Float32Array new: filterRadius + 1.
	sigma := filterRadius / 3.0.  "past 3 std-deviations, Gaussian is near-zero."
	
	"Compute unnormalized gaussian weights."
	0 to: filterRadius do: [:i |
		| t1 t2 |
		t1 := 1 / (sigma * (Float pi * 2) sqrt).
		t2 := (i / sigma) squared * -0.5.
		filterWeights at: i+1 put: (t1 * (Float e raisedTo: t2))
	].

	"Normalize.  We've computed half a bell curve, so count some weights twice so that the full curve sums to 1."
	sum := filterWeights sum * 2.
	sum := sum - (filterWeights first).  "only count the center of the curve once."
	filterWeights /= sum.
	
	"Upload filter weights to buffer."
	lastEvent := queue 
					writeBuffer: filterWeightsBuffer
					from: filterWeights
					waitOn: lastEvent.
	
	"Set up kernel arguments."
	horizontalKernel argAt: 0 putInt: filterRadius.
	verticalKernel argAt: 0 putInt: filterRadius.

	
]

{ #category : 'private' }
OpenCLBlur12 >> sourceCode [
	"Answer the OpenCL source code for the guassian-blur program."
^'

	__constant sampler_t sampler = CLK_NORMALIZED_COORDS_FALSE | CLK_ADDRESS_CLAMP_TO_EDGE | CLK_FILTER_NEAREST;

	__kernel void
	image_filter_horizontal (int filterHalfWidth,
							__constant float* filterWeights,  // of size filterHalfWidth + 1
							__read_only image2d_t src_image,
							__write_only image2d_t dst_image)
	{
		if (get_global_id(0) >= get_image_width(dst_image)) return;
		if (get_global_id(1) >= get_image_height(dst_image)) return;
		int i;
		int2 coord = (int2)(get_global_id(0), get_global_id(1));
		float4 weight = (float4)filterWeights[0];
		float4 out = read_imagef(src_image, sampler, coord) * weight;
		for (i=1; i <= filterHalfWidth; i++) {
			weight = (float4)filterWeights[i];
			out += (read_imagef(src_image, sampler, (coord + (int2)(i,0))) * weight);
			out += (read_imagef(src_image, sampler, (coord - (int2)(i,0))) * weight);
		}
		write_imagef(dst_image, coord, out);
	}
	
	__kernel void
	image_filter_vertical (int filterHalfHeight,
						__constant float* filterWeights, // of size filterHalfHeight + 1
						__read_only image2d_t src_image,
						__write_only image2d_t dst_image)
	{
		if (get_global_id(0) >= get_image_width(dst_image)) return;
		if (get_global_id(1) >= get_image_height(dst_image)) return;
		int i;
		int2 coord = (int2)(get_global_id(0), get_global_id(1));
		float4 weight = (float4)filterWeights[0];
		float4 out = read_imagef(src_image, sampler, coord) * weight;
		for (i=1; i <= filterHalfHeight; i++) {
			weight = (float4)filterWeights[i];
			out += (read_imagef(src_image, sampler, (coord + (int2)(0,i))) * weight);
			out += (read_imagef(src_image, sampler, (coord - (int2)(0,i))) * weight);
		}
		write_imagef(dst_image, coord, out);
	}'
]

{ #category : 'private' }
OpenCLBlur12 >> uploadDataToGPU: inputForm [
	"Block, because inputForm may be moved by GC before the data transfer occurs.  We could test to see if we're using an ExternalForm, and if so use a non-blocking command."
	lastEvent := queue
					writeImage: inputOutputImage
					block: false
					origin: #(0 0 0)
					region: {imageExtent x. imageExtent y. 1}
					rowPitch: inputForm wordsPerLine * 4
					slicePitch: 0
					pointer: inputForm
					waitOn: lastEvent
]
