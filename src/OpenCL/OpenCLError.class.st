"
Error that knows how to look up a human-readable string corresponding to the OpenCL error code.
"
Class {
	#name : 'OpenCLError',
	#superclass : 'Error',
	#instVars : [
		'errorCode'
	],
	#pools : [
		'OpenCLConstants'
	],
	#category : 'OpenCL',
	#package : 'OpenCL'
}

{ #category : 'signalling' }
OpenCLError class >> check: errCode [
	errCode == CL_SUCCESS ifTrue: [^self "no problemo"].
	self signalCode: errCode
	
]

{ #category : 'signalling' }
OpenCLError class >> check: errCode text: failureString [
	"If successful, do nothing.  Otherwise, signal an error with the specified failure-string."
	errCode == CL_SUCCESS ifTrue: [^self "no problemo"].
	self signal: failureString code: errCode
	
]

{ #category : 'signalling' }
OpenCLError class >> errorStringForCode: errCode [
	| errorNames |
	errorNames := #(
		'CLDeviceNotFound'
		'CLDeviceNotAvailable'
		'CLCompilerNotAvailable'
		'CLMemObjectAllocationFailure'
		'CLOutOfResources'
		'CLOutOfHostMemory'
		'CLProfilingInfoNotAvailable'
		'CLMemCopyOverlap'
		'CLImageFormatMismatch'
		'CLImageFormatNotSupported'
		'CLBuildProgramFailure'
		'CLMapFailure'
		'CL_MISALIGNED_SUB_BUFFER_OFFSET'
		'CL_EXEC_STATUS_ERROR_FOR_EVENTS_IN_WAIT_LIST'
		'CL_COMPILE_PROGRAM_FAILURE'
		'CL_LINKER_NOT_AVAILABLE'
		'CL_LINK_PROGRAM_FAILURE'
		'CL_DEVICE_PARTITION_FAILED'
		'CL_KERNEL_ARG_INFO_NOT_AVAILABLE'
		nil  "enough nils to fill indices 21-29"
		nil
		nil
		nil 
		nil
		nil
		nil
		nil 
		nil
		nil
		'CLInvalidValue'
		'CLInvalidDeviceType'
		'CLInvalidPlatform'
		'CLInvalidDevice'
		'CLInvalidContext'
		'CLInvalidQueueProperties'
		'CLInvalidCommandQueue'
		'CLInvalidHostPtr'
		'CLInvalidMemObject'
		'CLInvalidImageFormatDescriptor'
		'CLInvalidImageSize'
		'CLInvalidSampler'
		'CLInvalidBinary'
		'CLInvalidBuildOptions'
		'CLInvalidProgram'
		'CLInvalidProgramExecutable'
		'CLInvalidKernelName'
		'CLInvalidKernelDefinition'
		'CLInvalidKernel'
		'CLInvalidArgIndex'
		'CLInvalidArgValue'
		'CLInvalidArgSize'
		'CLInvalidKernelArgs'
		'CLInvalidWorkDimension'
		'CLInvalidWorkGroupSize'
		'CLInvalidWorkItemSize'
		'CLInvalidGlobalOffset'
		'CLInvalidEventWaitList'
		'CLInvalidEvent'
		'CLInvalidOperation'
		'CLInvalidGlObject'
		'CLInvalidBufferSize'
		'CLInvalidMipLevel'
		'CLInvalidGlobalWorkSize'
	).
	^[errorNames at: errCode negated] on: Error do: ['INVALID ERROR CODE (', errCode printString, ')!!!'].
]

{ #category : 'signalling' }
OpenCLError class >> signal: signalerText code: errCode [
	errCode == CL_SUCCESS ifTrue: [^self "no problemo"].
	^self new 
			code: errCode; 
			signal: (self errorStringForCode: errCode), ': ', signalerText
]

{ #category : 'signalling' }
OpenCLError class >> signalCode: errCode [
	^self new code: errCode; signal: (self errorStringForCode: errCode)
]

{ #category : 'accessing' }
OpenCLError >> code [
	^errorCode
]

{ #category : 'accessing' }
OpenCLError >> code: errorCodeInteger [
	errorCode := errorCodeInteger
]
