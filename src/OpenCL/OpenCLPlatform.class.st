"
Encapsulates a CLPlatformID, and provides convenience methods for accessing its properties.  Perhaps these methods should simply be added to CLPlatformID, and this class deleted  (except that we apparently can't add instance variables to subclasses of ExternalStructure, and still marshal them through the FFI).

OpenCLPlatform allPlatforms do: [ :platform | platform reportOn: Transcript ].
"
Class {
	#name : 'OpenCLPlatform',
	#superclass : 'OpenCLObject',
	#instVars : [
		'profile',
		'version',
		'name',
		'vendor',
		'extensions'
	],
	#classVars : [
		'PreferredDevice'
	],
	#category : 'OpenCL',
	#package : 'OpenCL'
}

{ #category : 'devices' }
OpenCLPlatform class >> allCPUs [
	"Answer some device. If possible, answer some GPU. If none is available, answer some CPU.
	If none is available, answer nil
	OpenCLPlatform allCPUs
	"
	| platforms |
	platforms := OpenCLPlatform allPlatforms.
	^ Array streamContents: [ :strm |
		platforms do: [ :platform | platform allCPUs do: [ :device | strm nextPut: device ]]]
]

{ #category : 'devices' }
OpenCLPlatform class >> allDevices [
	"Answer some device. If possible, answer some GPU. If none is available, answer some CPU.
	If none is available, answer nil
	OpenCLPlatform someDevice
	"
	| platforms |
	platforms := OpenCLPlatform allPlatforms.
	^ Array streamContents: [ :strm |
		platforms do: [ :platform | platform allDevices do: [ :device | strm nextPut: device ]]]
]

{ #category : 'devices' }
OpenCLPlatform class >> allGPUs [
	"Answer some device. If possible, answer some GPU. If none is available, answer some CPU.
	If none is available, answer nil
	OpenCLPlatform someDevice
	"
	| platforms |
	platforms := OpenCLPlatform allPlatforms.
	^ Array streamContents: [ :strm |
		platforms do: [ :platform | platform allGPUs do: [ :device | strm nextPut: device ]]]
]

{ #category : 'private' }
OpenCLPlatform class >> allPlatformIDs [
	"Answer a list of CLPlatformIDs corresponding to the available OpenCL platforms."
	| resultCount bytes result handles handleSize |
	
	resultCount := IntegerArray new: 1.
	"OpenCL will stash the results in 'bytes'."
	handleSize _ CLPlatformID byteSize.
	bytes := ByteArray new: (100 * handleSize). "100 is enough for anyone"
	result := OpenCLPrimitiveInterface current
				clGetPlatformIDs__cl_uint: 100 
							cl_platform_id__ptr: (CLPlatformID new setHandle: bytes) 
							cl_uint__ptr: resultCount.
	result == CL_SUCCESS ifFalse: [OpenCLError signal: 'failed to get platformIDs' code: result].
	resultCount := resultCount first. "don't need the IntegerArray any more."
	handles := Array new: resultCount.
	1 to: resultCount do: [:i |
		| handle |
		handle := bytes copyFrom: (i-1*handleSize+1) to: (i*handleSize).
		handles at: i put: (CLPlatformID new setHandle: handle)
	].
	^handles
]

{ #category : 'instance creation' }
OpenCLPlatform class >> allPlatforms [
	"OpenCLPlatform allPlatforms"
	^self allPlatformIDs collect: [:id | self wrappingHandle: id]
]

{ #category : 'report application' }
OpenCLPlatform class >> buildOpenCLReportApp [
	"
	OpenCLPlatform buildOpenCLReportApp
	"
	AppLauncher appGlobalName: self name appSelector: #shortReportAndQuit.
	Smalltalk reduceCuis.
	Smalltalk saveAs: 'OpenCLReport' andQuit: true clearAllClassState: false
]

{ #category : 'devices' }
OpenCLPlatform class >> cpu [
	self allPlatforms do: [ :platform | platform allCPUs do: [ :cpu | ^ cpu ]].
	^ nil
]

{ #category : 'devices' }
OpenCLPlatform class >> preferredDevice [
	^ PreferredDevice ifNil: [self someDevice]
]

{ #category : 'devices' }
OpenCLPlatform class >> preferredDevice: anOpenCLDevice [
	PreferredDevice := anOpenCLDevice 
]

{ #category : 'report application' }
OpenCLPlatform class >> shortReport [
	"On StdIO
	OpenCLPlatform shortReport
	"
	OpenCLPlatform allPlatforms do: [ :platform |
		platform shortReportOn: StdIOWriteStream stdout ]
]

{ #category : 'report application' }
OpenCLPlatform class >> shortReportAndQuit [
	"On StdIO
	OpenCLPlatform shortReport
	"
	OpenCLPlatform allPlatforms do: [ :platform |
		platform shortReportOn: StdIOWriteStream stdout ].

	Smalltalk snapshot: false andQuit: true embedded: false clearAllClassState: false
]

{ #category : 'devices' }
OpenCLPlatform class >> someDevice [
	"Answer some device. If possible, answer some GPU. If none is available, answer some CPU.
	If none is available, answer nil
	OpenCLPlatform someDevice
	"
	| platforms |
	platforms := OpenCLPlatform allPlatforms.
	platforms do: [ :platform | platform allGPUs do: [ :gpu | ^ gpu ]].
	platforms do: [ :platform | platform allDevices do: [ :device | ^ device ]].
	^ nil
]

{ #category : 'accessing' }
OpenCLPlatform >> allCPUs [
	^self allDevicesOfType: CL_DEVICE_TYPE_CPU
]

{ #category : 'accessing' }
OpenCLPlatform >> allDeviceIDsOfType: deviceType [
	"Answer a list of CLDeviceIDs corresponding to the available devices of the specified type."
	| resultCount bytes result handles handleSize |

	resultCount := IntegerArray new: 1.
	"OpenCL will stash the results in 'bytes'."
	handleSize := CLDeviceID byteSize.
	bytes := ByteArray new: (100 * handleSize). "100 is enough for anybody"
	result := OpenCLPrimitiveInterface current
				clGetDeviceIDs__cl_platform_id: id
							cl_device_type: deviceType
							cl_uint: 100
							cl_device_id__ptr: (CLDeviceID new setHandle: bytes)
							cl_uint__ptr: resultCount.
	result == CL_SUCCESS ifFalse: ["OpenCLError signal: 'failed to get deviceIDs' code: result" ^#()].
	resultCount := resultCount first. "don't need the IntegerArray any more."
	handles := Array new: resultCount.
	1 to: resultCount do: [:i |
		| handle |
		handle := bytes copyFrom: (i-1*handleSize+1) to: (i*handleSize).
		handles at: i put: (CLDeviceID new setHandle: handle)
	].
	^handles
]

{ #category : 'accessing' }
OpenCLPlatform >> allDevices [
	^self allDevicesOfType: CL_DEVICE_TYPE_ALL
]

{ #category : 'accessing' }
OpenCLPlatform >> allDevicesOfType: deviceType [
	^(self allDeviceIDsOfType: deviceType) 
		collect: [ :eachId | (OpenCLDevice wrappingHandle: eachId) platform: self]
]

{ #category : 'accessing' }
OpenCLPlatform >> allGPUs [
	^self allDevicesOfType: CL_DEVICE_TYPE_GPU
]

{ #category : 'accessing' }
OpenCLPlatform >> extensions [
	^extensions
]

{ #category : 'private' }
OpenCLPlatform >> getPlatformInfoParameter: param "cl_platform_info" [
	| buf result size |
	buf := String new: 1000.
	size := IntegerArray new: 1.
	result := OpenCLPrimitiveInterface current
			clGetPlatformInfo__cl_platform_id: id 
						cl_platform_info: param 
						size_t: buf size 
						void__ptr: buf 
						size_t__ptr: size.
	result == CL_SUCCESS ifFalse: [
		"If the reason that we failed is that there wasn't enough space, try again with more.
		 Unfortunately, we aren't told the actual size, so use something really big."
		buf := String new: 100000.
		result := OpenCLPrimitiveInterface current 
			clGetPlatformInfo__cl_platform_id: id 
						cl_platform_info: param 
						size_t: buf size
						void__ptr: buf 
						size_t__ptr: size.
	].
	result == CL_SUCCESS ifFalse: [OpenCLError signalCode: result].
	size := size first. "don't need the IntegerArray any more."
	(buf at: size) codePoint = 0 ifTrue: [size := size - 1 "strip off terminal NULL character"].
	^buf first: size
]

{ #category : 'initialize' }
OpenCLPlatform >> id: aCLPlatformID [
	super id: aCLPlatformID.
	profile := self getPlatformInfoParameter: CL_PLATFORM_PROFILE.
	version := self getPlatformInfoParameter: CL_PLATFORM_VERSION.
	name := self getPlatformInfoParameter: CL_PLATFORM_NAME.
	vendor := self getPlatformInfoParameter: CL_PLATFORM_VENDOR.
	extensions := self getPlatformInfoParameter: CL_PLATFORM_EXTENSIONS.
	extensions := extensions findTokens: Character space
]

{ #category : 'accessing' }
OpenCLPlatform >> name [
	^name
]

{ #category : 'accessing' }
OpenCLPlatform >> profile [
	^profile
]

{ #category : 'report' }
OpenCLPlatform >> reportOn: aStream [
	"
	OpenCLPlatform allPlatforms do: [ :platform | platform reportOn: Transcript ].
	OpenCLPlatform allPlatforms do: [ :platform | platform reportOn: StdIOWriteStream stdout ].
	"
	| context devices |
	aStream nextPutAll: '=================== '; newLine.
	aStream nextPutAll: 'Platform: '; nextPutAll: name; newLine.
	aStream nextPutAll: '=================== '; newLine.
	aStream nextPutAll: '-----GPUs---------------------------- '; newLine.
	aStream nextPutAll: '--------------------------------------- '; newLine.
	self allGPUs do: [ :gpu |
			gpu reportGeneralOn: aStream.
			aStream nextPutAll: '--------------------------------------- '; newLine.
			gpu reportExtensionsOn: aStream.
			aStream nextPutAll: '--------------------------------------- '; newLine.
			(OpenCLContext newForDevices: {gpu})
				reportImageFormatsOn: aStream ]
		separatedBy: [aStream nextPutAll: '--------------------------------------- '; newLine].
	aStream nextPutAll: '--------------------------------------- '; newLine.
	aStream nextPutAll: '-----CPUs---------------------------- '; newLine.
	aStream nextPutAll: '--------------------------------------- '; newLine.
	self allCPUs do: [ :cpu |
			cpu reportGeneralOn: aStream.
			aStream nextPutAll: '--------------------------------------- '; newLine.
			cpu reportExtensionsOn: aStream.
			aStream nextPutAll: '--------------------------------------- '; newLine.
			(OpenCLContext newForDevices: {cpu})
				reportImageFormatsOn: aStream ]
		separatedBy: [aStream nextPutAll: '--------------------------------------- '; newLine].
	aStream nextPutAll: '=================== '; newLine.
	devices _ self allDevices.
	devices notEmpty ifTrue: [
		context _ OpenCLContext newForDevices: devices.
		context reportImageFormatsOn: aStream.
		aStream nextPutAll: '=================== '; newLine ]
]

{ #category : 'report' }
OpenCLPlatform >> shortReportOn: aStream [
	"
	OpenCLPlatform allPlatforms do: [ :platform | platform shortReportOn: Transcript ].
	OpenCLPlatform allPlatforms do: [ :platform | platform shortReportOn: StdIOWriteStream stdout ].
	"
	aStream nextPutAll: '=================== '; newLine.
	aStream nextPutAll: 'Platform: '; nextPutAll: name; newLine.
	aStream nextPutAll: '=================== '; newLine.
	aStream nextPutAll: '-----GPUs---------------------------- '; newLine.
	aStream nextPutAll: '--------------------------------------- '; newLine.
	self allGPUs do: [ :gpu |
			gpu reportGeneralOn: aStream.
			aStream nextPutAll: '--------------------------------------- '; newLine.
			gpu reportExtensionsOn: aStream ]
		separatedBy: [aStream nextPutAll: '--------------------------------------- '; newLine].
	aStream nextPutAll: '--------------------------------------- '; newLine.
	aStream nextPutAll: '-----CPUs---------------------------- '; newLine.
	aStream nextPutAll: '--------------------------------------- '; newLine.
	self allCPUs do: [ :cpu |
			cpu reportGeneralOn: aStream.
			aStream nextPutAll: '--------------------------------------- '; newLine.
			cpu reportExtensionsOn: aStream ]
		separatedBy: [aStream nextPutAll: '--------------------------------------- '; newLine].
	aStream nextPutAll: '=================== '; newLine.
	aStream flush
]

{ #category : 'accessing' }
OpenCLPlatform >> vendor [
	^vendor
]

{ #category : 'accessing' }
OpenCLPlatform >> version [
	^version
]
