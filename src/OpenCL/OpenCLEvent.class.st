"
Encapsulates a CLEvent and provides convenience methods for accessing its properties.
"
Class {
	#name : 'OpenCLEvent',
	#superclass : 'OpenCLRefCountedObject',
	#instVars : [
		'commandQueue'
	],
	#category : 'OpenCL',
	#package : 'OpenCL'
}

{ #category : 'private-waiting' }
OpenCLEvent class >> generateWaitList: eventOrListOrNil  [
	"Private to the OpenCL framework.  If you call this, you're Doing It Wrong."
	"Process the argument and return a value that can be passed as the wait-list for any function that enqueues a command on a command-queue.  For convenience, this method is quite permissive... the argument may be nil, a single event, or a list of OpenCLEvents (and possibly nils).  Answers a 2-element array with: 1) the number of events 2) a CLEvent whose handle is a pointer to the concatenated handles of all events in the list (or nil if the number of events is zero)."
	| bytes events handleSize |
	eventOrListOrNil ifNil: [^#(0 nil)].
	events := eventOrListOrNil.
	events isCollection ifFalse: [events := {events}]. "easier to work with below"
	events := events select: [:evt | evt notNil]. "in case nils made it into the list"
	events size == 0 ifTrue: [^#(0 nil)].
	"If we reach here, there's at least one event that the enqueued command must wait for.
	Flatten the handles of these events into a single ByteArray, and wrap it in a CLEvent."
	handleSize := CLEvent byteSize.
	bytes := ByteArray new: (events size * handleSize).
	events withIndexDo: [:evt :i | bytes replaceFrom: (i-1*handleSize+1) to: (i*handleSize) with: evt id getHandle].
	^{events size. CLEvent new setHandle: bytes}
]

{ #category : 'waiting' }
OpenCLEvent class >> waitForEvents: events "single OpenCLEvent, or list of them" [
	"Blocking wait until all of the listed events are completed.  Eventually, this will be replaced with a mechanism that blocks only the current Squeak Process rather than the whole VM (see class comment of OpenCLPlugin). Note that this would require us to pin any objects passed as arguments, or disable GC (someway) until OpenCL is done..."
	| waitList result |
	waitList := OpenCLEvent generateWaitList: events.
	result := OpenCLPrimitiveInterface current 
				clWaitForEvents__cl_uint: waitList first 
							const__cl_event__ptr: waitList second.
	OpenCLError check: result text: 'failed to wait for events'.
	
]

{ #category : 'accessing' }
OpenCLEvent >> commandQueue [
	"Answer the command-queue that the command corresponding to this event was enqueued upon."
		^commandQueue
]

{ #category : 'initialize' }
OpenCLEvent >> commandQueue: anOpenCLCommandQueue [
	"Set the command-queue that the command corresponding to this event was enqueued upon."
	commandQueue := anOpenCLCommandQueue.
]

{ #category : 'accessing' }
OpenCLEvent >> commandType [
	"Answer an integer representing the cl_command_type of the event."
	| bytes |
	bytes := ByteArray new: 4.
	self getEventInfo: CL_EVENT_COMMAND_TYPE into: bytes.
	^bytes uint32At: 1 bigEndian: Smalltalk isBigEndian
]

{ #category : 'accessing' }
OpenCLEvent >> executionStatus [
	"Answer an integer representing the execution status of the event."
	| bytes |
	bytes := ByteArray new: 4.
	self getEventInfo: CL_EVENT_COMMAND_EXECUTION_STATUS into: bytes.
	^bytes unsignedLongAt: 1
]

{ #category : 'private' }
OpenCLEvent >> getEventInfo:  param into: bytes [
	| result |
	result := OpenCLPrimitiveInterface current
				clGetEventInfo__cl_event: id
							cl_event_info: param
							size_t: bytes byteSize
							void__ptr: bytes
							size_t__ptr: nil.
	OpenCLError check: result text: 'failed to get event-info'.

]

{ #category : 'testing' }
OpenCLEvent >> isComplete [
	"Is the event currently in the 'complete' state?"
	^self executionStatus == CL_COMPLETE
]

{ #category : 'testing' }
OpenCLEvent >> isQueued [
	"Is the event currently in the 'queued' state?"
	^self executionStatus == CL_QUEUED
]

{ #category : 'testing' }
OpenCLEvent >> isRunning [
	"Is the event currently in the 'running' state?"
	^self executionStatus == CL_RUNNING
]

{ #category : 'testing' }
OpenCLEvent >> isSubmitted [
	"Is the event currently in the 'submitted' state?"
	^self executionStatus == CL_SUBMITTED
]

{ #category : 'private' }
OpenCLEvent >> privateDestroy [
	commandQueue := nil.
	
]

{ #category : 'waiting' }
OpenCLEvent >> wait [
	"Blocking wait for this event to complete."
	OpenCLEvent waitForEvents: self.
]
