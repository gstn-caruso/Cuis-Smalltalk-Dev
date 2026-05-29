"
---EXPERIMENTAL!---

Parece que no tenemos OpenCL 1.2. Bueno usemos la api de 1.0 o 1.1... (O sea clCreateImage2D() y no clCreateImage() )

En este punto, esto fue abandonado. Eliminarlo, o completarlo... Ahora si tenemos OpenCL 1.2 y 2.0.
"
Class {
	#name : 'DeformationGridExample',
	#superclass : 'OpenCLExample',
	#instVars : [
		'kernel',
		'input',
		'gridX',
		'gridY',
		'result',
		'resultExtent',
		'lastEvent',
		'outputImage'
	],
	#pools : [
		'OpenCLConstants'
	],
	#category : 'OpenCL-Examples',
	#package : 'OpenCL',
	#tag : 'Examples'
}

{ #category : 'as yet unclassified' }
DeformationGridExample class >> dale [
	"
	DeformationGridExample dale
	Experimental. Unfinished. Requires SignalProcessing.pck.st
	En casa aun no puedo instanciar la de resultado...
	"
	| experiment gridXPositions gridYPositions inputImage resultExtent floatImageClass |
	experiment _ self new.
floatImageClass _ Smalltalk at: #FloatImage.
inputImage _ floatImageClass lena.
inputImage _ floatImageClass grid: 12@12 extent: 256@256.
resultExtent _ 512@512.
gridXPositions _ floatImageClass fromArrayOfArrays: #(
	(0.0 0.3 1.0)
	(0.0 0.6 1.0)
	(0.0 0.8 1.0)).
gridYPositions _ floatImageClass fromArrayOfArrays: #(
	(0.0 0.3 0.0)
	(0.7 0.6 0.5)
	(1.0 1.0 1.0)).

experiment input: inputImage gridX: gridXPositions gridY: gridYPositions resultExtent: resultExtent.
"
result replaceValues: [ :y :x :v |
	yy _ y-1.0/(result height-1) * (gridXPositions height-1) + 1.
	xx _ x-1.0/(result width-1) * (gridXPositions width-1) + 1.
	xp _ (gridXPositions bilinearInterpolatedValueAtX: xx y: yy) * 255+1.
	yp _ (gridYPositions bilinearInterpolatedValueAtX: xx y: yy) * 255+1.
	inputImage bilinearInterpolatedValueAtX: xp y: yp ].
"
experiment run.
experiment outputImage display.
	
	
	"
input _ FloatImage lena.
input _ FloatImage grid: 12@12 extent: 256@256.
result _ FloatImage extent: 500@500.
gridX _ FloatImage fromArrayOfArrays: #(
	(0.0 0.3 1.0)
	(0.0 0.6 1.0)
	(0.0 0.8 1.0)).
gridY _ FloatImage fromArrayOfArrays: #(
	(0.0 0.3 0.0)
	(0.7 0.6 0.5)
	(1.0 1.0 1.0)).

result replaceValues: [ :y :x :v |
	yy _ y-1.0/(result height-1) * (gridX height-1) + 1.
	xx _ x-1.0/(result width-1) * (gridX width-1) + 1.
	xp _ (gridX bilinearInterpolatedValueAtX: xx y: yy) * 255+1.
	yp _ (gridY bilinearInterpolatedValueAtX: xx y: yy) * 255+1.
	input bilinearInterpolatedValueAtX: xp y: yp ].
result display
"
]

