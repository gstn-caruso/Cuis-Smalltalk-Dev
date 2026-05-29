Class {
	#name : 'Win32Bitmap',
	#superclass : 'ExternalStructure',
	#category : 'ExtendedClipboard-Win32',
	#package : 'ExtendedClipboard',
	#tag : 'Win32'
}

{ #category : 'instance creation' }
Win32Bitmap class >> fields [
	"Win32TagBitmap defineFields"


	^ #(
		#(#bmType 'long')
		#(#bmWidth 'long')
		#(#bmHeight 'long')
		#(#bmWidthBytes 'long')
		#(#bmPlanes 'short')
		#(#bmBitsPixel 'short')
		#(#bmBits 'byte*')
	)

"typedef struct tagBITMAP {
  LONG   bmType; 
  LONG   bmWidth; 
  LONG   bmHeight; 
  LONG   bmWidthBytes; 
  WORD   bmPlanes; 
  WORD   bmBitsPixel; 
  LPVOID bmBits; 
} BITMAP"

]

{ #category : 'accessing' }
Win32Bitmap >> bmBits [
	"This method was automatically generated"
	^ExternalData fromHandle: (handle pointerAt: 21) type: ExternalType byte asPointerType
]

{ #category : 'accessing' }
Win32Bitmap >> bmBits: anObject [
	"This method was automatically generated"
	handle pointerAt: 21 put: anObject getHandle.
]

{ #category : 'accessing' }
Win32Bitmap >> bmBitsPixel [
	"This method was automatically generated"
	^handle signedShortAt: 19
]

{ #category : 'accessing' }
Win32Bitmap >> bmBitsPixel: anObject [
	"This method was automatically generated"
	handle signedShortAt: 19 put: anObject
]

{ #category : 'accessing' }
Win32Bitmap >> bmHeight [
	"This method was automatically generated"
	^handle signedLongAt: 9
]

{ #category : 'accessing' }
Win32Bitmap >> bmHeight: anObject [
	"This method was automatically generated"
	handle signedLongAt: 9 put: anObject
]

{ #category : 'accessing' }
Win32Bitmap >> bmPlanes [
	"This method was automatically generated"
	^handle signedShortAt: 17
]

{ #category : 'accessing' }
Win32Bitmap >> bmPlanes: anObject [
	"This method was automatically generated"
	handle signedShortAt: 17 put: anObject
]

{ #category : 'accessing' }
Win32Bitmap >> bmType [
	"This method was automatically generated"
	^handle signedLongAt: 1
]

{ #category : 'accessing' }
Win32Bitmap >> bmType: anObject [
	"This method was automatically generated"
	handle signedLongAt: 1 put: anObject
]

{ #category : 'accessing' }
Win32Bitmap >> bmWidth [
	"This method was automatically generated"
	^handle signedLongAt: 5
]

{ #category : 'accessing' }
Win32Bitmap >> bmWidth: anObject [
	"This method was automatically generated"
	handle signedLongAt: 5 put: anObject
]

{ #category : 'accessing' }
Win32Bitmap >> bmWidthBytes [
	"This method was automatically generated"
	^handle signedLongAt: 13
]

{ #category : 'accessing' }
Win32Bitmap >> bmWidthBytes: anObject [
	"This method was automatically generated"
	handle signedLongAt: 13 put: anObject
]
