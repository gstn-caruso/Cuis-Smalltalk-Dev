Class {
	#name : 'ExtendedClipboardInterface',
	#superclass : 'Object',
	#instVars : [
		'clipboard'
	],
	#classVars : [
		'Current',
		'WinClipboardTypes'
	],
	#category : 'ExtendedClipboard',
	#package : 'ExtendedClipboard'
}

{ #category : 'accessing' }
ExtendedClipboardInterface class >> current [
	| platform |
	Current ifNil: [
		platform _ Smalltalk platformName.
		Current _ platform = 'unix'
			ifTrue: [ ExtendedClipboardUnixInterface new ]
			ifFalse: [
				platform = 'Win32'
					ifTrue: [ ExtendedClipboardWinInterface new ]
					ifFalse: [ ExtendedClipboardMacInterface new ]]].
	^ Current.
]

{ #category : 'class initialization' }
ExtendedClipboardInterface class >> initialize [
	"ExtendedClipboardInterface initialize"
	Current := nil.
	Smalltalk
		addToStartUpList: self after: nil;
		addToShutDownList: self after: nil.
]

{ #category : 'system startup' }
ExtendedClipboardInterface class >> shutDown: quitting [

]

{ #category : 'system startup' }
ExtendedClipboardInterface class >> startUp: resuming [
	"The image is either being newly started (resuming is true), or it's just been snapshotted"

	Current := nil.
	self current.
]

{ #category : 'private' }
ExtendedClipboardInterface >> addClipboardData: data dataFormat: aFormat [
	clipboard = 0 ifTrue: [
		"Should never happen!"
		self error: 'broken clipboard'.
		^self].
	self primAddClipboardData: clipboard data: data dataFormat: aFormat asUtf8BytesOrByteString.
]

{ #category : 'testing' }
ExtendedClipboardInterface >> canImportRTF [
	^Smalltalk includesKey: #RTFTextBuilder
]

{ #category : 'testing' }
ExtendedClipboardInterface >> canStore [
	"Store into clipboard implemented on most platforms.
	Answer false in subclasses that can't store into clipboard."
	^clipboard ~= 0
]

{ #category : 'private' }
ExtendedClipboardInterface >> clearClipboard [
	clipboard = 0 ifTrue: [^self].
	^ self primClearClipboard: clipboard
]

{ #category : 'private' }
ExtendedClipboardInterface >> createClipboard [
	clipboard = 0 ifTrue: [^self].
	^ self primCreateClipboard
]

{ #category : 'object from raw data' }
ExtendedClipboardInterface >> fromBMPBytes: bytes [
	^ (BMPReadWriter onBinaryStream: bytes readStream) nextImage
]

{ #category : 'object from raw data' }
ExtendedClipboardInterface >> fromISO8859Bytes: bytes [

	^(String streamContents: [ :strm | bytes do: [ :byte | strm nextPut: (Character codePoint: byte) ]])
		withCuisLineEndings
]

{ #category : 'object from raw data' }
ExtendedClipboardInterface >> fromJPEGBytes: bytes [
	^ (JPEGReadWriter2 onBinaryStream: bytes readStream) nextImage
]

{ #category : 'object from raw data' }
ExtendedClipboardInterface >> fromPNGBytes: bytes [
	^ (PNGReadWriter onBinaryStream: bytes readStream) nextImage
]

{ #category : 'object from raw data' }
ExtendedClipboardInterface >> fromRefStreamBytes: bytes [
	^ ReferenceStream unStream: bytes
]

{ #category : 'object from raw data' }
ExtendedClipboardInterface >> fromTIFFBytes: bytes [
	^ (TIFFReadWriter on: bytes readStream) nextImage
]

{ #category : 'object from raw data' }
ExtendedClipboardInterface >> fromUTF8Bytes: utf8Bytes [

	^(UnicodeString fromUtf8Bytes: utf8Bytes) withCuisLineEndings
]

{ #category : 'private' }
ExtendedClipboardInterface >> getClipboardFormat: formatNumber [
	clipboard = 0 ifTrue: [^nil].
	^ self primGetClipboardFormat: clipboard formatNumber: formatNumber
]

{ #category : 'initialization' }
ExtendedClipboardInterface >> initialize [
	clipboard := [self createClipboard] on: Error do: [:ex | clipboard := 0]
]

{ #category : 'testing' }
ExtendedClipboardInterface >> isOperational [
	"Can be redefined if needed.
	We should check that ClipboardExtendedPlugin is available and operational."
	^clipboard ~= 0
]

{ #category : 'system primitives' }
ExtendedClipboardInterface >> primAddClipboardData: aClipboard data: data dataFormat: aFormat [

	<primitive:'ioAddClipboardData' module: 'ClipboardExtendedPlugin'>
	^ self primitiveFailed.
]

{ #category : 'system primitives' }
ExtendedClipboardInterface >> primClearClipboard: aClipboard [

	<primitive:'ioClearClipboard' module: 'ClipboardExtendedPlugin'>
	^ self primitiveFailed.

]

{ #category : 'system primitives' }
ExtendedClipboardInterface >> primCreateClipboard [
	<primitive:'ioCreateClipboard' module: 'ClipboardExtendedPlugin'>
	^ self primitiveFailed.

]

{ #category : 'system primitives' }
ExtendedClipboardInterface >> primGetClipboardFormat: aClipboard formatNumber: formatNumber [

	<primitive:'ioGetClipboardFormat' module: 'ClipboardExtendedPlugin'>
	^ self primitiveFailed.

]

{ #category : 'system primitives' }
ExtendedClipboardInterface >> primReadClipboardData: aClipboard format: format [

	<primitive:'ioReadClipboardData' module: 'ClipboardExtendedPlugin'>.
	^ self primitiveFailed.

]

{ #category : 'private' }
ExtendedClipboardInterface >> readClipboardData: format [
	^clipboard = 0 ifFalse: [
		self primReadClipboardData: clipboard format: format  asUtf8BytesOrByteString ]
]

{ #category : 'api - retrieve' }
ExtendedClipboardInterface >> retrieveId [
	^self subclassResponsibility
]

{ #category : 'api - retrieve' }
ExtendedClipboardInterface >> retrieveObject [
	^self subclassResponsibility
]

{ #category : 'api - store' }
ExtendedClipboardInterface >> storeForm: aForm id: otherString [
	"I presume the order is: most preferred format first, least desirable format last.
	Cuis object id at the end."
	^self subclassResponsibility
]

{ #category : 'api - store' }
ExtendedClipboardInterface >> storeString: aString id: otherString [
	"I presume the order is: most preferred format first, least desirable format last.
	Cuis object id at the end."
	^self subclassResponsibility
]

{ #category : 'api - store' }
ExtendedClipboardInterface >> storeText: aText id: otherString [
	"I presume the order is: most preferred format first, least desirable format last.
	Cuis object id is usually at the end, but don't include it if we include a streamed representation."

	^self subclassResponsibility
]
