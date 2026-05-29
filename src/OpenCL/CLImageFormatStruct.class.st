"
For uniformity with the other OpenCL FFI types, this would be called CLImageFormat.  However, there is already an OpenCL constant with that name.  The exception is made less objectionable by the other FFI types being opaque handle types, whereas this is the only structure type with accessible fields.

Declared in cl.h (unchanged in OpenCL 1.0, 1.1, 1.2 and 2.0) as:

typedef struct _cl_image_format {
    cl_channel_order        image_channel_order;
    cl_channel_type         image_channel_data_type;
} cl_image_format;
"
Class {
	#name : 'CLImageFormatStruct',
	#superclass : 'ExternalStructure',
	#pools : [
		'OpenCLConstants'
	],
	#category : 'OpenCL-FFI',
	#package : 'OpenCL',
	#tag : 'FFI'
}

{ #category : 'instance creation' }
CLImageFormatStruct class >> alpha8 [
	^self order: CL_A type: CL_UNSIGNED_INT8
]

{ #category : 'instance creation' }
CLImageFormatStruct class >> alpha8Norm [
	^self order: CL_A type: CL_UNORM_INT8
]

{ #category : 'instance creation' }
CLImageFormatStruct class >> argb8888 [
	^self order: CL_ARGB type: CL_UNSIGNED_INT8

]

{ #category : 'instance creation' }
CLImageFormatStruct class >> argb8888norm [
	^self order: CL_ARGB type: CL_UNORM_INT8

]

{ #category : 'instance creation' }
CLImageFormatStruct class >> bgra8888 [
	^self order: CL_BGRA type: CL_UNSIGNED_INT8

]

{ #category : 'instance creation' }
CLImageFormatStruct class >> bgra8888norm [
	^self order: CL_BGRA type: CL_UNORM_INT8

]

{ #category : 'field definition' }
CLImageFormatStruct class >> fields [
	"CLImageFormatStruct defineFields"
	^#(
		(image_channel_order 'ulong')
		(image_channel_data_type 'ulong')
	)
]

{ #category : 'utility' }
CLImageFormatStruct class >> image_channel_data_type_String: channelDataType "a cl_channel_type" [
	"Answer a descriptive string for the given constant."
	^channelDataType caseOf: {
		[CL_SNORM_INT8]			->	['CL_SNORM_INT8'].
		[CL_SNORM_INT16]			-> 	['CL_SNORM_INT16'].
		[CL_UNORM_INT8]			->	['CL_UNORM_INT8'].
		[CL_UNORM_INT16]			->	['CL_UNORM_INT16'].
		[CL_UNORM_SHORT_565]	->	['CL_UNORM_SHORT_565'].
		[CL_UNORM_SHORT_555]	->	['CL_UNORM_SHORT_555'].
		[CL_UNORM_INT_101010]	->	['CL_UNORM_INT_101010'].
		[CL_SIGNED_INT8]			->	['CL_SIGNED_INT8'].
		[CL_SIGNED_INT16]			->	['CL_SIGNED_INT16'].
		[CL_SIGNED_INT32]		->	['CL_SIGNED_INT32'].
		[CL_UNSIGNED_INT8]		->	['CL_UNSIGNED_INT8'].
		[CL_UNSIGNED_INT16]		->	['CL_UNSIGNED_INT16'].
		[CL_UNSIGNED_INT32]		->	['CL_UNSIGNED_INT32'].
		[CL_HALF_FLOAT]			->	['CL_HALF_FLOAT'].
		[CL_FLOAT]					->	['CL_FLOAT'].
		[CL_UNORM_INT24]			->	['CL_UNORM_INT24'].
	} otherwise: [
		String streamContents: [:s |
			s nextPutAll: '<unknown channel data-type '.
			channelDataType printOn: s base: 16.
			s nextPut: $>
		]]
]

{ #category : 'utility' }
CLImageFormatStruct class >> image_channel_order_String: channelOrderConstant "a cl_channel_order_constant" [
	"Answer a descriptive string for the given constant."
	^channelOrderConstant caseOf: {
		[CL_R]						->	['CL_R'].
		[CL_A]						-> 	['CL_A'].
		[CL_RG]					->	['CL_RG'].
		[CL_RA]					->	['CL_RA'].
		[CL_RGB]					->	['CL_RGB'].
		[CL_RGBA]				->	['CL_RGBA'].
		[CL_BGRA]				->	['CL_BGRA'].
		[CL_ARGB]				->	['CL_ARGB'].
		[CL_INTENSITY]			->	['CL_INTENSITY'].
		[CL_LUMINANCE]			->	['CL_LUMINANCE'].
		[CL_Rx]					->	['CL_Rx'].
		[CL_RGx]					-> 	['CL_RGx'].
		[CL_RGBx]				->	['CL_RGBx'].
		[CL_DEPTH]				->	['CL_DEPTH'].
		[CL_DEPTH_STENCIL]	->	['CL_DEPTH_STENCIL'].
		[CL_sRGB]				->	['CL_sRGB'].
		[CL_sRGBx]				->	['CL_sRGBx'].
		[CL_sRGBA]				->	['CL_sRGBA'].
		[CL_sBGRA]				->	['CL_sBGRA'].
		[CL_ABGR]				->	['CL_ABGR'].
	} otherwise: [
		String streamContents: [:s |
			s nextPutAll: '<unknown channel order '.
			channelOrderConstant printOn: s base: 16.
			s nextPut: $>
		]]
]

{ #category : 'instance creation' }
CLImageFormatStruct class >> intensity16SignedNorm [
	^self order: CL_INTENSITY type: CL_SNORM_INT16
]

{ #category : 'instance creation' }
CLImageFormatStruct class >> intensity8 [
	^self order: CL_INTENSITY type: CL_UNSIGNED_INT8
]

{ #category : 'instance creation' }
CLImageFormatStruct class >> intensity8Norm [
	^self order: CL_INTENSITY type: CL_UNORM_INT8
]

{ #category : 'instance creation' }
CLImageFormatStruct class >> intensityFloat [
	^self order: CL_INTENSITY type: CL_FLOAT
]

{ #category : 'instance creation' }
CLImageFormatStruct class >> luminance8 [
	^self order: CL_LUMINANCE type: CL_UNSIGNED_INT8
]

{ #category : 'instance creation' }
CLImageFormatStruct class >> luminance8Float [
	^self order: CL_LUMINANCE type: CL_FLOAT
]

{ #category : 'instance creation' }
CLImageFormatStruct class >> luminance8Norm [
	^self order: CL_LUMINANCE type: CL_UNORM_INT8
]

{ #category : 'instance creation' }
CLImageFormatStruct class >> order: imageChannelOrder type: imageChannelDataType [
	^self new
		image_channel_order: imageChannelOrder;
		image_channel_data_type: imageChannelDataType.
]

{ #category : 'instance creation' }
CLImageFormatStruct class >> r16Signed [
	^self order: CL_R type: CL_SIGNED_INT16
]

{ #category : 'instance creation' }
CLImageFormatStruct class >> r16SignedNorm [
	^self order: CL_R type: CL_SNORM_INT16
]

{ #category : 'instance creation' }
CLImageFormatStruct class >> r8 [
	^self order: CL_R type: CL_UNSIGNED_INT8
]

{ #category : 'instance creation' }
CLImageFormatStruct class >> r8Norm [
	^self order: CL_R type: CL_UNORM_INT8
]

{ #category : 'instance creation' }
CLImageFormatStruct class >> rFloat [
	^self order: CL_R type: CL_FLOAT
]

{ #category : 'instance creation' }
CLImageFormatStruct class >> rgba8888 [
	^self order: CL_RGBA type: CL_UNSIGNED_INT8

]

{ #category : 'instance creation' }
CLImageFormatStruct class >> rgba8888norm [
	^self order: CL_RGBA type: CL_UNORM_INT8

]

{ #category : 'accessing' }
CLImageFormatStruct >> image_channel_data_type [
	"This method was automatically generated"
	^handle unsignedLongAt: 5
]

{ #category : 'accessing' }
CLImageFormatStruct >> image_channel_data_type: anObject [
	"This method was automatically generated"
	handle unsignedLongAt: 5 put: anObject
]

{ #category : 'accessing' }
CLImageFormatStruct >> image_channel_order [
	"This method was automatically generated"
	^handle unsignedLongAt: 1
]

{ #category : 'accessing' }
CLImageFormatStruct >> image_channel_order: anObject [
	"This method was automatically generated"
	handle unsignedLongAt: 1 put: anObject
]

{ #category : 'printing' }
CLImageFormatStruct >> printOn: aStream [
	super printOn: aStream.
	aStream nextPut: $(.
	aStream nextPutAll: (self class image_channel_order_String: self image_channel_order).
	aStream space.
	aStream nextPutAll: (self class image_channel_data_type_String: self image_channel_data_type).
	aStream nextPut: $).
]
