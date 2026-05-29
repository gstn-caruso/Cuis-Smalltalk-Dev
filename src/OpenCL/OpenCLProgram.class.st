Class {
	#name : 'OpenCLProgram',
	#superclass : 'OpenCLContextObject',
	#instVars : [
		'sourceCode'
	],
	#category : 'OpenCL',
	#package : 'OpenCL'
}

{ #category : 'building' }
OpenCLProgram >> build [
	"Build the program with the default settings, for all devices associated with the program's context."
	self buildDevices: context devices options: ''

]

{ #category : 'building' }
OpenCLProgram >> buildDevices: deviceOrDeviceList [
	"Build the program for the specified devices with the default settings."
	self buildDevices: deviceOrDeviceList options: ''

]

{ #category : 'building' }
OpenCLProgram >> buildDevices: deviceOrDeviceList options: optionsString [
	| devices bytes devicesArg result handleSize |
	
	"Ensure that we have a list of at least one device."
	devices := deviceOrDeviceList.
	devices isCollection ifFalse: [devices := {devices}]..
	devices size == 0 ifTrue: [self error: 'no devices specified'].
	
	"Create the list of devices that we will pass to the FFI call."
	handleSize := CLDeviceID byteSize.
	bytes := ByteArray new: (devices size * handleSize).
	devices withIndexDo: [:dev :i | bytes replaceFrom: (i-1*handleSize+1) to: (i*handleSize) with: dev id getHandle].
	devicesArg := CLDeviceID new setHandle: bytes.
	
	"FFI call to build the program."
	result := OpenCLPrimitiveInterface current
				clBuildProgram__cl_program: id
							cl_uint: devices size
							const__cl_device_id__ptr: devicesArg
							const__char__ptr: optionsString
							void__ptrpfn_notifycl_program: nil "no callback yet"
							void__ptr: nil. "no callback yet"
	[OpenCLError check: result text: 'failed to build program']
		on: Error 
		do: [:err |
			false not ifTrue: [ "enable / disable debugging"
				(devices collect: [:dev | self buildLog: dev]) 
					inspectWithLabel: 'OpenCL Compilation Error'
			].
			err pass. 
		]

]

{ #category : 'building' }
OpenCLProgram >> buildLog: device [
	"Obtain the build-log of the last build attempt for the specfied device."
	| apiResult buildResult |
	buildResult := String new: 1000.
	apiResult := OpenCLPrimitiveInterface current
					clGetProgramBuildInfo__cl_program: id
								cl_device_id: device id
								cl_program_build_info: CL_PROGRAM_BUILD_LOG
								size_t: buildResult size
								void__ptr: buildResult
								size_t__ptr: nil.
	OpenCLError check: apiResult text: 'failed to obtain program build-log'.
	^buildResult
]

{ #category : 'building' }
OpenCLProgram >> buildOptions: optionsString [
	"Build the program with the specified options, for all devices associated with the program's context."
	self buildDevices: context devices options: optionsString

]

{ #category : 'building' }
OpenCLProgram >> buildStatus: device [
	"Obtain the status of the last build attempt for the specfied device.  Answers one of CLBuildNone, CLBuildError, CLBuildSuccess, or CLBuildInProgress."
	| apiResult buildResult |
	buildResult := IntegerArray new: 1.
	apiResult := OpenCLPrimitiveInterface current
					clGetProgramBuildInfo__cl_program: id
								cl_device_id: device id
								cl_program_build_info: CL_PROGRAM_BUILD_STATUS
								size_t: Smalltalk wordSize
								void__ptr: buildResult
								size_t__ptr: nil.
	OpenCLError check: apiResult text: 'failed to obtain program build-info'.
	^buildResult first
]

{ #category : 'initialize' }
OpenCLProgram >> context: anOpenCLContext sourceCode: stringOrListOfStrings [
	"Set the context that this buffer was created for, as well as its dimensions and format." 
	context := anOpenCLContext.
	sourceCode := stringOrListOfStrings.

]

{ #category : 'kernel creation' }
OpenCLProgram >> createKernel: kernelName [
	"Create an OpenCLKernel for this program.  The program must already have been successfully built."
	| result kernel |
	result := IntegerArray new: 1.
	kernel := OpenCLPrimitiveInterface current
				clCreateKernel__cl_program: id
							const__char__ptr: kernelName
							cl_int__ptr: result.
	result := result first.
	OpenCLError check: result text: 'failed create kernel named ', kernelName.
	kernel := OpenCLKernel wrappingHandle: kernel.
	kernel program: self.
	^kernel
]
