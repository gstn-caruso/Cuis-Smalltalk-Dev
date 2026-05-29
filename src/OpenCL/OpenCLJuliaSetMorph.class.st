"
OpenCLJuliaSetMorph new openInHand
"
Class {
	#name : 'OpenCLJuliaSetMorph',
	#superclass : 'ImageMorph',
	#instVars : [
		'julia'
	],
	#category : 'OpenCL-Examples',
	#package : 'OpenCL',
	#tag : 'Examples'
}

{ #category : 'private' }
OpenCLJuliaSetMorph >> changeIfDirty [
	"If the Julia set needs to be redrawn, then so does this morph."
	julia isDirty ifTrue: [self changed].
]

{ #category : 'drawing' }
OpenCLJuliaSetMorph >> drawOn: aCanvas [
	self initializeJuliaIfNecessary.
	julia isDirty ifTrue: [julia runKernel].
	super drawOn: aCanvas
]

{ #category : 'geometry' }
OpenCLJuliaSetMorph >> extent: aPoint [
	julia extent: aPoint.
	self image: julia outputForm.
	julia runKernel.
	self changed.
	
]

{ #category : 'accessing' }
OpenCLJuliaSetMorph >> imaginary [
	"Answer the 'imaginary' parameter of the Julia set."
	^julia imaginary
]

{ #category : 'accessing' }
OpenCLJuliaSetMorph >> imaginary: newImaginary [
	"Set the 'imaginary' parameter of the Julia set."
	julia imaginary: newImaginary.
	self changeIfDirty.
]

{ #category : 'initialize' }
OpenCLJuliaSetMorph >> initialize [
	super initialize.
	julia := OpenCLJuliaSet new.
	self useRainbowToneMap.
	self extent: 512@512.
	julia runKernel.
	self changed.
	

]

{ #category : 'private' }
OpenCLJuliaSetMorph >> initializeJuliaIfNecessary [
	"If the OpenCL context is absent or destroyed, we need to re-initialize 'julia'."
	(julia context isNil or: [julia context isDestroyed]) 
		ifTrue: [julia initialize.
				self image: julia outputForm]
]

{ #category : 'geometry testing' }
OpenCLJuliaSetMorph >> isOrthoRectangularMorph [
	^false
]

{ #category : 'accessing' }
OpenCLJuliaSetMorph >> real [
	"Answer the 'real' parameter of the Julia set."
	^julia real
]

{ #category : 'accessing' }
OpenCLJuliaSetMorph >> real: newReal [
	"Set the 'real' parameter of the Julia set."
	julia real: newReal.
	self changeIfDirty.
]

{ #category : 'tone-maps' }
OpenCLJuliaSetMorph >> useRainbowToneMap [
	"Generate a tone-map that cycles through the color-wheel.."
	self initializeJuliaIfNecessary.
	julia useRainbowToneMap
]
