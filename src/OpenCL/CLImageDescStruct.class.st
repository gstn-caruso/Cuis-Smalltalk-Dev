"
Similar to CLImageFormatStruct. For OpenCL's cl_image_desc

Declared in cl.h (OpenCL 1.2) as:

typedef struct _cl_image_desc {
    cl_mem_object_type      image_type;
    size_t                  image_width;
    size_t                  image_height;
    size_t                  image_depth;
    size_t                  image_array_size;
    size_t                  image_row_pitch;
    size_t                  image_slice_pitch;
    cl_uint                 num_mip_levels;
    cl_uint                 num_samples;
    cl_mem                  buffer;
} cl_image_desc;

Declared in cl.h (OpenCL 2.0) as:
typedef struct _cl_image_desc {
    cl_mem_object_type      image_type;
    size_t                  image_width;
    size_t                  image_height;
    size_t                  image_depth;
    size_t                  image_array_size;
    size_t                  image_row_pitch;
    size_t                  image_slice_pitch;
    cl_uint                 num_mip_levels;
    cl_uint                 num_samples;
#ifdef __GNUC__
    __extension__   /* Prevents warnings about anonymous union in -pedantic builds */
#endif
    union {
      cl_mem                  buffer;
      cl_mem                  mem_object;
    };
} cl_image_desc;
"
Class {
	#name : 'CLImageDescStruct',
	#superclass : 'ExternalStructure',
	#pools : [
		'OpenCLConstants'
	],
	#category : 'OpenCL-FFI',
	#package : 'OpenCL',
	#tag : 'FFI'
}

{ #category : 'accessing' }
CLImageDescStruct class >> fields [
	"
	CLImageDescStruct defineFields
	"
	^#(
		(image_type 'size_t') "Should actually be ulong. This is a hack: if size_8 is 8 bytes, aling next field (Assumes little endian!)"
		(image_width 'size_t')
		(image_height 'size_t')
		(image_depth 'size_t')
		(image_array_size 'size_t')
		(image_row_pitch 'size_t')
		(image_slice_pitch 'size_t')
		(num_mip_levels 'ulong')
		(num_samples 'ulong')
		(buffer 'ulong')
	)
]

