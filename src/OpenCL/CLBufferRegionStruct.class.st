"
Similar to CLImageFormatStruct and CLImageDescStruct. For OpenCL's cl_buffer_region

Declared in cl.h (unchanged in OpenCL 1.1, 1.2 and 2.0) as:

typedef struct _cl_buffer_region {
    size_t                  origin;
    size_t                  size;
} cl_buffer_region;
"
Class {
	#name : 'CLBufferRegionStruct',
	#superclass : 'ExternalStructure',
	#pools : [
		'OpenCLConstants'
	],
	#category : 'OpenCL-FFI',
	#package : 'OpenCL',
	#tag : 'FFI'
}

{ #category : 'accessing' }
CLBufferRegionStruct class >> fields [
	"
	CLBufferRegionStruct defineFields
	"
	^#(
		(origin 'size_t')
		(size 'size_t')
	)
]

{ #category : 'class initialization' }
CLBufferRegionStruct class >> initialize [
	"Different in 32 and 64 bits systems"
	CLBufferRegionStruct defineFields
]

{ #category : 'accessing' }
CLBufferRegionStruct >> origin [
	"This method was automatically generated. See CLBufferRegionStruct class>>fields."
	<generated>
	^handle uint64At: 1
]

{ #category : 'accessing' }
CLBufferRegionStruct >> origin: anObject [
	"This method was automatically generated. See CLBufferRegionStruct class>>fields."
	<generated>
	handle uint64At: 1 put: anObject
]

{ #category : 'accessing' }
CLBufferRegionStruct >> size [
	"This method was automatically generated. See CLBufferRegionStruct class>>fields."
	<generated>
	^handle uint64At: 9
]

{ #category : 'accessing' }
CLBufferRegionStruct >> size: anObject [
	"This method was automatically generated. See CLBufferRegionStruct class>>fields."
	<generated>
	handle uint64At: 9 put: anObject
]
