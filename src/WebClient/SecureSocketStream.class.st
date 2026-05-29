"
A variant on SocketStream supporting SSL/TLS encryption via SqueakSSL.

"
Class {
	#name : 'SecureSocketStream',
	#superclass : 'SocketStream',
	#instVars : [
		'ssl',
		'sendBuf',
		'readBuf',
		'decoded',
		'certIssues'
	],
	#category : 'WebClient-SqueakSSL-Core',
	#package : 'WebClient',
	#tag : 'SqueakSSL-Core'
}

{ #category : 'accessing' }
SecureSocketStream >> ascii [
	"Switch to ASCII"

	super ascii.
	decoded := (ReadStream 
		on: decoded originalContents asString 
		from: 1 to: decoded size)
			position: decoded position;
			yourself.

]

{ #category : 'private-compat' }
SecureSocketStream >> atEnd [
	"Pre Squeak 4.2 compatibility"

	self receiveAvailableData.
	^super atEnd
]

{ #category : 'accessing' }
SecureSocketStream >> binary [
	"Switch to binary"

	super binary.
	decoded := (ReadStream 
		on: decoded originalContents asByteArray 
		from: 1 to: decoded size)
			position: decoded position;
			yourself.

]

{ #category : 'errors' }
SecureSocketStream >> certError: errorString code: reason [
	"Signal an issue with a certificate. If the reason code matches the acceptable cert issues, continue, otherwise signal an error."

	(certIssues allMask: reason) ifTrue:[^self].
	^SqueakSSLCertificateError signal: errorString, '(code: ', reason, ')'.

]

{ #category : 'accessing' }
SecureSocketStream >> certState [
	"Returns the certificate verification bits. The returned value indicates
	whether the certificate is valid. The two standard values are:

		0 - The certificate is valid.
		-1 - No certificate has been provided by the peer.

	Otherwise, the result is a bit mask of the following values:

		1 - If set, there is an unspecified issue with the cert (generic error)
		2 - If set, the root CA is untrusted (usually a self-signed cert)
		4 - If set, the certificate is expired.
		8 - If set, the certificate is used for the wrong purpose
		16 - If set, the CN of the certificate is invalid.
		32 - If set, the certificate was revoked.

	"

	^ssl ifNotNil:[ssl certState]
]

{ #category : 'initialize' }
SecureSocketStream >> close [
	"Flush any data still not sent and take care of the socket."

	super close.
	ssl ifNotNil:[
		ssl destroy.
		ssl := nil.
	].
]

{ #category : 'initialize' }
SecureSocketStream >> destroy [
	"Destroy the receiver and its underlying socket. Does not attempt to flush the output buffers. For a graceful close use SocketStream>>close instead."

	"Pre-4.2 compatibility. Should be 'super destroy' instead of 'socket destroy'"
	socket ifNotNil:[
		socket destroy.
		socket := nil.
	].

	ssl ifNotNil:[
		ssl destroy.
		ssl := nil.
	].
]

{ #category : 'private-compat' }
SecureSocketStream >> flush [
	"Pre-Squeak 4.2 compatibility"

	((outNextToWrite > 1) and: [socket isOtherEndClosed not])
		ifTrue: [
			[self sendData: outBuffer count: outNextToWrite - 1]
				on: ConnectionTimedOut
				do: [:ex | shouldSignal ifFalse: ["swallow"]].
			outNextToWrite := 1]

]

{ #category : 'accessing' }
SecureSocketStream >> ignoredCertIssues [
	"Answer the mask of 'acceptable issues' with certs. To completely ignore all cert issues use -1 which still ensures privacy (encryption) to the remote host, but does not guard against a man-in-the-middle attack (i.e., you cannot be sure that the remote host is what he says he is). The reasons are a bit mask consisting of the following values:
		1 - If set, there is an unspecified issue with the cert (generic error)
		2 - If set, the root CA is untrusted (usually a self-signed cert)
		4 - If set, the certificate is expired.
		8 - If set, the certificate is used for the wrong purpose
		16 - If set, the CN of the certificate is invalid.
		32 - If set, the certificate was revoked.
	"

	^certIssues
]

{ #category : 'accessing' }
SecureSocketStream >> ignoredCertIssues: reasonsMask [
	"Set the mask of 'acceptable issues' with certs. To completely ignore all cert issues use -1 which still ensures privacy (encryption) to the remote host, but does not guard against a man-in-the-middle attack (i.e., you cannot be sure that the remote host is what he says he is). The reasons are a bit mask consisting of the following values:
		1 - If set, there is an unspecified issue with the cert (generic error)
		2 - If set, the root CA is untrusted (usually a self-signed cert)
		4 - If set, the certificate is expired.
		8 - If set, the certificate is used for the wrong purpose
		16 - If set, the CN of the certificate is invalid.
		32 - If set, the certificate was revoked.
	"

	certIssues := reasonsMask
]

{ #category : 'initialize' }
SecureSocketStream >> initialize [
	"Initialize the receiver"
	
	"I think 16k is the max for SSL frames so use a tad more"
	decoded := ReadStream on: (ByteArray new: 20000) from: 1 to: 0.

	super initialize.

	sendBuf := ByteArray new: 4096.
	readBuf := ByteArray new: 4096.
	certIssues := 0.

]

{ #category : 'private-compat' }
SecureSocketStream >> isDataAvailable [
	"Pre Squeak 4.2 compatibility"
 
	self isInBufferEmpty ifFalse: [^true].
	^self receiveAvailableData < inNextToWrite

]

{ #category : 'private-compat' }
SecureSocketStream >> nextPutAllFlush: aCollection [
	"Pre Squeak 4.2 compatibility"

	| toPut |
	toPut := binary ifTrue: [aCollection asByteArray] ifFalse: [aCollection asString].
	self flush. "first flush pending stuff, then directly send"
	socket isOtherEndClosed ifFalse: [
		[self sendData: toPut count: toPut size]
			on: ConnectionTimedOut
			do: [:ex | shouldSignal ifFalse: ["swallow"]]]

]

{ #category : 'accessing' }
SecureSocketStream >> peerName [
	"Returns the certificate name of the remote peer.
	The method only returns a name if the certificate has been verified."

	^ssl ifNotNil:[ssl peerName]
]

{ #category : 'private-compat' }
SecureSocketStream >> receiveAvailableData [
	"Pre Squeak 4.2 compatibility"
	
	recentlyRead := self receiveDataInto: inBuffer startingAt: inNextToWrite.
	^self adjustInBuffer: recentlyRead

]

{ #category : 'private-socket' }
SecureSocketStream >> receiveData [
	"This method drains the available decryption data before waiting for the socket"

	| pos |

	"Note: The loop here is necessary to catch cases where a TLS packet is
	split among TCP packets. In this case we would pull the first portion of
	the TLS packet here but receiveAvailableData would return nothing since
	the contents of the packet can't be decoded until the rest has come in."

	[pos := inNextToWrite.
	self receiveAvailableData.
	pos = inNextToWrite ifFalse:[^pos].

	"Pre-4.2 compatibility; should be 'super receiveData' instead."
	socket
		waitForDataFor: self timeout
		ifClosed: [self shouldSignal 
			ifTrue:[ConnectionClosed signal: 'Connection closed while waiting for data.']]
		ifTimedOut: [self shouldTimeout
			ifTrue:[ConnectionTimedOut signal: 'Data receive timed out.']].
	self isConnected] whileTrue.

	"Final attempt to read data if a non-signaling connection closes"
	^self receiveAvailableData.

]

{ #category : 'private-compat' }
SecureSocketStream >> receiveData: nBytes [
	"Pre Squeak 4.2 compatibility"

	self receiveAvailableData.
	^super receiveData: nBytes.
]

{ #category : 'private-compat' }
SecureSocketStream >> receiveDataIfAvailable [
	"Pre Squeak 4.2 compatibility"

	^self receiveAvailableData

]

{ #category : 'private-socket' }
SecureSocketStream >> receiveDataInto: buffer startingAt: index [
	"Read and decrypt the data from the underlying socket. "

	| count bytesRead |
	"While in handshake, use the superclass version"
	ssl ifNil:[
		"Pre-4.2 compatibility; should be 'super receiveDataInto: buffer startingAt: index'"
		^socket  receiveAvailableDataInto: buffer startingAt: index.
	].

	"Only decode more data if all the decoded contents has been drained"
	decoded atEnd ifTrue:[
		"Decrypt more data if available"
		bytesRead := 0.
		[count := ssl decrypt: readBuf from: 1 to: bytesRead into: decoded originalContents.
		count < 0 ifTrue:[^self error: 'SSL error, code: ', count].
		bytesRead := 0.
		count = 0 ifTrue:[
			bytesRead := socket receiveAvailableDataInto: readBuf startingAt: 1.
		].
		bytesRead = 0] whileFalse.
		"Update for number of bytes decoded"
		decoded setFrom: 1 to: count.
	].

	"Push data from decoded into the result buffer"
	count := (decoded size - decoded position) min: (buffer size - index + 1).
	(decoded next: count into: buffer startingAt: index) size < count
		ifTrue:[^self error: 'Unexpected read failure'].
	^count

]

{ #category : 'private-socket' }
SecureSocketStream >> sendData: buffer count: n [
	"Encrypts the data before sending it on the underlying socket.
	Breaks large chunks into 2k components to fit safely into ssl frame."

	| remain start amount count |
	"While in handshake, use the superclass version"
	ssl ifNil:[
		"Pre-4.2 compatibility; should be 'super sendData: buffer count: n' instead"
		^socket sendData: buffer count: n
	].

	"Break the input into reasonable chunks and send them"
	remain := n. start := 1.
	[remain > 0] whileTrue:[
		amount := remain min: 2048.
		count := ssl encrypt: buffer from: start to: start+amount-1 into: sendBuf.
		socket sendData: sendBuf count: count.
		remain := remain - amount.
		start := start + amount.
	].
]

{ #category : 'accessing' }
SecureSocketStream >> ssl [
	"The SqueakSSL instance"

	^ssl
]

{ #category : 'initialize' }
SecureSocketStream >> sslAccept: certName [
	"Perform the SSL server handshake. This method uses all the common SocketStream methods to adhere to the various timeout/signalling settings of SocketStream. It only installs the SSL instance after the handshake is complete."

	| squeakSSL result inbuf |
	inbuf := ''.
	squeakSSL := SqueakSSL new.
	squeakSSL certName: certName.

	"Perform the server handshake"
	[[squeakSSL isConnected] whileFalse:[
		"Read input"
		self receiveData.
		inbuf := self nextAvailable.
		result := squeakSSL accept: inbuf from: 1 to: inbuf size into: sendBuf.

		"Check for errors first"
		result < -1 ifTrue:[^self error: 'SSL accept failed with code: ', result printString].

		"If a token has been produced in the handshake, send it to the remote"
		result > 0 ifTrue:[
			self nextPutAll: (sendBuf copyFrom: 1 to: result).
			self flush.
		].
	].
	"There should be no pending data at this point, ensure it is so.
	XXXX: If you ever see this problem, please inform me."
	self isInBufferEmpty ifFalse:[self error: 'Unexpected input data'].
	"We are connected. From here on, encryption will take place."
	ssl := squeakSSL.
	] ifCurtailed:[
		"Make sure we destroy the platform handle if the handshake gets interrupted"
		squeakSSL destroy.
	].

]

{ #category : 'initialize' }
SecureSocketStream >> sslConnect [
	"Perform the SSL client handshake. This method uses all the common SocketStream methods to adhere to the various timeout/signalling settings of SocketStream. It only installs the SSL instance after the handshake is complete."

	self sslConnectTo: nil
]

{ #category : 'initialize' }
SecureSocketStream >> sslConnectTo: serverName [
	"Perform the SSL client handshake. This method uses all the common SocketStream methods to adhere to the various timeout/signalling settings of SocketStream. It only installs the SSL instance after the handshake is complete. If serverName is not nil, then try to use it for SNI."

	| inbuf squeakSSL result |
	inbuf := ''.
	squeakSSL := SqueakSSL new.
	serverName ifNotNil: [ squeakSSL serverName: serverName ].
	"Perform the SSL handshake"
	[[result := squeakSSL connect: inbuf from: 1 to: inbuf size into: sendBuf.
	result = 0] whileFalse:[
		"Check for errors first"
		result < -1 ifTrue:[^self error: 'SSL connect failed with code: ', result printString].

		"If a token has been produced in the handshake, send it to the remote"
		result > 0 ifTrue:[
			self nextPutAll: (sendBuf copyFrom: 1 to: result).
			self flush.
		].

		"Read more input and repeat"
		self receiveData.
		inbuf := self nextAvailable.
	].
	"There should be no pending data at this point, ensure it is so.
	XXXX: If you ever see this problem, please inform me."
	self isInBufferEmpty ifFalse:[self error: 'Unexpected input data'].
	"We are connected. From here on, encryption will take place."
	ssl := squeakSSL.
	] ifCurtailed:[
		"Make sure we destroy the platform handle if the handshake gets interrupted"
		squeakSSL destroy.
	].

]

{ #category : 'private-compat' }
SecureSocketStream >> upToAll: aStringOrByteArray [
	"Pre Squeak 4.2 compatibility"

	^self upToAll: aStringOrByteArray limit: 100000
]

{ #category : 'private-compat' }
SecureSocketStream >> upToAll: aStringOrByteArray limit: nBytes [
	"Pre Squeak 4.2 compatibility"

	| index sz result searchedSoFar target |
	"Deal with ascii vs. binary"
	self isBinary
		ifTrue:[target := aStringOrByteArray asByteArray]
		ifFalse:[target := aStringOrByteArray asString].

	sz := target size.
	"Look in the current inBuffer first"
	index := inBuffer indexOfSubCollection: target
						startingAt: lastRead - sz + 2.
	(index > 0 and: [(index + sz) <= inNextToWrite]) ifTrue: ["found it"
		result := self nextInBuffer: index - lastRead - 1.
		self skip: sz.
		^ result
	].

	[searchedSoFar :=  self inBufferSize.
	"Receive more data"
	self receiveData.
	recentlyRead > 0] whileTrue:[

		"Data begins at lastRead + 1, we add searchedSoFar as offset and 
		backs up sz - 1 so that we can catch any borderline hits."

		index := inBuffer indexOfSubCollection: target
						startingAt: (lastRead + searchedSoFar - sz + 2 max: 1).
		(index > 0 and: [(index + sz) <= inNextToWrite]) ifTrue: ["found it"
			result := self nextInBuffer: index - lastRead - 1.
			self skip: sz.
			^ result
		].
		"Check if we've exceeded the max. amount"
		(nBytes notNil and:[inNextToWrite - lastRead > nBytes]) 
			ifTrue:[^self nextAllInBuffer].
	].

	"not found and (non-signaling) connection was closed"
	^self nextAllInBuffer
]

{ #category : 'initialize' }
SecureSocketStream >> verifyCert: hostName [
	"Verifies the cert state and host name"

	| certFlags |
	certFlags := self certState.
	certFlags = -1 
		ifTrue:[^self certError: 'No certificate was provided' code: -1].
	certFlags = 0 
		ifFalse:[self certError: 'Invalid certificate' code: certFlags].
	(ssl peerName match: hostName) 
		ifFalse:[self certError: 'Host name mismatch' code: -1].
]