{ #category : 'utility' }
CLImageDescStruct class >> image_type_String: image_type "a image_type constant" [
	"Answer a descriptive string for the given constant."
	^image_type caseOf: {
		[CL_MEM_OBJECT_BUFFER]				->	['CL_MEM_OBJECT_BUFFER'].
		[CL_MEM_OBJECT_IMAGE2D]				-> 	['CL_MEM_OBJECT_IMAGE2D'].
		[CL_MEM_OBJECT_IMAGE3D]				->	['CL_MEM_OBJECT_IMAGE3D'].
		[CL_MEM_OBJECT_IMAGE2D_ARRAY]		->	['CL_MEM_OBJECT_IMAGE2D_ARRAY'].
		[CL_MEM_OBJECT_IMAGE1D]				->	['CL_MEM_OBJECT_IMAGE1D'].
		[CL_MEM_OBJECT_IMAGE1D_ARRAY]		->	['CL_MEM_OBJECT_IMAGE1D_ARRAY'].
		[CL_MEM_OBJECT_IMAGE1D_BUFFER]	->	['CL_MEM_OBJECT_IMAGE1D_BUFFER'].
		[CL_MEM_OBJECT_PIPE]					->	['CL_MEM_OBJECT_PIPE'].
	} otherwise: [
		String streamContents: [:s |
			s nextPutAll: '<unknown image_type '.
			image_type printOn: s base: 16.
			s nextPut: $>
		]]
]

{ #category : 'class initialization' }
CLImageDescStruct class >> initialize [
	"Different in 32 and 64 bits systems"
	CLImageDescStruct defineFields
]

{ #category : 'accessing' }
CLImageDescStruct >> buffer [
	"This method was automatically generated. See CLImageDescStruct class>>fields."
	<generated>
	^handle uint32At: 65
]

{ #category : 'accessing' }
CLImageDescStruct >> buffer: anObject [
	"This method was automatically generated. See CLImageDescStruct class>>fields."
	<generated>
	handle uint32At: 65 put: anObject
]

{ #category : 'accessing' }
CLImageDescStruct >> image_array_size [
	"This method was automatically generated. See CLImageDescStruct class>>fields."
	<generated>
	^handle uint64At: 33
]

{ #category : 'accessing' }
CLImageDescStruct >> image_array_size: anObject [
	"This method was automatically generated. See CLImageDescStruct class>>fields."
	<generated>
	handle uint64At: 33 put: anObject
]

{ #category : 'accessing' }
CLImageDescStruct >> image_depth [
	"This method was automatically generated. See CLImageDescStruct class>>fields."
	<generated>
	^handle uint64At: 25
]

{ #category : 'accessing' }
CLImageDescStruct >> image_depth: anObject [
	"This method was automatically generated. See CLImageDescStruct class>>fields."
	<generated>
	handle uint64At: 25 put: anObject
]

{ #category : 'accessing' }
CLImageDescStruct >> image_height [
	"This method was automatically generated. See CLImageDescStruct class>>fields."
	<generated>
	^handle uint64At: 17
]

{ #category : 'accessing' }
CLImageDescStruct >> image_height: anObject [
	"This method was automatically generated. See CLImageDescStruct class>>fields."
	<generated>
	handle uint64At: 17 put: anObject
]

{ #category : 'accessing' }
CLImageDescStruct >> image_row_pitch [
	"This method was automatically generated. See CLImageDescStruct class>>fields."
	<generated>
	^handle uint64At: 41
]

{ #category : 'accessing' }
CLImageDescStruct >> image_row_pitch: anObject [
	"This method was automatically generated. See CLImageDescStruct class>>fields."
	<generated>
	handle uint64At: 41 put: anObject
]

{ #category : 'accessing' }
CLImageDescStruct >> image_slice_pitch [
	"This method was automatically generated. See CLImageDescStruct class>>fields."
	<generated>
	^handle uint64At: 49
]

{ #category : 'accessing' }
CLImageDescStruct >> image_slice_pitch: anObject [
	"This method was automatically generated. See CLImageDescStruct class>>fields."
	<generated>
	handle uint64At: 49 put: anObject
]

{ #category : 'accessing' }
CLImageDescStruct >> image_type [
	"This method was automatically generated. See CLImageDescStruct class>>fields."
	<generated>
	^handle uint64At: 1
]

{ #category : 'accessing' }
CLImageDescStruct >> image_type: anObject [
	"This method was automatically generated. See CLImageDescStruct class>>fields."
	<generated>
	handle uint64At: 1 put: anObject
]

{ #category : 'accessing' }
CLImageDescStruct >> image_width [
	"This method was automatically generated. See CLImageDescStruct class>>fields."
	<generated>
	^handle uint64At: 9
]

{ #category : 'accessing' }
CLImageDescStruct >> image_width: anObject [
	"This method was automatically generated. See CLImageDescStruct class>>fields."
	<generated>
	handle uint64At: 9 put: anObject
]

{ #category : 'accessing' }
CLImageDescStruct >> mem_object [
	"In OpenCL 1.2, this field does not exist. At this position there is field 'buffer'
	In OpenCL 2.0, a union of 'buffer' and 'mem_object', both of type cl_mem"
	^handle unsignedLongAt: 37
]

{ #category : 'accessing' }
CLImageDescStruct >> mem_object: aMemObjectId [
	"In OpenCL 1.2, this field does not exist. At this position there is field 'buffer'
	In OpenCL 2.0, a union of 'buffer' and 'mem_object', both of type cl_mem"
	handle unsignedLongAt: 37 put: aMemObjectId
]

{ #category : 'accessing' }
CLImageDescStruct >> num_mip_levels [
	"This method was automatically generated. See CLImageDescStruct class>>fields."
	<generated>
	^handle uint32At: 57
]

{ #category : 'accessing' }
CLImageDescStruct >> num_mip_levels: anObject [
	"This method was automatically generated. See CLImageDescStruct class>>fields."
	<generated>
	handle uint32At: 57 put: anObject
]

{ #category : 'accessing' }
CLImageDescStruct >> num_samples [
	"This method was automatically generated. See CLImageDescStruct class>>fields."
	<generated>
	^handle uint32At: 61
]

{ #category : 'accessing' }
CLImageDescStruct >> num_samples: anObject [
	"This method was automatically generated. See CLImageDescStruct class>>fields."
	<generated>
	handle uint32At: 61 put: anObject
]

{ #category : 'printing' }
CLImageDescStruct >> printOn: aStream [
	super printOn: aStream.
	aStream
		nextPut: $(;
		nextPutAll: (self class image_type_String: self image_type);
		nextPutAll: ' width:'; print: self image_width;
		nextPutAll: ' height:'; print: self image_height;
		nextPutAll: ' depth'; print: self image_depth;
		nextPutAll: ' arraySize:'; print: self image_array_size;
		nextPutAll: ' rowPitch:'; print: self image_row_pitch;
		nextPutAll: ' slicePitch:'; print: self image_slice_pitch;
		nextPutAll: ' mipLevels:'; print: self num_mip_levels;
		nextPutAll: ' numSamples:'; print: self num_samples;
		nextPutAll: ' buffer:'; print: self buffer;
		nextPut: $)
]
