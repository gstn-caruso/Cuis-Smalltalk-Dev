"
A CallbackForARM32 is a callback for platforms with ARMv4/v5/v6/v7 processors using the System V ABI.
"
Class {
	#name : 'CallbackForARM32',
	#superclass : 'Callback',
	#category : 'Alien-Core',
	#package : 'Alien',
	#tag : 'Core'
}

{ #category : 'accessing' }
CallbackForARM32 class >> abi [
	^'ARM32'
]

{ #category : 'class initialization' }
CallbackForARM32 class >> isForCurrentPlatform [
	| processor |
	processor := (Smalltalk getSystemAttribute: 1003) asLowercase.
	^processor = 'arm' or: [(processor beginsWith: 'armv') and: [processor fifth <= $7]]
]

{ #category : 'signatures' }
CallbackForARM32 >> hwndlparamRetbool: callbackContext regs: regsAlien [
	<signature: #(BOOL CALLBACK (*)(HWND, LPARAM))>
	^callbackContext wordResult:
		(block
			value: (Alien forPointer: (regsAlien unsignedLongAt: 1))
			value: (regsAlien unsignedLongAt: 5)) asAlien "i.e. coerce true to 1 and false to 0"
]

{ #category : 'signatures' }
CallbackForARM32 >> intcharstarRetint: callbackContext regs: regsAlien [
	<signature: #(int (*)(int, char *))>
	^callbackContext wordResult:
		(block
			value: (regsAlien signedLongAt: 1)
			value: (Alien forPointer: (regsAlien unsignedLongAt: 5)))
]

{ #category : 'signatures' }
CallbackForARM32 >> logfontstartextmetricstardwordlparamRetint: callbackContext regs: regsAlien [
	<signature: #(int CALLBACK (*)(const LOGFONT *, const TEXTMETRIC *, DWORD, LPARAM))>
	^callbackContext wordResult:
		(block
			value: (Alien forPointer: (regsAlien unsignedLongAt: 1))
			value: (Alien forPointer: (regsAlien unsignedLongAt: 5))
			value: (regsAlien unsignedLongAt: 9)
			value: (regsAlien signedLongAt: 13))
]

{ #category : 'signatures' }
CallbackForARM32 >> voidstarvoidstarRetint: callbackContext regs: regsAlien [
	<signature: #(int (*)(const void *, const void *))>
	^callbackContext wordResult:
		(block
			value: (Alien forPointer: (regsAlien unsignedLongAt: 1))
			value: (Alien forPointer: (regsAlien unsignedLongAt: 5)))
]
