Class {
	#name : 'SecureSocket',
	#superclass : 'Socket',
	#instVars : [
		'ssl',
		'decoded',
		'readBuf',
		'sendBuf'
	],
	#category : 'WebClient-SqueakSSL-Core',
	#package : 'WebClient',
	#tag : 'SqueakSSL-Core'
}

{ #category : 'examples' }
SecureSocket class >> google: query [
	"An example HTTPS query to encrypted.google.com.
	Example:
		SecureSocket google: 'squeak'.
		SecureSocket google: 'SqueakSSL'.
	"

	| hostName address socket |

	"Change the host name to try an https request to some other host"
	hostName := 'encrypted.google.com'.

	address := NetNameResolver addressForName: hostName.
	socket := SecureSocket newTCP.

	"Connect the TCP socket"
	socket connectTo: address port: 443.
	socket waitForConnectionFor: 10.

	["Handle the client handshake"
	socket sslConnectTo: hostName.

	"Verify that the cert is valid"
	socket certState = 0 ifFalse:[
		self error: 'The certificate is invalid (code: ', socket certState,')'.
	].

	"If the certificate is valid, make sure we're were we wanted to go"
	(socket peerName match: hostName) ifFalse:[
		self error: 'Host name mismatch: ', socket peerName.
	].

	"Send encrypted data"
	socket sendData:
		'GET /search?q=', query,' HTTP/1.0', String crlfString,
		'Host: ', hostName, String crlfString,
		'Connection: close', String crlfString,
		String crlfString.

	"Wait for the response"
	^String streamContents:[:s|
		[[true] whileTrue:[s nextPutAll: socket receiveData]]
			on: ConnectionClosed, ConnectionTimedOut do:[:ex| ex return].
	]] ensure:[socket destroy].

]

{ #category : 'accessing' }
SecureSocket >> certState [
	^ssl ifNotNil:[ssl certState]
]

{ #category : 'primitives' }
SecureSocket >> decodeData [
	"Receive data from the given socket into the given array starting at the given index. Return the number of bytes read or zero if no data is available."
	| total bytesRead |
	decoded atEnd ifFalse:[^self].

	"Decrypt more data if available"
	bytesRead := 0.
	[total := ssl decrypt: readBuf from: 1 to: bytesRead into: decoded originalContents.
	total < 0 ifTrue:[^self error: 'SSL error, code: ', total].
	bytesRead := 0.
	total = 0 ifTrue:[
		bytesRead := super primSocket: socketHandle receiveDataInto: readBuf startingAt: 1 count: readBuf size.
	].
	bytesRead = 0] whileFalse.

	"Update for number of bytes decoded"
	decoded setFrom: 1 to: total.

]

{ #category : 'initialize' }
SecureSocket >> destroy [
	ssl ifNotNil:[
		ssl destroy.
		ssl := nil
	].
	super destroy.
]

{ #category : 'initialize' }
SecureSocket >> initialize [

	super initialize.
	decoded := ReadStream on: (ByteArray new: 20000) from: 1 to: 0.
	sendBuf := ByteArray new: 4096.
	readBuf := ByteArray new: 4096.

]

{ #category : 'primitives' }
SecureSocket >> isConnected [
	"Return true if this socket is connected."
	"We mustn't return false if there is data available"

	^super isConnected or:[self dataAvailable]
]

{ #category : 'accessing' }
SecureSocket >> peerName [
	^ssl ifNotNil:[ssl peerName]
]

{ #category : 'primitives' }
SecureSocket >> primSocket: socketID receiveDataInto: buffer startingAt: index count: count [
	"Receive data from the given socket into the given array starting at the given index. Return the number of bytes read or zero if no data is available."
	| total |

	ssl ifNil:[^super primSocket: socketID receiveDataInto: buffer startingAt: index count: count].

	self decodeData.

	"Push data from decoded into the result buffer"
	total := (decoded size - decoded position) min: (buffer size - index + 1).
	(decoded readInto: buffer startingAt: index count: total) = total 
		ifFalse:[self error: 'Unexpected read failure'].
	^total

]

{ #category : 'primitives' }
SecureSocket >> primSocket: socketID sendData: buffer startIndex: start count: amount [
	"Send data to the remote host through the given socket starting with the given byte index of the given byte array. The data sent is 'pushed' immediately. Return the number of bytes of data actually sent; any remaining data should be re-submitted for sending after the current send operation has completed."
	"Note: In general, it many take several sendData calls to transmit a large data array since the data is sent in send-buffer-sized chunks. The size of the send buffer is determined when the socket is created."

	| count |
	ssl ifNil:[^super primSocket: socketID sendData: buffer startIndex: start count: amount].

	count := ssl encrypt: buffer from: start to: start+amount-1 into: sendBuf.
	count < 0 ifTrue:[self error: 'SSL Error: ', count].
	^super primSocket: socketID sendData: sendBuf startIndex: 1 count: count
]

{ #category : 'primitives' }
SecureSocket >> primSocketReceiveDataAvailable: socketID [
	"Return true if data may be available for reading from the current socket."

	ssl ifNil:[^super primSocketReceiveDataAvailable: socketID].
	self decodeData.
	^decoded atEnd not
]

{ #category : 'accessing' }
SecureSocket >> ssl [
	"Answer the SqueakSSL instance"
	^ssl
]

{ #category : 'connect' }
SecureSocket >> sslAccept: certName [
	"Perform the SSL server handshake. This method uses all the common SocketStream methods to adhere to the various timeout/signalling settings of SocketStream. It only installs the SSL instance after the handshake is complete."

	| squeakSSL result inbuf |
	inbuf := ''.
	squeakSSL := SqueakSSL new.
	squeakSSL certName: certName.

	"Perform the server handshake"
	[[squeakSSL isConnected] whileFalse:[
		"Read input"
		inbuf := self receiveData.
		result := squeakSSL accept: inbuf from: 1 to: inbuf size into: sendBuf.

		"Check for errors first"
		result < -1 ifTrue:[^self error: 'SSL accept failed with code: ', result printString].

		"If a token has been produced in the handshake, send it to the remote"
		result > 0 ifTrue:[self sendData: (sendBuf copyFrom: 1 to: result)].
	].
	"We are connected. From here on, encryption will take place."
	ssl := squeakSSL.
	] ifCurtailed:[
		"Make sure we destroy the platform handle if the handshake gets interrupted"
		squeakSSL destroy.
	].

]

{ #category : 'connect' }
SecureSocket >> sslConnect [
	"Perform the SSL client handshake. This method uses all the common SocketStream methods to adhere to the various timeout/signalling settings of SocketStream. It only installs the SSL instance after the handshake is complete."

	self sslConnectTo: nil
]

{ #category : 'connect' }
SecureSocket >> sslConnectTo: serverName [
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
		result > 0 ifTrue:[self sendData: (sendBuf copyFrom: 1 to: result)].

		"Read more input and repeat"
		inbuf := self receiveData.
	].
	"We are connected. From here on, encryption will take place."
	ssl := squeakSSL.
	] ifCurtailed:[
		"Make sure we destroy the platform handle if the handshake gets interrupted"
		squeakSSL destroy.
	].

]
