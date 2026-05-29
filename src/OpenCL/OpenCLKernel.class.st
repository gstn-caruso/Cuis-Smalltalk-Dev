Class {
	#name : 'OpenCLKernel',
	#superclass : 'OpenCLRefCountedObject',
	#instVars : [
		'program'
	],
	#category : 'OpenCL',
	#package : 'OpenCL'
}

{ #category : 'private' }
OpenCLKernel >> argAt: index put: arg size: byteSize [
	"Please don't use. Prefer the type specific methods in category 'arguments'"

	| result | 
	result := OpenCLPrimitiveInterface current
				clSetKernelArg__cl_kernel: id
							cl_uint: index
							size_t: byteSize
							const__void__ptr: arg asOpenCLArg.
	OpenCLError check: result text: 'failed to set kernel argument ', index printString.
]

{ #category : 'private' }
OpenCLKernel >> argAt: index putBytesOf: anObject [
	"To be used with arguments other than OpenCL images and buffers.
	That is, to be used, for example with arguments declared in the OpenCL kernel as:
		int, float, double, float4, double4, etc.
	Usually prefer one of the type specific methods, such as argAt:putDouble:
	
	Takes bytes right away. No problem if openCLArg is moved or collected."

	| openCLArg result |
	openCLArg _ anObject asOpenCLArg.
	result _ OpenCLPrimitiveInterface current
				clSetKernelArg__cl_kernel: id
							cl_uint: index
							size_t: openCLArg byteSize 	"Size of the object. Number of bytes to be passed on the stack."
							const__void__ptr: openCLArg.
	OpenCLError check: result text: 'failed to set kernel argument ', index printString
]

{ #category : 'arguments' }
OpenCLKernel >> argAt: index putDouble: aNumber [
	"To be used with arguments declared in OpenCL as double.
	They are 64 bit floating point.

	Argument to this method is a Smalltalk object. Argument passed to #argAt:putBytesOf: is also a Smalltalk object.
	Given that bytes are copied right away, there's no problem with Garbage Collection moving or reclaiming them."

	^ self argAt: index putBytesOf: aNumber asFloat
]

{ #category : 'arguments' }
OpenCLKernel >> argAt: index putDouble4: aCollectionOfNumbers [
	"To be used with arguments declared in OpenCL as double4.
	They are 4 64 bit floating point numbers together.

	Argument to this method is a Smalltalk object. Argument passed to #argAt:putBytesOf: is also a Smalltalk object.
	Given that bytes are copied right away, there's no problem with Garbage Collection moving or reclaiming them."

	^ self argAt: index putBytesOf: (Float64Array new: 4 from: aCollectionOfNumbers)
]

{ #category : 'arguments' }
OpenCLKernel >> argAt: index putFloat: aNumber [
	"To be used with arguments declared in OpenCL as float.
	They are 32 bit floating point.

	Argument to this method is a Smalltalk object. Argument passed to #argAt:putBytesOf: is also a Smalltalk object.
	Given that bytes are copied right away, there's no problem with Garbage Collection moving or reclaiming them."

	^ self argAt: index putBytesOf: (Float32Array with: aNumber asFloat)
]

{ #category : 'arguments' }
OpenCLKernel >> argAt: index putFloat2: aCollectionOfNumbers [
	"To be used with arguments declared in OpenCL as float2.
	They are 2 32 bit floating point numbers together.

	Argument to this method is a Smalltalk object. Argument passed to #argAt:putBytesOf: is also a Smalltalk object.
	Given that bytes are copied right away, there's no problem with Garbage Collection moving or reclaiming them."

	^ self argAt: index putBytesOf: (Float32Array new: 2 from: aCollectionOfNumbers)
]

{ #category : 'arguments' }
OpenCLKernel >> argAt: index putFloat4: aCollectionOfNumbers [
	"To be used with arguments declared in OpenCL as float4.
	They are 4 32 bit floating point numbers together.

	Argument to this method is a Smalltalk object. Argument passed to #argAt:putBytesOf: is also a Smalltalk object.
	Given that bytes are copied right away, there's no problem with Garbage Collection moving or reclaiming them."

	^ self argAt: index putBytesOf: (Float32Array new: 4 from: aCollectionOfNumbers)
]

{ #category : 'arguments' }
OpenCLKernel >> argAt: index putInt: aNumber [
	"To be used with arguments declared in OpenCL as int.
	They are 32 bit signed integer.

	Argument to this method is a Smalltalk object. Argument passed to #argAt:putBytesOf: is also a Smalltalk object.
	Given that bytes are copied right away, there's no problem with Garbage Collection moving or reclaiming them."

	^ self argAt: index putBytesOf: (IntegerArray with: aNumber)
]

{ #category : 'arguments' }
OpenCLKernel >> argAt: index putPointer: anOpenCLContextObject [
	"To be used with arguments that are OpenCL images and buffers: OpenCLImage2D, OpenCLImage3D, OpenCLBuffer.
	That is, to be used, for example with arguments declared in the OpenCL kernel as:
		image2d_t
		float*
		etc.
	For things like float*, remember to create an OpenCLBuffer of approriate size, copy values back and forth as needed, etc.
	anOpenCLContextObject must be an OpenCLContextObject and not a regular Smalltalk object, as a Smalltalk object could
	be moved or collected, and the pointer become invalid.
	
	It could be possible to use ExternalObject. No experiments done yet, though.
	
	With a VM that supports pinned objects (Spur, someday?), thouse would be suitable too."

	| openCLArg result |
	openCLArg _ anOpenCLContextObject asOpenCLArg.
	result _ OpenCLPrimitiveInterface current
				clSetKernelArg__cl_kernel: id
							cl_uint: index
							size_t: Smalltalk wordSize 						"The size of the pointer. Number of bytes to be passed on the stack."
							const__void__ptr: openCLArg.
	OpenCLError check: result text: 'failed to set kernel argument ', index printString
]

{ #category : 'arguments' }
OpenCLKernel >> argAt: index putUnsignedInt: aNumber [
	"To be used with arguments declared in OpenCL as int.
	They are 32 bit unsigned integer.

	Argument to this method is a Smalltalk object. Argument passed to #argAt:putBytesOf: is also a Smalltalk object.
	Given that bytes are copied right away, there's no problem with Garbage Collection moving or reclaiming them."

	^ self argAt: index putBytesOf: (WordArray with: aNumber)
]

{ #category : 'accessing' }
OpenCLKernel >> context [
	^program context
]

{ #category : 'private' }
OpenCLKernel >> privateDestroy [
	program := nil.
	
]

{ #category : 'accessing' }
OpenCLKernel >> program [
	^program
]

{ #category : 'initialize' }
OpenCLKernel >> program: anOpenCLProgram [
	"Set the program that this kernel was created for."
	program := anOpenCLProgram.
]
