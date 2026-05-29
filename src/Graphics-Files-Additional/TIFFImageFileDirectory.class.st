"
Mirrors the structure of a TIFF file's Image File Directory. Can be created by parsing itself from a TIFFStream or can (future) write itself to a TIFFStream.
By Martin McClure

Structure:
 fields		Dictionary -- maps tag symbols to the TIFFFields that make up this IFD.
 
See TIFFStructure for more information about where I fit.
"
Class {
	#name : 'TIFFImageFileDirectory',
	#superclass : 'Object',
	#instVars : [
		'fields'
	],
	#category : 'Graphics-Files-Additional',
	#package : 'Graphics',
	#tag : 'Files-Additional'
}

{ #category : 'instance creation' }
TIFFImageFileDirectory class >> parseFrom: aTIFFStream [
	"Answer a new instance of the receiver resulting from parsing the given TIFFStream from its current position. Leave the stream positioned at the start of the next IFD, or at 0 if no more."
	^ self new parseFrom: aTIFFStream.
]

{ #category : 'accessing' }
TIFFImageFileDirectory >> at: tagSymbol [
	"Answer the value I have for the given tag Symbol. If I have no value for that tag, return the default value for that tag. 
	All TIFF tags are structured with array values, but many tags never have an array with more than one value. Thus, I answer the sole value for such tags, and answer an array for tags that can have more than one value.
	I report an error if I have no value for a tag that has no default or if I have more than one value for a tag that should only have one value."

	| field |
	field _ fields 
		at: tagSymbol
		ifAbsent: 
			[TIFFField defaultFor: tagSymbol]. "Raises error if no default."
	^ field value.
]

{ #category : 'private' }
TIFFImageFileDirectory >> parseFrom: aTIFFStream [
	"Blow away any former state I had and parse a new collection of fields from the given stream.
	Leave the stream positioned at the end of the IFD, just before the pointer to the next IFD."
	| fieldCount field |
	fieldCount := aTIFFStream nextUint16.
	fields := Dictionary newWithRoomForMoreThan: fieldCount.
	fieldCount timesRepeat: [
		field := TIFFField parseFrom: aTIFFStream.
		field isNil ifFalse: [fields at: field tagSymbol put: field] ].

]
