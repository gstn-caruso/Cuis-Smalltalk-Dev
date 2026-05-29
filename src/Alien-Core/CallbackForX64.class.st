"
A CallbackForX64 is a callback for platforms with x64/x86_64 processors using the System V ABI.
"
Class {
	#name : 'CallbackForX64',
	#superclass : 'Callback',
	#category : 'Alien-Core',
	#package : 'Alien',
	#tag : 'Core'
}

{ #category : 'accessing' }
CallbackForX64 class >> abi [
	^'X64'
]

{ #category : 'class initialization' }
CallbackForX64 class >> isForCurrentPlatform [
	| processor |
	CallbackForWin64X64 isForCurrentPlatform ifTrue:
		[^false].
	processor := (Smalltalk getSystemAttribute: 1003) asLowercase.
	^processor first = $x and: [processor = 'x64' or: [('x86#64*' match: processor)]]
]

{ #category : 'signatures' }
CallbackForX64 >> intcharstarRetint: callbackContext regs: regsAlien [
	<signature: #(int (*)(int, char *))>
	^callbackContext wordResult:
		(block
			value: (regsAlien signedLongLongAt: 1)
			value: (Alien forPointer: (regsAlien unsignedLongLongAt: 9)))
]

{ #category : 'signatures' }
CallbackForX64 >> voidstarvoidstarRetint: callbackContext regs: regsAlien [
	<signature: #(int (*)(const void *, const void *))>
	^callbackContext wordResult:
		(block
			value: (Alien forPointer: (regsAlien unsignedLongLongAt: 1))
			value: (Alien forPointer: (regsAlien unsignedLongLongAt: 9)))
]
