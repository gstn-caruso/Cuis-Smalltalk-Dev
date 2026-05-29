"
OpenCLJuliaSet example1
"
Class {
	#name : 'OpenCLJuliaSet',
	#superclass : 'OpenCLExample',
	#instVars : [
		'extent',
		'iterations',
		'outputForm',
		'workImage',
		'toneMapForm',
		'toneMapImage',
		'kernel',
		'lastEvent',
		'params',
		'paramsDirty',
		'paramsBuffer',
		'scale',
		'origin'
	],
	#pools : [
		'OpenCLConstants'
	],
	#category : 'OpenCL-Examples',
	#package : 'OpenCL',
	#tag : 'Examples'
}

{ #category : 'examples' }
OpenCLJuliaSet class >> example1 [
	"
	OpenCLJuliaSet example1
	"
	| clExample |

	clExample := OpenCLJuliaSet new.
	clExample extent: 1024@1024.
	clExample useRainbowToneMap.
	
	(ImageMorph new image:  clExample outputForm) openInHand.	
			
	0 to: 360 by: 2 do: [:i |
		| rads |
		rads := i degreesToRadians.
		clExample real: rads sin / 2.0*1.3.
		clExample imaginary: rads cos / 2.0*1.1.	
		clExample runKernel.
		clExample outputForm display.
	"	Display forceToScreen: (0@0 corner: 1024@1024)."
	].


	

]

{ #category : 'private' }
OpenCLJuliaSet >> adjustOriginAndStepSize [
	"For now we just hardcode to use the whole domain from (-2,-2) to (2,2)... no zoom/pan."
	params at: 1 put: -2.0.
	params at: 2 put: -2.0.
	params at: 3 put: (4.0 / extent x).
	params at: 4 put: (4.0 / extent y).


	paramsDirty := true.
]

{ #category : 'initialize' }
OpenCLJuliaSet >> extent: newExtent [
	newExtent = extent ifTrue: [^self "no change"].
	paramsDirty := true.
	extent := newExtent.
	outputForm := Form extent: extent depth: 32.
	
	self waitForEvent.
	workImage ifNotNil: [workImage destroy].
	workImage := context
					newImage2D: CL_MEM_WRITE_ONLY
					format: CLImageFormatStruct bgra8888norm
					width: extent x
					height: extent y
					rowPitch: nil
					hostPointer: nil.
	kernel argAt: 3 putPointer: workImage.
	
	self adjustOriginAndStepSize
]

{ #category : 'parameters' }
OpenCLJuliaSet >> imaginary [
	"Answer the 'imaginary' parameter of the Julia set."
	^params at: 6
]

{ #category : 'parameters' }
OpenCLJuliaSet >> imaginary: newImaginary [
	"Set the 'imaginary' parameter of the Julia set."
	| old |
	old := params at: 6.
	params at: 6 put: newImaginary.
	old = (params at: 6) ifTrue: [^self "no change"].
	paramsDirty := true
]

{ #category : 'initialize' }
OpenCLJuliaSet >> initialize [
	"We take care so that you can call #initialize again and none of the existing settings will be lost."
	| rememberedExtent |

	lastEvent := nil.	
	super initialize.

	"Set up kernels"
	kernel := program createKernel: 'julia'.

	scale ifNil: [
		"This is the first time #initialize is being run, so we need to initialize all variables.
		 Otherwise, we reuse the existing values, only resetting the OpenCL state."
		scale := 1.0.
		origin := 0.0.
	
		"Would be better to use ExternalData so that we don't have to block when uploading
		 the parameters to the GPU, but I don't know how write 32-bit floats via the FFI."
		params := Float32Array new: 7.
		params at: 5 put: 0.1.
		params at: 6 put: 0.5.
		params at: 7 put: 0.0.
		
		extent := 512@512.
	].

	paramsBuffer := context readWriteBufferOfSize: 7*4. "7 32-bit floats"
	kernel argAt: 1 putPointer: paramsBuffer.

	toneMapForm ifNotNil: [self toneMap: toneMapForm].
	
	rememberedExtent := extent.
	extent := nil. "force recreation of work-image."
	self extent: rememberedExtent.
	
	paramsDirty := true.
	
]

{ #category : 'accessing' }
OpenCLJuliaSet >> isDirty [
	"Answer true if parameters have changed and we need to re-render."
	^paramsDirty
]

{ #category : 'parameters' }
OpenCLJuliaSet >> origin: newOrigin [
	self error: 'unimplemented'. "see #adjustOriginAndStepSize"
	origin = newOrigin ifTrue: [^self "no change"].
	origin := newOrigin.
	self adjustOriginAndStepSize.
	
]

{ #category : 'accessing' }
OpenCLJuliaSet >> outputForm [
	^outputForm
]

{ #category : 'parameters' }
OpenCLJuliaSet >> real [
	"Answer the 'real' parameter of the Julia set."
	^params at: 5
]

{ #category : 'parameters' }
OpenCLJuliaSet >> real: newReal [
	"Set the 'real' parameter of the Julia set."
	| old |
	old := params at: 5.
	params at: 5 put: newReal.
	old = (params at: 5) ifTrue: [^self "no change"].
	paramsDirty := true
]

{ #category : 'private' }
OpenCLJuliaSet >> runKernel [
	paramsDirty ifTrue: [
		"Would be nice if this were non-blocking..."
		lastEvent := queue
						writeBuffer: paramsBuffer
						from: params
						waitOn: lastEvent.
		paramsDirty := false.
	].

	lastEvent := queue
					runKernel: kernel
					workDim: 2
					globalOffset: #(0 0)
					globalSize: {extent x roundUpTo: 32. extent y roundUpTo: 4}
					localSize: #(32 4)
					waitOn: lastEvent.
	queue
			readImage: workImage
			block: true
			origin: #(0 0 0)
			region: {extent x. extent y. 1}
			rowPitch: outputForm wordsPerLine * 4
			slicePitch: 0
			pointer: outputForm
			waitOn: lastEvent.
	lastEvent := nil
]

{ #category : 'private' }
OpenCLJuliaSet >> runKernelAndDisplay [
	self runKernel.
	outputForm displayAt: 0@0.
]

{ #category : 'parameters' }
OpenCLJuliaSet >> scale: newScale [
	self error: 'unimplemented'. "see #adjustOriginAndStepSize"
	scale = newScale ifTrue: [^self "no change"].
	scale := newScale.
	self adjustOriginAndStepSize.
]

{ #category : 'private' }
OpenCLJuliaSet >> sourceCode [
	"Answer the OpenCL source code for the Julia set program."
^'
__constant sampler_t sampler = 	CLK_NORMALIZED_COORDS_TRUE | 
									CLK_FILTER_LINEAR |
									CLK_ADDRESS_CLAMP_TO_EDGE ;

/* 	params[0]	x-origin
	params[1]	y-origin
	params[2]	x-step
	params[3]	y-step
	params[4]	real coefficient
	params[5]	imaginary coefficient
	params[6]	tone-map v-coord (u is computed based on # of iterations)
*/
			
__kernel void
julia (int iterations,
	__constant float* params,
	__read_only image2d_t tone_map,
	__write_only image2d_t dst_image)
{

	if (get_global_id(0) >= get_image_width(dst_image)) return;
	if (get_global_id(1) >= get_image_height(dst_image)) return;
	
	float x = params[0] + (params[2]*(float)get_global_id(0));
	float y = params[1] + (params[3]*(float)get_global_id(1));
	float real = params[4];
	float imaginary = params[5];

	int count = 0;	
	while (count < iterations) {
		if (x*x + y*y > 4.0) break;
		count++;
		
		float new_x = x*x - y*y + real;
		float new_y = 2*x*y + imaginary;
		x = new_x;
		y = new_y;	
	}

	float2 tex_coord = (float2)((float)count / (float)iterations, params[6]);
	write_imagef(	dst_image, 
					(int2)(get_global_id(0), get_global_id(1)), 
					read_imagef(tone_map, sampler, tex_coord));
}'
]

{ #category : 'initialize' }
OpenCLJuliaSet >> toneMap: newToneMapForm [
	| |
	
	toneMapForm := newToneMapForm.
	toneMapImage ifNotNil: [
		self waitForEvent.
		toneMapImage destroy.
	].

	"We clamp at a set number of iterations... if we haven't diverged after that long, 
	 we consider the point to be in the set.  We use the number of iterations before
	 diverging to pick a color to shade the pixel.  Therefore, it makes sense to make
	 the number of iterations equal to the width of the tone-map."
	iterations := toneMapForm width.
	kernel argAt: 0 putInt: iterations.

	toneMapImage := context
						newImage2D: CL_MEM_READ_ONLY
						format: CLImageFormatStruct bgra8888norm
						width: toneMapForm width
						height: toneMapForm height
						rowPitch: nil
						hostPointer: nil.
	kernel argAt: 2 putPointer: toneMapImage.
	lastEvent := queue
					writeImage: toneMapImage
					block: true
					origin: #(0 0 0)
					region: {toneMapImage width. toneMapImage height. 1}
					rowPitch: toneMapForm wordsPerLine * 4
					slicePitch: 0
					pointer: toneMapForm
					waitOn: lastEvent.
	paramsDirty := true
]

{ #category : 'parameters' }
OpenCLJuliaSet >> toneMapV: texVCoord [
	params at: 7 put: texVCoord.
	paramsDirty := true
]

{ #category : 'tone-maps' }
OpenCLJuliaSet >> useRainbowToneMap [
	"Generate a tone-map that cycles through the color-wheel.."
	| rainbow s |
s _ 32. "original"
s _ 80.
	rainbow := Form extent: s@s depth: 32.
	1 to: s-2 do: [:i |
		0 to: s-1 do: [:j |
			| hue bright |
			hue := ((j*11.25*32/s) + (i *11.25*32/s)) \\ 360.0.
			bright := (s-2 - i) / (s-2*2.0) + 0.35.
			rainbow colorAt: i@j put: (Color h: hue s: 1.0 v: bright).
		].
	].
	0 to: s-1 do: [:j |
		rainbow colorAt: 0@j put: (Color transparent).
		rainbow colorAt: s-1@j put: (Color transparent).
	].

	self toneMap: rainbow.
]

{ #category : 'private' }
OpenCLJuliaSet >> waitForEvent [
	"If there's an event pending, wait for it to complete."
	lastEvent ifNotNil: [lastEvent wait].
	lastEvent := nil.
]
