Class {
	#name : 'ExtendedClipboardUnixInterface',
	#superclass : 'ExtendedClipboardInterface',
	#category : 'ExtendedClipboard',
	#package : 'ExtendedClipboard'
}

{ #category : 'private' }
ExtendedClipboardUnixInterface >> readPrimAvailableFormats [
	| i availableFormats formatData |
	availableFormats _ OrderedCollection new.
	i _ 1.
	[
		formatData _ self getClipboardFormat: i.
		formatData notNil ] whileTrue: [
			availableFormats add: formatData.
			i _ i + 1 ].
	^ availableFormats
]

{ #category : 'api - retrieve' }
ExtendedClipboardUnixInterface >> retrieveId [
	| bytes formats |
	formats _ self readPrimAvailableFormats.
	(formats includes: 'cuis-id')
		ifTrue: [
			bytes _ self readClipboardData: 'cuis-id'.
			^ bytes asString ].
	^ nil
]

{ #category : 'api - retrieve' }
ExtendedClipboardUnixInterface >> retrieveObject [
	| conversion bytes |
	self readPrimAvailableFormats do: [ :format |
		conversion _ format caseOf: {
			"Unformatted plain text"
			[ 'UTF8_STRING' ] -> [ #fromUTF8Bytes: ].
			"Bitmap images (not sure if all of them are actually used in this platform)"
			[ 'image/png' ] -> [ #fromPNGBytes: ].
			[ 'image/tiff' ] -> [ #fromTIFFBytes: ].
			[ 'image/jpeg' ] -> [ #fromJPEGBytes: ].
			[ 'image/bmp' ] -> [ #fromBMPBytes: ].
			[ 'cuis-refStreamed' ] -> [ #fromRefStreamBytes: ].
			"Rich text"
"			[ '????rtf' ] -> [ #fromRTFBytes: ]"
		} otherwise: [ nil ].
		conversion ifNotNil: [
			bytes _ self readClipboardData: format.
			^self perform: conversion with: bytes ]
		].
	^nil	"Could not read any of the available formats"
]

{ #category : 'api - store' }
ExtendedClipboardUnixInterface >> storeForm: aForm id: otherString [
	"I presume the order is: most preferred format first, least desirable format last.
	Cuis object id at the end."
	self clearClipboard.
	self addClipboardData: (PNGReadWriter bytesFor: aForm) dataFormat: 'image/png'.
	self addClipboardData: otherString dataFormat: 'cuis-id'
]

{ #category : 'api - store' }
ExtendedClipboardUnixInterface >> storeString: aString id: otherString [
	"I presume the order is: most preferred format first, least desirable format last.
	Cuis object id at the end."
	self clearClipboard.
	self
		addClipboardData: aString asUtf8Bytes
		dataFormat: 'UTF8_STRING'.
	self addClipboardData: otherString dataFormat: 'cuis-id'
]

{ #category : 'api - store' }
ExtendedClipboardUnixInterface >> storeText: aText id: otherString [
	"I presume the order is: most preferred format first, least desirable format last.
	Cuis object id is usually at the end, but don't include it if we include a streamed representation."
	self clearClipboard.

	"SmartRefStream handles class changes, but a little testing shows stuff is twice as big, and takes 20 times more time to generate"
	self addClipboardData: (ReferenceStream streamedRepresentationOf: aText) dataFormat: 'cuis-refStreamed'.

	"onvert text to RTF and implement"
	"
	self
		addClipboardData: aText rtfString
		dataFormat: '????'
	"
	self
		addClipboardData: aText asString asUtf8Bytes
		dataFormat: 'UTF8_STRING'.

	"If we store a streamed representation, don't store the id. In these cases, we prefer rebuilding the object, regardless of
	whether it is present in memory (because we stored it in the clipboard) or not (because some other Cuis image did it)"
	self addClipboardData: otherString dataFormat: 'cuis-id'
]
