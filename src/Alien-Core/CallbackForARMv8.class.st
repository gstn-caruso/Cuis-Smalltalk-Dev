Class {
	#name : 'CallbackForARMv8',
	#superclass : 'Callback',
	#category : 'Alien-Core',
	#package : 'Alien',
	#tag : 'Core'
}

{ #category : 'accessing' }
CallbackForARMv8 class >> abi [
	^'ARMv8'
]

{ #category : 'class initialization' }
CallbackForARMv8 class >> isForCurrentPlatform [
	^#('aarch64' 'arm64') includes: (Smalltalk getSystemAttribute: 1003)
]

{ #category : 'signatures' }
CallbackForARMv8 >> intcharstarRetint: callbackContext regs: regsAlien [
	<signature: #(int (*)(int, char *))>
	^callbackContext wordResult:
		(block
			value: (regsAlien signedLongLongAt: 1)
			value: (Alien forPointer: (regsAlien unsignedLongLongAt: 9)))
]

{ #category : 'signatures' }
CallbackForARMv8 >> voidstarvoidstarRetint: callbackContext regs: regsAlien [
	<signature: #(int (*)(const void *, const void *))>
	^callbackContext wordResult:
		(block
			value: (Alien forPointer: (regsAlien unsignedLongLongAt: 1))
			value: (Alien forPointer: (regsAlien unsignedLongLongAt: 9)))
]
