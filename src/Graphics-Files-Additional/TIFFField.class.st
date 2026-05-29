"
I represent a TIFF field, or tag-value pair. I'm part of a TIFFImageFileDirectory.
By Martin McClure

Structure:
 tag			Integer -- one of my tag constants that is the integer TIFF tag indicating the field meaning.
 type		Integer -- one of my type constants that is the integer TIFF type of my values
 values		Array -- my array of values. The size of size is equal to the TIFF 'count' word.
					Each value should be of a type compatible with my 'type' ivar.

ValueReaderSelectors 		Dictionary -- maps TIFF type integers to the selectors of the methods used to read field values of that type.

TagSymbols					Dictionary -- maps TIFF tag integers to tag symbols.

SingleValuedTagSymbols		Set -- contains the tag symbols of the fields types that should have a value that consists of an array of length one.

DefaultFields				Dictionary -- maps tag symbols to the default field with that tag. Only maps tag symbols for which the TIFF spec defines a default.
"
Class {
	#name : 'TIFFField',
	#superclass : 'Object',
	#instVars : [
		'tag',
		'type',
		'values'
	],
	#classVars : [
		'DefaultFields',
		'SingleValuedTagSymbols',
		'TagSymbols',
		'ValueReaderSelectors'
	],
	#category : 'Graphics-Files-Additional',
	#package : 'Graphics',
	#tag : 'Files-Additional'
}