{ #category : 'as yet unclassified' }
DeformationGridExample >> downloadDataFromGPU: outputForm [
	"Block, because outputForm may be moved by GC before the data transfer occurs.  We could test to see if we're using an ExternalForm, and if so use a non-blocking command."
	
	"Öjo que origin y region tienen tamanio 3, no 2. Entender"
	
	lastEvent := queue
					readImage: result
					block: false
					origin: #(0 0 0)
					region: {resultExtent x. resultExtent y. 1}
					rowPitch: outputForm wordsPerLine * 4
					slicePitch: 0
					pointer: outputForm
					waitOn: lastEvent
]

{ #category : 'as yet unclassified' }
DeformationGridExample >> initialize [

	"Set up context, queue, program, kernels, etc."
	super initialize.

	"Set up Kernels"
	kernel := program createKernel: 'resample'.
	
	"Create a buffer for the filter weights, big enough for a blur-radius of 100 pixels."
	" 
	stuff
	filterWeights := FloatArray new: 0.
	filterWeightsBuffer := context readOnlyBufferOfSize: 101 * 4.
	kernel argAt: 1 put: filterWeightsBuffer size: 4.
	" 
]

{ #category : 'as yet unclassified' }
DeformationGridExample >> input: inputImage gridX: gridXPositions gridY: gridYPositions resultExtent: aResultExtent [
"
Alternativas.
- Que aloque la memoria. despues le copio onda #uploadDataToGPU:
- Le digo ahora CL_MEM_COPY_HOST_PTR y le paso una imagen Smalltalk
- Le digo CL_MEM_COPY_HOST_PTR, pero uso un ExternalForm (quizas eso se pareceria mas a lo que voy a querer despues...)
"
"De que tipo son? Para hacer algo realista, la entrada y la salida deben ser de 8 bits. Lo de norm... no se.
Los grid deben ser Float, o al menos de 16 bits!"
	| fmt |
"
Y esto que puse aca supone que en memoria son de 8 bits... Y al pasar hostPointer, como le digo que convierta?????? mhhhhhh
"
	"CL_UNORM_INT8   intensity8Norm
	Desde afuera, en la memoria hay un unsigned char, 0..255.
	Pero en el kernel uso read_imagef() y write_imagef(), son floats.
	http://stackoverflow.com/questions/31718492/meaning-of-cl-unorm-int8-for-cl-image-format-image-channel-data-type-and-its-di
	"
	
	"uhhhhhhh image format not supported....
	CLImageFormatNotSupported
	
	clGetSupportedImageFormats
	supportedImageFormats: flags type: imageType ' or 3D'
	https://www.khronos.org/registry/cl/sdk/1.0/docs/man/xhtml/clGetSupportedImageFormats.html
	"
	" 
Ejecutar
OpenCLPlatform allPlatforms do: [ :platform | platform reportImageFormatsOn: Transcript ].

(	context supportedImageFormats: CL_MEM_READ_WRITE type: CL_MEM_OBJECT_IMAGE2D) do: [ :a | a print].
(	context supportedImageFormats: CL_MEM_WRITE_ONLY type: CL_MEM_OBJECT_IMAGE2D) do: [ :a | a print].
(	context supportedImageFormats: CL_MEM_READ_ONLY type: CL_MEM_OBJECT_IMAGE2D) do: [ :a | a print].
" 
"
CL_MEM_READ_WRITE
CL_MEM_WRITE_ONLY
CL_MEM_READ_ONLY
"

"
=================== 
I3 de la oficina (GPU vieja, sin OpenCL):
NO TIENE ningun formato de 8 bit por pixel!
=================== 
#(an OpenCLPlatform)
a CLImageFormatStruct(RGBA unorm-int8)
a CLImageFormatStruct(RGBA unorm-int16)
a CLImageFormatStruct(RGBA int8)
a CLImageFormatStruct(RGBA int16)
a CLImageFormatStruct(RGBA int32)
a CLImageFormatStruct(RGBA uint8)
a CLImageFormatStruct(RGBA uint16)
a CLImageFormatStruct(RGBA uint32)
a CLImageFormatStruct(RGBA half-float)
a CLImageFormatStruct(RGBA float)
a CLImageFormatStruct(BGRA unorm-int8)
a CLImageFormatStruct(Intensity float)
a CLImageFormatStruct(Luminance float)
===============================
Celeron de casa (GPU mas nueva, con OpenCL)
No tiene Intensity o Luminance, pero al menos tiene 'R uint8'
=================== 
a CLImageFormatStruct(RGBA unorm-int8)
a CLImageFormatStruct(RGBA unorm-int16)
a CLImageFormatStruct(RGBA int8)
a CLImageFormatStruct(RGBA int16)
a CLImageFormatStruct(RGBA int32)
a CLImageFormatStruct(RGBA uint8)
a CLImageFormatStruct(RGBA uint16)
a CLImageFormatStruct(RGBA uint32)
a CLImageFormatStruct(RGBA half-float)
a CLImageFormatStruct(RGBA float)
a CLImageFormatStruct(BGRA unorm-int8)
a CLImageFormatStruct(R float)
a CLImageFormatStruct(R unorm-int8)
a CLImageFormatStruct(R unorm-int16)
a CLImageFormatStruct(R int8)
a CLImageFormatStruct(R int16)
a CLImageFormatStruct(R int32)
a CLImageFormatStruct(R uint8)
a CLImageFormatStruct(R uint16)
a CLImageFormatStruct(R uint32)
a CLImageFormatStruct(R half-float)
a CLImageFormatStruct(A unorm-int8)
a CLImageFormatStruct(RG unorm-int8)
a CLImageFormatStruct(RG unorm-int16)
a CLImageFormatStruct(RG int8)
a CLImageFormatStruct(RG int16)
a CLImageFormatStruct(RG int32)
a CLImageFormatStruct(RG uint8)
a CLImageFormatStruct(RG uint16)
a CLImageFormatStruct(RG uint32)
a CLImageFormatStruct(RG half-float)
a CLImageFormatStruct(RG float)
================================
En la AMD A4-5000,
OpenCLPlatform allPlatforms do: [ :platform |
    '-----' print.
    platform name print.
    ((OpenCLContext newForDevices: platform allGPUs, platform allCPUs) supportedImageFormats: CL_MEM_READ_ONLY type: 16r10F1) do: [ :each |
        each print ]].
==================
AMD Accelerated Parallel Processing
a CLImageFormatStruct(R snorm-int8)
a CLImageFormatStruct(R snorm-int16)
a CLImageFormatStruct(R unorm-int8)
a CLImageFormatStruct(R unorm-int16)
a CLImageFormatStruct(R int8)
a CLImageFormatStruct(R int16)
a CLImageFormatStruct(R int32)
a CLImageFormatStruct(R uint8)
a CLImageFormatStruct(R uint16)
a CLImageFormatStruct(R uint32)
a CLImageFormatStruct(R half-float)
a CLImageFormatStruct(R float)
a CLImageFormatStruct(A snorm-int8)
a CLImageFormatStruct(A snorm-int16)
a CLImageFormatStruct(A unorm-int8)
a CLImageFormatStruct(A unorm-int16)
a CLImageFormatStruct(A int8)
a CLImageFormatStruct(A int16)
a CLImageFormatStruct(A int32)
a CLImageFormatStruct(A uint8)
a CLImageFormatStruct(A uint16)
a CLImageFormatStruct(A uint32)
a CLImageFormatStruct(A half-float)
a CLImageFormatStruct(A float)
a CLImageFormatStruct(RG snorm-int8)
a CLImageFormatStruct(RG snorm-int16)
a CLImageFormatStruct(RG unorm-int8)
a CLImageFormatStruct(RG unorm-int16)
a CLImageFormatStruct(RG int8)
a CLImageFormatStruct(RG int16)
a CLImageFormatStruct(RG int32)
a CLImageFormatStruct(RG uint8)
a CLImageFormatStruct(RG uint16)
a CLImageFormatStruct(RG uint32)
a CLImageFormatStruct(RG half-float)
a CLImageFormatStruct(RG float)
a CLImageFormatStruct(RGBA snorm-int8)
a CLImageFormatStruct(RGBA snorm-int16)
a CLImageFormatStruct(RGBA unorm-int8)
a CLImageFormatStruct(RGBA unorm-int16)
a CLImageFormatStruct(RGBA int8)
a CLImageFormatStruct(RGBA int16)
a CLImageFormatStruct(RGBA int32)
a CLImageFormatStruct(RGBA uint8)
a CLImageFormatStruct(RGBA uint16)
a CLImageFormatStruct(RGBA uint32)
a CLImageFormatStruct(RGBA half-float)
a CLImageFormatStruct(RGBA float)
a CLImageFormatStruct(ARGB snorm-int8)
a CLImageFormatStruct(ARGB unorm-int8)
a CLImageFormatStruct(ARGB int8)
a CLImageFormatStruct(ARGB uint8)
a CLImageFormatStruct(BGRA snorm-int8)
a CLImageFormatStruct(BGRA unorm-int8)
a CLImageFormatStruct(BGRA int8)
a CLImageFormatStruct(BGRA uint8)
a CLImageFormatStruct(Luminance snorm-int8)
a CLImageFormatStruct(Luminance snorm-int16)
a CLImageFormatStruct(Luminance unorm-int8)
a CLImageFormatStruct(Luminance unorm-int16)
a CLImageFormatStruct(Luminance half-float)
a CLImageFormatStruct(Luminance float)
a CLImageFormatStruct(Intensity snorm-int8)
a CLImageFormatStruct(Intensity snorm-int16)
a CLImageFormatStruct(Intensity unorm-int8)
a CLImageFormatStruct(Intensity unorm-int16)
a CLImageFormatStruct(Intensity half-float)
a CLImageFormatStruct(Intensity float)
a CLImageFormatStruct(RA snorm-int8)
a CLImageFormatStruct(RA snorm-int16)
a CLImageFormatStruct(RA unorm-int8)
a CLImageFormatStruct(RA unorm-int16)
a CLImageFormatStruct(RA int8)
a CLImageFormatStruct(RA int16)
a CLImageFormatStruct(RA int32)
a CLImageFormatStruct(RA uint8)
a CLImageFormatStruct(RA uint16)
a CLImageFormatStruct(RA uint32)
a CLImageFormatStruct(RA half-float)
a CLImageFormatStruct(RA float)
#(an OpenCLPlatform)
"
	
	
	fmt := CLImageFormatStruct bgra8888norm.
	fmt := CLImageFormatStruct luminance8.
"	fmt := CLImageFormatStruct r8Norm.
	fmt := CLImageFormatStruct intensityFloat."
	fmt := CLImageFormatStruct r8.
	input := context 
							newImage2D: CL_MEM_READ_ONLY
							format: fmt
							width: inputImage width
							height: inputImage height
							rowPitch: nil
							hostPointer: nil.
							


							
	resultExtent _ aResultExtent.
	outputImage _ (Smalltalk at: #FloatImage) extent: aResultExtent.
	fmt := CLImageFormatStruct intensity8Norm.
	input := context 
					newImage2D: CL_MEM_READ_ONLY "+ CL_MEM_COPY_HOST_PTR"
					format: fmt
					width: inputImage width
					height: inputImage height
					rowPitch: nil
					hostPointer: "(inputImage elements collect: [ :v | (v * 256) floor min: 255 max: 0 ] into: ByteArray)" nil.
"
	gridX := context 
					newImage2D: CL_MEM_READ_ONLY | CL_MEM_COPY_HOST_PTR
					format: fmt
					width: gridXPositions width
					height: gridXPositions height
					rowPitch: nil
					hostPointer: gridXPositions asOpenCLArg.
	gridY := context 
					newImage2D: CL_MEM_READ_ONLY | CL_MEM_COPY_HOST_PTR
					format: fmt
					width: gridYPositions width
					height: gridYPositions height
					rowPitch: nil
					hostPointer: gridYPositions asOpenCLArg.
"
	fmt := CLImageFormatStruct r8.
	result := context 
					newImage2D: CL_MEM_WRITE_ONLY
					format: fmt
					width: resultExtent x
					height: resultExtent y
					rowPitch: nil
					hostPointer: nil.
]

{ #category : 'as yet unclassified' }
DeformationGridExample >> outputImage [
^outputImage
]

{ #category : 'as yet unclassified' }
DeformationGridExample >> run [
	"Compute work sizes."
	| globalWorkSize localWorkSize |
	localWorkSize := #(16 16).  "should fit on most devices... see #maxWorkGroupSize"
	globalWorkSize := {resultExtent x. resultExtent y}.
	globalWorkSize := globalWorkSize 
							with: localWorkSize 
							collect: [:global :local | global roundUpTo: local].		
					
	"Run the two kernels to blur the image first horizontally, then vertically."
	lastEvent := queue
					runKernel: kernel
					workDim: 2
					globalOffset: #(0 0)
					globalSize: globalWorkSize
					localSize: localWorkSize 
					waitOn: lastEvent.
					
	self downloadDataFromGPU: outputImage
]

{ #category : 'as yet unclassified' }
DeformationGridExample >> sourceCode [
	"Answer the OpenCL source code for the guassian-blur program."
	"Sampleamos el resultado de manera discreta"
^'

	__constant sampler_t sampler = CLK_NORMALIZED_COORDS_FALSE | CLK_ADDRESS_CLAMP_TO_EDGE | CLK_FILTER_NEAREST;

	__kernel void resample (
			__read_only image2d_t src_image,
			__read_only image2d_t gridX_image,
			__read_only image2d_t gridY_image,
			__write_only image2d_t dst_image) {

		if (get_global_id(0) >= get_image_width(dst_image)) return;
		if (get_global_id(1) >= get_image_height(dst_image)) return;

		int2 coord = (int2)(get_global_id(0), get_global_id(1));
		float4 out = read_imagef(src_image, sampler, coord);
		write_imagef(dst_image, coord, out);
	}'
]
