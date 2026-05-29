Class {
	#name : 'ExtendedClipboardMacInterface',
	#superclass : 'ExtendedClipboardInterface',
	#category : 'ExtendedClipboard',
	#package : 'ExtendedClipboard'
}

{ #category : 'private' }
ExtendedClipboardMacInterface >> readPrimAvailableFormats [
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
ExtendedClipboardMacInterface >> retrieveId [
	| bytes formats |
	formats _ self readPrimAvailableFormats.
	(formats includes: 'cuis-id')
		ifTrue: [
			bytes _ self readClipboardData: 'cuis-id'.
			^ bytes asString ].
	^ nil
]

{ #category : 'api - retrieve' }
ExtendedClipboardMacInterface >> retrieveObject [
	| conversion bytes |
	self readPrimAvailableFormats do: [ :format |
		conversion _ format caseOf: {
			"Unformatted plain text"
			[ 'public.utf8-plain-text' ] -> [ #fromUTF8Bytes: ].
			"Bitmap images (not sure if all of them are actually used in this platform)"
			[ 'public.png' ] -> [ #fromPNGBytes: ].
			[ 'public.tiff' ] -> [ #fromTIFFBytes: ].
			[ 'public.jpeg' ] -> [ #fromJPEGBytes: ].
			[ 'public.bmp' ] -> [ #fromBMPBytes: ].
			[ 'cuis-refStreamed' ] -> [ #fromRefStreamBytes: ].
			"Rich text"
			[ 'public.rtf' ] -> [ self canImportRTF ifTrue: [#fromRTFBytes:] ]	"Only if package RTFImporting is loaded"
		} otherwise: [ nil ].
		conversion ifNotNil: [
			bytes _ self readClipboardData: format.
			^self perform: conversion with: bytes ]
		].
	^nil	"Could not read any of the available formats"
]

{ #category : 'api - store' }
ExtendedClipboardMacInterface >> storeForm: aForm id: otherString [
	"I presume the order is: most preferred format first, least desirable format last.
	Cuis object id at the end."
	self clearClipboard.
	self addClipboardData: (PNGReadWriter bytesFor: aForm) dataFormat: 'public.png'.
	"
	Could be done in addition...
	self addClipboardData: (JPEGReadWriter2 bytesFor: aForm) dataFormat: 'public.jpeg'
	"
	self addClipboardData: otherString dataFormat: 'cuis-id'
]

{ #category : 'api - store' }
ExtendedClipboardMacInterface >> storeString: aString id: otherString [
	"I presume the order is: most preferred format first, least desirable format last.
	Cuis object id at the end."
	self clearClipboard.
	self
		addClipboardData: aString asUtf8Bytes
		dataFormat: 'public.utf8-plain-text'.
	"Could be done in addition (maybe with cr line ending?)
	self
		addClipboardData: (aString asByteArray collect: [ :c | Character latin1ToMacRoman: c ])
		dataFormat: 'com.apple.traditional-mac-plain-text'.
		"
	self addClipboardData: otherString dataFormat: 'cuis-id'
]

{ #category : 'api - store' }
ExtendedClipboardMacInterface >> storeText: aText id: otherString [
	"I presume the order is: most preferred format first, least desirable format last.
	Cuis object id is usually at the end, but don't include it if we include a streamed representation."
	self clearClipboard.

	"SmartRefStream handles class changes, but a little testing shows stuff is twice as big, and takes 20 times more time to generate"
	self addClipboardData: (ReferenceStream streamedRepresentationOf: aText) dataFormat: 'cuis-refStreamed'.

	"RTF format
	#rtfString might not be loaded (Package RTFExporting)"
	[ self addClipboardData: aText rtfString asUtf8Bytes dataFormat: 'public.rtf' ] on: MessageNotUnderstood do: [].

	"Just the string"
	self
		addClipboardData: aText asString asUtf8Bytes
		dataFormat: 'public.utf8-plain-text'.

	"If we store a streamed representation, don't store the id. In these cases, we prefer rebuilding the object, regardless of
	whether it is present in memory (because we stored it in the clipboard) or not (because some other Cuis image did it)"
	self addClipboardData: otherString dataFormat: 'cuis-id'
]
