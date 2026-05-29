Class {
	#name : 'ExtendedClipboardWinInterface',
	#superclass : 'ExtendedClipboardInterface',
	#instVars : [
		'lastSeenSequenceNr'
	],
	#category : 'ExtendedClipboard',
	#package : 'ExtendedClipboard'
}

{ #category : 'private' }
ExtendedClipboardWinInterface >> addClipboardData: data dataFormat: aFormat [
	self canStore ifFalse: [
		self error: 'Writing to Extended Clipboard not implemented in Windows' ]
]

{ #category : 'system calls' }
ExtendedClipboardWinInterface >> attemptCloseClipboard [
	"ExtendedClipboardWinInterface new closeClipboard"
	"http://msdn.microsoft.com/library/default.asp?url=/library/en-us/winui/winui/windowsuserinterface/dataexchange/clipboard/clipboardreference/clipboardfunctions/getclipboardformatname.asp

BOOL CloseClipboard(      

    VOID 
);"
	<apicall: long 'CloseClipboard' () module: 'user32.dll'>
]

{ #category : 'testing' }
ExtendedClipboardWinInterface >> canStore [
	"Store into clipboard not yet implemented on Windows"
	^false
]

{ #category : 'private' }
ExtendedClipboardWinInterface >> clearClipboard [
	self canStore ifFalse: [
		self error: 'Writing to Extended Clipboard not implemented in Windows' ]
]

{ #category : 'system calls' }
ExtendedClipboardWinInterface >> clipboardAvailable: format [
	"ExtendedClipboardWinInterface new clipboardAvailable: 8"

	"http://msdn2.microsoft.com/en-us/library/ms649047(VS.85).aspx

BOOL IsClipboardFormatAvailable(      
    UINT format
);"
	<apicall: bool 'IsClipboardFormatAvailable' (ulong) module: 'user32.dll'>
	^self externalCallFailed
]

{ #category : 'system calls' }
ExtendedClipboardWinInterface >> closeClipboard [
	"ExtendedClipboardWinInterface new closeClipboard"
	"http://msdn.microsoft.com/library/default.asp?url=/library/en-us/winui/winui/windowsuserinterface/dataexchange/clipboard/clipboardreference/clipboardfunctions/getclipboardformatname.asp

BOOL CloseClipboard(      

    VOID 
);"
	<apicall: long 'CloseClipboard' () module: 'user32.dll'>
	^self externalCallFailed
]

{ #category : 'private' }
ExtendedClipboardWinInterface >> createClipboard [
	"Not on Windows"
	clipboard := 0
]

{ #category : 'system calls' }
ExtendedClipboardWinInterface >> format: format [
	"ExtendedClipboardInterface format: 0"

	"http://msdn.microsoft.com/library/default.asp?url=/library/en-us/winui/winui/windowsuserinterface/dataexchange/clipboard/clipboardreference/clipboardfunctions/emptyclipboard.asp

UINT EnumClipboardFormats(      

    UINT format
);"
	<apicall: ulong 'EnumClipboardFormats' (ulong) module: 'user32.dll'>
	^self externalCallFailed
]

{ #category : 'system calls' }
ExtendedClipboardWinInterface >> getBitmapBitsFrom: handle count: nrOfBytes buffer: buffer [
	"ExtendedClipboardWinInterface new getBitmapBitsFrom: handle count: nrOfBytes buffer: buffer"

	"http://msdn2.microsoft.com/en-us/library/ms532332(VS.85).aspx

LONG GetBitmapBits(
  HBITMAP hbmp,      // handle to bitmap
  LONG cbBuffer,     // number of bytes to copy
  LPVOID lpvBits     // buffer to receive bits
);"
	<apicall: long 'GetBitmapBits' (void* long byte* ) module: 'Gdi32.dll'>
	^self externalCallFailed
]

{ #category : 'system calls' }
ExtendedClipboardWinInterface >> getClipboardData: format [
	"ExtendedClipboardWinInterface new getClipboardData: 1"

	"http://msdn.microsoft.com/library/default.asp?url=/library/en-us/winui/winui/windowsuserinterface/dataexchange/clipboard/clipboardreference/clipboardfunctions/getclipboarddata.asp

HANDLE GetClipboardData(      

    UINT uFormat
);"
	<apicall: byte * 'GetClipboardData' (ulong) module: 'user32.dll'>
	^self externalCallFailed
]

{ #category : 'system calls' }
ExtendedClipboardWinInterface >> getClipboardDataHandle: format [
	"ExtendedClipboardWinInterface new getBMPClipboardData: 2"

	"http://msdn2.microsoft.com/en-us/library/ms649039.aspx

HANDLE GetClipboardData(      

    UINT uFormat
);"
	<apicall: void* 'GetClipboardData' (ulong) module: 'user32.dll'>
	^self externalCallFailed
]

{ #category : 'system calls' }
ExtendedClipboardWinInterface >> getClipboardFormatName: format name: string size: stringSize [
	"ExtendedClipboardInterface getClipboardFormatName: 49171 name: (String new:128) size: 128"

	"http://msdn.microsoft.com/library/default.asp?url=/library/en-us/winui/winui/windowsuserinterface/dataexchange/clipboard/clipboardreference/clipboardfunctions/getclipboardformatname.asp

int GetClipboardFormatName(      

    UINT format,
    LPTSTR lpszFormatName,
    int cchMaxCount
);"
	<apicall: long 'GetClipboardFormatNameA' (ulong char* long) module: 'user32.dll'>
	^self externalCallFailed
]

{ #category : 'system calls' }
ExtendedClipboardWinInterface >> getClipboardSequenceNumber [

	"http://msdn2.microsoft.com/en-us/library/ms649042(VS.85).aspx

 DWORD GetClipboardSequenceNumber(      
    VOID 
);"
	<apicall: long 'GetClipboardSequenceNumber' () module: 'user32.dll'>
	^self externalCallFailed
]

{ #category : 'system calls' }
ExtendedClipboardWinInterface >> getObject: handle bufferSize: bufferSize buffer: buffer [
	"ExtendedClipboardWinInterface new getObject: handle bufferSize buffer: buffer"

	"http://msdn2.microsoft.com/en-us/library/ms533268.aspx

int GetObject(
  HGDIOBJ hgdiobj,  // handle to graphics object
  int cbBuffer,     // size of buffer for object information
  LPVOID lpvObject  // buffer for object information
);"
	<apicall: long 'GetObjectW' (void* long Win32TagBitmap *) module: 'Gdi32.dll'>
	^self externalCallFailed
]

{ #category : 'testing' }
ExtendedClipboardWinInterface >> hasExternalClipboardChanged [
	| prevSequenceNr |
	prevSequenceNr :=  self lastSeenSequenceNr.
	self
		openClipboard;
		closeClipboard.
	^prevSequenceNr < self lastSeenSequenceNr
]

{ #category : 'testing' }
ExtendedClipboardWinInterface >> isOperational [
	"Check that we can access the Wiindows clipboard."
	| result |
	result _ self openClipboard: 0.
	self attemptCloseClipboard.
	^result ~= 0
]

{ #category : 'private' }
ExtendedClipboardWinInterface >> lastSeenSequenceNr [
	^lastSeenSequenceNr ifNil: [lastSeenSequenceNr := -1].
]

{ #category : 'system calls' }
ExtendedClipboardWinInterface >> listFormats [
	"ExtendedClipboardWinInterface new listFormats"

	| currentFormat result data buffer |
	result := self openClipboard: 0.
	result = 0
		ifTrue: [^self halt].
	currentFormat := 0.
	[
		'' print.
		currentFormat := self format: currentFormat.
		Transcript show: 'format: '; show: currentFormat printString; newLine.
		(#(1 16 7 49510 49355) includes: currentFormat)
			ifTrue: [
				data := self getClipboardData: currentFormat.
				Transcript show: data fromCString; newLine].
"		13 = currentFormat
			ifTrue: [
				data := self getClipboardData: currentFormat.
				Transcript show: data fromUTF16String; newLine]."

		currentFormat > 18
			ifTrue: [
				buffer := ByteArray new:128.
				self getClipboardFormatName: currentFormat name: buffer size: buffer size.
				Transcript show: 'buffer: '; show: buffer; newLine].
		currentFormat ~= 0
	] whileTrue.
	self closeClipboard
]

{ #category : 'system calls' }
ExtendedClipboardWinInterface >> openClipboard [
	| result |
	result := self openClipboard: 0.
	lastSeenSequenceNr := self getClipboardSequenceNumber.
	result = 0
		ifTrue: [self halt].

]

{ #category : 'system calls' }
ExtendedClipboardWinInterface >> openClipboard: windowOwner [
	"ExtendedClipboardInterface openClipboard: 0"

	"http://msdn.microsoft.com/library/default.asp?url=/library/en-us/winui/winui/windowsuserinterface/dataexchange/clipboard/clipboardreference/clipboardfunctions/openclipboard.asp

BOOL OpenClipboard(      

    HWND hWndNewOwner
);"
	<apicall: long 'OpenClipboard' (long) module: 'user32.dll'>
	"^self externalCallFailed"
	^0
]

{ #category : 'private' }
ExtendedClipboardWinInterface >> readClipboardData: format [
	| answer |
	self openClipboard.
	[
		answer _ (self getClipboardData: format) "fromCString" fromCStringAsByteArray
	] ensure: [ self closeClipboard ].
	^ answer
]

{ #category : 'private' }
ExtendedClipboardWinInterface >> readPrimAvailableFormats [
	| i availableFormats |
	availableFormats _ OrderedCollection new.
	i _ 0.
	self openClipboard.
	[
		i _ self format: i.
		i ~= 0 ] whileTrue: [
			availableFormats add: i ].
	self closeClipboard.
	^ availableFormats
]

{ #category : 'api - retrieve' }
ExtendedClipboardWinInterface >> retrieveId [
	"Implement!"
	^nil
]

{ #category : 'api - retrieve' }
ExtendedClipboardWinInterface >> retrieveObject [
	| conversion formatName bytes |
	conversion _ nil.
	self readPrimAvailableFormats do: [ :format |

		"Bitmap images "		
		format = 2 ifTrue: [
			^ self retrieveWindowsBMPForm ].	"CF_BITMAP: read using FFI"

		"Unformatted plain text"
		format = 1 ifTrue: [
			conversion _ #fromISO8859Bytes: ].	"'text/plain' CF_TEXT"
			"Check for other formats such as 13 'text/unicode' CF_UNICODETEXT if needed"


		format > 18 ifTrue: [
			formatName := ByteArray new:128.
			self getClipboardFormatName: format name: formatName size: formatName size.
			(formatName asString beginsWith: 'Rich Text Format') ifTrue: [
				self canImportRTF ifTrue: [conversion _ #fromRTFBytes:] ].		"text/rtf" "Only if package RTFImporting is loaded"
		].

		"Work on this when we do copy to clipboard"
		"[ 'cuis-refStreamed' ] -> [ #fromRefStreamBytes: ]"

		conversion ifNotNil: [
			bytes _ self readClipboardData: format.
			^self perform: conversion with: bytes ]
	].
	^ nil	"Could not read any of the available formats"
]

{ #category : 'private' }
ExtendedClipboardWinInterface >> retrieveWindowsBMPForm [
	| handle bitmap result form bitBuffer byteCount |
	self openClipboard.
	[handle := self getClipboardDataHandle: 2 " 'image/*' CF_BITMAP"]
		ensure: [self closeClipboard].

	"Check handle"
	"Allocate buffer for bitmap structure"
	bitmap := Win32Bitmap new.
	result := self getObject: handle bufferSize: Win32Bitmap byteSize buffer: bitmap.
	byteCount := bitmap bmWidth * bitmap bmHeight * bitmap bmBitsPixel / 8.
	bitBuffer := ByteArray new: byteCount.
	result := self getBitmapBitsFrom: handle count: byteCount buffer: bitBuffer.

	result = 0
		ifTrue: [
			^nil].
	form := Form fromWin32BitMap: bitmap bits: bitBuffer.
	^form
]

{ #category : 'private' }
ExtendedClipboardWinInterface >> retrieveWindowsDIBForm [
	| handle bitmap result form bitBuffer |
	self openClipboard.
	[handle := self getClipboardDataHandle: 8 "CF_DIB"]
		ensure: [self closeClipboard].

	"Check handle"
	"Allocate buffer for bitmap structure"
"	result := self getObject: handle bufferSize: Win32BitmapInfoHeader byteSize buffer: nil."
self halt.
	bitmap := Win32Bitmap new.
	result := self getObject: handle bufferSize: Win32Bitmap byteSize buffer: bitmap.
	bitBuffer := ExternalAddress allocate: bitmap bmWidth*bitmap bmHeight*bitmap bmBitsPixel.
	bitmap bmBits: (ExternalData fromHandle: bitBuffer type: ExternalType byte asPointerType).
	result := self getObject: handle bufferSize: Win32Bitmap byteSize buffer: bitmap.

	result = 0
		ifTrue: [
			bitBuffer free.
			self halt.
			^nil].
	form := Form fromWin32BitMap: bitmap.
	bitBuffer free.
	^form
]

{ #category : 'system calls' }
ExtendedClipboardWinInterface >> setClipboardFormat: format data: data  [
	"ExtendedClipboardInterface current setClipboardFormat: 1 data: ('clipboard test' copyWith: (Character codePoint: 0)) "

	"http://msdn.microsoft.com/library/default.asp?url=/library/en-us/winui/winui/windowsuserinterface/dataexchange/clipboard/clipboardreference/clipboardfunctions/setclipboarddata.asp

HANDLE SetClipboardData(      

    UINT uFormat,
    HANDLE hMem
);"
	<apicall: long 'SetClipboardData' (ulong char*) module: 'user32.dll'>
	^self externalCallFailed
]

{ #category : 'system calls' }
ExtendedClipboardWinInterface >> setClipboardString: string [
	"ExtendedClipboardInterface current setClipboardString: 'clipboard test'"

	"http://msdn.microsoft.com/library/default.asp?url=/library/en-us/winui/winui/windowsuserinterface/dataexchange/clipboard/clipboardreference/clipboardfunctions/setclipboarddata.asp

HANDLE SetClipboardData(      

    UINT uFormat,
    HANDLE hMem
);"
"	Warning (jmv) This code from Sophie gives a compilation error in Cuis. Learn why.
	<apicall: long 'SetClipboardData' (ulong char*) module: 'user32.dll'>
"
	^self externalCallFailed
]

{ #category : 'api - store' }
ExtendedClipboardWinInterface >> storeForm: aForm id: otherString [
	"I presume the order is: most preferred format first, least desirable format last.
	Cuis object id at the end."
	"To be implemented"
	self halt
]

{ #category : 'api - store' }
ExtendedClipboardWinInterface >> storeString: aString id: otherString [
	"I presume the order is: most preferred format first, least desirable format last.
	Cuis object id at the end."
	"To be implemented"
	self halt
]

{ #category : 'api - store' }
ExtendedClipboardWinInterface >> storeText: aText id: otherString [
	"To be implemented (store both as string and as RTF)"
	"I presume the order is: most preferred format first, least desirable format last.
	Cuis object id is usually at the end, but don't include it if we include a streamed representation."
	self halt
]