{ #category : 'defaults' }
TIFFField class >> defaultFor: tagSymbol [
		"Answer the default field for the given tag Symbol. Raise an error if there is no default field for the given tag Symbol."
	^ DefaultFields 
		at: tagSymbol
		ifAbsent: [self error: 'No default value for this tag.']. 
]

{ #category : 'initializing' }
TIFFField class >> initialize [
	"TIFFField initialize."

	self initializeValueReaderSelectors.
	self initializeTagSymbols.
	self initializeSingleValuedTagSymbols.
	self initializeDefaultFields.
]

{ #category : 'initializing' }
TIFFField class >> initializeDefaultFields [
	"DefaultFields				Dictionary -- maps tag symbols to the default field with that tag. Only maps tag symbols for which the TIFF spec defines a default."

	DefaultFields _ Dictionary new.
	DefaultFields
		at: #BitsPerSample "1-bit bi-level image."
		put: (TIFFField tag: 258 type: 3 values: (Array with: 1));

		at: #Compression "No compression"
		put: (TIFFField tag: 259 type: 3 values: (Array with: 1));

		at: #Predictor "No predictor"
		put: (TIFFField tag: 317 type: 3 values: (Array with: 1));
		
		at: #FillOrder "Lower column values in higher-order bits"
		put: (TIFFField tag: 266 type: 3 values: (Array with: 1));
		
		at: #GrayResponseUnit "hundredths"
		put: (TIFFField tag: 290 type: 3 values: (Array with: 2));
		
		"The defaults for MaxSampleValue and MinSampleValue are a function of BitsPerSample and SmaplesPerPixel, and I don't anticipate needing these fields for Squeak purposes, so defaults for them are not handled according to the spec."

		at: #NewSubfileType "Primary Image"
		put: (TIFFField tag: 254 type: 4 values: (Array with: 0));
		
		at: #Orientation "0, 0 is top left of image"
		put: (TIFFField tag: 274 type: 3 values: (Array with: 1));
		
		at: #PlanarConfiguration "Chunky"
		put: (TIFFField tag: 284 type: 3 values: (Array with: 1));
		
		at: #ResolutionUnit "Inch"
		put: (TIFFField tag: 296 type: 3 values: (Array with: 2));
		
		at: #RowsPerStrip "Effectively infinite"
		put: (TIFFField tag: 278 type: 4 values: (Array with: 16rFFFFFFFF));
		
		at: #SamplesPerPixel "One"
		put: (TIFFField tag: 277 type: 3 values: (Array with: 1));
		
		at: #Threshholding "No dithering or halftoning applied"
		put: (TIFFField tag: 263 type: 3 values: (Array with: 1)).
		

]

{ #category : 'initializing' }
TIFFField class >> initializeSingleValuedTagSymbols [
	"SingleValuedTagSymbols		Set -- contains the tag symbols of the fields types that should have a value that consists of an array of length one."
	SingleValuedTagSymbols _ Set new.
	SingleValuedTagSymbols
		add: #CellLength ;
		add: #CellWidth ;
		add: #Compression ;
		add: #Predictor ;
		add: #DateTime ; "Should be a single String."
		add: #FillOrder ;
		add: #GrayResponseUnit ;
		add: #ImageLength ;
		add: #ImageWidth ;
		add: #NewSubfileType ;
		add: #Orientation ;
		add: #PhotometricInterpretation ;
		add: #PlanarConfiguration ;
		add: #ResolutionUnit ;
		add: #RowsPerStrip ;
		add: #SamplesPerPixel ;
		add: #SubfileType ;
		add: #Threshholding ;
		add: #XResolution ;
		add: #YResolution .

]

{ #category : 'initializing' }
TIFFField class >> initializeTagSymbols [
	"TagSymbols					Dictionary -- maps TIFF tag integers to tag symbols."
	TagSymbols _ Dictionary new.
	TagSymbols
		at: 315 put: #Artist ;
		at: 258 put: #BitsPerSample ;
		at: 265 put: #CellLength ;
		at: 264 put: #CellWidth ;
		at: 320 put: #ColorMap ;
		at: 259 put: #Compression ;
		at: 317 put: #Predictor ;
		at: 33432 put: #Copyright ;
		at: 306 put: #DateTime ;
		at: 338 put: #ExtraSamples ;
		at: 266 put: #FillOrder ;
		at: 289 put: #FreeByteCounts ;
		at: 288 put: #FreeOffsets ;
		at: 291 put: #GrayResponseCurve ;
		at: 290 put: #GrayResponseUnit ;
		at: 316 put: #HostComputer ;
		at: 270 put: #ImageDescription ;
		at: 257 put: #ImageLength ;
		at: 256 put: #ImageWidth ;
		at: 271 put: #Make ;
		at: 281 put: #MaxSampleValue ;
		at: 280 put: #MinSampleValue ;
		at: 272 put: #Model ;
		at: 254 put: #NewSubfileType ;
		at: 274 put: #Orientation ;
		at: 262 put: #PhotometricInterpretation ;
		at: 284 put: #PlanarConfiguration ;
		at: 296 put: #ResolutionUnit ;
		at: 278 put: #RowsPerStrip ;
		at: 277 put: #SamplesPerPixel ;
		at: 305 put: #Software ;
		at: 279 put: #StripByteCounts ;
		at: 273 put: #StripOffsets ;
		at: 255 put: #SubfileType ;
		at: 263 put: #Threshholding ;
		at: 282 put: #XResolution ;
		at: 283 put: #YResolution .

]

{ #category : 'initializing' }
TIFFField class >> initializeValueReaderSelectors [
	"ValueReaderSelectors 	Dictionary -- maps TIFF type integers to the selectors of the methods used to read field values of that type."

	ValueReaderSelectors _ Dictionary new.
	ValueReaderSelectors
		at: 1 put: #readByteValuesFrom: ;
		at: 2 put: #readAsciiValuesFrom: ;
		at: 3 put: #readShortValuesFrom: ;
		at: 4 put: #readLongValuesFrom: ;
		at: 5 put: #readRationalValuesFrom: .

]

{ #category : 'instance creation' }
TIFFField class >> parseFrom: aTIFFStream [
	"Answer a new instance of the receiver resulting from parsing the given TIFFStream from its current position. Leave the stream positioned after the field, which will be the beginning of the next field, if any."

	^ self new parseFrom: aTIFFStream.
]

{ #category : 'private' }
TIFFField class >> tag: tagInteger type: typeInteger values: valueArray [
	"Answer a new instance with the given state."
	^ self new 
		tag: tagInteger
		type: typeInteger
		values: valueArray.
]

{ #category : 'private' }
TIFFField >> isSingleValued [
	"Answer true iff my tag is one that should only have one value, and I only have one value.
	Raise an error if I should have exactly one value but I have some other number of values."
	| singleValued |
	singleValued _ SingleValuedTagSymbols includes: self tagSymbol.
	(singleValued and: [values size ~= 1])
		ifTrue: [self error: 'Field not single-valued that should be.'].
	^ singleValued.
]

{ #category : 'private' }
TIFFField >> parseFrom: aTIFFStream [
	"Fill in my state with the results from parsing the given TIFFStream from its current position. Leave the stream positioned after the field, which will be the beginning of the next field, if any. Answer nil if the field has an unknown tag, otherwise answer self."

	| selector |
	tag := aTIFFStream nextUint16.
	(TagSymbols includesKey: tag) 
		ifFalse: [aTIFFStream skip: 10. "Move past the type, count, and value/offset."
				^ nil].
	type := aTIFFStream nextUint16.
	selector := ValueReaderSelectors 
		at: type 
		ifAbsent: "Can't read this type, ignore the field."
			[aTIFFStream skip: 8. "Move past the value/offset."
			^ nil].
	self perform: selector with: aTIFFStream.
	
]

{ #category : 'printing' }
TIFFField >> printOn: aStream [

	super printOn: aStream.
	values printOn: aStream.
]

{ #category : 'private-value reading' }
TIFFField >> read: count charsFrom: aTIFFStream [
	"Read count bytes from the current position of aTIFFStream and return them as an Array of Strings, using NUL as the separating character between strings. Don't worry about the ending position of aTIFFStream."
	| strings oneString size |
	strings := OrderedCollection new.
	oneString := OrderedCollection new.
	1 to: count do: [ :i |
		aTIFFStream peek = 0
			ifFalse: [
				oneString add: (Character codePoint: aTIFFStream nextByte) ]
			ifTrue: [ "Null, so that's the end of this string. "
				size := oneString size.
				strings add: ((String new: size) replaceFrom: 1 to: size with: oneString) ]].
	^ strings asArray
]

{ #category : 'private-value reading' }
TIFFField >> readAsciiValuesFrom: aTIFFStream [
	"Read the count long and count number of characters from aTIFFStream at its current position according to my type. Store the result as one or more Strings in my array of values, using the NUL character to detect separation between strings. Leave aTIFFStream positioned eight bytes past its starting position."

	| count |
	count := aTIFFStream nextUint32.
	values := (count <= 4) "Offset is immediate data, not pointer to data."
		ifTrue: [self readImmediate: count charsFrom: aTIFFStream.]
		ifFalse: [self readIndirect: count charsFrom: aTIFFStream.].
]

{ #category : 'private-value reading' }
TIFFField >> readByteValuesFrom: aTIFFStream [
	"Read the count long and count number of bytes from aTIFFStream at its current position according to my type. Store the result as my array of values. Leave aTIFFStream positioned eight bytes past its starting position."

	| count |
	count := aTIFFStream nextUint32.
	values := Array new: count.
	(count <= 4) "Offset is immediate data, not pointer to data."
		ifTrue: [self readImmediate: count bytesFrom: aTIFFStream.]
		ifFalse: [self readIndirect: count bytesFrom: aTIFFStream.].

]

{ #category : 'private-value reading' }
TIFFField >> readImmediate: count bytesFrom: aTIFFStream [
	"Put the next count bytes in aTIFFStream into my values array, starting from values at: 1. Leave aTIFFStream positioned four bytes past its starting position. Count must be <= 4."
	| position |
	position _ aTIFFStream position.
	1 to: count do: [ :i | values at: i put: aTIFFStream nextByte].
	aTIFFStream position: position + 4.
	
]

{ #category : 'private-value reading' }
TIFFField >> readImmediate: count charsFrom: aTIFFStream [
	"Read the next count bytes in aTIFFStream and return an Array of Strings, using NUL as the separating character between strings. Leave aTIFFStream positioned four bytes past its starting position. Count must be <= 4."
	| position result |
	position _ aTIFFStream position.
	result _ self read: count charsFrom: aTIFFStream.
	aTIFFStream position: position + 4.
	^ result.
]

{ #category : 'private-value reading' }
TIFFField >> readImmediate: count longsFrom: aTIFFStream [
	"Put the next count 32-bit longs in aTIFFStream into my values array, starting from values at: 1. Leave aTIFFStream positioned four bytes past its starting position. Count must be <= 1."
	| position |
	position := aTIFFStream position.
	1 to: count do: [:i | values at: i put: aTIFFStream nextUint32].
	aTIFFStream position: position + 4.
	
]

{ #category : 'private-value reading' }
TIFFField >> readImmediate: count shortsFrom: aTIFFStream [
	"Put the next count 16-bit shorts in aTIFFStream into my values array, starting from values at: 1. Leave aTIFFStream positioned four bytes past its starting position. Count must be <= 2."
	| position |
	position := aTIFFStream position.
	1 to: count do: [:i | values at: i put: aTIFFStream nextUint16].
	aTIFFStream position: position + 4.
	
]

{ #category : 'private-value reading' }
TIFFField >> readIndirect: count bytesFrom: aTIFFStream [
	"Read a long offset from aTIFFStream, then read count bytes from that offset in aTIFFStream into my values array, starting from values at: 1. Leave aTIFFStream positioned four bytes past its starting position."
	| offset position |
	offset := aTIFFStream nextUint32.
	position := aTIFFStream position.
	aTIFFStream position: offset.
	1 to: count do: [:i | values at: i put: aTIFFStream nextByte].
	aTIFFStream position: position.
]

{ #category : 'private-value reading' }
TIFFField >> readIndirect: count charsFrom: aTIFFStream [
	"Read a long offset from aTIFFStream, then read count bytes from that offset in aTIFFStream and return them as an Array of Strings, using NUL as the separating character between strings. Leave aTIFFStream positioned four bytes past its starting position."
	| offset position result |
	offset := aTIFFStream nextUint32.
	position := aTIFFStream position.
	aTIFFStream position: offset.
	result := self read: count charsFrom: aTIFFStream.
	aTIFFStream position: position.
	^ result.
]

{ #category : 'private-value reading' }
TIFFField >> readIndirect: count longsFrom: aTIFFStream [
	"Read a 32-bit offset from aTIFFStream, then read count 32-bit longs from that offset in aTIFFStream into my values array, starting from values at: 1. Leave aTIFFStream positioned four bytes past its starting position."
	| offset position |
	offset := aTIFFStream nextUint32.
	position := aTIFFStream position.
	aTIFFStream position: offset.
	1 to: count do: [:i | values at: i put: aTIFFStream nextUint32].
	aTIFFStream position: position.
]

{ #category : 'private-value reading' }
TIFFField >> readIndirect: count rationalsFrom: aTIFFStream [
	"Read a 32-bit offset from aTIFFStream, then read count 32-bit longs from that offset in aTIFFStream into my values array, starting from values at: 1. Leave aTIFFStream positioned four bytes past its starting position."
	| offset position |
	offset := aTIFFStream nextUint32.
	position := aTIFFStream position.
	aTIFFStream position: offset.
	1 to: count do: [:i | values at: i put: (aTIFFStream nextUint32 / aTIFFStream nextUint32)].
	aTIFFStream position: position.
]

{ #category : 'private-value reading' }
TIFFField >> readIndirect: count shortsFrom: aTIFFStream [
	"Read a long offset from aTIFFStream, then read count 16-bit shorts from that offset in aTIFFStream into my values array, starting from values at: 1. Leave aTIFFStream positioned four bytes past its starting position."
	| offset position |
	offset := aTIFFStream nextUint32.
	position := aTIFFStream position.
	aTIFFStream position: offset.
	1 to: count do: [:i | values at: i put: aTIFFStream nextUint16].
	aTIFFStream position: position.
]

{ #category : 'private-value reading' }
TIFFField >> readLongValuesFrom: aTIFFStream [
	"Read the 32-bit count and count number of 32-bit values from aTIFFStream at its current position according to my type. Store the result as my array of values. Leave aTIFFStream positioned eight bytes past its starting position."

	| count |
	count := aTIFFStream nextUint32.
	values := Array new: count.
	(count <= 1) "Offset is immediate data, not pointer to data."
		ifTrue: [self readImmediate: count longsFrom: aTIFFStream.]
		ifFalse: [self readIndirect: count longsFrom: aTIFFStream.].

]

{ #category : 'private-value reading' }
TIFFField >> readRationalValuesFrom: aTIFFStream [
	"Read the 32-bit count and count number of 64-bit rational values from aTIFFStream at its current position according to my type. Store the result as my array of values. Leave aTIFFStream positioned eight bytes past its starting position."

	| count |
	count := aTIFFStream nextUint32.
	values := Array new: count.
	"Can't fit even one rational into 32 bits, so always indirect, never immediate."
	self readIndirect: count rationalsFrom: aTIFFStream.

]

{ #category : 'private-value reading' }
TIFFField >> readShortValuesFrom: aTIFFStream [
	"Read the 32-bit count and count number of 16-bit shorts from aTIFFStream at its current position according to my type. Store the result as my array of values. Leave aTIFFStream positioned eight bytes past its starting position."

	| count |
	count := aTIFFStream nextUint32.
	values := Array new: count.
	(count <= 2) "Offset is immediate data, not pointer to data."
		ifTrue: [self readImmediate: count shortsFrom: aTIFFStream.]
		ifFalse: [self readIndirect: count shortsFrom: aTIFFStream.].

]

{ #category : 'accessing' }
TIFFField >> tag [
	"Return the tag integer that indicates what kind of TIFF field this is."
	^ tag.

]

{ #category : 'private' }
TIFFField >> tag: tagInteger type: typeInteger values: valueArray [
	"Set my state to the given values."
	tag _ tagInteger.
	type _ typeInteger.
	values _ valueArray.
]

{ #category : 'accessing' }
TIFFField >> tagSymbol [
	"Answer the Symbol that indicates what kind of TIFF field this is.
	If it's an unknown tag, answer nil."
	^ TagSymbols at: tag ifAbsent: [nil].

]

{ #category : 'accessing' }
TIFFField >> value [
	"Answer my value. All TIFF fields are structured with array values, but many tags never have an array with more than one value. Thus, I answer the sole value for such tags, and answer an array for tags that can have more than one value.
	I report an error if I have more than one value for a tag that should only have one value."

	^ (self isSingleValued) 
		ifTrue: [values at: 1]
		ifFalse: [values].
]
