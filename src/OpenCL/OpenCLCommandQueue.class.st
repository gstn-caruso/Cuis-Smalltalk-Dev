"
Encapsulates a CLCommandQueue and provides convenience methods for accessing its properties.
"
Class {
	#name : 'OpenCLCommandQueue',
	#superclass : 'OpenCLContextObject',
	#instVars : [
		'device',
		'isInOrder',
		'isProfiling'
	],
	#category : 'OpenCL',
	#package : 'OpenCL'
}

{ #category : 'deprecated in OpenCL 1.2' }
OpenCLCommandQueue >> barrier [
	"Ensures that all currently-queued commands will finish before any subsequently-queued commands are executed..  This should be equivalent to 'queue waitForEvents: queue marker' (of course, doing it with the C API would be somewhat less convenient)."
	"Deprecated in OpenCL1.2:
	clEnqueueMarker, clEnqueueBarrier and clEnqueueWaitForEvents have been merged into clEnqueueMarkerWithWaitList and clEnqueueBarrierWithWaitList. The barrier and marker functionality are still the same, but if a non-NULL waiting-list is given it will also continue if all the events have occurred. This was tricky to program before. A new option is that you can fire an event when all previous events have occurred.
	"
	| result |
	result := OpenCLPrimitiveInterface current clEnqueueBarrier__cl_command_queue: id.
	OpenCLError check: result text: 'failed to enqueue barrier'.
]

{ #category : 'properties' }
OpenCLCommandQueue >> beInOrder [
	"The spec warns that this can be slow, since OpenCL will block until all currently-queued commands have finished."
	| result |
	isInOrder ifTrue: [^self].
	"Warning: clSetCommandQueueProperty() was deprecated in OpenCL 1.1 and is no longer in headers in 1.2 and 2.0.
	I believe callers should be converted to use clCreateCommandQueueWithProperties()"
	result := OpenCLPrimitiveInterface current
				clSetCommandQueueProperty__cl_command_queue: id
							cl_command_queue_properties: CL_QUEUE_OUT_OF_ORDER_EXEC_MODE_ENABLE
							cl_bool: CL_TRUE
							cl_command_queue_properties__ptr: nil.
	OpenCLError check: result.
	isInOrder := true. "only if we succeed"
]

{ #category : 'properties' }
OpenCLCommandQueue >> beOutOfOrder [
	"The spec warns that this can be slow, since OpenCL will block until all currently-queued commands have finished."
	| result |
	isInOrder ifFalse: [^self].
	"Warning: clSetCommandQueueProperty() was deprecated in OpenCL 1.1 and is no longer in headers in 1.2 and 2.0.
	I believe callers should be converted to use clCreateCommandQueueWithProperties()"
	result := OpenCLPrimitiveInterface current
				clSetCommandQueueProperty__cl_command_queue: id
							cl_command_queue_properties: CL_QUEUE_OUT_OF_ORDER_EXEC_MODE_ENABLE
							cl_bool: CL_FALSE
							cl_command_queue_properties__ptr: nil.
	OpenCLError check: result.
	isInOrder := false. "only if we succeed"
]

{ #category : 'initialize' }
OpenCLCommandQueue >> context: anOpenCLContext device: anOpenCLDevice [
	"Set the context and device that this queue was created for."
	context := anOpenCLContext.
	device := anOpenCLDevice.

]

{ #category : 'mem read/write/copy' }
OpenCLCommandQueue >> copyBuffer: srcBuf "an OpenCLBuffer" at: srcOffset into: destBuf "an OpenCLBuffer" at: destOffset size: sz waitOn: events "nil, single OpenCLEvent, or list of them" [
	| result evt waitList |
	waitList := OpenCLEvent generateWaitList: events.
	result := OpenCLPrimitiveInterface current
				clEnqueueCopyBuffer__cl_command_queue: id
							cl_mem: srcBuf id
							cl_mem: destBuf id
							size_t: srcOffset
							size_t: destOffset
							size_t: sz
							cl_uint: waitList first "number of events to wait on"
							const__cl_event__ptr: waitList second "concatenated event handles"
							cl_event__ptr: (evt := CLEvent new).
	OpenCLError check: result text: 'failed to enqueue copy-buffer'.
	^self wrapEventHandle: evt
]

{ #category : 'mem read/write/copy' }
OpenCLCommandQueue >> copyBuffer: srcBuffer offset: srcOffset intoImage: destImage origin: destOrigin region: destRegion waitOn: events [
	"Arguments:
		srcBuffer	-		An OpenCLBuffer
		srcOffset	-		integer
		destImage	-		An OpenCLImage2D/3D
		destOrigin	-		3-element Array or IntegerArray
		destRegion	-		ditto
		events		-		nil, single OpenCLEvent, or list of them"
	| result evt waitList |
	waitList := OpenCLEvent generateWaitList: events.
	result := OpenCLPrimitiveInterface current
				clEnqueueCopyBufferToImage__cl_command_queue: id
							cl_mem: srcBuffer id
							cl_mem: destImage id
							size_t: srcOffset
							const__size_t__ptr: destOrigin asMachineWordArray
							const__size_t__ptr: destRegion asMachineWordArray
							cl_uint: waitList first "number of events to wait on"
							const__cl_event__ptr: waitList second "concatenated event handles"
							cl_event__ptr: (evt := CLEvent new).
	OpenCLError check: result text: 'failed to enqueue copy-buffer-to-image'.
	^self wrapEventHandle: evt
]

{ #category : 'mem read/write/copy' }
OpenCLCommandQueue >> copyImage: srcImage origin: srcOrigin into: destImage origin: destOrigin region: region waitOn: events [
	"Arguments:
		srcImage	-		An OpenCLImage2D/3D
		srcOrigin	-		3-element Array or IntegerArray
		destImage	-		An OpenCLImage2D/3D
		destOrigin	-		3-element Array or IntegerArray
		region		-		ditto
		events		-		nil, single OpenCLEvent, or list of them"
	| result evt waitList |
	waitList := OpenCLEvent generateWaitList: events.
	result := OpenCLPrimitiveInterface current
				clEnqueueCopyImage__cl_command_queue: id
							cl_mem: srcImage id
							cl_mem: destImage id
							const__size_t__ptr: srcOrigin asMachineWordArray
							const__size_t__ptr: destOrigin asMachineWordArray
							const__size_t__ptr: region asMachineWordArray
							cl_uint: waitList first "number of events to wait on"
							const__cl_event__ptr: waitList second "concatenated event handles"
							cl_event__ptr: (evt := CLEvent new).
	OpenCLError check: result text: 'failed to enqueue copy-image'.
	^self wrapEventHandle: evt
]

{ #category : 'mem read/write/copy' }
OpenCLCommandQueue >> copyImage: srcImage origin: srcOrigin region: srcRegion intoBuffer: destBuffer offset: destOffset waitOn: events [
	"Arguments:
		srcImage	-		An OpenCLImage2D/3D
		srcOrigin	-		3-element Array or IntegerArray
		srcRegion	-		ditto
		destBuffer	-		An OpenCLBuffer
		destOffset	-		integer
		events		-		nil, single OpenCLEvent, or list of them"
	| result evt waitList |
	waitList := OpenCLEvent generateWaitList: events.
	result := OpenCLPrimitiveInterface current
				clEnqueueCopyImageToBuffer__cl_command_queue: id
							cl_mem: srcImage id
							cl_mem: destBuffer id
							const__size_t__ptr: srcOrigin asMachineWordArray
							const__size_t__ptr: srcRegion asMachineWordArray
							size_t: destOffset asMachineWordArray
							cl_uint: waitList first "number of events to wait on"
							const__cl_event__ptr: waitList second "concatenated event handles"
							cl_event__ptr: (evt := CLEvent new).
	OpenCLError check: result text: 'failed to enqueue copy-image-to-buffer'.
	^self wrapEventHandle: evt
]

{ #category : 'accessing' }
OpenCLCommandQueue >> device [
	"Answer the OpenCLDevice that this queue belongs to."
	^device
]

{ #category : 'commands - synchronization' }
OpenCLCommandQueue >> finish [
	"Blocks until all previously-queued commands in the queue have completed."
	| result |
	result := OpenCLPrimitiveInterface current clFinish__cl_command_queue: id.
	OpenCLError check: result text: 'failed to finish events in the command-queue'.

]

{ #category : 'command sync' }
OpenCLCommandQueue >> flush [
	"Issues all previously-queued commands to the device associated with the queue (i.e. so that they won't potentially be buffered forever in the host-API."
	| result |
	result := OpenCLPrimitiveInterface current clFlush__cl_command_queue: id.
	OpenCLError check: result text: 'failed to flush command-queue'.

]

{ #category : 'initialize' }
OpenCLCommandQueue >> initialize [
	super initialize.
	isInOrder := false.  "See #newQueueOn:"
	isProfiling := false. "ditto"
]

{ #category : 'properties' }
OpenCLCommandQueue >> isInOrder [
	^isInOrder
]

{ #category : 'properties' }
OpenCLCommandQueue >> isProfiling [
	^isProfiling
]

{ #category : 'mem mapping' }
OpenCLCommandQueue >> mapBuffer: buf block: shouldBlock flags: flags offset: offset size: sz waitOn: events [
	"This is the most general buffer-mapping method; it corresponds directly to the OpenCL API call.  In practice, more convenient methods will allow omitting many arguments."
	"Arguments:
		buf			-	An OpenCLBuffer
		shouldBlock	-	boolean
		flags		-	CL_MAP_READ and/or CL_MAP_WRITE
		offset		-	integer offset
		size		-	size of area to map
		events		-	nil, single OpenCLEvent, or list of them"
	| ptr evt waitList result |
	waitList := OpenCLEvent generateWaitList: events.
	result := IntegerArray new: 1.
	ptr := OpenCLPrimitiveInterface current
			clEnqueueMapBuffer__cl_command_queue: id
						cl_mem: buf id
						cl_bool: shouldBlock
						cl_map_flags: flags
						size_t: offset
						size_t: sz
						cl_uint: waitList first "number of events to wait on"
						const__cl_event__ptr: waitList second "concatenated event handles"
						cl_event__ptr: (evt := CLEvent new)
						cl_int__ptr: result.
	result := result first.
	OpenCLError check: result text: 'failed to enqueue map-buffer'.
	(evt := OpenCLMapEvent wrappingHandle: evt)
		commandQueue: self;
		pointer: ptr.
	^evt
	
]

{ #category : 'mem mapping' }
OpenCLCommandQueue >> mapBuffer: buf waitOn: events [

	^self mapBuffer: buf block: true flags: CL_MAP_WRITE + CL_MAP_READ offset: 0 size: buf byteSize waitOn: events
]

{ #category : 'mem mapping' }
OpenCLCommandQueue >> mapImage: image block: shouldBlock flags: flags origin: origin region: region waitOn: events [
	"This is the most general image-mapping method; it corresponds directly to the OpenCL API call.  In practice, more convenient methods will allow omitting many arguments."
	"Arguments:
		image			-	An OpenCLBuffer
		shouldBlock	-	boolean
		flags			-	CL_MAP_READ and/or CL_MAP_WRITE, CL_MAP_WRITE_INVALIDATE_REGION
		origin			-		3-element Array or IntegerArray
		region			-		ditto
		events		-	nil, single OpenCLEvent, or list of them"
	| ptr evt waitList result rowPitch slicePitch|
	waitList := OpenCLEvent generateWaitList: events.
	result := IntegerArray new: 1.
	rowPitch := IntegerArray new: 1.
	slicePitch := IntegerArray new: 1.
	ptr := OpenCLPrimitiveInterface current
			clEnqueueMapImage__cl_command_queue: id
						cl_mem: image id
						cl_bool: shouldBlock
						cl_map_flags: flags
						const__size_t__ptr: origin asMachineWordArray
						const__size_t__ptr: region asMachineWordArray
						size_t__ptr: rowPitch
						size_t__ptr: slicePitch
						cl_uint: waitList first "number of events to wait on"
						const__cl_event__ptr: waitList second "concatenated event handles"
						cl_event__ptr: (evt := CLEvent new)
						cl_int__ptr: result.
	result := result first.
	OpenCLError check: result text: 'failed to enqueue map-image'.
	(evt := OpenCLMapEvent wrappingHandle: evt)
		commandQueue: self;
		pointer: ptr;
		rowPitch: rowPitch first;
		slicePitch: slicePitch first.
	^evt
	
]

{ #category : 'deprecated in OpenCL 1.2' }
OpenCLCommandQueue >> marker [
	"Obtain a marker event (an OpenCLEvent) that won't complete until all previously-queued events have completed."
	"Deprecated in OpenCL1.2:
	clEnqueueMarker, clEnqueueBarrier and clEnqueueWaitForEvents have been merged into clEnqueueMarkerWithWaitList and clEnqueueBarrierWithWaitList. The barrier and marker functionality are still the same, but if a non-NULL waiting-list is given it will also continue if all the events have occurred. This was tricky to program before. A new option is that you can fire an event when all previous events have occurred.
	"
	| result evt |
	result := OpenCLPrimitiveInterface current
		clEnqueueMarker__cl_command_queue: id 
					cl_event__ptr: (evt := CLEvent new).
	OpenCLError check: result text: 'failed to obtain marker event'.
	^self wrapEventHandle: evt
]

{ #category : 'mem read/write/copy' }
OpenCLCommandQueue >> readBuffer: buf "an OpenCLBuffer" block: shouldBlock "boolean" offset: offset size: sz pointer: ptr "a ByteArray or ExternalAddress" waitOn: events "nil, single OpenCLEvent, or list of them" [
	| result evt waitList |
	waitList := OpenCLEvent generateWaitList: events.
	result := OpenCLPrimitiveInterface current
				clEnqueueReadBuffer__cl_command_queue: id
							cl_mem: buf id
							cl_bool: shouldBlock asOpenCLBoolean
							size_t: offset
							size_t: sz
							void__ptr: ptr
							cl_uint: waitList first "number of events to wait on"
							const__cl_event__ptr: waitList second "concatenated event handles"
							cl_event__ptr: (evt := CLEvent new).
	OpenCLError check: result text: 'failed to enqueue read-buffer'.
	^self wrapEventHandle: evt
]

{ #category : 'mem read/write/copy' }
OpenCLCommandQueue >> readBuffer: buf into: bytes "a ByteArray" waitOn: events [
	"Convenient blocking read into a ByteArray (or similar type, like IntegerArray or FloatArray)."
	^self readBuffer: buf block: true offset: 0 size: bytes byteSize pointer: bytes waitOn: events
]

{ #category : 'mem read/write/copy' }
OpenCLCommandQueue >> readImage: image block: shouldBlock origin: origin region: region rowPitch: rowPitch slicePitch: slicePitch pointer: ptr waitOn: events [
	"Arguments:
		image		-		An OpenCLImage2D/3D
		shouldBlock	-		boolean
		origin		-		3-element Array or IntegerArray
		region		-		ditto
		rowPitch	-		integer
		slicePitch	-		integer
		ptr			-		a ByteArray or ExternalAddress
		events		-		nil, single OpenCLEvent, or list of them"
	| result evt waitList |
	waitList := OpenCLEvent generateWaitList: events.
	result := OpenCLPrimitiveInterface current
				clEnqueueReadImage__cl_command_queue: id
							cl_mem: image id
							cl_bool: shouldBlock asOpenCLBoolean
							const__size_t__ptr: origin asMachineWordArray
							const__size_t__ptr: region asMachineWordArray
							size_t: rowPitch
							size_t: slicePitch
							void__ptr: ptr asOpenCLArg
							cl_uint: waitList first "number of events to wait on"
							const__cl_event__ptr: waitList second "concatenated event handles"
							cl_event__ptr: (evt := CLEvent new).
	OpenCLError check: result text: 'failed to enqueue read-image'.
	^self wrapEventHandle: evt
]

{ #category : 'kernels and tasks' }
OpenCLCommandQueue >> runKernel: kernel workDim: workDim globalOffset: globalWorkOffset globalSize: globalWorkSize localSize: localWorkSize waitOn: events [
	"Arguments
		kernel					-	An OpenCLKernel
		workDim				-	# of dimensions used to specify local/global work sizes/offsets
										(the sizes of the other arguments must match)
		globalWorkOffset		-	array of integers
		globalWorkSize		-	array of integers
		localWorkSize			-	array of integers
		events					-	nil, single OpenCLEvent, or list of them"
	| result evt waitList |
	waitList := OpenCLEvent generateWaitList: events.
	result := OpenCLPrimitiveInterface current
				clEnqueueNDRangeKernel__cl_command_queue: id
							cl_kernel: kernel id
							cl_uint: workDim
							const__size_t__ptr: globalWorkOffset asMachineWordArray
							const__size_t__ptr: globalWorkSize asMachineWordArray
							const__size_t__ptr: localWorkSize asMachineWordArray
							cl_uint: waitList first "number of events to wait on"
							const__cl_event__ptr: waitList second "concatenated event handles"
							cl_event__ptr: (evt := CLEvent new).	
	OpenCLError check: result text: 'failed to enqueue kernel for execution'.
	^self wrapEventHandle: evt
]

{ #category : 'properties' }
OpenCLCommandQueue >> startProfiling [
	"Enable profiling on this queue... once an event has finished processing, we can query how long it took to process."
	| result |
	isProfiling ifTrue: [^self].
	"Warning: clSetCommandQueueProperty() was deprecated in OpenCL 1.1 and is no longer in headers in 1.2 and 2.0.
	I believe callers should be converted to use clCreateCommandQueueWithProperties()"
	result := OpenCLPrimitiveInterface current
				clSetCommandQueueProperty__cl_command_queue: id
							cl_command_queue_properties: CL_QUEUE_PROFILING_ENABLE
							cl_bool: CL_TRUE
							cl_command_queue_properties__ptr: nil.
	OpenCLError check: result.
	isProfiling := true. "only if we succeed"
]

{ #category : 'properties' }
OpenCLCommandQueue >> stopProfiling [
	"Stop profiling on this queue."
	| result |
	isProfiling ifFalse: [^self].
	"Warning: clSetCommandQueueProperty() was deprecated in OpenCL 1.1 and is no longer in headers in 1.2 and 2.0.
	I believe callers should be converted to use clCreateCommandQueueWithProperties()"
	result := OpenCLPrimitiveInterface current
				clSetCommandQueueProperty__cl_command_queue: id
							cl_command_queue_properties: CL_QUEUE_PROFILING_ENABLE
							cl_bool: CL_FALSE
							cl_command_queue_properties__ptr: nil.
	OpenCLError check: result.
	isProfiling := false. "only if we succeed"
]

{ #category : 'mem mapping' }
OpenCLCommandQueue >> unmap: memObject "image or buffer" pointer: ptr waitOn: events "nil, single OpenCLEvent, or list of them" [
	| evt waitList result |
	waitList := OpenCLEvent generateWaitList: events.
	result := OpenCLPrimitiveInterface current
				clEnqueueUnmapMemObject__cl_command_queue: id
							cl_mem: memObject id
							void__ptr: ptr
							cl_uint: waitList first "number of events to wait on"
							const__cl_event__ptr: waitList second "concatenated event handles"
							cl_event__ptr: (evt := CLEvent new).
	OpenCLError check: result text: 'failed to enqueue unmap-mem-object'.
	^self wrapEventHandle: evt
	
	
]

{ #category : 'deprecated in OpenCL 1.2' }
OpenCLCommandQueue >> waitForEvents: events "single OpenCLEvent, or list of them" [
	"Enqueue a wait for the specified events, so that any future commands will wait until all the events have completed."
	"Deprecated in OpenCL1.2:
	clEnqueueMarker, clEnqueueBarrier and clEnqueueWaitForEvents have been merged into clEnqueueMarkerWithWaitList and clEnqueueBarrierWithWaitList. The barrier and marker functionality are still the same, but if a non-NULL waiting-list is given it will also continue if all the events have occurred. This was tricky to program before. A new option is that you can fire an event when all previous events have occurred.
	"
	| waitList result |
	waitList := OpenCLEvent generateWaitList: events.
	result := OpenCLPrimitiveInterface current 
				clEnqueueWaitForEvents__cl_command_queue: id 
							cl_uint: waitList first 
							const__cl_event__ptr: waitList second.
	OpenCLError check: result text: 'failed to enqueue wait for events'
]

{ #category : 'private' }
OpenCLCommandQueue >> wrapEventHandle: aCLEvent [
	"Answer an event corresponding to an enqueued command."
	^(OpenCLEvent wrappingHandle: aCLEvent) commandQueue: self
]

{ #category : 'mem read/write/copy' }
OpenCLCommandQueue >> writeBuffer: buf "an OpenCLBuffer" block: shouldBlock "boolean" offset: offset size: sz pointer: ptr "a ByteArray or ExternalAddress" waitOn: events "nil, single OpenCLEvent, or list of them" [
	| result evt waitList |
	evt := CLEvent new.
	waitList := OpenCLEvent generateWaitList: events.
	result := OpenCLPrimitiveInterface current
				clEnqueueWriteBuffer__cl_command_queue: id
							cl_mem: buf id
							cl_bool: shouldBlock asOpenCLBoolean
							size_t: offset
							size_t: sz
							const__void__ptr: ptr
							cl_uint: waitList first "number of events to wait on"
							const__cl_event__ptr: waitList second "concatenated event handles"
							cl_event__ptr: (evt := CLEvent new).
	OpenCLError check: result text: 'failed to enqueue write-buffer'.
	^self wrapEventHandle: evt
]

{ #category : 'mem read/write/copy' }
OpenCLCommandQueue >> writeBuffer: buf from: bytes "a ByteArray" waitOn: events [
	"Convenient blocking write from a ByteArray (or similar type, like IntegerArray or FloatArray)."
	^self writeBuffer: buf block: true offset: 0 size: bytes byteSize pointer: bytes waitOn: events
]

{ #category : 'mem read/write/copy' }
OpenCLCommandQueue >> writeImage: image block: shouldBlock origin: origin region: region rowPitch: rowPitch slicePitch: slicePitch pointer: ptr waitOn: events [
	"Arguments:
		image		-		An OpenCLImage2D/3D
		shouldBlock	-		boolean
		origin		-		3-element Array or IntegerArray
		region		-		ditto
		rowPitch	-		integer
		slicePitch	-		integer
		ptr			-		a ByteArray or ExternalAddress
		events		-		nil, single OpenCLEvent, or list of them"
	| result evt waitList |
	waitList := OpenCLEvent generateWaitList: events.
	result := OpenCLPrimitiveInterface current
				clEnqueueWriteImage__cl_command_queue: id
							cl_mem: image id
							cl_bool: shouldBlock asOpenCLBoolean
							const__size_t__ptr: origin asMachineWordArray
							const__size_t__ptr: region asMachineWordArray
							size_t: rowPitch
							size_t: slicePitch
							const__void__ptr: ptr asOpenCLArg
							cl_uint: waitList first "number of events to wait on"
							const__cl_event__ptr: waitList second "concatenated event handles"
							cl_event__ptr: (evt := CLEvent new).
	OpenCLError check: result text: 'failed to enqueue write-image'.
	^self wrapEventHandle: evt
]
