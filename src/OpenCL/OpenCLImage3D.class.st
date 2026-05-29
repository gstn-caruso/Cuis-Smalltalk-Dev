Class {
	#name : 'OpenCLImage3D',
	#superclass : 'OpenCLContextObject',
	#instVars : [
		'format',
		'width',
		'height',
		'depth',
		'rowPitch',
		'slicePitch'
	],
	#category : 'OpenCL',
	#package : 'OpenCL'
}

{ #category : 'initialize' }
OpenCLImage3D >> context: anOpenCLContext format: fmt "a CLImageFormatStruct" width: w height: h depth: d rowPitch: rp slicePitch: sp [
	"Set the context that this buffer was created for, as well as its dimensions and format." 
	context := anOpenCLContext.
	format := fmt.
	width := w.
	height := h.
	depth := d.
	rowPitch := rp.
	slicePitch := sp
]

{ #category : 'accessing' }
OpenCLImage3D >> depth [
	^depth
]

{ #category : 'accessing' }
OpenCLImage3D >> format [
	^format
]

{ #category : 'accessing' }
OpenCLImage3D >> height [
	^height
]

{ #category : 'accessing' }
OpenCLImage3D >> rowPitch [
	^rowPitch
]

{ #category : 'accessing' }
OpenCLImage3D >> slicePitch [
	^slicePitch
]

{ #category : 'accessing' }
OpenCLImage3D >> width [
	^width
]
