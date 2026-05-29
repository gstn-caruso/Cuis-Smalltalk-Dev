"
I mirror the logical structure of a TIFF file, including its directories and fields but not its pixel data. I can parse a TIFFStream or (future) write to a TIFFStream. I'm not too smart about what my structure means, I leave that interpretation to TIFFImage.
By Martin McClure

Structure:
 imageFileDirectories		SequenceableCollection -- each element is a TIFFImageFileDirectory

I hold the logical structure of the TIFF, but I do not preserve the physical structure (specific offsets) of the file I was parsed from (except for the offsets of the pixel data.)

See TIFFReader (and future TIFFWriter) for more information about the structure into which I fit.
"
Class {
	#name : 'TIFFStructure',
	#superclass : 'Object',
	#instVars : [
		'imageFileDirectories'
	],
	#category : 'Graphics-Files-Additional',
	#package : 'Graphics',
	#tag : 'Files-Additional'
}

{ #category : 'instance creation' }
TIFFStructure class >> parseFrom: aTIFFStream [
	"Answer a new instance of the receiver resulting from parsing the given TIFFStream from a position of 0. Error if the TIFFStream does not contain a valid TIFF."

	^ self new parseFrom: aTIFFStream.
]

{ #category : 'accessing' }
TIFFStructure >> at: tagSymbol [
	"Answer the value I have for the given tag Symbol. If I have no value for that tag, return the default value for that tag. 
	All TIFF tags are structured with array values, but many tags never have an array with more than one value. Thus, I answer the sole value for such tags, and answer an array for tags that can have more than one value.
	I report an error if I have no value for a tag that has no default or if I have more than one value for a tag that should only have one value.
	I only look in my first image file directory for values."

	| ifd |
	ifd _ imageFileDirectories first. "Reports an error if no IFDs."
	^ ifd at: tagSymbol.
]

{ #category : 'parsing' }
TIFFStructure >> parseFrom: aTIFFStream [
	"Parse the given TIFFStream and set my internal state to match. Error if the TIFFStream does not contain a valid TIFF."

	"Wipe out any former contents."
	imageFileDirectories _ OrderedCollection new.

	self validateHeaderOf: aTIFFStream.
	self parseIFDsFrom: aTIFFStream.
	aTIFFStream compressionType: (self at: #Compression)
]

{ #category : 'parsing' }
TIFFStructure >> parseIFDsFrom: aTIFFStream [
	"Read as many image file directories as aTIFFStream contains, and put them into my state. Per the TIFF spec, there must be at least one IFD."

	| ifd ifdPosition |
	aTIFFStream position: 4. "Offset in header of pointer to first IFD."
	ifdPosition := aTIFFStream nextUint32.
	[ifdPosition = 0] 
		whileFalse: [
			aTIFFStream position: ifdPosition.
			ifd := TIFFImageFileDirectory parseFrom: aTIFFStream.
			imageFileDirectories add: ifd.
			ifdPosition := aTIFFStream nextUint32].

]

{ #category : 'parsing' }
TIFFStructure >> validateHeaderOf: aTIFFStream [
	"Report an error if the header of the given stream is not valid, 
	or does not match the endian-ness of the TIFFStream."

	| expectedWord douglasAdams |
	expectedWord := aTIFFStream isBigEndian 
		ifTrue: [16r4D4D]
		ifFalse: [16r4949].
	douglasAdams := 42.
	aTIFFStream reset.
	(aTIFFStream nextUint16 = expectedWord) 
		ifFalse: [self error: 'TIFF Header not valid. First word not correct for expected endian-ness'].
	(aTIFFStream nextUint16 = douglasAdams) 
		ifFalse: [self error: 'TIFF Header not valid. Answer not 42.']
]
