"
I parse a TIFF file and produce a Form. I usually am created and used by a TIFFReadWriter.
By Martin McClure

Structure:
 stream		TIFFStream -- Usually over a TIFF file.
 structure		TIFFStructure -- The TIFF IFDs and fields that together make up the image characteristics, all the information but the pixels themselves.


"
Class {
	#name : 'TIFFReader',
	#superclass : 'Object',
	#instVars : [
		'stream',
		'structure'
	],
	#category : 'Graphics-Files-Additional',
	#package : 'Graphics',
	#tag : 'Files-Additional'
}

{ #category : 'instance creation' }
TIFFReader class >> onTiffStream: aTIFFStream [
	"Create and answer an instance of the receiver based on the given TIFFStream. Parse the structure at this time as well."
	^ self new tiffStream: aTIFFStream.

]

{ #category : 'accessing' }
TIFFReader >> extent [
	"Answer a Point that defines my image's size in pixels."
	^ (structure at: #ImageWidth) @ (structure at: #ImageLength).

]

{ #category : 'private' }
TIFFReader >> positionStreamToStripNum: anInteger [
	"Position my TIFFStream at the start of the given strip, where 1 is the first strip."
	stream position: ((structure at: #StripOffsets) at: anInteger).
	stream newStrip
]

{ #category : 'reading' }
TIFFReader >> readForm [
	"Answer a Form created from the data in my stream and structure."
	| result bps |
	self validateTIFFType. "Make sure it's a type we can handle."
	
	(structure at: #SamplesPerPixel) >= 3 ifTrue: [
		result _ Form 
				extent: self extent
				depth: 32. "32 bits form with RGB or RGBA"
		
		((structure at: #PlanarConfiguration) = 1)
		ifTrue: [ 	"chunky" 
			self
				readRGB8PixelsInto: result
				readAlpha: (structure at: #SamplesPerPixel) = 4
				horizontalPredictor: ((structure at: #Predictor) = 2) ]
		ifFalse: [ 	"planar"
			self
				readPlanarRGB8PixelsInto: result
				readAlpha: (structure at: #SamplesPerPixel) = 4
				horizontalPredictor: (structure at: #Predictor) = 2 ]].
	
	(structure at: #SamplesPerPixel) = 1 ifTrue: [
		bps _ (structure at: #BitsPerSample) at: 1.
		bps caseOf: {
			[ 8 ] -> [
				"ColorForm set for 8bpp gray scale images"
				result _ GrayForm extent: self extent.
				self
					readGray8PixelsInto: result
					horizontalPredictor: ((structure at: #Predictor) = 2) ].

			[ 16 ] -> [
				"float image"
				result _ (Smalltalk at: #ShortWordMatrix ifAbsent: [
						self error: '16bpp TIFF requires ShortWordMatrix (LinearAlgebra package)' ])
					extent: self extent.
				self readGray16PixelsInto: result ] }].

	^ result
]

{ #category : 'private' }
TIFFReader >> readGray16PixelsInto: aShortWordMatrix [
	"Replace the given Form's pixel values with pixel values from my TIFFStream. aForm must have the correct extent.
	Handles 16 bit pixels on source, float as destination."

	| elements totalPixels pixelsPerStrip currentStripNum pixel | 
	elements := aShortWordMatrix elements.
	totalPixels := elements size.
	pixelsPerStrip := aShortWordMatrix extent x * (structure at: #RowsPerStrip).
	currentStripNum := 0.

	1 to: totalPixels do: [ :pixNum |
		(pixNum-1 \\ aShortWordMatrix width = 0) ifTrue: [
			(pixNum - 1 \\ pixelsPerStrip = 0) ifTrue: [
				"Time to go to next strip"
				currentStripNum := currentStripNum + 1.
				self positionStreamToStripNum: currentStripNum ]].

		pixel := stream nextUint16.
		elements at: pixNum put: pixel ]
]

{ #category : 'private' }
TIFFReader >> readGray8PixelsInto: aGrayForm horizontalPredictor: useHorizontalPredictor [
	"Replace the given Form's pixel values with pixel values from my TIFFStream. aForm must have the correct extent.
	Only handles 8-bit gray pixels on both source and destination."

	| bits totalPixels pixelsPerStrip currentStripNum g gg pixel bytesPerRow row column |
	bits _ aGrayForm bits.
	totalPixels _ aGrayForm width * aGrayForm height.
	pixelsPerStrip _ aGrayForm width * (structure at: #RowsPerStrip).
	currentStripNum _ 0.
	row _ -1.
	column _ 0.
	bytesPerRow _ aGrayForm width + 3 // 4 * 4.
	1 to: totalPixels do: [ :pixNum |
		(pixNum-1 \\ aGrayForm width = 0) ifTrue: [
			row _ row + 1.
			column _ 0.
			(pixNum - 1 \\ pixelsPerStrip = 0) ifTrue: [
				"Time to go to next strip"
				currentStripNum _ currentStripNum + 1.
				self positionStreamToStripNum: currentStripNum ].
			useHorizontalPredictor ifTrue: [
				g _ 0 ]].
		column _ column + 1.

		gg _ stream nextByteInBody.

		useHorizontalPredictor
			ifTrue: [
				g _ (g + gg) bitAnd: 255 ]
			ifFalse: [
				g _ gg ].
		pixel _ g.
		bits byteAt: (row *  bytesPerRow) + column put: pixel bigEndian: aGrayForm isBigEndian ]
]

{ #category : 'private' }
TIFFReader >> readPlanarRGB8PixelsInto: a32BitForm readAlpha: doReadAlpha horizontalPredictor: useHorizontalPredictor [
	"Replace the given Form's pixel values with pixel values from my TIFFStream. aForm must have the correct extent.
	Handles 24 or 32-bit pixels on source, and destination of 32 bits per pixel."

	| bits totalPixels pixelsPerStrip currentStripNum pixel component componentByte shifts | 
	bits _ a32BitForm bits.
	totalPixels _ bits size.
	pixelsPerStrip _ a32BitForm extent x * (structure at: #RowsPerStrip).
	currentStripNum _ 0.

	shifts _ doReadAlpha
		ifTrue: [ #( 24 16 8 0 ) ]
		ifFalse: [ #( 16 8 0 ) ].

	shifts do: [ :shift |
		1 to: totalPixels do: [ :pixNum |
			(pixNum-1 \\ a32BitForm width = 0) ifTrue: [
				(pixNum - 1 \\ pixelsPerStrip = 0) ifTrue: [
					"Time to go to next strip"
					currentStripNum _ currentStripNum + 1.
					self positionStreamToStripNum: currentStripNum ].
				useHorizontalPredictor ifTrue: [
					component _ 0 ]].

			componentByte _ stream nextByteInBody.
			component _ useHorizontalPredictor
				ifTrue: [ (component + componentByte) bitAnd: 255 ]
				ifFalse: [ componentByte ].

			pixel _ component << shift + (bits at: pixNum).
			bits at: pixNum put: pixel ]].

	"Alpha set at the end, to avoid LargIntegers in the code above
	(a32BitForm came with all zeros, see senders)"
	doReadAlpha ifFalse: [
		a32BitForm makeAllPixelsOpaque ]
]

{ #category : 'private' }
TIFFReader >> readRGB8PixelsInto: a32BitForm readAlpha: doReadAlpha horizontalPredictor: useHorizontalPredictor [
	"Replace the given Form's pixel values with pixel values from my TIFFStream. aForm must have the correct extent.
	Handles 24 or 32-bit pixels on source, and destination of 32 bits per pixel."

	| bits totalPixels pixelsPerStrip currentStripNum pixel a b g r aa bb rr gg | 
	bits _ a32BitForm bits.
	totalPixels _ bits size.
	pixelsPerStrip _ a32BitForm extent x * (structure at: #RowsPerStrip).
	currentStripNum _ 0.
	a _ 255.

	1 to: totalPixels do: [ :pixNum |
		(pixNum-1 \\ a32BitForm width = 0) ifTrue: [
			(pixNum - 1 \\ pixelsPerStrip = 0) ifTrue: [
				"Time to go to next strip"
				currentStripNum _ currentStripNum + 1.
				self positionStreamToStripNum: currentStripNum ].
			useHorizontalPredictor ifTrue: [
				r _ g _ b _ 0.
				a _ doReadAlpha ifTrue: [ 0 ] ifFalse: [ 255 ] ]].

		rr _ stream nextByteInBody.
		gg _ stream nextByteInBody.
		bb _ stream nextByteInBody.
		doReadAlpha
			ifTrue: [ aa _ stream nextByteInBody ].

		useHorizontalPredictor
			ifTrue: [
				r _ (r + rr) bitAnd: 255.
				g _ (g + gg) bitAnd: 255.
				b _ (b + bb) bitAnd: 255.
				doReadAlpha
					ifTrue: [ a _ (a + aa) bitAnd: 255 ] ]
			ifFalse: [
				r _ rr.
				g _ gg.
				b _ bb.
				doReadAlpha
					ifTrue: [ a _ aa ] ].
		pixel _ (r << 16) + (g << 8) + b + (a << 24).
		bits at: pixNum put: pixel.].
]

{ #category : 'private' }
TIFFReader >> tiffStream: aTIFFStream [
	"Set the given stream as my stream, and read the TIFF's structure from that stream."
	stream _ aTIFFStream.
	structure _ TIFFStructure parseFrom: stream.

]

{ #category : 'private' }
TIFFReader >> validateTIFFType [
	"Examine my structure to see if it represents a TIFF that I know how to read. 
	At the moment, I can read only
		Gray 8-bit
		Gray 16-bit
		RGB 24-bit 
		RGB 32-bit with an alpha channel,
	uncompressed, chunky TIFFs ."

	| bpsArray compression predictor |
	((structure at: #PhotometricInterpretation) between: 1 and: 2) "Black is zero: 1, RGB: 2"
		ifFalse: [self error: 'Cannot read, this is not an Gray or RGB TIFF.'].
	(#(1 3 4) includes: (structure at: #SamplesPerPixel))  "gray/bilevel: 1, RGB: 3, RGBA: 4"
		ifFalse: [self error: 'Cannot read, this TIFF is not a Gray, Bilevel, RGB, or RGBA TIFF.'].
	compression _ structure at: #Compression.
	(compression = 1 or: [ compression = 5 ]) "Uncompressed (1) or LZW (5)"
		ifFalse: [self error: 'Cannot read, this TIFF is compressed with an unsupported algorithm.'].
	predictor _ structure at: #Predictor.
	(predictor = 1 or: [ predictor = 2 and: [ compression = 5]])
		ifFalse: [self error: 'Cannot read, this TIFF uses an unsupported predictor.'].
	((structure at: #FillOrder) = 1) 
		ifFalse: [self error: 'Cannot read, this TIFF has a FillOrder other than 1.'].
	((structure at: #Orientation) = 1) 
		ifFalse: [self error: 'Cannot read, this TIFF has an Orientation other than 1.'].
	bpsArray _ structure at: #BitsPerSample.
	((#(1 3 4) includes: bpsArray size) and: [ (bpsArray allSatisfy: [ :d | d = 8 ]) or: [bpsArray = #(16)]])
		ifFalse: [self error: 'Cannot read, this TIFF is not a Gray, RGB or RGBA TIFF with 8bpp or Gray 16bpp.']
]
