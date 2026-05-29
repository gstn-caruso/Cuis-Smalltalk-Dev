Class {
	#name : 'OpenCLImage2D',
	#superclass : 'OpenCLContextObject',
	#instVars : [
		'format',
		'width',
		'height',
		'rowPitch'
	],
	#category : 'OpenCL',
	#package : 'OpenCL'
}

{ #category : 'initialize' }
OpenCLImage2D >> context: anOpenCLContext format: fmt "a CLImageFormatStruct" width: w height: h rowPitch: rp  [
	"Set the context that this buffer was created for, as well as its dimensions and format." 
	context := anOpenCLContext.
	format := fmt.
	width := w.
	height := h.
	rowPitch := rp.
]

{ #category : 'accessing' }
OpenCLImage2D >> extent [
	^width@height
]

{ #category : 'accessing' }
OpenCLImage2D >> format [
	^format
]

{ #category : 'accessing' }
OpenCLImage2D >> height [
	^height
]

{ #category : 'accessing' }
OpenCLImage2D >> rowPitch [
	^rowPitch
]

{ #category : 'accessing' }
OpenCLImage2D >> width [
	^width
]
