Class {
	#name : 'OpenCLMacOSInterface',
	#superclass : 'OpenCL64BitsPrimitiveInterface',
	#category : 'OpenCL',
	#package : 'OpenCL'
}

{ #category : 'FFI-generated-Program Object APIs' }
OpenCLMacOSInterface class >> clBuildProgram__cl_program: program  [
						cl_uint: num_devices 
						const__cl_device_id__ptr: device_list 
						const__char__ptr: options 
						void__ptrpfn_notifycl_program: pfn_notify 
						void__ptr: user_data 

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clBuildProgram__cl_program: program getHandle asExternalPointer
						cl_uint: num_devices 
						const__cl_device_id__ptr: device_list 
						const__char__ptr: options 
						void__ptrpfn_notifycl_program: pfn_notify 
						void__ptr: user_data .

	^ answer
]

{ #category : 'FFI-generated-Program Object APIs' }
OpenCLMacOSInterface class >> clCompileProgram__cl_program: program  [
						cl_uint: num_devices 
						const__cl_device_id__ptr: device_list 
						const__char__ptr: options 
						cl_uint: num_input_headers 
						const__cl_program__ptr: input_headers 
						const__char__ptr__ptr: header_include_names 
						void__ptr: no_callbacks_jmv 
						void__ptr: user_data 

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clCompileProgram__cl_program: program getHandle asExternalPointer
						cl_uint: num_devices 
						const__cl_device_id__ptr: device_list 
						const__char__ptr: options 
						cl_uint: num_input_headers 
						const__cl_program__ptr: input_headers 
						const__char__ptr__ptr: header_include_names 
						void__ptr: no_callbacks_jmv 
						void__ptr: user_data .

	^ answer
]

{ #category : 'FFI-generated-Memory Object APIs' }
OpenCLMacOSInterface class >> clCreateBuffer__cl_context: context  [
						cl_mem_flags: flags 
						size_t: size 
						void__ptr: host_ptr 
						cl_int__ptr: errcode_ret 

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clCreateBuffer__cl_context: context getHandle asExternalPointer
						cl_mem_flags: flags 
						size_t: size 
						void__ptr: host_ptr 
						cl_int__ptr: errcode_ret .

	answer := CLMem new setHandle: answer getHandle asByteArrayPointer.
	^ answer
]

{ #category : 'FFI-generated-Deprecated OpenCL 2.0 APIs' }
OpenCLMacOSInterface class >> clCreateCommandQueue__cl_context: context  [
						cl_device_id: device 
						cl_command_queue_properties: properties 
						cl_int__ptr: errcode_ret 

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clCreateCommandQueue__cl_context: context getHandle asExternalPointer
						cl_device_id: device getHandle asExternalPointer
						cl_command_queue_properties: properties 
						cl_int__ptr: errcode_ret .

	answer := CLCommandQueue new setHandle: answer getHandle asByteArrayPointer.
	^ answer
]

{ #category : 'FFI-generated-Command Queue APIs' }
OpenCLMacOSInterface class >> clCreateCommandQueueWithProperties__cl_context: context  [
						cl_device_id: device 
						const__cl_queue_properties__ptr: properties 
						cl_int__ptr: errcode_ret 

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clCreateCommandQueueWithProperties__cl_context: context getHandle asExternalPointer
						cl_device_id: device getHandle asExternalPointer
						const__cl_queue_properties__ptr: properties 
						cl_int__ptr: errcode_ret .

	answer := CLCommandQueue new setHandle: answer getHandle asByteArrayPointer.
	^ answer
]

{ #category : 'FFI-generated-Context APIs' }
OpenCLMacOSInterface class >> clCreateContext__const__cl_context_properties__ptr: properties  [
						cl_uint: num_devices 
						const__cl_device_id__ptr: devices 
						void__ptrpfn_notifyconst__char__ptrconst__void__ptrsize_tvoid__ptr: pfn_notify 
						void__ptr: user_data 
						cl_int__ptr: errcode_ret 

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clCreateContext__const__cl_context_properties__ptr: properties 
						cl_uint: num_devices 
						const__cl_device_id__ptr: devices 
						void__ptrpfn_notifyconst__char__ptrconst__void__ptrsize_tvoid__ptr: pfn_notify 
						void__ptr: user_data 
						cl_int__ptr: errcode_ret .

	answer := CLContext new setHandle: answer getHandle asByteArrayPointer.
	^ answer
]

{ #category : 'FFI-generated-Context APIs' }
OpenCLMacOSInterface class >> clCreateContextFromType__const__cl_context_properties__ptr: properties  [
						cl_device_type: device_type 
						void__ptrpfn_notifyconst__char__ptrconst__void__ptrsize_tvoid__ptr: pfn_notify 
						void__ptr: user_data 
						cl_int__ptr: errcode_ret 

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clCreateContextFromType__const__cl_context_properties__ptr: properties 
						cl_device_type: device_type 
						void__ptrpfn_notifyconst__char__ptrconst__void__ptrsize_tvoid__ptr: pfn_notify 
						void__ptr: user_data 
						cl_int__ptr: errcode_ret .

	answer := CLContext new setHandle: answer getHandle asByteArrayPointer.
	^ answer
]

{ #category : 'FFI-generated-Memory Object APIs' }
OpenCLMacOSInterface class >> clCreateImage__cl_context: context  [
						cl_mem_flags: flags 
						const__cl_image_format__ptr: image_format 
						const__cl_image_desc__ptr: image_desc 
						void__ptr: host_ptr 
						cl_int__ptr: errcode_ret 

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clCreateImage__cl_context: context getHandle asExternalPointer
						cl_mem_flags: flags 
						const__cl_image_format__ptr: image_format 
						const__cl_image_desc__ptr: image_desc 
						void__ptr: host_ptr 
						cl_int__ptr: errcode_ret .

	answer := CLMem new setHandle: answer getHandle asByteArrayPointer.
	^ answer
]

{ #category : 'FFI-generated-Deprecated OpenCL 1.1 APIs' }
OpenCLMacOSInterface class >> clCreateImage2D__cl_context: context  [
						cl_mem_flags: flags 
						const__cl_image_format__ptr: image_format 
						size_t: image_width 
						size_t: image_height 
						size_t: image_row_pitch 
						void__ptr: host_ptr 
						cl_int__ptr: errcode_ret 

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clCreateImage2D__cl_context: context getHandle asExternalPointer
						cl_mem_flags: flags 
						const__cl_image_format__ptr: image_format 
						size_t: image_width 
						size_t: image_height 
						size_t: image_row_pitch 
						void__ptr: host_ptr 
						cl_int__ptr: errcode_ret .

	answer := CLMem new setHandle: answer getHandle asByteArrayPointer.
	^ answer
]

{ #category : 'FFI-generated-Deprecated OpenCL 1.1 APIs' }
OpenCLMacOSInterface class >> clCreateImage3D__cl_context: context  [
						cl_mem_flags: flags 
						const__cl_image_format__ptr: image_format 
						size_t: image_width 
						size_t: image_height 
						size_t: image_depth 
						size_t: image_row_pitch 
						size_t: image_slice_pitch 
						void__ptr: host_ptr 
						cl_int__ptr: errcode_ret 

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clCreateImage3D__cl_context: context getHandle asExternalPointer
						cl_mem_flags: flags 
						const__cl_image_format__ptr: image_format 
						size_t: image_width 
						size_t: image_height 
						size_t: image_depth 
						size_t: image_row_pitch 
						size_t: image_slice_pitch 
						void__ptr: host_ptr 
						cl_int__ptr: errcode_ret .

	answer := CLMem new setHandle: answer getHandle asByteArrayPointer.
	^ answer
]

{ #category : 'FFI-generated-Kernel Object APIs' }
OpenCLMacOSInterface class >> clCreateKernel__cl_program: program  [
						const__char__ptr: kernel_name 
						cl_int__ptr: errcode_ret 

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clCreateKernel__cl_program: program getHandle asExternalPointer
						const__char__ptr: kernel_name 
						cl_int__ptr: errcode_ret .

	answer := CLKernel new setHandle: answer getHandle asByteArrayPointer.
	^ answer
]

{ #category : 'FFI-generated-Kernel Object APIs' }
OpenCLMacOSInterface class >> clCreateKernelsInProgram__cl_program: program  [
						cl_uint: num_kernels 
						cl_kernel__ptr: kernels 
						cl_uint__ptr: num_kernels_ret 

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clCreateKernelsInProgram__cl_program: program getHandle asExternalPointer
						cl_uint: num_kernels 
						cl_kernel__ptr: kernels 
						cl_uint__ptr: num_kernels_ret .

	^ answer
]

{ #category : 'FFI-generated-Memory Object APIs' }
OpenCLMacOSInterface class >> clCreatePipe__cl_context: context  [
						cl_mem_flags: flags 
						cl_uint: pipe_packet_size 
						cl_uint: pipe_max_packets 
						const__cl_pipe_properties__ptr: properties 
						cl_int__ptr: errcode_ret 

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clCreatePipe__cl_context: context getHandle asExternalPointer
						cl_mem_flags: flags 
						cl_uint: pipe_packet_size 
						cl_uint: pipe_max_packets 
						const__cl_pipe_properties__ptr: properties 
						cl_int__ptr: errcode_ret .

	answer := CLMem new setHandle: answer getHandle asByteArrayPointer.
	^ answer
]

{ #category : 'FFI-generated-Program Object APIs' }
OpenCLMacOSInterface class >> clCreateProgramWithBinary__cl_context: context  [
						cl_uint: num_devices 
						const__cl_device_id__ptr: device_list 
						const__size_t__ptr: lengths 
						const__unsignedchar__ptr__ptr: binaries 
						cl_int__ptr: binary_status 
						cl_int__ptr: errcode_ret 

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clCreateProgramWithBinary__cl_context: context getHandle asExternalPointer
						cl_uint: num_devices 
						const__cl_device_id__ptr: device_list 
						const__size_t__ptr: lengths 
						const__unsignedchar__ptr__ptr: binaries 
						cl_int__ptr: binary_status 
						cl_int__ptr: errcode_ret .

	answer := CLProgram new setHandle: answer getHandle asByteArrayPointer.
	^ answer
]

{ #category : 'FFI-generated-Program Object APIs' }
OpenCLMacOSInterface class >> clCreateProgramWithBuiltInKernels__cl_context: context  [
						cl_uint: num_devices 
						const__cl_device_id__ptr: device_list 
						const__char__ptr: kernel_names 
						cl_int__ptr: errcode_ret 

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clCreateProgramWithBuiltInKernels__cl_context: context getHandle asExternalPointer
						cl_uint: num_devices 
						const__cl_device_id__ptr: device_list 
						const__char__ptr: kernel_names 
						cl_int__ptr: errcode_ret .

	answer := CLProgram new setHandle: answer getHandle asByteArrayPointer.
	^ answer
]

{ #category : 'FFI-generated-Program Object APIs' }
OpenCLMacOSInterface class >> clCreateProgramWithSource__cl_context: context  [
						cl_uint: count 
						const__char__ptr__ptr: strings 
						const__size_t__ptr: lengths 
						cl_int__ptr: errcode_ret 

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clCreateProgramWithSource__cl_context: context getHandle asExternalPointer
						cl_uint: count 
						const__char__ptr__ptr: strings 
						const__size_t__ptr: lengths 
						cl_int__ptr: errcode_ret .

	answer := CLProgram new setHandle: answer getHandle asByteArrayPointer.
	^ answer
]

{ #category : 'FFI-generated-Deprecated OpenCL 2.0 APIs' }
OpenCLMacOSInterface class >> clCreateSampler__cl_context: context  [
						cl_bool: normalized_coords 
						cl_addressing_mode: addressing_mode 
						cl_filter_mode: filter_mode 
						cl_int__ptr: errcode_ret 

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clCreateSampler__cl_context: context getHandle asExternalPointer
						cl_bool: normalized_coords 
						cl_addressing_mode: addressing_mode 
						cl_filter_mode: filter_mode 
						cl_int__ptr: errcode_ret .

	answer := CLSampler new setHandle: answer getHandle asByteArrayPointer.
	^ answer
]

{ #category : 'FFI-generated-Sampler APIs' }
OpenCLMacOSInterface class >> clCreateSamplerWithProperties__cl_context: context  [
						const__cl_sampler_properties__ptr: normalized_coords 
						cl_int__ptr: errcode_ret 

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clCreateSamplerWithProperties__cl_context: context getHandle asExternalPointer
						const__cl_sampler_properties__ptr: normalized_coords 
						cl_int__ptr: errcode_ret .

	answer := CLSampler new setHandle: answer getHandle asByteArrayPointer.
	^ answer
]

{ #category : 'FFI-generated-Memory Object APIs' }
OpenCLMacOSInterface class >> clCreateSubBuffer__cl_mem: buffer  [
						cl_mem_flags: flags 
						cl_buffer_create_type: buffer_create_type 
						const__void__ptr: buffer_create_info 
						cl_int__ptr: errcode_ret 

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clCreateSubBuffer__cl_mem: buffer getHandle asExternalPointer
						cl_mem_flags: flags 
						cl_buffer_create_type: buffer_create_type 
						const__void__ptr: buffer_create_info 
						cl_int__ptr: errcode_ret .

	answer := CLMem new setHandle: answer getHandle asByteArrayPointer.
	^ answer
]

{ #category : 'FFI-generated-Device APIs' }
OpenCLMacOSInterface class >> clCreateSubDevices__cl_device_id: in_device  [
						const__cl_device_partition_property__ptr: properties 
						cl_uint: num_devices 
						cl_device_id__ptr: out_devices 
						cl_uint__ptr: num_devices_ret 

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clCreateSubDevices__cl_device_id: in_device getHandle asExternalPointer
						const__cl_device_partition_property__ptr: properties 
						cl_uint: num_devices 
						cl_device_id__ptr: out_devices 
						cl_uint__ptr: num_devices_ret .

	^ answer
]

{ #category : 'FFI-generated-Event Object APIs' }
OpenCLMacOSInterface class >> clCreateUserEvent__cl_context: context  [
						cl_int__ptr: errcode_ret 

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clCreateUserEvent__cl_context: context getHandle asExternalPointer
						cl_int__ptr: errcode_ret .

	answer := CLEvent new setHandle: answer getHandle asByteArrayPointer.
	^ answer
]

{ #category : 'FFI-generated-Deprecated OpenCL 1.1 APIs' }
OpenCLMacOSInterface class >> clEnqueueBarrier__cl_command_queue: command_queue  [

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clEnqueueBarrier__cl_command_queue: command_queue getHandle asExternalPointer.

	^ answer
]

{ #category : 'FFI-generated-Enqueued Commands APIs' }
OpenCLMacOSInterface class >> clEnqueueBarrierWithWaitList__cl_command_queue: command_queue  [
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event 

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clEnqueueBarrierWithWaitList__cl_command_queue: command_queue getHandle asExternalPointer
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event .

	^ answer
]

{ #category : 'FFI-generated-Enqueued Commands APIs' }
OpenCLMacOSInterface class >> clEnqueueCopyBuffer__cl_command_queue: command_queue  [
						cl_mem: src_buffer 
						cl_mem: dst_buffer 
						size_t: src_offset 
						size_t: dst_offset 
						size_t: size 
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event 

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clEnqueueCopyBuffer__cl_command_queue: command_queue getHandle asExternalPointer
						cl_mem: src_buffer getHandle asExternalPointer
						cl_mem: dst_buffer getHandle asExternalPointer
						size_t: src_offset 
						size_t: dst_offset 
						size_t: size 
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event .

	^ answer
]

{ #category : 'FFI-generated-Enqueued Commands APIs' }
OpenCLMacOSInterface class >> clEnqueueCopyBufferRect__cl_command_queue: command_queue  [
						cl_mem: src_buffer 
						cl_mem: dst_buffer 
						const__size_t__ptr: src_origin 
						const__size_t__ptr: dst_origin 
						const__size_t__ptr: region 
						size_t: src_row_pitch 
						size_t: src_slice_pitch 
						size_t: dst_row_pitch 
						size_t: dst_slice_pitch 
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event 

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clEnqueueCopyBufferRect__cl_command_queue: command_queue getHandle asExternalPointer
						cl_mem: src_buffer getHandle asExternalPointer
						cl_mem: dst_buffer getHandle asExternalPointer
						const__size_t__ptr: src_origin 
						const__size_t__ptr: dst_origin 
						const__size_t__ptr: region 
						size_t: src_row_pitch 
						size_t: src_slice_pitch 
						size_t: dst_row_pitch 
						size_t: dst_slice_pitch 
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event .

	^ answer
]

{ #category : 'FFI-generated-Enqueued Commands APIs' }
OpenCLMacOSInterface class >> clEnqueueCopyBufferToImage__cl_command_queue: command_queue  [
						cl_mem: src_buffer 
						cl_mem: dst_image 
						size_t: src_offset 
						const__size_t__ptr: dst_origin 
						const__size_t__ptr: region 
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event 

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clEnqueueCopyBufferToImage__cl_command_queue: command_queue getHandle asExternalPointer
						cl_mem: src_buffer getHandle asExternalPointer
						cl_mem: dst_image getHandle asExternalPointer
						size_t: src_offset 
						const__size_t__ptr: dst_origin 
						const__size_t__ptr: region 
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event .

	^ answer
]

{ #category : 'FFI-generated-Enqueued Commands APIs' }
OpenCLMacOSInterface class >> clEnqueueCopyImage__cl_command_queue: command_queue  [
						cl_mem: src_image 
						cl_mem: dst_image 
						const__size_t__ptr: src_origin 
						const__size_t__ptr: dst_origin 
						const__size_t__ptr: region 
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event 

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clEnqueueCopyImage__cl_command_queue: command_queue getHandle asExternalPointer
						cl_mem: src_image getHandle asExternalPointer
						cl_mem: dst_image getHandle asExternalPointer
						const__size_t__ptr: src_origin 
						const__size_t__ptr: dst_origin 
						const__size_t__ptr: region 
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event .

	^ answer
]

{ #category : 'FFI-generated-Enqueued Commands APIs' }
OpenCLMacOSInterface class >> clEnqueueCopyImageToBuffer__cl_command_queue: command_queue  [
						cl_mem: src_image 
						cl_mem: dst_buffer 
						const__size_t__ptr: src_origin 
						const__size_t__ptr: region 
						size_t: dst_offset 
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event 

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clEnqueueCopyImageToBuffer__cl_command_queue: command_queue getHandle asExternalPointer
						cl_mem: src_image getHandle asExternalPointer
						cl_mem: dst_buffer getHandle asExternalPointer
						const__size_t__ptr: src_origin 
						const__size_t__ptr: region 
						size_t: dst_offset 
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event .

	^ answer
]

{ #category : 'FFI-generated-Enqueued Commands APIs' }
OpenCLMacOSInterface class >> clEnqueueFillBuffer__cl_command_queue: command_queue  [
						cl_mem: buffer 
						const__void__ptr: pattern 
						size_t: pattern_size 
						size_t: offset 
						size_t: size 
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event 

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clEnqueueFillBuffer__cl_command_queue: command_queue getHandle asExternalPointer
						cl_mem: buffer getHandle asExternalPointer
						const__void__ptr: pattern 
						size_t: pattern_size 
						size_t: offset 
						size_t: size 
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event .

	^ answer
]

{ #category : 'FFI-generated-Enqueued Commands APIs' }
OpenCLMacOSInterface class >> clEnqueueFillImage__cl_command_queue: command_queue  [
						cl_mem: image 
						const__void__ptr: fill_color 
						const__size_t__ptr: origin 
						const__size_t__ptr: region 
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event 

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clEnqueueFillImage__cl_command_queue: command_queue getHandle asExternalPointer
						cl_mem: image getHandle asExternalPointer
						const__void__ptr: fill_color 
						const__size_t__ptr: origin 
						const__size_t__ptr: region 
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event .

	^ answer
]

{ #category : 'FFI-generated-Enqueued Commands APIs' }
OpenCLMacOSInterface class >> clEnqueueMapBuffer__cl_command_queue: command_queue  [
						cl_mem: buffer 
						cl_bool: blocking_map 
						cl_map_flags: map_flags 
						size_t: offset 
						size_t: size 
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event 
						cl_int__ptr: errcode_ret 

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clEnqueueMapBuffer__cl_command_queue: command_queue getHandle asExternalPointer
						cl_mem: buffer getHandle asExternalPointer
						cl_bool: blocking_map 
						cl_map_flags: map_flags 
						size_t: offset 
						size_t: size 
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event 
						cl_int__ptr: errcode_ret .

	^ answer
]

{ #category : 'FFI-generated-Enqueued Commands APIs' }
OpenCLMacOSInterface class >> clEnqueueMapImage__cl_command_queue: command_queue  [
						cl_mem: image 
						cl_bool: blocking_map 
						cl_map_flags: map_flags 
						const__size_t__ptr: origin 
						const__size_t__ptr: region 
						size_t__ptr: image_row_pitch 
						size_t__ptr: image_slice_pitch 
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event 
						cl_int__ptr: errcode_ret 

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clEnqueueMapImage__cl_command_queue: command_queue getHandle asExternalPointer
						cl_mem: image getHandle asExternalPointer
						cl_bool: blocking_map 
						cl_map_flags: map_flags 
						const__size_t__ptr: origin 
						const__size_t__ptr: region 
						size_t__ptr: image_row_pitch 
						size_t__ptr: image_slice_pitch 
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event 
						cl_int__ptr: errcode_ret .

	^ answer
]

{ #category : 'FFI-generated-Deprecated OpenCL 1.1 APIs' }
OpenCLMacOSInterface class >> clEnqueueMarker__cl_command_queue: command_queue  [
						cl_event__ptr: event 

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clEnqueueMarker__cl_command_queue: command_queue getHandle asExternalPointer
						cl_event__ptr: event .

	^ answer
]

{ #category : 'FFI-generated-Enqueued Commands APIs' }
OpenCLMacOSInterface class >> clEnqueueMarkerWithWaitList__cl_command_queue: command_queue  [
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event 

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clEnqueueMarkerWithWaitList__cl_command_queue: command_queue getHandle asExternalPointer
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event .

	^ answer
]

{ #category : 'FFI-generated-Enqueued Commands APIs' }
OpenCLMacOSInterface class >> clEnqueueMigrateMemObjects__cl_command_queue: command_queue  [
						cl_uint: num_mem_objects 
						const__cl_mem__ptr: mem_objects 
						cl_mem_migration_flags: flags 
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event 

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clEnqueueMigrateMemObjects__cl_command_queue: command_queue getHandle asExternalPointer
						cl_uint: num_mem_objects 
						const__cl_mem__ptr: mem_objects 
						cl_mem_migration_flags: flags 
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event .

	^ answer
]

{ #category : 'FFI-generated-Enqueued Commands APIs' }
OpenCLMacOSInterface class >> clEnqueueNDRangeKernel__cl_command_queue: command_queue  [
						cl_kernel: kernel 
						cl_uint: work_dim 
						const__size_t__ptr: global_work_offset 
						const__size_t__ptr: global_work_size 
						const__size_t__ptr: local_work_size 
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event 

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clEnqueueNDRangeKernel__cl_command_queue: command_queue getHandle asExternalPointer
						cl_kernel: kernel getHandle asExternalPointer
						cl_uint: work_dim 
						const__size_t__ptr: global_work_offset 
						const__size_t__ptr: global_work_size 
						const__size_t__ptr: local_work_size 
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event .

	^ answer
]

{ #category : 'FFI-generated-Enqueued Commands APIs' }
OpenCLMacOSInterface class >> clEnqueueNativeKernel__cl_command_queue: command_queue  [
						void__ptruser_funcvoid__ptrvoid__ptr: user_func 
						size_t: cb_args 
						cl_uint: num_mem_objects 
						const__cl_mem__ptr: mem_list 
						const__void__ptr__ptr: args_mem_loc 
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event 

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clEnqueueNativeKernel__cl_command_queue: command_queue getHandle asExternalPointer
						void__ptruser_funcvoid__ptrvoid__ptr: user_func 
						size_t: cb_args 
						cl_uint: num_mem_objects 
						const__cl_mem__ptr: mem_list 
						const__void__ptr__ptr: args_mem_loc 
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event .

	^ answer
]

{ #category : 'FFI-generated-Enqueued Commands APIs' }
OpenCLMacOSInterface class >> clEnqueueReadBuffer__cl_command_queue: command_queue  [
						cl_mem: buffer 
						cl_bool: blocking_read 
						size_t: offset 
						size_t: size 
						void__ptr: ptr 
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event 

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clEnqueueReadBuffer__cl_command_queue: command_queue getHandle asExternalPointer
						cl_mem: buffer getHandle asExternalPointer
						cl_bool: blocking_read 
						size_t: offset 
						size_t: size 
						void__ptr: ptr 
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event .

	^ answer
]

{ #category : 'FFI-generated-Enqueued Commands APIs' }
OpenCLMacOSInterface class >> clEnqueueReadBufferRect__cl_command_queue: command_queue  [
						cl_mem: buffer 
						cl_bool: blocking_read 
						const__size_t__ptr: buffer_offset 
						const__size_t__ptr: host_offset 
						const__size_t__ptr: region 
						size_t: buffer_row_pitch 
						size_t: buffer_slice_pitch 
						size_t: host_row_pitch 
						size_t: host_slice_pitch 
						void__ptr: ptr 
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event 

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clEnqueueReadBufferRect__cl_command_queue: command_queue getHandle asExternalPointer
						cl_mem: buffer getHandle asExternalPointer
						cl_bool: blocking_read 
						const__size_t__ptr: buffer_offset 
						const__size_t__ptr: host_offset 
						const__size_t__ptr: region 
						size_t: buffer_row_pitch 
						size_t: buffer_slice_pitch 
						size_t: host_row_pitch 
						size_t: host_slice_pitch 
						void__ptr: ptr 
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event .

	^ answer
]

{ #category : 'FFI-generated-Enqueued Commands APIs' }
OpenCLMacOSInterface class >> clEnqueueReadImage__cl_command_queue: command_queue  [
						cl_mem: image 
						cl_bool: blocking_read 
						const__size_t__ptr: origin 
						const__size_t__ptr: region 
						size_t: row_pitch 
						size_t: slice_pitch 
						void__ptr: ptr 
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event 

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clEnqueueReadImage__cl_command_queue: command_queue getHandle asExternalPointer
						cl_mem: image getHandle asExternalPointer
						cl_bool: blocking_read 
						const__size_t__ptr: origin 
						const__size_t__ptr: region 
						size_t: row_pitch 
						size_t: slice_pitch 
						void__ptr: ptr 
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event .

	^ answer
]

{ #category : 'FFI-generated-Enqueued Commands APIs' }
OpenCLMacOSInterface class >> clEnqueueSVMFree__cl_command_queue: command_queue  [
						cl_uint: num_svm_pointers 
						void__ptr: svm_pointers 
						void__ptr: no_callbacks_jmv 
						void__ptr: user_data 
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event 

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clEnqueueSVMFree__cl_command_queue: command_queue getHandle asExternalPointer
						cl_uint: num_svm_pointers 
						void__ptr: svm_pointers 
						void__ptr: no_callbacks_jmv 
						void__ptr: user_data 
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event .

	^ answer
]

{ #category : 'FFI-generated-Enqueued Commands APIs' }
OpenCLMacOSInterface class >> clEnqueueSVMMap__cl_command_queue: command_queue  [
						cl_bool: blocking_map 
						cl_map_flags: flags 
						void__ptr: svm_ptr 
						size_t: size 
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event 

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clEnqueueSVMMap__cl_command_queue: command_queue getHandle asExternalPointer
						cl_bool: blocking_map 
						cl_map_flags: flags 
						void__ptr: svm_ptr 
						size_t: size 
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event .

	^ answer
]

{ #category : 'FFI-generated-Enqueued Commands APIs' }
OpenCLMacOSInterface class >> clEnqueueSVMMemFill__cl_command_queue: command_queue  [
						void__ptr: svm_ptr 
						const__void__ptr: pattern 
						size_t: pattern_size 
						size_t: size 
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event 

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clEnqueueSVMMemFill__cl_command_queue: command_queue getHandle asExternalPointer
						void__ptr: svm_ptr 
						const__void__ptr: pattern 
						size_t: pattern_size 
						size_t: size 
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event .

	^ answer
]

{ #category : 'FFI-generated-Enqueued Commands APIs' }
OpenCLMacOSInterface class >> clEnqueueSVMMemcpy__cl_command_queue: command_queue  [
						cl_bool: blocking_copy 
						void__ptr: dst_ptr 
						const__void__ptr: src_ptr 
						size_t: size 
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event 

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clEnqueueSVMMemcpy__cl_command_queue: command_queue getHandle asExternalPointer
						cl_bool: blocking_copy 
						void__ptr: dst_ptr 
						const__void__ptr: src_ptr 
						size_t: size 
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event .

	^ answer
]

{ #category : 'FFI-generated-Enqueued Commands APIs' }
OpenCLMacOSInterface class >> clEnqueueSVMUnmap__cl_command_queue: command_queue  [
						void__ptr: svm_ptr 
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event 

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clEnqueueSVMUnmap__cl_command_queue: command_queue getHandle asExternalPointer
						void__ptr: svm_ptr 
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event .

	^ answer
]

{ #category : 'FFI-generated-Deprecated OpenCL 2.0 APIs' }
OpenCLMacOSInterface class >> clEnqueueTask__cl_command_queue: command_queue  [
						cl_kernel: kernel 
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event 

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clEnqueueTask__cl_command_queue: command_queue getHandle asExternalPointer
						cl_kernel: kernel getHandle asExternalPointer
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event .

	^ answer
]

{ #category : 'FFI-generated-Enqueued Commands APIs' }
OpenCLMacOSInterface class >> clEnqueueUnmapMemObject__cl_command_queue: command_queue  [
						cl_mem: memobj 
						void__ptr: mapped_ptr 
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event 

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clEnqueueUnmapMemObject__cl_command_queue: command_queue getHandle asExternalPointer
						cl_mem: memobj getHandle asExternalPointer
						void__ptr: mapped_ptr 
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event .

	^ answer
]

{ #category : 'FFI-generated-Deprecated OpenCL 1.1 APIs' }
OpenCLMacOSInterface class >> clEnqueueWaitForEvents__cl_command_queue: command_queue  [
						cl_uint: num_events 
						const__cl_event__ptr: event_list 

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clEnqueueWaitForEvents__cl_command_queue: command_queue getHandle asExternalPointer
						cl_uint: num_events 
						const__cl_event__ptr: event_list .

	^ answer
]

{ #category : 'FFI-generated-Enqueued Commands APIs' }
OpenCLMacOSInterface class >> clEnqueueWriteBuffer__cl_command_queue: command_queue  [
						cl_mem: buffer 
						cl_bool: blocking_write 
						size_t: offset 
						size_t: size 
						const__void__ptr: ptr 
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event 

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clEnqueueWriteBuffer__cl_command_queue: command_queue getHandle asExternalPointer
						cl_mem: buffer getHandle asExternalPointer
						cl_bool: blocking_write 
						size_t: offset 
						size_t: size 
						const__void__ptr: ptr 
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event .

	^ answer
]

{ #category : 'FFI-generated-Enqueued Commands APIs' }
OpenCLMacOSInterface class >> clEnqueueWriteBufferRect__cl_command_queue: command_queue  [
						cl_mem: buffer 
						cl_bool: blocking_write 
						const__size_t__ptr: buffer_offset 
						const__size_t__ptr: host_offset 
						const__size_t__ptr: region 
						size_t: buffer_row_pitch 
						size_t: buffer_slice_pitch 
						size_t: host_row_pitch 
						size_t: host_slice_pitch 
						const__void__ptr: ptr 
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event 

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clEnqueueWriteBufferRect__cl_command_queue: command_queue getHandle asExternalPointer
						cl_mem: buffer getHandle asExternalPointer
						cl_bool: blocking_write 
						const__size_t__ptr: buffer_offset 
						const__size_t__ptr: host_offset 
						const__size_t__ptr: region 
						size_t: buffer_row_pitch 
						size_t: buffer_slice_pitch 
						size_t: host_row_pitch 
						size_t: host_slice_pitch 
						const__void__ptr: ptr 
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event .

	^ answer
]

{ #category : 'FFI-generated-Enqueued Commands APIs' }
OpenCLMacOSInterface class >> clEnqueueWriteImage__cl_command_queue: command_queue  [
						cl_mem: image 
						cl_bool: blocking_write 
						const__size_t__ptr: origin 
						const__size_t__ptr: region 
						size_t: input_row_pitch 
						size_t: input_slice_pitch 
						const__void__ptr: ptr 
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event 

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clEnqueueWriteImage__cl_command_queue: command_queue getHandle asExternalPointer
						cl_mem: image getHandle asExternalPointer
						cl_bool: blocking_write 
						const__size_t__ptr: origin 
						const__size_t__ptr: region 
						size_t: input_row_pitch 
						size_t: input_slice_pitch 
						const__void__ptr: ptr 
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event .

	^ answer
]

{ #category : 'FFI-generated-Flush and Finish APIs' }
OpenCLMacOSInterface class >> clFinish__cl_command_queue: command_queue  [

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clFinish__cl_command_queue: command_queue getHandle asExternalPointer.

	^ answer
]

{ #category : 'FFI-generated-Flush and Finish APIs' }
OpenCLMacOSInterface class >> clFlush__cl_command_queue: command_queue  [

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clFlush__cl_command_queue: command_queue getHandle asExternalPointer.

	^ answer
]

{ #category : 'FFI-generated-Command Queue APIs' }
OpenCLMacOSInterface class >> clGetCommandQueueInfo__cl_command_queue: command_queue  [
						cl_command_queue_info: param_name 
						size_t: param_value_size 
						void__ptr: param_value 
						size_t__ptr: param_value_size_ret 

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clGetCommandQueueInfo__cl_command_queue: command_queue getHandle asExternalPointer
						cl_command_queue_info: param_name 
						size_t: param_value_size 
						void__ptr: param_value 
						size_t__ptr: param_value_size_ret .

	^ answer
]

{ #category : 'FFI-generated-Context APIs' }
OpenCLMacOSInterface class >> clGetContextInfo__cl_context: context  [
						cl_context_info: param_name 
						size_t: param_value_size 
						void__ptr: param_value 
						size_t__ptr: param_value_size_ret 

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clGetContextInfo__cl_context: context getHandle asExternalPointer
						cl_context_info: param_name 
						size_t: param_value_size 
						void__ptr: param_value 
						size_t__ptr: param_value_size_ret .

	^ answer
]

{ #category : 'FFI-generated-Device APIs' }
OpenCLMacOSInterface class >> clGetDeviceIDs__cl_platform_id: platform  [
						cl_device_type: device_type 
						cl_uint: num_entries 
						cl_device_id__ptr: devices 
						cl_uint__ptr: num_devices 

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clGetDeviceIDs__cl_platform_id: platform getHandle asExternalPointer
						cl_device_type: device_type 
						cl_uint: num_entries 
						cl_device_id__ptr: devices 
						cl_uint__ptr: num_devices .

	^ answer
]

{ #category : 'FFI-generated-Device APIs' }
OpenCLMacOSInterface class >> clGetDeviceInfo__cl_device_id: device  [
						cl_device_info: param_name 
						size_t: param_value_size 
						void__ptr: param_value 
						size_t__ptr: param_value_size_ret 

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clGetDeviceInfo__cl_device_id: device getHandle asExternalPointer
						cl_device_info: param_name 
						size_t: param_value_size 
						void__ptr: param_value 
						size_t__ptr: param_value_size_ret .

	^ answer
]

{ #category : 'FFI-generated-Event Object APIs' }
OpenCLMacOSInterface class >> clGetEventInfo__cl_event: event  [
						cl_event_info: param_name 
						size_t: param_value_size 
						void__ptr: param_value 
						size_t__ptr: param_value_size_ret 

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clGetEventInfo__cl_event: event getHandle asExternalPointer
						cl_event_info: param_name 
						size_t: param_value_size 
						void__ptr: param_value 
						size_t__ptr: param_value_size_ret .

	^ answer
]

{ #category : 'FFI-generated-Profiling APIs' }
OpenCLMacOSInterface class >> clGetEventProfilingInfo__cl_event: event  [
						cl_profiling_info: param_name 
						size_t: param_value_size 
						void__ptr: param_value 
						size_t__ptr: param_value_size_ret 

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clGetEventProfilingInfo__cl_event: event getHandle asExternalPointer
						cl_profiling_info: param_name 
						size_t: param_value_size 
						void__ptr: param_value 
						size_t__ptr: param_value_size_ret .

	^ answer
]

{ #category : 'FFI-generated-Deprecated OpenCL 1.1 APIs' }
OpenCLMacOSInterface class >> clGetExtensionFunctionAddress__const__char__ptr: func_name  [

	"This method was automatically generated."

	"void * clGetExtensionFunctionAddress(
			const char * func_name
	);"
	<apicall: void* 'clGetExtensionFunctionAddress' (schar*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-Extension function access' }
OpenCLMacOSInterface class >> clGetExtensionFunctionAddressForPlatform__cl_platform_id: platform  [
						const__char__ptr: func_name 

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clGetExtensionFunctionAddressForPlatform__cl_platform_id: platform getHandle asExternalPointer
						const__char__ptr: func_name .

	^ answer
]

{ #category : 'FFI-generated-Memory Object APIs' }
OpenCLMacOSInterface class >> clGetImageInfo__cl_mem: image  [
						cl_image_info: param_name 
						size_t: param_value_size 
						void__ptr: param_value 
						size_t__ptr: param_value_size_ret 

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clGetImageInfo__cl_mem: image getHandle asExternalPointer
						cl_image_info: param_name 
						size_t: param_value_size 
						void__ptr: param_value 
						size_t__ptr: param_value_size_ret .

	^ answer
]

{ #category : 'FFI-generated-Kernel Object APIs' }
OpenCLMacOSInterface class >> clGetKernelArgInfo__cl_kernel: kernel  [
						cl_uint: arg_indx 
						cl_kernel_arg_info: param_name 
						size_t: param_value_size 
						void__ptr: param_value 
						size_t__ptr: param_value_size_ret 

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clGetKernelArgInfo__cl_kernel: kernel getHandle asExternalPointer
						cl_uint: arg_indx 
						cl_kernel_arg_info: param_name 
						size_t: param_value_size 
						void__ptr: param_value 
						size_t__ptr: param_value_size_ret .

	^ answer
]

{ #category : 'FFI-generated-Kernel Object APIs' }
OpenCLMacOSInterface class >> clGetKernelInfo__cl_kernel: kernel  [
						cl_kernel_info: param_name 
						size_t: param_value_size 
						void__ptr: param_value 
						size_t__ptr: param_value_size_ret 

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clGetKernelInfo__cl_kernel: kernel getHandle asExternalPointer
						cl_kernel_info: param_name 
						size_t: param_value_size 
						void__ptr: param_value 
						size_t__ptr: param_value_size_ret .

	^ answer
]

{ #category : 'FFI-generated-Kernel Object APIs' }
OpenCLMacOSInterface class >> clGetKernelWorkGroupInfo__cl_kernel: kernel  [
						cl_device_id: device 
						cl_kernel_work_group_info: param_name 
						size_t: param_value_size 
						void__ptr: param_value 
						size_t__ptr: param_value_size_ret 

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clGetKernelWorkGroupInfo__cl_kernel: kernel getHandle asExternalPointer
						cl_device_id: device getHandle asExternalPointer
						cl_kernel_work_group_info: param_name 
						size_t: param_value_size 
						void__ptr: param_value 
						size_t__ptr: param_value_size_ret .

	^ answer
]

{ #category : 'FFI-generated-Memory Object APIs' }
OpenCLMacOSInterface class >> clGetMemObjectInfo__cl_mem: memobj  [
						cl_mem_info: param_name 
						size_t: param_value_size 
						void__ptr: param_value 
						size_t__ptr: param_value_size_ret 

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clGetMemObjectInfo__cl_mem: memobj getHandle asExternalPointer
						cl_mem_info: param_name 
						size_t: param_value_size 
						void__ptr: param_value 
						size_t__ptr: param_value_size_ret .

	^ answer
]

{ #category : 'FFI-generated-Memory Object APIs' }
OpenCLMacOSInterface class >> clGetPipeInfo__cl_mem: pipe  [
						cl_pipe_info: param_name 
						size_t: param_value_size 
						void__ptr: param_value 
						size_t__ptr: param_value_size_ret 

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clGetPipeInfo__cl_mem: pipe getHandle asExternalPointer
						cl_pipe_info: param_name 
						size_t: param_value_size 
						void__ptr: param_value 
						size_t__ptr: param_value_size_ret .

	^ answer
]

{ #category : 'FFI-generated-Platform API' }
OpenCLMacOSInterface class >> clGetPlatformIDs__cl_uint: num_entries  [
						cl_platform_id__ptr: platforms 
						cl_uint__ptr: num_platforms 

	"This method was automatically generated."

	"cl_int clGetPlatformIDs(
			cl_uint num_entries, 
			cl_platform_id * platforms, 
			cl_uint * num_platforms
	);"
	<apicall: long 'clGetPlatformIDs' (ulong CLPlatformID* ulong*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-Platform API' }
OpenCLMacOSInterface class >> clGetPlatformInfo__cl_platform_id: platform  [
						cl_platform_info: param_name 
						size_t: param_value_size 
						void__ptr: param_value 
						size_t__ptr: param_value_size_ret 

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clGetPlatformInfo__cl_platform_id: platform getHandle asExternalPointer
						cl_platform_info: param_name 
						size_t: param_value_size 
						void__ptr: param_value 
						size_t__ptr: param_value_size_ret .

	^ answer
]

{ #category : 'FFI-generated-Program Object APIs' }
OpenCLMacOSInterface class >> clGetProgramBuildInfo__cl_program: program  [
						cl_device_id: device 
						cl_program_build_info: param_name 
						size_t: param_value_size 
						void__ptr: param_value 
						size_t__ptr: param_value_size_ret 

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clGetProgramBuildInfo__cl_program: program getHandle asExternalPointer
						cl_device_id: device getHandle asExternalPointer
						cl_program_build_info: param_name 
						size_t: param_value_size 
						void__ptr: param_value 
						size_t__ptr: param_value_size_ret .

	^ answer
]

{ #category : 'FFI-generated-Program Object APIs' }
OpenCLMacOSInterface class >> clGetProgramInfo__cl_program: program  [
						cl_program_info: param_name 
						size_t: param_value_size 
						void__ptr: param_value 
						size_t__ptr: param_value_size_ret 

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clGetProgramInfo__cl_program: program getHandle asExternalPointer
						cl_program_info: param_name 
						size_t: param_value_size 
						void__ptr: param_value 
						size_t__ptr: param_value_size_ret .

	^ answer
]

{ #category : 'FFI-generated-Sampler APIs' }
OpenCLMacOSInterface class >> clGetSamplerInfo__cl_sampler: sampler  [
						cl_sampler_info: param_name 
						size_t: param_value_size 
						void__ptr: param_value 
						size_t__ptr: param_value_size_ret 

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clGetSamplerInfo__cl_sampler: sampler getHandle asExternalPointer
						cl_sampler_info: param_name 
						size_t: param_value_size 
						void__ptr: param_value 
						size_t__ptr: param_value_size_ret .

	^ answer
]

{ #category : 'FFI-generated-Memory Object APIs' }
OpenCLMacOSInterface class >> clGetSupportedImageFormats__cl_context: context  [
						cl_mem_flags: flags 
						cl_mem_object_type: image_type 
						cl_uint: num_entries 
						cl_image_format__ptr: image_formats 
						cl_uint__ptr: num_image_formats 

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clGetSupportedImageFormats__cl_context: context getHandle asExternalPointer
						cl_mem_flags: flags 
						cl_mem_object_type: image_type 
						cl_uint: num_entries 
						cl_image_format__ptr: image_formats 
						cl_uint__ptr: num_image_formats .

	^ answer
]

{ #category : 'FFI-generated-Program Object APIs' }
OpenCLMacOSInterface class >> clLinkProgram__cl_context: context  [
						cl_uint: num_devices 
						const__cl_device_id__ptr: device_list 
						const__char__ptr: options 
						cl_uint: num_input_programs 
						const__cl_program__ptr: input_programs 
						void__ptr: no_callbacks_jmv 
						void__ptr: user_data 
						cl_int__ptr: errcode_ret 

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clLinkProgram__cl_context: context getHandle asExternalPointer
						cl_uint: num_devices 
						const__cl_device_id__ptr: device_list 
						const__char__ptr: options 
						cl_uint: num_input_programs 
						const__cl_program__ptr: input_programs 
						void__ptr: no_callbacks_jmv 
						void__ptr: user_data 
						cl_int__ptr: errcode_ret .

	answer := CLProgram new setHandle: answer getHandle asByteArrayPointer.
	^ answer
]

{ #category : 'FFI-generated-Command Queue APIs' }
OpenCLMacOSInterface class >> clReleaseCommandQueue__cl_command_queue: command_queue  [

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clReleaseCommandQueue__cl_command_queue: command_queue getHandle asExternalPointer.

	^ answer
]

{ #category : 'FFI-generated-Context APIs' }
OpenCLMacOSInterface class >> clReleaseContext__cl_context: context  [

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clReleaseContext__cl_context: context getHandle asExternalPointer.

	^ answer
]

{ #category : 'FFI-generated-Device APIs' }
OpenCLMacOSInterface class >> clReleaseDevice__cl_device_id: device  [

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clReleaseDevice__cl_device_id: device getHandle asExternalPointer.

	^ answer
]

{ #category : 'FFI-generated-Event Object APIs' }
OpenCLMacOSInterface class >> clReleaseEvent__cl_event: event  [

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clReleaseEvent__cl_event: event getHandle asExternalPointer.

	^ answer
]

{ #category : 'FFI-generated-Kernel Object APIs' }
OpenCLMacOSInterface class >> clReleaseKernel__cl_kernel: kernel  [

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clReleaseKernel__cl_kernel: kernel getHandle asExternalPointer.

	^ answer
]

{ #category : 'FFI-generated-Memory Object APIs' }
OpenCLMacOSInterface class >> clReleaseMemObject__cl_mem: memobj  [

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clReleaseMemObject__cl_mem: memobj getHandle asExternalPointer.

	^ answer
]

{ #category : 'FFI-generated-Program Object APIs' }
OpenCLMacOSInterface class >> clReleaseProgram__cl_program: program  [

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clReleaseProgram__cl_program: program getHandle asExternalPointer.

	^ answer
]

{ #category : 'FFI-generated-Sampler APIs' }
OpenCLMacOSInterface class >> clReleaseSampler__cl_sampler: sampler  [

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clReleaseSampler__cl_sampler: sampler getHandle asExternalPointer.

	^ answer
]

{ #category : 'FFI-generated-Command Queue APIs' }
OpenCLMacOSInterface class >> clRetainCommandQueue__cl_command_queue: command_queue  [

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clRetainCommandQueue__cl_command_queue: command_queue getHandle asExternalPointer.

	^ answer
]

{ #category : 'FFI-generated-Context APIs' }
OpenCLMacOSInterface class >> clRetainContext__cl_context: context  [

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clRetainContext__cl_context: context getHandle asExternalPointer.

	^ answer
]

{ #category : 'FFI-generated-Device APIs' }
OpenCLMacOSInterface class >> clRetainDevice__cl_device_id: device  [

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clRetainDevice__cl_device_id: device getHandle asExternalPointer.

	^ answer
]

{ #category : 'FFI-generated-Event Object APIs' }
OpenCLMacOSInterface class >> clRetainEvent__cl_event: event  [

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clRetainEvent__cl_event: event getHandle asExternalPointer.

	^ answer
]

{ #category : 'FFI-generated-Kernel Object APIs' }
OpenCLMacOSInterface class >> clRetainKernel__cl_kernel: kernel  [

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clRetainKernel__cl_kernel: kernel getHandle asExternalPointer.

	^ answer
]

{ #category : 'FFI-generated-Memory Object APIs' }
OpenCLMacOSInterface class >> clRetainMemObject__cl_mem: memobj  [

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clRetainMemObject__cl_mem: memobj getHandle asExternalPointer.

	^ answer
]

{ #category : 'FFI-generated-Program Object APIs' }
OpenCLMacOSInterface class >> clRetainProgram__cl_program: program  [

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clRetainProgram__cl_program: program getHandle asExternalPointer.

	^ answer
]

{ #category : 'FFI-generated-Sampler APIs' }
OpenCLMacOSInterface class >> clRetainSampler__cl_sampler: sampler  [

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clRetainSampler__cl_sampler: sampler getHandle asExternalPointer.

	^ answer
]

{ #category : 'FFI-generated-SVM Allocation APIs' }
OpenCLMacOSInterface class >> clSVMAlloc__cl_context: context  [
						cl_svm_mem_flags: flags 
						size_t: size 
						cl_uint: alignment 

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clSVMAlloc__cl_context: context getHandle asExternalPointer
						cl_svm_mem_flags: flags 
						size_t: size 
						cl_uint: alignment .

	^ answer
]

{ #category : 'FFI-generated-SVM Allocation APIs' }
OpenCLMacOSInterface class >> clSVMFree__cl_context: context  [
						void__ptr: svm_pointer 

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clSVMFree__cl_context: context getHandle asExternalPointer
						void__ptr: svm_pointer .

	^ answer
]

{ #category : 'FFI-generated-Event Object APIs' }
OpenCLMacOSInterface class >> clSetEventCallback__cl_event: event  [
						cl_int: command_exec_callback_type 
						void__ptr: no_callbacks_jmv 
						void__ptr: user_data 

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clSetEventCallback__cl_event: event getHandle asExternalPointer
						cl_int: command_exec_callback_type 
						void__ptr: no_callbacks_jmv 
						void__ptr: user_data .

	^ answer
]

{ #category : 'FFI-generated-Kernel Object APIs' }
OpenCLMacOSInterface class >> clSetKernelArg__cl_kernel: kernel  [
						cl_uint: arg_index 
						size_t: arg_size 
						const__void__ptr: arg_value 

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clSetKernelArg__cl_kernel: kernel getHandle asExternalPointer
						cl_uint: arg_index 
						size_t: arg_size 
						const__void__ptr: arg_value .

	^ answer
]

{ #category : 'FFI-generated-Kernel Object APIs' }
OpenCLMacOSInterface class >> clSetKernelArgSVMPointer__cl_kernel: kernel  [
						cl_uint: arg_index 
						const__void__ptr: arg_value 

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clSetKernelArgSVMPointer__cl_kernel: kernel getHandle asExternalPointer
						cl_uint: arg_index 
						const__void__ptr: arg_value .

	^ answer
]

{ #category : 'FFI-generated-Kernel Object APIs' }
OpenCLMacOSInterface class >> clSetKernelExecInfo__cl_kernel: kernel  [
						cl_kernel_exec_info: param_name 
						size_t: param_value_size 
						const__void__ptr: param_value 

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clSetKernelExecInfo__cl_kernel: kernel getHandle asExternalPointer
						cl_kernel_exec_info: param_name 
						size_t: param_value_size 
						const__void__ptr: param_value .

	^ answer
]

{ #category : 'FFI-generated-Memory Object APIs' }
OpenCLMacOSInterface class >> clSetMemObjectDestructorCallback__cl_mem: memobj  [
						void__ptr: no_callbacks_jmv 
						void__ptr: user_data 

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clSetMemObjectDestructorCallback__cl_mem: memobj getHandle asExternalPointer
						void__ptr: no_callbacks_jmv 
						void__ptr: user_data .

	^ answer
]

{ #category : 'FFI-generated-Event Object APIs' }
OpenCLMacOSInterface class >> clSetUserEventStatus__cl_event: event  [
						cl_int: execution_status 

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clSetUserEventStatus__cl_event: event getHandle asExternalPointer
						cl_int: execution_status .

	^ answer
]

{ #category : 'FFI-generated-Deprecated OpenCL 1.1 APIs' }
OpenCLMacOSInterface class >> clUnloadCompiler [

	"This method was automatically generated."

	"cl_int clUnloadCompiler(
	);"
	<apicall: long 'clUnloadCompiler' () module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-Program Object APIs' }
OpenCLMacOSInterface class >> clUnloadPlatformCompiler__cl_platform_id: platform  [

	"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"

	| answer |
	answer := self private_clUnloadPlatformCompiler__cl_platform_id: platform getHandle asExternalPointer.

	^ answer
]

{ #category : 'FFI-generated-Event Object APIs' }
OpenCLMacOSInterface class >> clWaitForEvents__cl_uint: num_events  [
						const__cl_event__ptr: event_list 

	"This method was automatically generated."

	"cl_int clWaitForEvents(
			cl_uint num_events, 
			const cl_event * event_list
	);"
	<apicall: long 'clWaitForEvents' (ulong CLEvent*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'class initialization' }
OpenCLMacOSInterface class >> libraryForCurrentPlatform [
	"Answer the name of the OpenCL library on the current platform."
	^'OpenCL.framework'
]

{ #category : 'FFI-generated-private-Program Object APIs' }
OpenCLMacOSInterface class >> private_clBuildProgram__cl_program: program  [
						cl_uint: num_devices 
						const__cl_device_id__ptr: device_list 
						const__char__ptr: options 
						void__ptrpfn_notifycl_program: pfn_notify 
						void__ptr: user_data 

	"This method was automatically generated."

	"cl_int clBuildProgram(
			cl_program program, 
			cl_uint num_devices, 
			const cl_device_id * device_list, 
			const char * options, 
			void (*pfn_notify)(cl_program pfn_notify, 
			void * user_data
	);"
	<apicall: long 'clBuildProgram' (void* ulong CLDeviceID* schar* void* void*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Program Object APIs' }
OpenCLMacOSInterface class >> private_clCompileProgram__cl_program: program  [
						cl_uint: num_devices 
						const__cl_device_id__ptr: device_list 
						const__char__ptr: options 
						cl_uint: num_input_headers 
						const__cl_program__ptr: input_headers 
						const__char__ptr__ptr: header_include_names 
						void__ptr: no_callbacks_jmv 
						void__ptr: user_data 

	"This method was automatically generated."

	"cl_int clCompileProgram(
			cl_program program, 
			cl_uint num_devices, 
			const cl_device_id * device_list, 
			const char * options, 
			cl_uint num_input_headers, 
			const cl_program * input_headers, 
			const char ** header_include_names, 
			void * no_callbacks_jmv, 
			void * user_data
	);"
	<apicall: long 'clCompileProgram' (void* ulong CLDeviceID* schar* ulong CLProgram* void* void* void*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Memory Object APIs' }
OpenCLMacOSInterface class >> private_clCreateBuffer__cl_context: context  [
						cl_mem_flags: flags 
						size_t: size 
						void__ptr: host_ptr 
						cl_int__ptr: errcode_ret 

	"This method was automatically generated."

	"cl_mem clCreateBuffer(
			cl_context context, 
			cl_mem_flags flags, 
			size_t size, 
			void * host_ptr, 
			cl_int * errcode_ret
	);"
	<apicall: void* 'clCreateBuffer' (void* ulonglong ulong void* long*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Deprecated OpenCL 2.0 APIs' }
OpenCLMacOSInterface class >> private_clCreateCommandQueue__cl_context: context  [
						cl_device_id: device 
						cl_command_queue_properties: properties 
						cl_int__ptr: errcode_ret 

	"This method was automatically generated."

	"cl_command_queue clCreateCommandQueue(
			cl_context context, 
			cl_device_id device, 
			cl_command_queue_properties properties, 
			cl_int * errcode_ret
	);"
	<apicall: void* 'clCreateCommandQueue' (void* void* ulonglong long*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Command Queue APIs' }
OpenCLMacOSInterface class >> private_clCreateCommandQueueWithProperties__cl_context: context  [
						cl_device_id: device 
						const__cl_queue_properties__ptr: properties 
						cl_int__ptr: errcode_ret 

	"This method was automatically generated."

	"cl_command_queue clCreateCommandQueueWithProperties(
			cl_context context, 
			cl_device_id device, 
			const cl_queue_properties * properties, 
			cl_int * errcode_ret
	);"
	<apicall: void* 'clCreateCommandQueueWithProperties' (void* void* ulonglong* long*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Context APIs' }
OpenCLMacOSInterface class >> private_clCreateContext__const__cl_context_properties__ptr: properties  [
						cl_uint: num_devices 
						const__cl_device_id__ptr: devices 
						void__ptrpfn_notifyconst__char__ptrconst__void__ptrsize_tvoid__ptr: pfn_notify 
						void__ptr: user_data 
						cl_int__ptr: errcode_ret 

	"This method was automatically generated."

	"cl_context clCreateContext(
			const cl_context_properties * properties, 
			cl_uint num_devices, 
			const cl_device_id * devices, 
			void (*pfn_notify)(const char *, const void *, size_t, void *) pfn_notify, 
			void * user_data, 
			cl_int * errcode_ret
	);"
	<apicall: void* 'clCreateContext' (void* ulong CLDeviceID* void* void* long*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Context APIs' }
OpenCLMacOSInterface class >> private_clCreateContextFromType__const__cl_context_properties__ptr: properties  [
						cl_device_type: device_type 
						void__ptrpfn_notifyconst__char__ptrconst__void__ptrsize_tvoid__ptr: pfn_notify 
						void__ptr: user_data 
						cl_int__ptr: errcode_ret 

	"This method was automatically generated."

	"cl_context clCreateContextFromType(
			const cl_context_properties * properties, 
			cl_device_type device_type, 
			void (*pfn_notify)(const char *, const void *, size_t, void *) pfn_notify, 
			void * user_data, 
			cl_int * errcode_ret
	);"
	<apicall: void* 'clCreateContextFromType' (void* ulonglong void* void* long*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Memory Object APIs' }
OpenCLMacOSInterface class >> private_clCreateImage__cl_context: context  [
						cl_mem_flags: flags 
						const__cl_image_format__ptr: image_format 
						const__cl_image_desc__ptr: image_desc 
						void__ptr: host_ptr 
						cl_int__ptr: errcode_ret 

	"This method was automatically generated."

	"cl_mem clCreateImage(
			cl_context context, 
			cl_mem_flags flags, 
			const cl_image_format * image_format, 
			const cl_image_desc * image_desc, 
			void * host_ptr, 
			cl_int * errcode_ret
	);"
	<apicall: void* 'clCreateImage' (void* ulonglong CLImageFormatStruct* CLImageDescStruct* void* long*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Deprecated OpenCL 1.1 APIs' }
OpenCLMacOSInterface class >> private_clCreateImage2D__cl_context: context  [
						cl_mem_flags: flags 
						const__cl_image_format__ptr: image_format 
						size_t: image_width 
						size_t: image_height 
						size_t: image_row_pitch 
						void__ptr: host_ptr 
						cl_int__ptr: errcode_ret 

	"This method was automatically generated."

	"cl_mem clCreateImage2D(
			cl_context context, 
			cl_mem_flags flags, 
			const cl_image_format * image_format, 
			size_t image_width, 
			size_t image_height, 
			size_t image_row_pitch, 
			void * host_ptr, 
			cl_int * errcode_ret
	);"
	<apicall: void* 'clCreateImage2D' (void* ulonglong CLImageFormatStruct* ulong ulong ulong void* long*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Deprecated OpenCL 1.1 APIs' }
OpenCLMacOSInterface class >> private_clCreateImage3D__cl_context: context  [
						cl_mem_flags: flags 
						const__cl_image_format__ptr: image_format 
						size_t: image_width 
						size_t: image_height 
						size_t: image_depth 
						size_t: image_row_pitch 
						size_t: image_slice_pitch 
						void__ptr: host_ptr 
						cl_int__ptr: errcode_ret 

	"This method was automatically generated."

	"cl_mem clCreateImage3D(
			cl_context context, 
			cl_mem_flags flags, 
			const cl_image_format * image_format, 
			size_t image_width, 
			size_t image_height, 
			size_t image_depth, 
			size_t image_row_pitch, 
			size_t image_slice_pitch, 
			void * host_ptr, 
			cl_int * errcode_ret
	);"
	<apicall: void* 'clCreateImage3D' (void* ulonglong CLImageFormatStruct* ulong ulong ulong ulong ulong void* long*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Kernel Object APIs' }
OpenCLMacOSInterface class >> private_clCreateKernel__cl_program: program  [
						const__char__ptr: kernel_name 
						cl_int__ptr: errcode_ret 

	"This method was automatically generated."

	"cl_kernel clCreateKernel(
			cl_program program, 
			const char * kernel_name, 
			cl_int * errcode_ret
	);"
	<apicall: void* 'clCreateKernel' (void* schar* long*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Kernel Object APIs' }
OpenCLMacOSInterface class >> private_clCreateKernelsInProgram__cl_program: program  [
						cl_uint: num_kernels 
						cl_kernel__ptr: kernels 
						cl_uint__ptr: num_kernels_ret 

	"This method was automatically generated."

	"cl_int clCreateKernelsInProgram(
			cl_program program, 
			cl_uint num_kernels, 
			cl_kernel * kernels, 
			cl_uint * num_kernels_ret
	);"
	<apicall: long 'clCreateKernelsInProgram' (void* ulong CLKernel* ulong*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Memory Object APIs' }
OpenCLMacOSInterface class >> private_clCreatePipe__cl_context: context  [
						cl_mem_flags: flags 
						cl_uint: pipe_packet_size 
						cl_uint: pipe_max_packets 
						const__cl_pipe_properties__ptr: properties 
						cl_int__ptr: errcode_ret 

	"This method was automatically generated."

	"cl_mem clCreatePipe(
			cl_context context, 
			cl_mem_flags flags, 
			cl_uint pipe_packet_size, 
			cl_uint pipe_max_packets, 
			const cl_pipe_properties * properties, 
			cl_int * errcode_ret
	);"
	<apicall: void* 'clCreatePipe' (void* ulonglong ulong ulong void* long*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Program Object APIs' }
OpenCLMacOSInterface class >> private_clCreateProgramWithBinary__cl_context: context  [
						cl_uint: num_devices 
						const__cl_device_id__ptr: device_list 
						const__size_t__ptr: lengths 
						const__unsignedchar__ptr__ptr: binaries 
						cl_int__ptr: binary_status 
						cl_int__ptr: errcode_ret 

	"This method was automatically generated."

	"cl_program clCreateProgramWithBinary(
			cl_context context, 
			cl_uint num_devices, 
			const cl_device_id * device_list, 
			const size_t * lengths, 
			const unsigned char ** binaries, 
			cl_int * binary_status, 
			cl_int * errcode_ret
	);"
	<apicall: void* 'clCreateProgramWithBinary' (void* ulong CLDeviceID* ulong* void* long* long*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Program Object APIs' }
OpenCLMacOSInterface class >> private_clCreateProgramWithBuiltInKernels__cl_context: context  [
						cl_uint: num_devices 
						const__cl_device_id__ptr: device_list 
						const__char__ptr: kernel_names 
						cl_int__ptr: errcode_ret 

	"This method was automatically generated."

	"cl_program clCreateProgramWithBuiltInKernels(
			cl_context context, 
			cl_uint num_devices, 
			const cl_device_id * device_list, 
			const char * kernel_names, 
			cl_int * errcode_ret
	);"
	<apicall: void* 'clCreateProgramWithBuiltInKernels' (void* ulong CLDeviceID* schar* long*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Program Object APIs' }
OpenCLMacOSInterface class >> private_clCreateProgramWithSource__cl_context: context  [
						cl_uint: count 
						const__char__ptr__ptr: strings 
						const__size_t__ptr: lengths 
						cl_int__ptr: errcode_ret 

	"This method was automatically generated."

	"cl_program clCreateProgramWithSource(
			cl_context context, 
			cl_uint count, 
			const char ** strings, 
			const size_t * lengths, 
			cl_int * errcode_ret
	);"
	<apicall: void* 'clCreateProgramWithSource' (void* ulong void* ulong* long*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Deprecated OpenCL 2.0 APIs' }
OpenCLMacOSInterface class >> private_clCreateSampler__cl_context: context  [
						cl_bool: normalized_coords 
						cl_addressing_mode: addressing_mode 
						cl_filter_mode: filter_mode 
						cl_int__ptr: errcode_ret 

	"This method was automatically generated."

	"cl_sampler clCreateSampler(
			cl_context context, 
			cl_bool normalized_coords, 
			cl_addressing_mode addressing_mode, 
			cl_filter_mode filter_mode, 
			cl_int * errcode_ret
	);"
	<apicall: void* 'clCreateSampler' (void* ulong ulong ulong long*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Sampler APIs' }
OpenCLMacOSInterface class >> private_clCreateSamplerWithProperties__cl_context: context  [
						const__cl_sampler_properties__ptr: normalized_coords 
						cl_int__ptr: errcode_ret 

	"This method was automatically generated."

	"cl_sampler clCreateSamplerWithProperties(
			cl_context context, 
			const cl_sampler_properties * normalized_coords, 
			cl_int * errcode_ret
	);"
	<apicall: void* 'clCreateSamplerWithProperties' (void* ulonglong* long*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Memory Object APIs' }
OpenCLMacOSInterface class >> private_clCreateSubBuffer__cl_mem: buffer  [
						cl_mem_flags: flags 
						cl_buffer_create_type: buffer_create_type 
						const__void__ptr: buffer_create_info 
						cl_int__ptr: errcode_ret 

	"This method was automatically generated."

	"cl_mem clCreateSubBuffer(
			cl_mem buffer, 
			cl_mem_flags flags, 
			cl_buffer_create_type buffer_create_type, 
			const void * buffer_create_info, 
			cl_int * errcode_ret
	);"
	<apicall: void* 'clCreateSubBuffer' (void* ulonglong ulong void* long*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Device APIs' }
OpenCLMacOSInterface class >> private_clCreateSubDevices__cl_device_id: in_device  [
						const__cl_device_partition_property__ptr: properties 
						cl_uint: num_devices 
						cl_device_id__ptr: out_devices 
						cl_uint__ptr: num_devices_ret 

	"This method was automatically generated."

	"cl_int clCreateSubDevices(
			cl_device_id in_device, 
			const cl_device_partition_property * properties, 
			cl_uint num_devices, 
			cl_device_id * out_devices, 
			cl_uint * num_devices_ret
	);"
	<apicall: long 'clCreateSubDevices' (void* void* ulong CLDeviceID* ulong*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Event Object APIs' }
OpenCLMacOSInterface class >> private_clCreateUserEvent__cl_context: context  [
						cl_int__ptr: errcode_ret 

	"This method was automatically generated."

	"cl_event clCreateUserEvent(
			cl_context context, 
			cl_int * errcode_ret
	);"
	<apicall: void* 'clCreateUserEvent' (void* long*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Deprecated OpenCL 1.1 APIs' }
OpenCLMacOSInterface class >> private_clEnqueueBarrier__cl_command_queue: command_queue  [

	"This method was automatically generated."

	"cl_int clEnqueueBarrier(
			cl_command_queue command_queue
	);"
	<apicall: long 'clEnqueueBarrier' (void*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Enqueued Commands APIs' }
OpenCLMacOSInterface class >> private_clEnqueueBarrierWithWaitList__cl_command_queue: command_queue  [
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event 

	"This method was automatically generated."

	"cl_int clEnqueueBarrierWithWaitList(
			cl_command_queue command_queue, 
			cl_uint num_events_in_wait_list, 
			const cl_event * event_wait_list, 
			cl_event * event
	);"
	<apicall: long 'clEnqueueBarrierWithWaitList' (void* ulong CLEvent* CLEvent*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Enqueued Commands APIs' }
OpenCLMacOSInterface class >> private_clEnqueueCopyBuffer__cl_command_queue: command_queue  [
						cl_mem: src_buffer 
						cl_mem: dst_buffer 
						size_t: src_offset 
						size_t: dst_offset 
						size_t: size 
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event 

	"This method was automatically generated."

	"cl_int clEnqueueCopyBuffer(
			cl_command_queue command_queue, 
			cl_mem src_buffer, 
			cl_mem dst_buffer, 
			size_t src_offset, 
			size_t dst_offset, 
			size_t size, 
			cl_uint num_events_in_wait_list, 
			const cl_event * event_wait_list, 
			cl_event * event
	);"
	<apicall: long 'clEnqueueCopyBuffer' (void* void* void* ulong ulong ulong ulong CLEvent* CLEvent*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Enqueued Commands APIs' }
OpenCLMacOSInterface class >> private_clEnqueueCopyBufferRect__cl_command_queue: command_queue  [
						cl_mem: src_buffer 
						cl_mem: dst_buffer 
						const__size_t__ptr: src_origin 
						const__size_t__ptr: dst_origin 
						const__size_t__ptr: region 
						size_t: src_row_pitch 
						size_t: src_slice_pitch 
						size_t: dst_row_pitch 
						size_t: dst_slice_pitch 
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event 

	"This method was automatically generated."

	"cl_int clEnqueueCopyBufferRect(
			cl_command_queue command_queue, 
			cl_mem src_buffer, 
			cl_mem dst_buffer, 
			const size_t * src_origin, 
			const size_t * dst_origin, 
			const size_t * region, 
			size_t src_row_pitch, 
			size_t src_slice_pitch, 
			size_t dst_row_pitch, 
			size_t dst_slice_pitch, 
			cl_uint num_events_in_wait_list, 
			const cl_event * event_wait_list, 
			cl_event * event
	);"
	<apicall: long 'clEnqueueCopyBufferRect' (void* void* void* ulong* ulong* ulong* ulong ulong ulong ulong ulong CLEvent* CLEvent*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Enqueued Commands APIs' }
OpenCLMacOSInterface class >> private_clEnqueueCopyBufferToImage__cl_command_queue: command_queue  [
						cl_mem: src_buffer 
						cl_mem: dst_image 
						size_t: src_offset 
						const__size_t__ptr: dst_origin 
						const__size_t__ptr: region 
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event 

	"This method was automatically generated."

	"cl_int clEnqueueCopyBufferToImage(
			cl_command_queue command_queue, 
			cl_mem src_buffer, 
			cl_mem dst_image, 
			size_t src_offset, 
			const size_t * dst_origin[3], 
			const size_t * region[3], 
			cl_uint num_events_in_wait_list, 
			const cl_event * event_wait_list, 
			cl_event * event
	);"
	<apicall: long 'clEnqueueCopyBufferToImage' (void* void* void* ulong ulong* ulong* ulong CLEvent* CLEvent*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Enqueued Commands APIs' }
OpenCLMacOSInterface class >> private_clEnqueueCopyImage__cl_command_queue: command_queue  [
						cl_mem: src_image 
						cl_mem: dst_image 
						const__size_t__ptr: src_origin 
						const__size_t__ptr: dst_origin 
						const__size_t__ptr: region 
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event 

	"This method was automatically generated."

	"cl_int clEnqueueCopyImage(
			cl_command_queue command_queue, 
			cl_mem src_image, 
			cl_mem dst_image, 
			const size_t * src_origin[3], 
			const size_t * dst_origin[3], 
			const size_t * region[3], 
			cl_uint num_events_in_wait_list, 
			const cl_event * event_wait_list, 
			cl_event * event
	);"
	<apicall: long 'clEnqueueCopyImage' (void* void* void* ulong* ulong* ulong* ulong CLEvent* CLEvent*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Enqueued Commands APIs' }
OpenCLMacOSInterface class >> private_clEnqueueCopyImageToBuffer__cl_command_queue: command_queue  [
						cl_mem: src_image 
						cl_mem: dst_buffer 
						const__size_t__ptr: src_origin 
						const__size_t__ptr: region 
						size_t: dst_offset 
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event 

	"This method was automatically generated."

	"cl_int clEnqueueCopyImageToBuffer(
			cl_command_queue command_queue, 
			cl_mem src_image, 
			cl_mem dst_buffer, 
			const size_t * src_origin[3], 
			const size_t * region[3], 
			size_t dst_offset, 
			cl_uint num_events_in_wait_list, 
			const cl_event * event_wait_list, 
			cl_event * event
	);"
	<apicall: long 'clEnqueueCopyImageToBuffer' (void* void* void* ulong* ulong* ulong ulong CLEvent* CLEvent*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Enqueued Commands APIs' }
OpenCLMacOSInterface class >> private_clEnqueueFillBuffer__cl_command_queue: command_queue  [
						cl_mem: buffer 
						const__void__ptr: pattern 
						size_t: pattern_size 
						size_t: offset 
						size_t: size 
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event 

	"This method was automatically generated."

	"cl_int clEnqueueFillBuffer(
			cl_command_queue command_queue, 
			cl_mem buffer, 
			const void * pattern, 
			size_t pattern_size, 
			size_t offset, 
			size_t size, 
			cl_uint num_events_in_wait_list, 
			const cl_event * event_wait_list, 
			cl_event * event
	);"
	<apicall: long 'clEnqueueFillBuffer' (void* void* void* ulong ulong ulong ulong CLEvent* CLEvent*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Enqueued Commands APIs' }
OpenCLMacOSInterface class >> private_clEnqueueFillImage__cl_command_queue: command_queue  [
						cl_mem: image 
						const__void__ptr: fill_color 
						const__size_t__ptr: origin 
						const__size_t__ptr: region 
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event 

	"This method was automatically generated."

	"cl_int clEnqueueFillImage(
			cl_command_queue command_queue, 
			cl_mem image, 
			const void * fill_color, 
			const size_t * origin[3], 
			const size_t * region[3], 
			cl_uint num_events_in_wait_list, 
			const cl_event * event_wait_list, 
			cl_event * event
	);"
	<apicall: long 'clEnqueueFillImage' (void* void* void* ulong* ulong* ulong CLEvent* CLEvent*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Enqueued Commands APIs' }
OpenCLMacOSInterface class >> private_clEnqueueMapBuffer__cl_command_queue: command_queue  [
						cl_mem: buffer 
						cl_bool: blocking_map 
						cl_map_flags: map_flags 
						size_t: offset 
						size_t: size 
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event 
						cl_int__ptr: errcode_ret 

	"This method was automatically generated."

	"void * clEnqueueMapBuffer(
			cl_command_queue command_queue, 
			cl_mem buffer, 
			cl_bool blocking_map, 
			cl_map_flags map_flags, 
			size_t offset, 
			size_t size, 
			cl_uint num_events_in_wait_list, 
			const cl_event * event_wait_list, 
			cl_event * event, 
			cl_int * errcode_ret
	);"
	<apicall: void* 'clEnqueueMapBuffer' (void* void* ulong ulonglong ulong ulong ulong CLEvent* CLEvent* long*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Enqueued Commands APIs' }
OpenCLMacOSInterface class >> private_clEnqueueMapImage__cl_command_queue: command_queue  [
						cl_mem: image 
						cl_bool: blocking_map 
						cl_map_flags: map_flags 
						const__size_t__ptr: origin 
						const__size_t__ptr: region 
						size_t__ptr: image_row_pitch 
						size_t__ptr: image_slice_pitch 
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event 
						cl_int__ptr: errcode_ret 

	"This method was automatically generated."

	"void * clEnqueueMapImage(
			cl_command_queue command_queue, 
			cl_mem image, 
			cl_bool blocking_map, 
			cl_map_flags map_flags, 
			const size_t * origin[3], 
			const size_t * region[3], 
			size_t * image_row_pitch, 
			size_t * image_slice_pitch, 
			cl_uint num_events_in_wait_list, 
			const cl_event * event_wait_list, 
			cl_event * event, 
			cl_int * errcode_ret
	);"
	<apicall: void* 'clEnqueueMapImage' (void* void* ulong ulonglong ulong* ulong* ulong* ulong* ulong CLEvent* CLEvent* long*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Deprecated OpenCL 1.1 APIs' }
OpenCLMacOSInterface class >> private_clEnqueueMarker__cl_command_queue: command_queue  [
						cl_event__ptr: event 

	"This method was automatically generated."

	"cl_int clEnqueueMarker(
			cl_command_queue command_queue, 
			cl_event * event
	);"
	<apicall: long 'clEnqueueMarker' (void* CLEvent*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Enqueued Commands APIs' }
OpenCLMacOSInterface class >> private_clEnqueueMarkerWithWaitList__cl_command_queue: command_queue  [
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event 

	"This method was automatically generated."

	"cl_int clEnqueueMarkerWithWaitList(
			cl_command_queue command_queue, 
			cl_uint num_events_in_wait_list, 
			const cl_event * event_wait_list, 
			cl_event * event
	);"
	<apicall: long 'clEnqueueMarkerWithWaitList' (void* ulong CLEvent* CLEvent*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Enqueued Commands APIs' }
OpenCLMacOSInterface class >> private_clEnqueueMigrateMemObjects__cl_command_queue: command_queue  [
						cl_uint: num_mem_objects 
						const__cl_mem__ptr: mem_objects 
						cl_mem_migration_flags: flags 
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event 

	"This method was automatically generated."

	"cl_int clEnqueueMigrateMemObjects(
			cl_command_queue command_queue, 
			cl_uint num_mem_objects, 
			const cl_mem * mem_objects, 
			cl_mem_migration_flags flags, 
			cl_uint num_events_in_wait_list, 
			const cl_event * event_wait_list, 
			cl_event * event
	);"
	<apicall: long 'clEnqueueMigrateMemObjects' (void* ulong CLMem* ulonglong ulong CLEvent* CLEvent*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Enqueued Commands APIs' }
OpenCLMacOSInterface class >> private_clEnqueueNDRangeKernel__cl_command_queue: command_queue  [
						cl_kernel: kernel 
						cl_uint: work_dim 
						const__size_t__ptr: global_work_offset 
						const__size_t__ptr: global_work_size 
						const__size_t__ptr: local_work_size 
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event 

	"This method was automatically generated."

	"cl_int clEnqueueNDRangeKernel(
			cl_command_queue command_queue, 
			cl_kernel kernel, 
			cl_uint work_dim, 
			const size_t * global_work_offset, 
			const size_t * global_work_size, 
			const size_t * local_work_size, 
			cl_uint num_events_in_wait_list, 
			const cl_event * event_wait_list, 
			cl_event * event
	);"
	<apicall: long 'clEnqueueNDRangeKernel' (void* void* ulong ulong* ulong* ulong* ulong CLEvent* CLEvent*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Enqueued Commands APIs' }
OpenCLMacOSInterface class >> private_clEnqueueNativeKernel__cl_command_queue: command_queue  [
						void__ptruser_funcvoid__ptrvoid__ptr: user_func 
						size_t: cb_args 
						cl_uint: num_mem_objects 
						const__cl_mem__ptr: mem_list 
						const__void__ptr__ptr: args_mem_loc 
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event 

	"This method was automatically generated."

	"cl_int clEnqueueNativeKernel(
			cl_command_queue command_queue, 
			void (*user_func)(void *), 
                      void * user_func, 
			size_t cb_args, 
			cl_uint num_mem_objects, 
			const cl_mem * mem_list, 
			const void ** args_mem_loc, 
			cl_uint num_events_in_wait_list, 
			const cl_event * event_wait_list, 
			cl_event * event
	);"
	<apicall: long 'clEnqueueNativeKernel' (void* void* ulong ulong CLMem* void* ulong CLEvent* CLEvent*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Enqueued Commands APIs' }
OpenCLMacOSInterface class >> private_clEnqueueReadBuffer__cl_command_queue: command_queue  [
						cl_mem: buffer 
						cl_bool: blocking_read 
						size_t: offset 
						size_t: size 
						void__ptr: ptr 
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event 

	"This method was automatically generated."

	"cl_int clEnqueueReadBuffer(
			cl_command_queue command_queue, 
			cl_mem buffer, 
			cl_bool blocking_read, 
			size_t offset, 
			size_t size, 
			void * ptr, 
			cl_uint num_events_in_wait_list, 
			const cl_event * event_wait_list, 
			cl_event * event
	);"
	<apicall: long 'clEnqueueReadBuffer' (void* void* ulong ulong ulong void* ulong CLEvent* CLEvent*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Enqueued Commands APIs' }
OpenCLMacOSInterface class >> private_clEnqueueReadBufferRect__cl_command_queue: command_queue  [
						cl_mem: buffer 
						cl_bool: blocking_read 
						const__size_t__ptr: buffer_offset 
						const__size_t__ptr: host_offset 
						const__size_t__ptr: region 
						size_t: buffer_row_pitch 
						size_t: buffer_slice_pitch 
						size_t: host_row_pitch 
						size_t: host_slice_pitch 
						void__ptr: ptr 
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event 

	"This method was automatically generated."

	"cl_int clEnqueueReadBufferRect(
			cl_command_queue command_queue, 
			cl_mem buffer, 
			cl_bool blocking_read, 
			const size_t * buffer_offset, 
			const size_t * host_offset, 
			const size_t * region, 
			size_t buffer_row_pitch, 
			size_t buffer_slice_pitch, 
			size_t host_row_pitch, 
			size_t host_slice_pitch, 
			void * ptr, 
			cl_uint num_events_in_wait_list, 
			const cl_event * event_wait_list, 
			cl_event * event
	);"
	<apicall: long 'clEnqueueReadBufferRect' (void* void* ulong ulong* ulong* ulong* ulong ulong ulong ulong void* ulong CLEvent* CLEvent*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Enqueued Commands APIs' }
OpenCLMacOSInterface class >> private_clEnqueueReadImage__cl_command_queue: command_queue  [
						cl_mem: image 
						cl_bool: blocking_read 
						const__size_t__ptr: origin 
						const__size_t__ptr: region 
						size_t: row_pitch 
						size_t: slice_pitch 
						void__ptr: ptr 
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event 

	"This method was automatically generated."

	"cl_int clEnqueueReadImage(
			cl_command_queue command_queue, 
			cl_mem image, 
			cl_bool blocking_read, 
			const size_t * origin[3], 
			const size_t * region[3], 
			size_t row_pitch, 
			size_t slice_pitch, 
			void * ptr, 
			cl_uint num_events_in_wait_list, 
			const cl_event * event_wait_list, 
			cl_event * event
	);"
	<apicall: long 'clEnqueueReadImage' (void* void* ulong ulong* ulong* ulong ulong void* ulong CLEvent* CLEvent*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Enqueued Commands APIs' }
OpenCLMacOSInterface class >> private_clEnqueueSVMFree__cl_command_queue: command_queue  [
						cl_uint: num_svm_pointers 
						void__ptr: svm_pointers 
						void__ptr: no_callbacks_jmv 
						void__ptr: user_data 
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event 

	"This method was automatically generated."

	"cl_int clEnqueueSVMFree(
			cl_command_queue command_queue, 
			cl_uint num_svm_pointers, 
			void * svm_pointers[], 
			void * no_callbacks_jmv, 
			void * user_data, 
			cl_uint num_events_in_wait_list, 
			const cl_event * event_wait_list, 
			cl_event * event
	);"
	<apicall: long 'clEnqueueSVMFree' (void* ulong void* void* void* ulong CLEvent* CLEvent*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Enqueued Commands APIs' }
OpenCLMacOSInterface class >> private_clEnqueueSVMMap__cl_command_queue: command_queue  [
						cl_bool: blocking_map 
						cl_map_flags: flags 
						void__ptr: svm_ptr 
						size_t: size 
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event 

	"This method was automatically generated."

	"cl_int clEnqueueSVMMap(
			cl_command_queue command_queue, 
			cl_bool blocking_map, 
			cl_map_flags flags, 
			void * svm_ptr, 
			size_t size, 
			cl_uint num_events_in_wait_list, 
			const cl_event * event_wait_list, 
			cl_event * event
	);"
	<apicall: long 'clEnqueueSVMMap' (void* ulong ulonglong void* ulong ulong CLEvent* CLEvent*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Enqueued Commands APIs' }
OpenCLMacOSInterface class >> private_clEnqueueSVMMemFill__cl_command_queue: command_queue  [
						void__ptr: svm_ptr 
						const__void__ptr: pattern 
						size_t: pattern_size 
						size_t: size 
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event 

	"This method was automatically generated."

	"cl_int clEnqueueSVMMemFill(
			cl_command_queue command_queue, 
			void * svm_ptr, 
			const void * pattern, 
			size_t pattern_size, 
			size_t size, 
			cl_uint num_events_in_wait_list, 
			const cl_event * event_wait_list, 
			cl_event * event
	);"
	<apicall: long 'clEnqueueSVMMemFill' (void* void* void* ulong ulong ulong CLEvent* CLEvent*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Enqueued Commands APIs' }
OpenCLMacOSInterface class >> private_clEnqueueSVMMemcpy__cl_command_queue: command_queue  [
						cl_bool: blocking_copy 
						void__ptr: dst_ptr 
						const__void__ptr: src_ptr 
						size_t: size 
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event 

	"This method was automatically generated."

	"cl_int clEnqueueSVMMemcpy(
			cl_command_queue command_queue, 
			cl_bool blocking_copy, 
			void * dst_ptr, 
			const void * src_ptr, 
			size_t size, 
			cl_uint num_events_in_wait_list, 
			const cl_event * event_wait_list, 
			cl_event * event
	);"
	<apicall: long 'clEnqueueSVMMemcpy' (void* ulong void* void* ulong ulong CLEvent* CLEvent*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Enqueued Commands APIs' }
OpenCLMacOSInterface class >> private_clEnqueueSVMUnmap__cl_command_queue: command_queue  [
						void__ptr: svm_ptr 
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event 

	"This method was automatically generated."

	"cl_int clEnqueueSVMUnmap(
			cl_command_queue command_queue, 
			void * svm_ptr, 
			cl_uint num_events_in_wait_list, 
			const cl_event * event_wait_list, 
			cl_event * event
	);"
	<apicall: long 'clEnqueueSVMUnmap' (void* void* ulong CLEvent* CLEvent*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Deprecated OpenCL 2.0 APIs' }
OpenCLMacOSInterface class >> private_clEnqueueTask__cl_command_queue: command_queue  [
						cl_kernel: kernel 
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event 

	"This method was automatically generated."

	"cl_int clEnqueueTask(
			cl_command_queue command_queue, 
			cl_kernel kernel, 
			cl_uint num_events_in_wait_list, 
			const cl_event * event_wait_list, 
			cl_event * event
	);"
	<apicall: long 'clEnqueueTask' (void* void* ulong CLEvent* CLEvent*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Enqueued Commands APIs' }
OpenCLMacOSInterface class >> private_clEnqueueUnmapMemObject__cl_command_queue: command_queue  [
						cl_mem: memobj 
						void__ptr: mapped_ptr 
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event 

	"This method was automatically generated."

	"cl_int clEnqueueUnmapMemObject(
			cl_command_queue command_queue, 
			cl_mem memobj, 
			void * mapped_ptr, 
			cl_uint num_events_in_wait_list, 
			const cl_event * event_wait_list, 
			cl_event * event
	);"
	<apicall: long 'clEnqueueUnmapMemObject' (void* void* void* ulong CLEvent* CLEvent*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Deprecated OpenCL 1.1 APIs' }
OpenCLMacOSInterface class >> private_clEnqueueWaitForEvents__cl_command_queue: command_queue  [
						cl_uint: num_events 
						const__cl_event__ptr: event_list 

	"This method was automatically generated."

	"cl_int clEnqueueWaitForEvents(
			cl_command_queue command_queue, 
			cl_uint num_events, 
			const cl_event * event_list
	);"
	<apicall: long 'clEnqueueWaitForEvents' (void* ulong CLEvent*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Enqueued Commands APIs' }
OpenCLMacOSInterface class >> private_clEnqueueWriteBuffer__cl_command_queue: command_queue  [
						cl_mem: buffer 
						cl_bool: blocking_write 
						size_t: offset 
						size_t: size 
						const__void__ptr: ptr 
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event 

	"This method was automatically generated."

	"cl_int clEnqueueWriteBuffer(
			cl_command_queue command_queue, 
			cl_mem buffer, 
			cl_bool blocking_write, 
			size_t offset, 
			size_t size, 
			const void * ptr, 
			cl_uint num_events_in_wait_list, 
			const cl_event * event_wait_list, 
			cl_event * event
	);"
	<apicall: long 'clEnqueueWriteBuffer' (void* void* ulong ulong ulong void* ulong CLEvent* CLEvent*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Enqueued Commands APIs' }
OpenCLMacOSInterface class >> private_clEnqueueWriteBufferRect__cl_command_queue: command_queue  [
						cl_mem: buffer 
						cl_bool: blocking_write 
						const__size_t__ptr: buffer_offset 
						const__size_t__ptr: host_offset 
						const__size_t__ptr: region 
						size_t: buffer_row_pitch 
						size_t: buffer_slice_pitch 
						size_t: host_row_pitch 
						size_t: host_slice_pitch 
						const__void__ptr: ptr 
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event 

	"This method was automatically generated."

	"cl_int clEnqueueWriteBufferRect(
			cl_command_queue command_queue, 
			cl_mem buffer, 
			cl_bool blocking_write, 
			const size_t * buffer_offset, 
			const size_t * host_offset, 
			const size_t * region, 
			size_t buffer_row_pitch, 
			size_t buffer_slice_pitch, 
			size_t host_row_pitch, 
			size_t host_slice_pitch, 
			const void * ptr, 
			cl_uint num_events_in_wait_list, 
			const cl_event * event_wait_list, 
			cl_event * event
	);"
	<apicall: long 'clEnqueueWriteBufferRect' (void* void* ulong ulong* ulong* ulong* ulong ulong ulong ulong void* ulong CLEvent* CLEvent*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Enqueued Commands APIs' }
OpenCLMacOSInterface class >> private_clEnqueueWriteImage__cl_command_queue: command_queue  [
						cl_mem: image 
						cl_bool: blocking_write 
						const__size_t__ptr: origin 
						const__size_t__ptr: region 
						size_t: input_row_pitch 
						size_t: input_slice_pitch 
						const__void__ptr: ptr 
						cl_uint: num_events_in_wait_list 
						const__cl_event__ptr: event_wait_list 
						cl_event__ptr: event 

	"This method was automatically generated."

	"cl_int clEnqueueWriteImage(
			cl_command_queue command_queue, 
			cl_mem image, 
			cl_bool blocking_write, 
			const size_t * origin[3], 
			const size_t * region[3], 
			size_t input_row_pitch, 
			size_t input_slice_pitch, 
			const void * ptr, 
			cl_uint num_events_in_wait_list, 
			const cl_event * event_wait_list, 
			cl_event * event
	);"
	<apicall: long 'clEnqueueWriteImage' (void* void* ulong ulong* ulong* ulong ulong void* ulong CLEvent* CLEvent*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Flush and Finish APIs' }
OpenCLMacOSInterface class >> private_clFinish__cl_command_queue: command_queue  [

	"This method was automatically generated."

	"cl_int clFinish(
			cl_command_queue command_queue
	);"
	<apicall: long 'clFinish' (void*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Flush and Finish APIs' }
OpenCLMacOSInterface class >> private_clFlush__cl_command_queue: command_queue  [

	"This method was automatically generated."

	"cl_int clFlush(
			cl_command_queue command_queue
	);"
	<apicall: long 'clFlush' (void*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Command Queue APIs' }
OpenCLMacOSInterface class >> private_clGetCommandQueueInfo__cl_command_queue: command_queue  [
						cl_command_queue_info: param_name 
						size_t: param_value_size 
						void__ptr: param_value 
						size_t__ptr: param_value_size_ret 

	"This method was automatically generated."

	"cl_int clGetCommandQueueInfo(
			cl_command_queue command_queue, 
			cl_command_queue_info param_name, 
			size_t param_value_size, 
			void * param_value, 
			size_t * param_value_size_ret
	);"
	<apicall: long 'clGetCommandQueueInfo' (void* ulong ulong void* ulong*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Context APIs' }
OpenCLMacOSInterface class >> private_clGetContextInfo__cl_context: context  [
						cl_context_info: param_name 
						size_t: param_value_size 
						void__ptr: param_value 
						size_t__ptr: param_value_size_ret 

	"This method was automatically generated."

	"cl_int clGetContextInfo(
			cl_context context, 
			cl_context_info param_name, 
			size_t param_value_size, 
			void * param_value, 
			size_t * param_value_size_ret
	);"
	<apicall: long 'clGetContextInfo' (void* ulong ulong void* ulong*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Device APIs' }
OpenCLMacOSInterface class >> private_clGetDeviceIDs__cl_platform_id: platform  [
						cl_device_type: device_type 
						cl_uint: num_entries 
						cl_device_id__ptr: devices 
						cl_uint__ptr: num_devices 

	"This method was automatically generated."

	"cl_int clGetDeviceIDs(
			cl_platform_id platform, 
			cl_device_type device_type, 
			cl_uint num_entries, 
			cl_device_id * devices, 
			cl_uint * num_devices
	);"
	<apicall: long 'clGetDeviceIDs' (void* ulonglong ulong CLDeviceID* ulong*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Device APIs' }
OpenCLMacOSInterface class >> private_clGetDeviceInfo__cl_device_id: device  [
						cl_device_info: param_name 
						size_t: param_value_size 
						void__ptr: param_value 
						size_t__ptr: param_value_size_ret 

	"This method was automatically generated."

	"cl_int clGetDeviceInfo(
			cl_device_id device, 
			cl_device_info param_name, 
			size_t param_value_size, 
			void * param_value, 
			size_t * param_value_size_ret
	);"
	<apicall: long 'clGetDeviceInfo' (void* ulong ulong void* ulong*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Event Object APIs' }
OpenCLMacOSInterface class >> private_clGetEventInfo__cl_event: event  [
						cl_event_info: param_name 
						size_t: param_value_size 
						void__ptr: param_value 
						size_t__ptr: param_value_size_ret 

	"This method was automatically generated."

	"cl_int clGetEventInfo(
			cl_event event, 
			cl_event_info param_name, 
			size_t param_value_size, 
			void * param_value, 
			size_t * param_value_size_ret
	);"
	<apicall: long 'clGetEventInfo' (void* ulong ulong void* ulong*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Profiling APIs' }
OpenCLMacOSInterface class >> private_clGetEventProfilingInfo__cl_event: event  [
						cl_profiling_info: param_name 
						size_t: param_value_size 
						void__ptr: param_value 
						size_t__ptr: param_value_size_ret 

	"This method was automatically generated."

	"cl_int clGetEventProfilingInfo(
			cl_event event, 
			cl_profiling_info param_name, 
			size_t param_value_size, 
			void * param_value, 
			size_t * param_value_size_ret
	);"
	<apicall: long 'clGetEventProfilingInfo' (void* ulong ulong void* ulong*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Extension function access' }
OpenCLMacOSInterface class >> private_clGetExtensionFunctionAddressForPlatform__cl_platform_id: platform  [
						const__char__ptr: func_name 

	"This method was automatically generated."

	"void * clGetExtensionFunctionAddressForPlatform(
			cl_platform_id platform, 
			const char * func_name
	);"
	<apicall: void* 'clGetExtensionFunctionAddressForPlatform' (void* schar*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Memory Object APIs' }
OpenCLMacOSInterface class >> private_clGetImageInfo__cl_mem: image  [
						cl_image_info: param_name 
						size_t: param_value_size 
						void__ptr: param_value 
						size_t__ptr: param_value_size_ret 

	"This method was automatically generated."

	"cl_int clGetImageInfo(
			cl_mem image, 
			cl_image_info param_name, 
			size_t param_value_size, 
			void * param_value, 
			size_t * param_value_size_ret
	);"
	<apicall: long 'clGetImageInfo' (void* ulong ulong void* ulong*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Kernel Object APIs' }
OpenCLMacOSInterface class >> private_clGetKernelArgInfo__cl_kernel: kernel  [
						cl_uint: arg_indx 
						cl_kernel_arg_info: param_name 
						size_t: param_value_size 
						void__ptr: param_value 
						size_t__ptr: param_value_size_ret 

	"This method was automatically generated."

	"cl_int clGetKernelArgInfo(
			cl_kernel kernel, 
			cl_uint arg_indx, 
			cl_kernel_arg_info param_name, 
			size_t param_value_size, 
			void * param_value, 
			size_t * param_value_size_ret
	);"
	<apicall: long 'clGetKernelArgInfo' (void* ulong ulong ulong void* ulong*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Kernel Object APIs' }
OpenCLMacOSInterface class >> private_clGetKernelInfo__cl_kernel: kernel  [
						cl_kernel_info: param_name 
						size_t: param_value_size 
						void__ptr: param_value 
						size_t__ptr: param_value_size_ret 

	"This method was automatically generated."

	"cl_int clGetKernelInfo(
			cl_kernel kernel, 
			cl_kernel_info param_name, 
			size_t param_value_size, 
			void * param_value, 
			size_t * param_value_size_ret
	);"
	<apicall: long 'clGetKernelInfo' (void* ulong ulong void* ulong*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Kernel Object APIs' }
OpenCLMacOSInterface class >> private_clGetKernelWorkGroupInfo__cl_kernel: kernel  [
						cl_device_id: device 
						cl_kernel_work_group_info: param_name 
						size_t: param_value_size 
						void__ptr: param_value 
						size_t__ptr: param_value_size_ret 

	"This method was automatically generated."

	"cl_int clGetKernelWorkGroupInfo(
			cl_kernel kernel, 
			cl_device_id device, 
			cl_kernel_work_group_info param_name, 
			size_t param_value_size, 
			void * param_value, 
			size_t * param_value_size_ret
	);"
	<apicall: long 'clGetKernelWorkGroupInfo' (void* void* ulong ulong void* ulong*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Memory Object APIs' }
OpenCLMacOSInterface class >> private_clGetMemObjectInfo__cl_mem: memobj  [
						cl_mem_info: param_name 
						size_t: param_value_size 
						void__ptr: param_value 
						size_t__ptr: param_value_size_ret 

	"This method was automatically generated."

	"cl_int clGetMemObjectInfo(
			cl_mem memobj, 
			cl_mem_info param_name, 
			size_t param_value_size, 
			void * param_value, 
			size_t * param_value_size_ret
	);"
	<apicall: long 'clGetMemObjectInfo' (void* ulong ulong void* ulong*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Memory Object APIs' }
OpenCLMacOSInterface class >> private_clGetPipeInfo__cl_mem: pipe  [
						cl_pipe_info: param_name 
						size_t: param_value_size 
						void__ptr: param_value 
						size_t__ptr: param_value_size_ret 

	"This method was automatically generated."

	"cl_int clGetPipeInfo(
			cl_mem pipe, 
			cl_pipe_info param_name, 
			size_t param_value_size, 
			void * param_value, 
			size_t * param_value_size_ret
	);"
	<apicall: long 'clGetPipeInfo' (void* ulong ulong void* ulong*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Platform API' }
OpenCLMacOSInterface class >> private_clGetPlatformInfo__cl_platform_id: platform  [
						cl_platform_info: param_name 
						size_t: param_value_size 
						void__ptr: param_value 
						size_t__ptr: param_value_size_ret 

	"This method was automatically generated."

	"cl_int clGetPlatformInfo(
			cl_platform_id platform, 
			cl_platform_info param_name, 
			size_t param_value_size, 
			void * param_value, 
			size_t * param_value_size_ret
	);"
	<apicall: long 'clGetPlatformInfo' (void* ulong ulong void* ulong*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Program Object APIs' }
OpenCLMacOSInterface class >> private_clGetProgramBuildInfo__cl_program: program  [
						cl_device_id: device 
						cl_program_build_info: param_name 
						size_t: param_value_size 
						void__ptr: param_value 
						size_t__ptr: param_value_size_ret 

	"This method was automatically generated."

	"cl_int clGetProgramBuildInfo(
			cl_program program, 
			cl_device_id device, 
			cl_program_build_info param_name, 
			size_t param_value_size, 
			void * param_value, 
			size_t * param_value_size_ret
	);"
	<apicall: long 'clGetProgramBuildInfo' (void* void* ulong ulong void* ulong*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Program Object APIs' }
OpenCLMacOSInterface class >> private_clGetProgramInfo__cl_program: program  [
						cl_program_info: param_name 
						size_t: param_value_size 
						void__ptr: param_value 
						size_t__ptr: param_value_size_ret 

	"This method was automatically generated."

	"cl_int clGetProgramInfo(
			cl_program program, 
			cl_program_info param_name, 
			size_t param_value_size, 
			void * param_value, 
			size_t * param_value_size_ret
	);"
	<apicall: long 'clGetProgramInfo' (void* ulong ulong void* ulong*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Sampler APIs' }
OpenCLMacOSInterface class >> private_clGetSamplerInfo__cl_sampler: sampler  [
						cl_sampler_info: param_name 
						size_t: param_value_size 
						void__ptr: param_value 
						size_t__ptr: param_value_size_ret 

	"This method was automatically generated."

	"cl_int clGetSamplerInfo(
			cl_sampler sampler, 
			cl_sampler_info param_name, 
			size_t param_value_size, 
			void * param_value, 
			size_t * param_value_size_ret
	);"
	<apicall: long 'clGetSamplerInfo' (void* ulong ulong void* ulong*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Memory Object APIs' }
OpenCLMacOSInterface class >> private_clGetSupportedImageFormats__cl_context: context  [
						cl_mem_flags: flags 
						cl_mem_object_type: image_type 
						cl_uint: num_entries 
						cl_image_format__ptr: image_formats 
						cl_uint__ptr: num_image_formats 

	"This method was automatically generated."

	"cl_int clGetSupportedImageFormats(
			cl_context context, 
			cl_mem_flags flags, 
			cl_mem_object_type image_type, 
			cl_uint num_entries, 
			cl_image_format * image_formats, 
			cl_uint * num_image_formats
	);"
	<apicall: long 'clGetSupportedImageFormats' (void* ulonglong ulong ulong CLImageFormatStruct* ulong*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Program Object APIs' }
OpenCLMacOSInterface class >> private_clLinkProgram__cl_context: context  [
						cl_uint: num_devices 
						const__cl_device_id__ptr: device_list 
						const__char__ptr: options 
						cl_uint: num_input_programs 
						const__cl_program__ptr: input_programs 
						void__ptr: no_callbacks_jmv 
						void__ptr: user_data 
						cl_int__ptr: errcode_ret 

	"This method was automatically generated."

	"cl_program clLinkProgram(
			cl_context context, 
			cl_uint num_devices, 
			const cl_device_id * device_list, 
			const char * options, 
			cl_uint num_input_programs, 
			const cl_program * input_programs, 
			void * no_callbacks_jmv, 
			void * user_data, 
			cl_int * errcode_ret
	);"
	<apicall: void* 'clLinkProgram' (void* ulong CLDeviceID* schar* ulong CLProgram* void* void* long*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Command Queue APIs' }
OpenCLMacOSInterface class >> private_clReleaseCommandQueue__cl_command_queue: command_queue  [

	"This method was automatically generated."

	"cl_int clReleaseCommandQueue(
			cl_command_queue command_queue
	);"
	<apicall: long 'clReleaseCommandQueue' (void*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Context APIs' }
OpenCLMacOSInterface class >> private_clReleaseContext__cl_context: context  [

	"This method was automatically generated."

	"cl_int clReleaseContext(
			cl_context context
	);"
	<apicall: long 'clReleaseContext' (void*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Device APIs' }
OpenCLMacOSInterface class >> private_clReleaseDevice__cl_device_id: device  [

	"This method was automatically generated."

	"cl_int clReleaseDevice(
			cl_device_id device
	);"
	<apicall: long 'clReleaseDevice' (void*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Event Object APIs' }
OpenCLMacOSInterface class >> private_clReleaseEvent__cl_event: event  [

	"This method was automatically generated."

	"cl_int clReleaseEvent(
			cl_event event
	);"
	<apicall: long 'clReleaseEvent' (void*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Kernel Object APIs' }
OpenCLMacOSInterface class >> private_clReleaseKernel__cl_kernel: kernel  [

	"This method was automatically generated."

	"cl_int clReleaseKernel(
			cl_kernel kernel
	);"
	<apicall: long 'clReleaseKernel' (void*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Memory Object APIs' }
OpenCLMacOSInterface class >> private_clReleaseMemObject__cl_mem: memobj  [

	"This method was automatically generated."

	"cl_int clReleaseMemObject(
			cl_mem memobj
	);"
	<apicall: long 'clReleaseMemObject' (void*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Program Object APIs' }
OpenCLMacOSInterface class >> private_clReleaseProgram__cl_program: program  [

	"This method was automatically generated."

	"cl_int clReleaseProgram(
			cl_program program
	);"
	<apicall: long 'clReleaseProgram' (void*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Sampler APIs' }
OpenCLMacOSInterface class >> private_clReleaseSampler__cl_sampler: sampler  [

	"This method was automatically generated."

	"cl_int clReleaseSampler(
			cl_sampler sampler
	);"
	<apicall: long 'clReleaseSampler' (void*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Command Queue APIs' }
OpenCLMacOSInterface class >> private_clRetainCommandQueue__cl_command_queue: command_queue  [

	"This method was automatically generated."

	"cl_int clRetainCommandQueue(
			cl_command_queue command_queue
	);"
	<apicall: long 'clRetainCommandQueue' (void*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Context APIs' }
OpenCLMacOSInterface class >> private_clRetainContext__cl_context: context  [

	"This method was automatically generated."

	"cl_int clRetainContext(
			cl_context context
	);"
	<apicall: long 'clRetainContext' (void*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Device APIs' }
OpenCLMacOSInterface class >> private_clRetainDevice__cl_device_id: device  [

	"This method was automatically generated."

	"cl_int clRetainDevice(
			cl_device_id device
	);"
	<apicall: long 'clRetainDevice' (void*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Event Object APIs' }
OpenCLMacOSInterface class >> private_clRetainEvent__cl_event: event  [

	"This method was automatically generated."

	"cl_int clRetainEvent(
			cl_event event
	);"
	<apicall: long 'clRetainEvent' (void*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Kernel Object APIs' }
OpenCLMacOSInterface class >> private_clRetainKernel__cl_kernel: kernel  [

	"This method was automatically generated."

	"cl_int clRetainKernel(
			cl_kernel kernel
	);"
	<apicall: long 'clRetainKernel' (void*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Memory Object APIs' }
OpenCLMacOSInterface class >> private_clRetainMemObject__cl_mem: memobj  [

	"This method was automatically generated."

	"cl_int clRetainMemObject(
			cl_mem memobj
	);"
	<apicall: long 'clRetainMemObject' (void*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Program Object APIs' }
OpenCLMacOSInterface class >> private_clRetainProgram__cl_program: program  [

	"This method was automatically generated."

	"cl_int clRetainProgram(
			cl_program program
	);"
	<apicall: long 'clRetainProgram' (void*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Sampler APIs' }
OpenCLMacOSInterface class >> private_clRetainSampler__cl_sampler: sampler  [

	"This method was automatically generated."

	"cl_int clRetainSampler(
			cl_sampler sampler
	);"
	<apicall: long 'clRetainSampler' (void*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-SVM Allocation APIs' }
OpenCLMacOSInterface class >> private_clSVMAlloc__cl_context: context  [
						cl_svm_mem_flags: flags 
						size_t: size 
						cl_uint: alignment 

	"This method was automatically generated."

	"void * clSVMAlloc(
			cl_context context, 
			cl_svm_mem_flags flags, 
			size_t size, 
			cl_uint alignment
	);"
	<apicall: void* 'clSVMAlloc' (void* ulonglong ulong ulong) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-SVM Allocation APIs' }
OpenCLMacOSInterface class >> private_clSVMFree__cl_context: context  [
						void__ptr: svm_pointer 

	"This method was automatically generated."

	"void clSVMFree(
			cl_context context, 
			void * svm_pointer
	);"
	<apicall: void 'clSVMFree' (void* void*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Event Object APIs' }
OpenCLMacOSInterface class >> private_clSetEventCallback__cl_event: event  [
						cl_int: command_exec_callback_type 
						void__ptr: no_callbacks_jmv 
						void__ptr: user_data 

	"This method was automatically generated."

	"cl_int clSetEventCallback(
			cl_event event, 
			cl_int command_exec_callback_type, 
			void * no_callbacks_jmv, 
			void * user_data
	);"
	<apicall: long 'clSetEventCallback' (void* long void* void*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Kernel Object APIs' }
OpenCLMacOSInterface class >> private_clSetKernelArg__cl_kernel: kernel  [
						cl_uint: arg_index 
						size_t: arg_size 
						const__void__ptr: arg_value 

	"This method was automatically generated."

	"cl_int clSetKernelArg(
			cl_kernel kernel, 
			cl_uint arg_index, 
			size_t arg_size, 
			const void * arg_value
	);"
	<apicall: long 'clSetKernelArg' (void* ulong ulong void*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Kernel Object APIs' }
OpenCLMacOSInterface class >> private_clSetKernelArgSVMPointer__cl_kernel: kernel  [
						cl_uint: arg_index 
						const__void__ptr: arg_value 

	"This method was automatically generated."

	"cl_int clSetKernelArgSVMPointer(
			cl_kernel kernel, 
			cl_uint arg_index, 
			const void * arg_value
	);"
	<apicall: long 'clSetKernelArgSVMPointer' (void* ulong void*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Kernel Object APIs' }
OpenCLMacOSInterface class >> private_clSetKernelExecInfo__cl_kernel: kernel  [
						cl_kernel_exec_info: param_name 
						size_t: param_value_size 
						const__void__ptr: param_value 

	"This method was automatically generated."

	"cl_int clSetKernelExecInfo(
			cl_kernel kernel, 
			cl_kernel_exec_info param_name, 
			size_t param_value_size, 
			const void * param_value
	);"
	<apicall: long 'clSetKernelExecInfo' (void* ulong ulong void*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Memory Object APIs' }
OpenCLMacOSInterface class >> private_clSetMemObjectDestructorCallback__cl_mem: memobj  [
						void__ptr: no_callbacks_jmv 
						void__ptr: user_data 

	"This method was automatically generated."

	"cl_int clSetMemObjectDestructorCallback(
			cl_mem memobj, 
			void * no_callbacks_jmv, 
			void * user_data
	);"
	<apicall: long 'clSetMemObjectDestructorCallback' (void* void* void*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Event Object APIs' }
OpenCLMacOSInterface class >> private_clSetUserEventStatus__cl_event: event  [
						cl_int: execution_status 

	"This method was automatically generated."

	"cl_int clSetUserEventStatus(
			cl_event event, 
			cl_int execution_status
	);"
	<apicall: long 'clSetUserEventStatus' (void* long) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'FFI-generated-private-Program Object APIs' }
OpenCLMacOSInterface class >> private_clUnloadPlatformCompiler__cl_platform_id: platform  [

	"This method was automatically generated."

	"cl_int clUnloadPlatformCompiler(
			cl_platform_id platform
	);"
	<apicall: long 'clUnloadPlatformCompiler' (void*) module: 'OpenCL.framework'>

	^self externalCallFailed
]

{ #category : 'class initialization' }
OpenCLMacOSInterface class >> supportedPlatform [
	^'Mac OS'
]
