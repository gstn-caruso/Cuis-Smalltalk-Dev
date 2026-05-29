"
For translating Forms to and from the TIFF file format. 
By Martin McClure

This work is based on TIFF revision 6.0. I got the specification from:
http://partners.adobe.com/asn/developer/PDFS/TN/TIFF6.pdf
The spec itself claims it can be obtained from:
http://www.adobe.com/Support/TechNotes.html
and from:
ftp://ftp.adobe.com/pub/adobe/DeveloperSupport/TechNotes/PDFfiles


Structure:
 stream			TIFFStream -- defined by superclass, wraps the stream that
							is being read or written

Current features:
* Reads uncompressed 24-bit RGB TIFF files with 8-bit alpha channels
  into 32-bit Forms, with the alpha channel intact.
* Reads both big-endian and little-endian TIFF files
* Reading TIFFs without alpha channels
* Reading compressed TIFFS (LZW only)

Some features not yet implemented that would be reasonable for this class:
* Writing TIFFs
* Reading TIFFS of different bit depths
* Any of the many other TIFF features

I've tried to make it reasonably easy for anyone who wants to add more of the missing features by breaking the design down into simple little chunks. The chief components are TIFFStream, which wraps a PositionableStream and translates the endian-ness of the stream, TIFFStructure and all its associated classes, which mirror the logical structure of the TIFF file, and TIFFReader (and future TIFFWriter) which interprets the structure of a TIFF and generates the appropriate Form.
"
Class {
	#name : 'TIFFReadWriter',
	#superclass : 'ImageReadWriter',
	#category : 'Graphics-Files-Additional',
	#package : 'Graphics',
	#tag : 'Files-Additional'
}

{ #category : 'private' }
TIFFReadWriter >> binaryStream: aPositionableStream [
	"Reset the given Stream, wrap it in a TIFFStream, and set it as my stream."

	| bigEndian |
	super binaryStream: aPositionableStream.
	bigEndian _ (aPositionableStream peek) = 16r4D. 
		"Assume 16r49 or 16r4D. Bad first byte caught later by TIFFStructure>>validateHeaderOf:"
	stream _ TIFFStream 
		on: aPositionableStream 
		bigEndian: bigEndian.
]

{ #category : 'accessing' }
TIFFReadWriter >> nextImage [
	"Decode an image on my stream and answer the image as a Form."
	^ self reader readForm
]

{ #category : 'accessing' }
TIFFReadWriter >> nextPutImage: aForm [
	"Encode aForm into TIFF form and write on my stream."

	^self error: 'Not Yet Implemented.'.
]

{ #category : 'accessing' }
TIFFReadWriter >> reader [
	| reader |
	reader _ TIFFReader onTiffStream: stream.
	^ reader
]

{ #category : 'testing' }
TIFFReadWriter >> understandsImageFormat [
	"Test to see if the image stream format is understood by this decoder."
	"Return true if this stream appears to contain a TIFF file, otherwise 
	return false."

	"Check for Big-endian header."
	(self hasMagicNumber: 
		(ByteArray with: 16r4D with: 16r4D with: 16r00 with: 16r2A) )
		ifTrue: [ ^ true].

	"Check for little-endian header."
	^ (self hasMagicNumber: 
		(ByteArray with: 16r49 with: 16r49 with: 16r2A with: 16r00) ).
]
