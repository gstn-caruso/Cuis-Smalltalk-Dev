"
Encapsulates a CLDeviceID, and provides convenience methods for accessing its properties.  Perhaps these methods should simply be added to CLDeviceID, and this class deleted (except that we apparently can't add instance variables to subclasses of ExternalStructure, and still marshal them through the FFI)..
"
Class {
	#name : 'OpenCLDevice',
	#superclass : 'OpenCLObject',
	#instVars : [
		'platform',
		'extensions'
	],
	#category : 'OpenCL',
	#package : 'OpenCL'
}

{ #category : 'accessing' }
OpenCLDevice >> addressBits [
	"Get the CL_DEVICE_ADDRESS_BITS property: the default compute device address space size specified as an unsigned integer value in bits. Currently supported values are 32 or 64 bits."
	| buf |
	buf := IntegerArray new: 1.
	self getDeviceInfoParameter: CL_DEVICE_ADDRESS_BITS into: buf.
	^buf first
]

{ #category : 'private' }
OpenCLDevice >> bitfieldProperty: property [
	"Get the specified property of type cl_bitfield (or a subtype)."
	^self ulongProperty: property
]

{ #category : 'private' }
OpenCLDevice >> booleanProperty: property [
	"Get the boolean device property:  'true' if the device is available and 'false' if the device is not available."
	| buf bool |
	buf := IntegerArray new: 1.
	self getDeviceInfoParameter: property into: buf.
	bool := buf first.
	bool == CL_TRUE ifTrue: [^true].
	bool == CL_FALSE ifTrue: [^false].
	self error: 'failed to obtain boolean device property'
]

{ #category : 'accessing' }
OpenCLDevice >> canExecuteKernel [
	^((self bitfieldProperty: CL_DEVICE_EXECUTION_CAPABILITIES) bitAnd: CL_EXEC_KERNEL) > 0
]

{ #category : 'accessing' }
OpenCLDevice >> canExecuteNativeKernel [
	^((self bitfieldProperty: CL_DEVICE_EXECUTION_CAPABILITIES) bitAnd: CL_EXEC_NATIVE_KERNEL) > 0
]

{ #category : 'accessing' }
OpenCLDevice >> canQueueEnableProfiling [
	^(self queueProperties bitAnd: CL_QUEUE_PROFILING_ENABLE) > 0

]

{ #category : 'accessing' }
OpenCLDevice >> canQueueOutOfOrder [
	^(self queueProperties bitAnd: CL_QUEUE_OUT_OF_ORDER_EXEC_MODE_ENABLE) > 0

]

{ #category : 'accessing' }
OpenCLDevice >> doublePrecisionConfig [
	self notYetImplemented. "CLDeviceDoubleFpConfig is in an extension header file"
	"^self floatingPointPrecisionConfig: CLDeviceDoubleFpConfig"

]

{ #category : 'accessing' }
OpenCLDevice >> driverVersion [
	"OpenCL software driver version string in the form major_number.minor_number."
	^self stringProperty: CL_DRIVER_VERSION
]

{ #category : 'accessing' }
OpenCLDevice >> extensions [
	^extensions ifNil: [
		| buf size |
		buf := String new: 10000.
		size := self getDeviceInfoParameter: CL_DEVICE_EXTENSIONS into: buf.
		(buf at: size) codePoint = 0 ifTrue: [size := size - 1 "strip off terminal NULL"].
		extensions := (buf first: size) findTokens: Character space.
	].

]

{ #category : 'private' }
OpenCLDevice >> floatingPointPrecisionConfig: precision "CLDevice[Single|Double|Half]FpConfig" [
	"Get the specified property, one of CL_DEVICE_SINGLE_FP_CONFIG, CL_DEVICE_DOUBLE_FP_CONFIG, or CL_DEVICE_HALF_FP_CONFIG. property.  Answer a bit-field that describes the OPTIONAL double precision floating-point capability of the OpenCL device. This is a bit-field that describes one or more of the following values:
	CL_FP_DENORM - denorms are supported.
	CL_FP_INF_NAN - INF and NaNs are supported.
	CL_FP_ROUND_TO_NEAREST - round to nearest even rounding mode supported.
	CL_FP_ROUND_TO_ZERO - round to zero rounding mode supported.
	CL_FP_ROUND_TO_INF - round to +ve and -ve infinity rounding modes supported.
	CP_FP_FMA - IEEE754-2008 fused multiply-add is supported."
	| buf isBigEndian |
	buf := ByteArray new: 8.
	self getDeviceInfoParameter: precision into: buf.
	isBigEndian := Smalltalk isBigEndian.
	^ ((buf uint32At: 5 bigEndian: isBigEndian) bitShift: 32) +
		(buf uint32At: 1 bigEndian: isBigEndian)
]

{ #category : 'private' }
OpenCLDevice >> getDeviceInfoParameter: param "cl_device_info" into: buf "String, IntegerArray, etc." [
	"Read the specified parameter into 'buf'.  Answer the size (in bytes) of the data stored into 'buf'."
	| result size |
	size := IntegerArray new: 1.
	result := OpenCLPrimitiveInterface current
			clGetDeviceInfo__cl_device_id: id
						cl_device_info: param
						size_t: buf byteSize
						void__ptr: buf
						size_t__ptr: size.
	result == CL_SUCCESS ifFalse: [OpenCLError signal: 'failed to get device info' code: result].
	^size first
]

{ #category : 'accessing' }
OpenCLDevice >> globalMemCacheSize [
	"Size of global memory cache in bytes."
	^self ulongProperty: CL_DEVICE_GLOBAL_MEM_SIZE
]

{ #category : 'accessing' }
OpenCLDevice >> globalMemCacheType [
	"Type of global memory cache supported. Valid values are: CL_NONE, CL_READ_ONLY_CACHE, and CL_READ_WRITE_CACHE."
	^self uintProperty: CL_DEVICE_GLOBAL_MEM_CACHE_TYPE
]

{ #category : 'accessing' }
OpenCLDevice >> globalMemCachelineSize [
	"Size of global memory cache line in bytes."
	^self uintProperty: CL_DEVICE_GLOBAL_MEM_CACHELINE_SIZE
	
]

{ #category : 'accessing' }
OpenCLDevice >> globalMemSize [
	"Size of global device memory in bytes"
	^self ulongProperty: CL_DEVICE_GLOBAL_MEM_SIZE
	
]

{ #category : 'accessing' }
OpenCLDevice >> halfPrecisionConfig [
	self notYetImplemented. "CLDeviceHalfFpConfig is in an extension header file"
	"^self floatingPointPrecisionConfig: CLDeviceHalfFpConfig"

]

{ #category : 'accessing' }
OpenCLDevice >> hasImageSupport [
	"Is CL_TRUE if images are supported by the OpenCL device and CL_FALSE otherwise."
	^self booleanProperty: CL_DEVICE_IMAGE_SUPPORT
]

{ #category : 'accessing' }
OpenCLDevice >> image2dMaxHeight [
	"Max height of 2D image in pixels. The minimum value is 8192 if CL_DEVICE_IMAGE_SUPPORT is CL_TRUE."
	^self sizetProperty: CL_DEVICE_IMAGE2D_MAX_HEIGHT
]

{ #category : 'accessing' }
OpenCLDevice >> image2dMaxWidth [
	"Max width of 2D image in pixels. The minimum value is 8192 if CL_DEVICE_IMAGE_SUPPORT is CL_TRUE."
	^self sizetProperty: CL_DEVICE_IMAGE2D_MAX_WIDTH
]

{ #category : 'accessing' }
OpenCLDevice >> image3dMaxDepth [
	"Max depth of 3D image in pixels. The minimum value is 2048 if CL_DEVICE_IMAGE_SUPPORT is CL_TRUE."
	^self sizetProperty: CL_DEVICE_IMAGE3D_MAX_DEPTH
]

{ #category : 'accessing' }
OpenCLDevice >> image3dMaxHeight [
	"Max height of 3D image in pixels. The minimum value is 2048 if CL_DEVICE_IMAGE_SUPPORT is CL_TRUE."
	^self sizetProperty: CL_DEVICE_IMAGE3D_MAX_HEIGHT
]

{ #category : 'accessing' }
OpenCLDevice >> image3dMaxWidth [
	"Max width of 3D image in pixels. The minimum value is 2048 if CL_DEVICE_IMAGE_SUPPORT is CL_TRUE."
	^self sizetProperty: CL_DEVICE_IMAGE3D_MAX_WIDTH
]

{ #category : 'accessing' }
OpenCLDevice >> isAvailable [
	"Get the CL_DEVICE_AVAILABLE property:  'true' if the device is available and 'false' if the device is not available."
	^self booleanProperty: CL_DEVICE_AVAILABLE
]

{ #category : 'accessing' }
OpenCLDevice >> isCompilerAvailable [
	"Get the CL_DEVICE_COMPILER_AVAILABLE property:  Is 'false' if the implementation does not have a compiler available to compile the program source. Is 'true' if the compiler is available. This can be 'false' for the embededed platform profile only."
	^self booleanProperty: CL_DEVICE_COMPILER_AVAILABLE
]

{ #category : 'accessing' }
OpenCLDevice >> isLittleEndian [
	"Get the CL_DEVICE_ENDIAN_LITTLE property:  Is 'true' if the OpenCL device is a little endian device and 'false' otherwise.."
	^self booleanProperty: CL_DEVICE_ENDIAN_LITTLE
]

{ #category : 'accessing' }
OpenCLDevice >> localMemSize [
	"Size of local memory arena in bytes. The minimum value is 16 KB."
	^self ulongProperty: CL_DEVICE_LOCAL_MEM_SIZE
	
]

{ #category : 'accessing' }
OpenCLDevice >> localMemType [
	"Type of local memory supported. This can be set to CL_LOCAL implying dedicated local memory storage such as SRAM, or CL_GLOBAL."
	^self uintProperty: CL_DEVICE_LOCAL_MEM_TYPE
]

{ #category : 'accessing' }
OpenCLDevice >> maxClockFrequency [
	"Maximum configured clock frequency of the device in MHz."
	^self uintProperty: CL_DEVICE_MAX_CLOCK_FREQUENCY
]

{ #category : 'accessing' }
OpenCLDevice >> maxComputeUnits [
	"The number of parallel compute cores on the OpenCL device. The minimum value is 1."
	^self uintProperty: CL_DEVICE_MAX_COMPUTE_UNITS
]

{ #category : 'accessing' }
OpenCLDevice >> maxConstantArgs [
	"Max number of arguments declared with the __constant qualifier in a kernel. The minimum value is 8."
	^self uintProperty: CL_DEVICE_MAX_CONSTANT_ARGS
]

{ #category : 'accessing' }
OpenCLDevice >> maxConstantBufferSize [
	"Max size in bytes of a constant buffer allocation. The minimum value is 64 KB."
	^self ulongProperty: CL_DEVICE_MAX_CONSTANT_BUFFER_SIZE
]

{ #category : 'accessing' }
OpenCLDevice >> maxMemAllocSize [
	"Max size of memory object allocation in bytes. The minimum value is max (1/4th of CL_DEVICE_GLOBAL_MEM_SIZE, 128*1024*1024)"
	^self ulongProperty: CL_DEVICE_MAX_MEM_ALLOC_SIZE
]

{ #category : 'accessing' }
OpenCLDevice >> maxParameterSize [
	"Max size in bytes of the arguments that can be passed to a kernel. The minimum value is 256."
	^self sizetProperty: CL_DEVICE_MAX_PARAMETER_SIZE
]

{ #category : 'accessing' }
OpenCLDevice >> maxReadImageArgs [
	"Max number of simultaneous image objects that can be read by a kernel. The minimum value is 128 if CL_DEVICE_IMAGE_SUPPORT is CL_TRUE."
	^self uintProperty: CL_DEVICE_MAX_READ_IMAGE_ARGS
]

{ #category : 'accessing' }
OpenCLDevice >> maxSamplers [
	"Maximum number of samplers that can be used in a kernel. The minimum value is 16 if CL_DEVICE_IMAGE_SUPPORT is CL_TRUE. (Also see sampler_t.)"
	^self uintProperty: CL_DEVICE_MAX_SAMPLERS
]

{ #category : 'accessing' }
OpenCLDevice >> maxWorkGroupSize [
	"Maximum number of work-items in a work-group executing a kernel using the data parallel execution model. (Refer to clEnqueueNDRangeKernel). The minimum value is 1."
	^self sizetProperty: CL_DEVICE_MAX_WORK_GROUP_SIZE
]

{ #category : 'accessing' }
OpenCLDevice >> maxWorkItemDimensions [
	"Maximum dimensions that specify the global and local work-item IDs used by the data parallel execution model. (Refer to clEnqueueNDRangeKernel). The minimum value is 3."
	^self uintProperty: CL_DEVICE_MAX_WORK_ITEM_DIMENSIONS
]

{ #category : 'accessing' }
OpenCLDevice >> maxWorkItemSizes [
	"Maximum number of work-items that can be specified in each dimension of the work-group to clEnqueueNDRangeKernel.

Returns n size_t entries, where n is the value returned by the query for CL_DEVICE_MAX_WORK_ITEM_DIMENSIONS. The minimum value is (1, 1, 1)."
	| buf | 
Smalltalk wordSize = 8 ifTrue: [
	buf := ByteArray new: 24.
	self getDeviceInfoParameter: CL_DEVICE_MAX_WORK_ITEM_SIZES into: buf.
	^#(1 9 17) 
		collect: [:i | buf uint64At: i bigEndian: Smalltalk isBigEndian].
].
	buf := ByteArray new: 12.
	self getDeviceInfoParameter: CL_DEVICE_MAX_WORK_ITEM_SIZES into: buf.
	^#(1 5 9) 
		collect: [:i | buf uint32At: i bigEndian: Smalltalk isBigEndian].
	
]

{ #category : 'accessing' }
OpenCLDevice >> maxWriteImageArgs [
	"Max number of simultaneous image objects that can be written to by a kernel. The minimum value is 8 if CL_DEVICE_IMAGE_SUPPORT is CL_TRUE."
	^self uintProperty: CL_DEVICE_MAX_WRITE_IMAGE_ARGS
]

{ #category : 'accessing' }
OpenCLDevice >> memBaseAddrAlign [
	"Describes the alignment in bits of the base address of any allocated memory object."
	^self uintProperty: CL_DEVICE_MEM_BASE_ADDR_ALIGN
]

{ #category : 'accessing' }
OpenCLDevice >> minDataTypeAlignSize [
	"The smallest alignment in bytes which can be used for any data type."
	^self uintProperty: CL_DEVICE_MIN_DATA_TYPE_ALIGN_SIZE
]

{ #category : 'accessing' }
OpenCLDevice >> name [
	"Device name string."
	^self stringProperty: CL_DEVICE_NAME
]

{ #category : 'accessing' }
OpenCLDevice >> platform [
	"The platform associated with this device (cached during initialization)."
	^platform
	
]

{ #category : 'initialize' }
OpenCLDevice >> platform: anOpenCLPlatform [
	platform := anOpenCLPlatform
]

{ #category : 'accessing' }
OpenCLDevice >> preferredVectorWidthChar [
	"Preferred native vector width size for built-in scalar types that can be put into vectors. The vector width is defined as the number of scalar elements that can be stored in the vector."
	^self uintProperty: CL_DEVICE_PREFERRED_VECTOR_WIDTH_CHAR
]

{ #category : 'accessing' }
OpenCLDevice >> preferredVectorWidthDouble [
	"Preferred native vector width size for built-in scalar types that can be put into vectors. The vector width is defined as the number of scalar elements that can be stored in the vector.

If the cl_khr_fp64 extension is not supported, CL_DEVICE_PREFERRED_VECTOR_WIDTH_DOUBLE must return 0."
	^self uintProperty: CL_DEVICE_PREFERRED_VECTOR_WIDTH_DOUBLE
]

{ #category : 'accessing' }
OpenCLDevice >> preferredVectorWidthFloat [
	"Preferred native vector width size for built-in scalar types that can be put into vectors. The vector width is defined as the number of scalar elements that can be stored in the vector."
	^self uintProperty: CL_DEVICE_PREFERRED_VECTOR_WIDTH_FLOAT
]

{ #category : 'accessing' }
OpenCLDevice >> preferredVectorWidthInt [
	"Preferred native vector width size for built-in scalar types that can be put into vectors. The vector width is defined as the number of scalar elements that can be stored in the vector."
	^self uintProperty: CL_DEVICE_PREFERRED_VECTOR_WIDTH_INT
]

{ #category : 'accessing' }
OpenCLDevice >> preferredVectorWidthLong [
	"Preferred native vector width size for built-in scalar types that can be put into vectors. The vector width is defined as the number of scalar elements that can be stored in the vector."
	^self uintProperty: CL_DEVICE_PREFERRED_VECTOR_WIDTH_LONG
]

{ #category : 'accessing' }
OpenCLDevice >> preferredVectorWidthShort [
	"Preferred native vector width size for built-in scalar types that can be put into vectors. The vector width is defined as the number of scalar elements that can be stored in the vector."
	^self uintProperty: CL_DEVICE_PREFERRED_VECTOR_WIDTH_SHORT
]

{ #category : 'printing' }
OpenCLDevice >> printOn: aStream [
	super printOn: aStream.
	aStream nextPut: $(; print: self name; nextPut:$)
]

{ #category : 'accessing' }
OpenCLDevice >> profile [
	"OpenCL profile string. Returns the profile name supported by the device (see note). The profile name returned can be one of the following strings:

FULL_PROFILE - if the device supports the OpenCL specification (functionality defined as part of the core specification and does not require any extensions to be supported).

EMBEDDED_PROFILE - if the device supports the OpenCL embedded profile."
	^self stringProperty: CL_DEVICE_PROFILE
]

{ #category : 'accessing' }
OpenCLDevice >> profilingTimerResolution [
	"Describes the resolution of device timer. This is measured in nanoseconds."
	^self sizetProperty: CL_DEVICE_PROFILING_TIMER_RESOLUTION
]

{ #category : 'accessing' }
OpenCLDevice >> queueProperties [
	"Describes the command-queue properties supported by the device. This is a bit-field that describes one or more of the following values:
	CL_QUEUE_OUT_OF_ORDER_EXEC_MODE_ENABLE
	CL_QUEUE_PROFILING_ENABLE
These properties are described in the table for clCreateCommandQueue. The mandated minimum capability is CL_QUEUE_PROFILING_ENABLE."
	^self bitfieldProperty: CL_DEVICE_QUEUE_PROPERTIES
]

{ #category : 'report' }
OpenCLDevice >> reportExtensionsOn: aStream [
	"
	OpenCLPlatform allPlatforms do: [ :platform | platform reportOn: Transcript ].
	"
	aStream nextPutAll: 'Extensions: '; newLine.
	self extensions do: [ :extension | aStream nextPut: $	 ; nextPutAll: extension; newLine ]
]

{ #category : 'report' }
OpenCLDevice >> reportGeneralOn: aStream [
	"
	OpenCLPlatform allPlatforms do: [ :platform | platform reportOn: Transcript ].
	"

	aStream nextPutAll: 'Device id: '.
	id getHandle printOn: aStream.
	aStream newLine.
	aStream nextPutAll: 'Name: '; nextPutAll: self name; newLine.
	aStream nextPutAll: 'Vendor: '; nextPutAll: self vendor; newLine.
	aStream nextPutAll: 'DriverVersion: '; nextPutAll: self driverVersion printString; newLine.
	aStream nextPutAll: 'MaxComputeUnits: '; nextPutAll: self maxComputeUnits printString; newLine.
	aStream nextPutAll: 'Version: '; nextPutAll: self version; newLine.

	aStream nextPutAll: 'AddressBits: '; nextPutAll: self addressBits printString; newLine.
	aStream nextPutAll: 'CanExecuteKernel: '; nextPutAll: self canExecuteKernel printString; newLine.
	aStream nextPutAll: 'CanExecuteNativeKernel: '; nextPutAll: self canExecuteNativeKernel printString; newLine.
	aStream nextPutAll: 'CanQueueEnableProfiling: '; nextPutAll: self canQueueEnableProfiling printString; newLine.
	aStream nextPutAll: 'CanQueueOutOfOrder: '; nextPutAll: self canQueueOutOfOrder printString; newLine.
	aStream nextPutAll: 'GlobalMemCacheSize: '; nextPutAll: self globalMemCacheSize printStringAsBytes; newLine.
	aStream nextPutAll: 'GlobalMemCacheType: '; nextPutAll: self globalMemCacheType printString; newLine.
	aStream nextPutAll: 'GlobalMemCachelineSize: '; nextPutAll: self globalMemCachelineSize printString; newLine.
	aStream nextPutAll: 'GlobalMemSize: '; nextPutAll: self globalMemSize printStringAsBytes; newLine.
	aStream nextPutAll: 'HasImageSupport: '; nextPutAll: self hasImageSupport printString; newLine.
	aStream nextPutAll: 'Image2dMaxHeight: '; nextPutAll: self image2dMaxHeight printString; newLine.
	aStream nextPutAll: 'Image2dMaxWidth: '; nextPutAll: self image2dMaxWidth printString; newLine.
	aStream nextPutAll: 'Image3dMaxDepth: '; nextPutAll: self image3dMaxDepth printString; newLine.
	aStream nextPutAll: 'Image3dMaxHeight: '; nextPutAll: self image3dMaxHeight printString; newLine.
	aStream nextPutAll: 'Image3dMaxWidth: '; nextPutAll: self image3dMaxWidth printString; newLine.
	aStream nextPutAll: 'IsAvailable: '; nextPutAll: self isAvailable printString; newLine.
	aStream nextPutAll: 'IsCompilerAvailable: '; nextPutAll: self isCompilerAvailable printString; newLine.
	aStream nextPutAll: 'IsLittleEndian: '; nextPutAll: self isLittleEndian printString; newLine.
	aStream nextPutAll: 'LocalMemSize: '; nextPutAll: self localMemSize printString; newLine.
	aStream nextPutAll: 'LocalMemType: '; nextPutAll: self localMemType printString; newLine.
	aStream nextPutAll: 'MaxClockFrequency: '; nextPutAll: self maxClockFrequency printString; newLine.
	aStream nextPutAll: 'MaxConstantArgs: '; nextPutAll: self maxConstantArgs printString; newLine.
	aStream nextPutAll: 'MaxConstantBufferSize: '; nextPutAll: self maxConstantBufferSize printStringAsBytes; newLine.
	aStream nextPutAll: 'MaxMemAllocSize: '; nextPutAll: self maxMemAllocSize printStringAsBytes; newLine.
	aStream nextPutAll: 'MaxParameterSize: '; nextPutAll: self maxParameterSize printString; newLine.
	aStream nextPutAll: 'MaxReadImageArgs: '; nextPutAll: self maxReadImageArgs printString; newLine.
	aStream nextPutAll: 'MaxSamplers: '; nextPutAll: self maxSamplers printString; newLine.
	aStream nextPutAll: 'MaxWorkGroupSize: '; nextPutAll: self maxWorkGroupSize printString; newLine.
	aStream nextPutAll: 'MaxWorkItemDimensions: '; nextPutAll: self maxWorkItemDimensions printString; newLine.
	aStream nextPutAll: 'MaxWorkItemSizes: '; nextPutAll: self maxWorkItemSizes printString; newLine.
	aStream nextPutAll: 'MaxWriteImageArgs: '; nextPutAll: self maxWriteImageArgs printString; newLine.
	aStream nextPutAll: 'MemBaseAddrAlign: '; nextPutAll: self memBaseAddrAlign printString; newLine.
	aStream nextPutAll: 'MinDataTypeAlignSize: '; nextPutAll: self minDataTypeAlignSize printString; newLine.
	aStream nextPutAll: 'PreferredVectorWidthChar: '; nextPutAll: self preferredVectorWidthChar printString; newLine.
	aStream nextPutAll: 'PreferredVectorWidthDouble: '; nextPutAll: self preferredVectorWidthDouble printString; newLine.
	aStream nextPutAll: 'PreferredVectorWidthFloat: '; nextPutAll: self preferredVectorWidthFloat printString; newLine.
	aStream nextPutAll: 'PreferredVectorWidthInt: '; nextPutAll: self preferredVectorWidthInt printString; newLine.
	aStream nextPutAll: 'PreferredVectorWidthLong: '; nextPutAll: self preferredVectorWidthLong printString; newLine.
	aStream nextPutAll: 'PreferredVectorWidthShort: '; nextPutAll: self preferredVectorWidthShort printString; newLine.
	aStream nextPutAll: 'Profile: '; nextPutAll: self profile; newLine.
	aStream nextPutAll: 'ProfilingTimerResolution: '; nextPutAll: self profilingTimerResolution printString; newLine.
	aStream nextPutAll: 'QueueProperties: '; nextPutAll: self queueProperties printString; newLine.
	aStream nextPutAll: 'SinglePrecisionConfig: '; nextPutAll: self singlePrecisionConfig printString; newLine.
	aStream nextPutAll: 'SupportsErrorCorrection: '; nextPutAll: self supportsErrorCorrection printString; newLine.
	aStream nextPutAll: 'Type: '; nextPutAll: self type printString; newLine.
	aStream nextPutAll: 'VendorID: '; nextPutAll: self vendorID printString; newLine.
]

{ #category : 'accessing' }
OpenCLDevice >> singlePrecisionConfig [
	^self floatingPointPrecisionConfig: CL_DEVICE_SINGLE_FP_CONFIG

]

{ #category : 'private' }
OpenCLDevice >> sizetProperty: property [
	"Get the specified size_t property."
	^Smalltalk wordSize = 8
		ifTrue: [ self ulongProperty: property ]
		ifFalse: [ self uintProperty: property ]
]

{ #category : 'private' }
OpenCLDevice >> stringProperty: property [
	"Get the char[] device property."
	| string size |
	string := String new: 1000.
	[size := self getDeviceInfoParameter: property into: string]
		on: OpenCLError do: [
			"Try again with much larger string."
			string := String new: 100000.
			size := self getDeviceInfoParameter: property into: string
		].
	(string at: size) codePoint = 0 ifTrue: [size := size - 1 "strip off terminal NULL character"].
	^string first: size
]

{ #category : 'accessing' }
OpenCLDevice >> supportsErrorCorrection [
	"Get the CL_DEVICE_ERROR_CORRECTION_SUPPORT property:  Is 'true' if the device implements error correction for the memories, caches, registers etc. in the device. Is 'false' if the device does not implement error correction. This can be a requirement for certain clients of OpenCL."
	^self booleanProperty: CL_DEVICE_ERROR_CORRECTION_SUPPORT
]

{ #category : 'accessing' }
OpenCLDevice >> type [
	"The OpenCL device type. Currently supported values are one of or a combination of: CL_DEVICE_TYPE_CPU, CL_DEVICE_TYPE_GPU, CL_DEVICE_TYPE_ACCELERATOR, or CL_DEVICE_TYPE_DEFAULT."
	^self ulongProperty: CL_DEVICE_TYPE
]

{ #category : 'private' }
OpenCLDevice >> uintProperty: property [
	"Get the specified unsigned 32-bit property."
	| buf |
	buf := ByteArray new: 4.
	self getDeviceInfoParameter: property into: buf.
	^buf uint32At: 1 bigEndian: Smalltalk isBigEndian
]

{ #category : 'private' }
OpenCLDevice >> ulongProperty: property [
	"Get the specified unsigned 64-bit property."
	| buf isBigEndian |
	buf := ByteArray new: 8.
	self getDeviceInfoParameter: property into: buf.
	isBigEndian := Smalltalk isBigEndian.
	^ ((buf uint32At: 5 bigEndian: isBigEndian) bitShift: 32) +
		(buf uint32At: 1 bigEndian: isBigEndian)
]

{ #category : 'accessing' }
OpenCLDevice >> vendor [
	"Vendor name string."
	^self stringProperty: CL_DEVICE_VENDOR
]

{ #category : 'accessing' }
OpenCLDevice >> vendorID [
	"A unique device vendor identifier. An example of a unique device identifier could be the PCIe ID."
	^self uintProperty: CL_DEVICE_VENDOR_ID
]

{ #category : 'accessing' }
OpenCLDevice >> version [
	"OpenCL version string. Returns the OpenCL version supported by the device. This version string has the following format:

OpenCL<space><major_version.minor_version><space><vendor-specific information>

The major_version.minor_version value returned will be 1.0."
	^self stringProperty: CL_DEVICE_VERSION
]
