Class {
	#name : 'CallbackForRiscV64',
	#superclass : 'Callback',
	#category : 'Alien-Core',
	#package : 'Alien',
	#tag : 'Core'
}

{ #category : 'accessing' }
CallbackForRiscV64 class >> abi [
	^'RiscV64'
]

{ #category : 'class initialization' }
CallbackForRiscV64 class >> isForCurrentPlatform [
	^#('riscv64' 'RiscV64') includes: (Smalltalk getSystemAttribute: 1003)
]

{ #category : 'signatures' }
CallbackForRiscV64 >> intcharstarRetint: callbackContext regs: regsAlien [
	<signature: #(int (*)(int, char *))>
	^callbackContext wordResult:
		(block
			value: (regsAlien signedLongLongAt: 1)
			value: (Alien forPointer: (regsAlien unsignedLongLongAt: 9)))
]

{ #category : 'signatures' }
CallbackForRiscV64 >> voidstarvoidstarRetint: callbackContext regs: regsAlien [
	<signature: #(int (*)(const void *, const void *))>
	^callbackContext wordResult:
		(block
			value: (Alien forPointer: (regsAlien unsignedLongLongAt: 1))
			value: (Alien forPointer: (regsAlien unsignedLongLongAt: 9)))
]
