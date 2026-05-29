"
A wrapper object for the WebSocket API.
"
Class {
	#name : 'WebSocket07',
	#superclass : 'WebSocket',
	#instVars : [
		'frameType',
		'frameData',
		'closing',
		'masking'
	],
	#category : 'WebClient-Core',
	#package : 'WebClient',
	#tag : 'Core'
}

{ #category : 'control requests' }
WebSocket07 >> close [
	"Send a close control request"

	closing ifFalse:[
		closing := true.
		self send: #[] code: 8.
	].
]

{ #category : 'read/write' }
WebSocket07 >> firstFragment: aStringOrBytes [
	"Writes the first fragment of data"

	aStringOrBytes isString 
		ifTrue:[^self send: aStringOrBytes asUtf8Bytes code: 1 final: false]
		ifFalse:[^self send: aStringOrBytes code: 2 final: false].
]

{ #category : 'control requests' }
WebSocket07 >> handleClose: payload [
	"Close is being sent by remote in process of shutting down connection"

	closing ifFalse:[^self close].

	"We're done. We've received the close and responded to it"
	stream close.


]

{ #category : 'control requests' }
WebSocket07 >> handleControl: payload type: opcode [
	"Handle a control opcode"

	opcode caseOf: {
		[8]	-> [self handleClose: payload].
		[9]	-> [self handlePing: payload].
		[10] -> [self handlePong: payload].
	} otherwise:[self error: 'Unknown control request: ', opcode].


]

{ #category : 'control requests' }
WebSocket07 >> handlePing: payload [

	self handle: 'ping' 
		arguments: (Array with: payload with: self)
		ifAbsent:[self pong: payload].

]

{ #category : 'control requests' }
WebSocket07 >> handlePong: payload [

	self handle: 'pong' arguments: (Array with: payload with: self).
]

{ #category : 'initialize' }
WebSocket07 >> initialize [

	super initialize.
	closing := false.
	masking := true. " 	http://tools.ietf.org/html/draft-ietf-hybi-thewebsocketprotocol-07#section-4.1 says:
   ''Frames sent from the client to the server are masked to
   avoid confusing network intermediaries, such as intercepting proxies.''"
]

{ #category : 'read/write' }
WebSocket07 >> lastFragment: aStringOrBytes [
	"Writes the last fragment of data.
	Note: Spec says that code is ZERO for final fragment."

	aStringOrBytes isString 
		ifTrue:[^self send: aStringOrBytes asUtf8Bytes code: 0 final: true]
		ifFalse:[^self send: aStringOrBytes code: 0 final: true].
]

{ #category : 'accessing' }
WebSocket07 >> masking [
	"If true, outgoing frames are masked."

	^masking
]

{ #category : 'accessing' }
WebSocket07 >> masking: aBool [
	"If true, outgoing frames are masked."

	masking := aBool
]

{ #category : 'read/write' }
WebSocket07 >> nextFragment: aStringOrBytes [
	"Writes the first fragment of data
	Note: Spec says that code is ZERO for intermediate fragments."

	aStringOrBytes isString 
		ifTrue:[^self send: aStringOrBytes asUtf8Bytes code: 0 final: false]
		ifFalse:[^self send: aStringOrBytes code: 0 final: false].
]

{ #category : 'private' }
WebSocket07 >> nextNumber: n from: aStream [
	"Answer the next n bytes as a positive Integer or LargePositiveInteger."
	| s |
	s := 0.
	1 to: n do: 	[ :i | | b |
		b := aStream next.
		b isCharacter ifTrue: [ b := b codePoint ].
		s := (s bitShift: 8) bitOr: b ].
	^ s normalize
]

{ #category : 'control requests' }
WebSocket07 >> onPing: aBlock [
	"Set the handler block to invoke when a ping is received"

	handlers at: 'ping' put: aBlock.
]

{ #category : 'control requests' }
WebSocket07 >> onPong: aBlock [
	"Set the handler block to invoke when a pong is received"

	handlers at: 'pong' put: aBlock.
]

{ #category : 'control requests' }
WebSocket07 >> ping: data [
	"Send a ping control request"

	self send: data code: 9.
]

{ #category : 'control requests' }
WebSocket07 >> pong: data [
	"Send a pong control request"

	self send: data code: 10.
]

{ #category : 'read/write' }
WebSocket07 >> readFrame [
	"Reads one frame worth of data"

	^self readFrameFrom: stream
]

{ #category : 'read/write' }
WebSocket07 >> readFrameFrom: aStream [
	"Reads one frame worth of data"

	| byte length final mask opcode payload |
	byte := aStream next ifNil: [^nil].
	byte isCharacter ifTrue: [ byte := byte codePoint ].

	final := byte anyMask: 128.
	opcode := byte bitAnd: 15.

	byte := aStream next ifNil: [^nil].
	byte isCharacter ifTrue: [ byte := byte codePoint ].
	mask := byte anyMask: 128.
	length := byte bitAnd: 127.

	length = 126 ifTrue:[
		length := self nextNumber: 2 from: aStream.
	] ifFalse:[
		length = 127 ifTrue:[length := self nextNumber: 8 from: aStream].
	].

	mask 
		ifTrue:[mask := aStream next: 4] 
		ifFalse:[mask := nil].

	payload := ByteArray new: length.
	aStream next: length into: payload.

	"Unmask payload"
	mask ifNotNil:[self xor: payload with: mask asByteArray].

	"First see if this is a control frame which can be inserted into fragmented messages."
	opcode >= 8 ifTrue:[^self handleControl: payload type: opcode].

	"Now see if this is a fragmented message"
	frameType ifNil:[
		frameType := opcode.
		frameData := Array with: payload.
	] ifNotNil:[
		frameData := frameData copyWith: payload.
	].

	final ifTrue:[
		"This was the final fragment"
		frameData size = 1 ifTrue:[
			payload := frameData first
		] ifFalse:[
			payload := frameData allButFirst 
							inject: frameData first 
							into:[:each :next| each, next].
		].
		frameType = 1 ifTrue:[payload := String fromUtf8Bytes: payload asByteArray].
		self handleMessage: payload type: frameType.
		frameType := frameData := nil.
	].

]

{ #category : 'running' }
WebSocket07 >> run [
	"Run the WebSocket's input process."

	[[[stream isConnected] whileTrue:[
		self readFrame.
	]] on: Error do:[:ex| self handleError: ex]] ensure:[
		[stream socket destroy] on: Error do:[:ex|].
		self handleClose.
	].

]

{ #category : 'read/write' }
WebSocket07 >> send: aStringOrBytes [
	"Writes one frame worth of data"

	aStringOrBytes isString 
		ifTrue:[^self send: aStringOrBytes asString asUtf8Bytes code: 1]
		ifFalse:[^self send: aStringOrBytes code: 2].
]

{ #category : 'read/write' }
WebSocket07 >> send: data code: opcode [
	"Sends unfragmented data using the given opcode"

	^self send: data code: opcode final: true
]

{ #category : 'read/write' }
WebSocket07 >> send: data code: opcode final: isFinal [
	"Sends unfragmented data using the given opcode"

	^self send: data code: opcode final: isFinal mask: self masking
]

{ #category : 'read/write' }
WebSocket07 >> send: data code: opcode final: isFinal mask: doMask [
	"Sends unfragmented data using the given opcode"

	| byte1 byte2 mask xLength copy |
	byte1 := opcode. "FIN = 1, RSV1=RSV2=RSV3=0"
	isFinal ifTrue:[byte1 := byte1 bitOr: 128].
	data size > 125 ifTrue:[
		data size > 16rFFFF ifTrue:[
			byte2 := 127.
			xLength := ByteArray new: 8.
			(WriteStream on: xLength)
				nextUint32Put: data size >> 32 bigEndian: true;
				nextUint32Put: (data size bitAnd: 16rFFFFFFFF) bigEndian: true.
		] ifFalse:[
			byte2 := 126.
			xLength := ByteArray new: 2.
			(WriteStream on: xLength) nextUint16Put: data size bigEndian: true.
		].
	] ifFalse:[
		byte2 := data size.
		xLength := #[].
	].
	doMask ifTrue:[
		byte2 := byte2 bitOr: 128. "Mask = 1"
		mask := ByteArray new: 4.
		1 to: 4 do:[:i| mask at: i put: 256 atRandom-1].
		copy := data copy asByteArray.
		self xor: copy with: mask.
	] ifFalse:[
		copy := data.
	].
	stream nextPut: byte1.
	stream nextPut: byte2.
	stream nextPutAll: xLength.
	mask ifNotNil:[stream nextPutAll: mask].
	stream nextPutAll: copy.
	stream flush.
]

{ #category : 'read/write' }
WebSocket07 >> xor: data with: mask [
	"XOR all the data using the given mask bytes.

	WARNING: Does inplace reversal; do not call with literal data."

	"This would be much faster w/ BitBlt but data may not be 
	4-byte aligned and so BB will barf."
	1 to: data size do:[:i|
		data at: i put: ((data at: i) bitXor: (mask at: i-1 \\ 4 + 1)).
	].

]
