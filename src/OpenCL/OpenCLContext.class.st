"
Encapsulates a CLContext, and provides convenience methods for accessing its properties.  Perhaps these methods should simply be added to CLContext, and this class deleted  (except that we apparently can't add instance variables to subclasses of ExternalStructure, and still marshal them through the FFI).
"
Class {
	#name : 'OpenCLContext',
	#superclass : 'OpenCLRefCountedObject',
	#instVars : [
		'devices'
	],
	#category : 'OpenCL',
	#package : 'OpenCL'
}

{ #category : 'instance creation' }
OpenCLContext class >> newForDevices: deviceList "of OpenCLDevices"  [
	| context allHandles result |
	
	allHandles := (deviceList collect: [:dev | dev id getHandle]) concatenation asByteArray.
	result := IntegerArray new: 1.
	context := OpenCLPrimitiveInterface current
				clCreateContext__const__cl_context_properties__ptr: nil
							cl_uint: deviceList size
							const__cl_device_id__ptr: (CLDeviceID fromHandle: allHandles)
							void__ptrpfn_notifyconst__char__ptrconst__void__ptrsize_tvoid__ptr: nil "error callback"
							void__ptr: nil "user-data for error callback"
							cl_int__ptr: result.
	result := result first.
	OpenCLError check: result text: 'failed to create context'.
	context := self wrappingHandle: context.
	context devices: deviceList.
	^context
				
]

{ #category : 'buffer creation' }
OpenCLContext >> bufferOfSize: byteSize [
	"By default, buffers are read-write."
	^self readWriteBufferOfSize: byteSize
]

{ #category : 'deprecated in OpenCL 2.0' }
OpenCLContext >> commandQueueOn: anOpenCLDevice [
	"Instantate a new OpenCLCommandQueue."
	"Deprecated in OpenCL 2.0:
	The clCreateCommandQueue function was deprecated as of OpenCL 2.0, and replaced with clCreateCommandQueueWithProperties. If you are only targeting devices that support OpenCL 2.0 (some recent Intel and AMD processors at the time of writing), you can safely use this new function.

If you need your code to run on devices that don't yet support OpenCL 2.0, you can continue using the deprecated clCreateCommandQueue function by using the preprocessor macros that the OpenCL headers provide, e.g:

#define CL_USE_DEPRECATED_OPENCL_2_0_APIS
#include <CL/cl.h>
"
	| queue result |
	result := IntegerArray new: 1.
	queue := OpenCLPrimitiveInterface current
				clCreateCommandQueue__cl_context: id 
							cl_device_id: anOpenCLDevice id
							cl_command_queue_properties: 0 "out-of-order exec seems to not work on OS X"
							cl_int__ptr: result.
	result := result first.
	OpenCLError check: result text: 'failed to create queue'.
	"Wrap the CLCommandQueue with an OpenCLCommandQueue."
	queue := OpenCLCommandQueue wrappingHandle: queue.
	queue context: self device: anOpenCLDevice.
	^queue
]

{ #category : 'buffer creation' }
OpenCLContext >> copyReadOnlyBufferFrom: bytes [
	"Create an OpenCLBuffer that is only readable.  The size and inital contents are obtained from the 'bytes' argument."
	^self newBuffer: CL_MEM_READ_ONLY copyFrom: bytes
]

{ #category : 'buffer creation' }
OpenCLContext >> copyReadWriteBufferFrom: bytes [
	"Create an OpenCLBuffer that is both readable and writable.  The size and inital contents are obtained from the 'bytes' argument."
	^self newBuffer: CL_MEM_READ_WRITE copyFrom: bytes
]

{ #category : 'buffer creation' }
OpenCLContext >> copyWriteOnlyBufferFrom: bytes [
	"Create an OpenCLBuffer that is only writable.  The size and inital contents are obtained from the 'bytes' argument."
	^self newBuffer: CL_MEM_WRITE_ONLY copyFrom: bytes
]

{ #category : 'accessing' }
OpenCLContext >> devices [
	"Answer the list of devices that this context was created with."
	^devices
]

{ #category : 'initialize' }
OpenCLContext >> devices: deviceList "Collection of OpenCLDevices" [
	"Answer the list of devices that this context was created with."
	devices := deviceList
]

{ #category : 'private' }
OpenCLContext >> externalStringFor: aString [
	| addr |
	addr := ExternalAddress allocate: aString size + 1.
	aString withIndexDo: [:char :i | addr unsignedCharAt: i put: char].
	addr unsignedByteAt: aString size + 1 put: 0.
	^addr
]

{ #category : 'private' }
OpenCLContext >> newBuffer: flags copyFrom: bytes [
	| mem result |
	result := IntegerArray new: 1.
	mem := OpenCLPrimitiveInterface current
				clCreateBuffer__cl_context: id
							cl_mem_flags: (flags+CL_MEM_COPY_HOST_PTR)
							size_t: bytes byteSize
							void__ptr: bytes
							cl_int__ptr: result.
	result := result first.
	OpenCLError check: result text: 'failed to create buffer'.
	mem := OpenCLBuffer wrappingHandle: mem.
	mem context: self byteSize: bytes byteSize.
	^mem
	
	
]

{ #category : 'private' }
OpenCLContext >> newBuffer: flags ofSize: byteSize [
	| mem result |
	result := IntegerArray new: 1.
	mem := OpenCLPrimitiveInterface current
				clCreateBuffer__cl_context: id
							cl_mem_flags: flags
							size_t: byteSize
							void__ptr: nil
							cl_int__ptr: result.
	result := result first.
	OpenCLError check: result text: 'failed to create buffer'.
	mem := OpenCLBuffer wrappingHandle: mem.
	mem context: self byteSize: byteSize.
	^mem
	
	
]

{ #category : 'private' }
OpenCLContext >> newBuffer: flags on: bytes [
	"Using a Smalltalk object from OpenCL requires pinning it.
	You might unpit it when done."
	| mem result mustPinUnpin |
	mustPinUnpin _ bytes isPinned not.
	mustPinUnpin ifTrue: [ bytes pin ].
	result := IntegerArray new: 1.
	mem := OpenCLPrimitiveInterface current
				clCreateBuffer__cl_context: id
							cl_mem_flags: (flags+CL_MEM_USE_HOST_PTR)
							size_t: bytes byteSize
							void__ptr: bytes
							cl_int__ptr: result.
	result := result first.
	OpenCLError check: result text: 'failed to create buffer'.
	mem := OpenCLBuffer wrappingHandle: mem.
	mem context: self byteSize: bytes byteSize.
	mustPinUnpin ifTrue: [
		mem smalltalkObject: bytes].
	^mem
]

{ #category : 'image creation' }
OpenCLContext >> newImage: flags format: imageFormat description: imageDescription hostPointer: hostPtr [
	"Most general image-creation method.  Basis for more specific, convenient methods."
	| mem result |
	result := IntegerArray new: 1.
	mem := OpenCLPrimitiveInterface current
				clCreateImage__cl_context: id
							cl_mem_flags: flags
							const__cl_image_format__ptr: imageFormat
							const__cl_image_desc__ptr: imageDescription
							void__ptr: hostPtr asOpenCLArg
							cl_int__ptr: result.
	result := result first.
	OpenCLError check: result text: 'failed to instantiate image. image_desc: ', imageDescription printString.

	imageDescription image_type = CL_MEM_OBJECT_IMAGE2D ifTrue: [
		mem := OpenCLImage2D wrappingHandle: mem.
		mem context: self format: imageFormat width: imageDescription image_width height: imageDescription image_height rowPitch: imageDescription image_row_pitch.
		^mem ].

	self error: 'Support this case here!'
]

{ #category : 'deprecated in OpenCL 1.2' }
OpenCLContext >> newImage2D: flags format: imageFormat width: width height: height rowPitch: rowPitch hostPointer: hostPtr [
	"Most general 2D image-creation method.  Basis for more specific, convenient methods."
	"Deprecated in OpenCL1.2:
	clCreateImage2D and clCreateImage3D have been merged into clCreateImage"
	| mem result |
	result := IntegerArray new: 1.
	mem := OpenCLPrimitiveInterface current
				clCreateImage2D__cl_context: id
							cl_mem_flags: flags
							const__cl_image_format__ptr: imageFormat
							size_t: width
							size_t: height
							size_t: rowPitch
							void__ptr: hostPtr
							cl_int__ptr: result.
	result := result first.
	OpenCLError check: result text: 'failed to instantiate 2D image'.
	mem := OpenCLImage2D wrappingHandle: mem.
	mem context: self format: imageFormat width: width height: height rowPitch: rowPitch.
	^mem
]

{ #category : 'deprecated in OpenCL 1.2' }
OpenCLContext >> newImage3D: flags format: imageFormat width: width height: height depth: depth rowPitch: rowPitch slicePitch: slicePitch hostPointer: hostPtr [
	"Most general 3D image-creation method.  Basis for more specific, convenient methods."
	"Deprecated in OpenCL1.2:
	clCreateImage2D and clCreateImage3D have been merged into clCreateImage"
	| mem result |
	result := IntegerArray new: 1.
	mem := OpenCLPrimitiveInterface current
				clCreateImage3D__cl_context: id
							cl_mem_flags: flags
							const__cl_image_format__ptr: imageFormat
							size_t: width
							size_t: height
							size_t: depth
							size_t: rowPitch
							size_t: slicePitch
							void__ptr: hostPtr
							cl_int__ptr: result.
	result := result first.
	OpenCLError check: result text: 'failed to instantiate 3D image'.
	mem := OpenCLImage3D wrappingHandle: mem.
	mem 
		context: self 
		format: imageFormat 
		width: width 
		height: height 
		depth: depth 
		rowPitch: rowPitch 
		slicePitch: slicePitch.
	^mem
]

{ #category : 'sampler creation' }
OpenCLContext >> normalizedLinearSampler: addressingMode [
	^self sampler: true addressing: addressingMode filter: CL_FILTER_LINEAR
]

{ #category : 'sampler creation' }
OpenCLContext >> normalizedNearestSampler: addressingMode [
	^self sampler: true addressing: addressingMode filter: CL_FILTER_NEAREST
]

{ #category : 'private' }
OpenCLContext >> privateDestroy [
	"Nothing needs to be done."
]

{ #category : 'program creation' }
OpenCLContext >> programWithSource: stringOrListOfStrings [
	| strings pointers program result  |
	
	"Easier if we uniformly deal with a list of strings."
	stringOrListOfStrings isString
		ifTrue: [strings := {stringOrListOfStrings}]
		ifFalse: [strings := stringOrListOfStrings].
		
	"Transform the strings into null-terminated strings on the C heap."
	strings := strings collect: [:s | self externalStringFor: s].
	
	"Put all string pointers into a single list."
	pointers := WriteStream on: (ByteArray new: strings size * Smalltalk wordSize).
	strings do: [:s | pointers nextPutAll: s].
	pointers := pointers contents.
	
	"Make the OpenCL API call to create the program."
	result := IntegerArray new: 1.
	[program := OpenCLPrimitiveInterface current
					clCreateProgramWithSource__cl_context: id
								cl_uint: strings size
								const__char__ptr__ptr: pointers
								const__size_t__ptr: nil "null-terminated, so no lengths necessary"
								cl_int__ptr: result.
	] ensure: [strings do: [:s | s free]].				
	result := result first.
	OpenCLError check: result text: 'failed to instantiate program'.
	program := OpenCLProgram wrappingHandle: program.
	program context: self sourceCode: stringOrListOfStrings.
	^program
	
]

{ #category : 'buffer creation' }
OpenCLContext >> readOnlyBufferOfSize: byteSize [
	"Create an OpenCLBuffer that is only readable."
	^self newBuffer: CL_MEM_READ_ONLY ofSize: byteSize
]

{ #category : 'buffer creation' }
OpenCLContext >> readOnlyBufferOn: bytes [
	"Create an OpenCLBuffer that is only readable. It will work directly on the contents of the 'bytes' argument.
	The 'bytes' argument will be pinned as long as this buffer exists."
	^self newBuffer: CL_MEM_READ_ONLY on: bytes
]

{ #category : 'buffer creation' }
OpenCLContext >> readWriteBufferOfSize: byteSize [
	"Create an OpenCLBuffer that is both readable and writeable."
	^self newBuffer: CL_MEM_READ_WRITE ofSize: byteSize
]

{ #category : 'buffer creation' }
OpenCLContext >> readWriteBufferOn: bytes [
	"Create an OpenCLBuffer that is both readable and writable. It will work directly on the contents of the 'bytes' argument.
	The 'bytes' argument will be pinned as long as this buffer exists."
	^self newBuffer: CL_MEM_READ_WRITE on: bytes
]

{ #category : 'report' }
OpenCLContext >> reportImageFormatsOn: aStream [
	"
	OpenCLPlatform allPlatforms do: [ :platform | platform reportOn: Transcript ].
	"
	aStream nextPutAll: 'Image Formats for devices: { ['.
	self devices do: [ :device | aStream nextPutAll: device name ] separatedBy: [ aStream nextPutAll: '], [' ].
	aStream nextPutAll: '] }'; newLine.
	aStream nextPutAll: '--- Image formats for CL_MEM_READ_WRITE ---'; newLine.
	(self supportedImageFormats: 1 "CL_MEM_READ_WRITE" type: 16r10F1"CL_MEM_OBJECT_IMAGE2D") do: [ :each |
		aStream nextPutAll: each printString; newLine ].
	aStream nextPutAll: '--- Image formats for CL_MEM_WRITE_ONLY ---'; newLine.
	(self supportedImageFormats: 2 "CL_MEM_WRITE_ONLY" type: 16r10F1"CL_MEM_OBJECT_IMAGE2D") do: [ :each | 
		aStream nextPutAll: each printString; newLine ].
	aStream nextPutAll: '--- Image formats for CL_MEM_READ_ONLY ---'; newLine.
	(self supportedImageFormats: 4 "CL_MEM_READ_ONLY" type: 16r10F1"CL_MEM_OBJECT_IMAGE2D") do: [ :each |
		aStream nextPutAll: each printString; newLine ]
]

{ #category : 'deprecated in OpenCL 2.0' }
OpenCLContext >> sampler: useNormalizedCoords addressing: addressingMode filter: filterMode [
	"Most general sampler-creation method."
	"Deprecated in OpenCL 2.0
	Replaced with clCreateSamplerWithProperties
	"
	| sampler result |
	result := IntegerArray new: 1.
	sampler := OpenCLPrimitiveInterface current
				clCreateSampler__cl_context: id
							cl_bool: (useNormalizedCoords ifTrue: [CL_TRUE] ifFalse: [CL_FALSE])
							cl_addressing_mode: addressingMode
							cl_filter_mode: filterMode
							cl_int__ptr: result.
	result := result first.
	OpenCLError check: result text: 'failed to instantiate sampler'.
	sampler := OpenCLSampler wrappingHandle: sampler.
	sampler context: self normalized: useNormalizedCoords addressing: addressingMode filter: filterMode.
	^sampler
]

{ #category : 'image creation' }
OpenCLContext >> supportedImageFormats: flags type: imageType "CL_MEM_OBJECT_IMAGE2D or 3D" [
	| result maxResults numResults bytes byteSize |
	maxResults := 200.  "The maximum number of results... bump this up if necessary."
	numResults := IntegerArray new: 1.
	byteSize := CLImageFormatStruct byteSize.
	bytes := ByteArray new: (maxResults * byteSize).
	result := OpenCLPrimitiveInterface current
				clGetSupportedImageFormats__cl_context: id
							cl_mem_flags: flags
							cl_mem_object_type: imageType
							cl_uint: maxResults
							cl_image_format__ptr: (CLImageFormatStruct new setHandle: bytes)
							cl_uint__ptr: numResults.
	OpenCLError check: result text: 'failed to obtain supported image formats'.
	
	"Construct a list of CLImageFormatStructs to return."
	numResults := numResults first.
	^(1 to: numResults) collect: [:i |
		| struct |
		struct := CLImageFormatStruct new.
		struct image_channel_order: (bytes unsignedLongAt: (i-1*byteSize+1)).
		struct image_channel_data_type: (bytes unsignedLongAt: (i-1*byteSize+1+(byteSize/2))).
	]
	

	
]

{ #category : 'sampler creation' }
OpenCLContext >> unnormalizedLinearSampler: addressingMode [
	^self sampler: false addressing: addressingMode filter: CL_FILTER_LINEAR
]

{ #category : 'sampler creation' }
OpenCLContext >> unnormalizedNearestSampler: addressingMode [
	^self sampler: false addressing: addressingMode filter: CL_FILTER_NEAREST
]

{ #category : 'buffer creation' }
OpenCLContext >> writeOnlyBufferOfSize: byteSize [
	"Create an OpenCLBuffer that is only writeable."
	^self newBuffer: CL_MEM_WRITE_ONLY ofSize: byteSize
]

{ #category : 'buffer creation' }
OpenCLContext >> writeOnlyBufferOn: bytes [
	"Create an OpenCLBuffer that is only readable. It will work directly on the contents of the 'bytes' argument.
	The 'bytes' argument will be pinned as long as this buffer exists."
	^self newBuffer: CL_MEM_WRITE_ONLY on: bytes
]
