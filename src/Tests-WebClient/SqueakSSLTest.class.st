Class {
	#name : 'SqueakSSLTest',
	#superclass : 'TestCase',
	#instVars : [
		'clientReadQueue',
		'serverWriteQueue',
		'serverReadQueue',
		'clientWriteQueue',
		'sslClient',
		'sslServer',
		'clientProcess',
		'serverProcess'
	],
	#classVars : [
		'CertName'
	],
	#category : 'Tests-WebClient',
	#package : 'Tests',
	#tag : 'WebClient'
}

{ #category : 'accessing' }
SqueakSSLTest class >> certName [
	"The name of the cert to use for the test"

	^CertName
]

{ #category : 'accessing' }
SqueakSSLTest class >> certName: aString [
	"The name of the cert to use for the test.
		SqueakSSLTest certName: nil.
		SqueakSSLTest certName: 'Internet Widgits Pty'.
		SqueakSSLTest certName: '/home/andreas/certs/testcert.pem'.
	"

	CertName := aString
]

{ #category : 'utilities' }
SqueakSSLTest class >> ensureValidCert [
	"Ensure that we have a valid certificate for the tests"

	CertName := SqueakSSL ensureSampleCert.

]

{ #category : 'setup' }
SqueakSSLTest >> certName [
	"Answer the name of the cert to use in tests"
	
	^self class certName
]

{ #category : 'setup' }
SqueakSSLTest >> expectedFailures [
	"If we don't have a cert all the tests fail"

	SqueakSSL platformName = 'Mac OS' ifTrue:[
		"The following tests all need certificate selection
		to work properly."
		^#(
			testConnectAccept 
			testEncryptDecrypt 
			testMultiFrameDecrypt 
			testSingleByteDecrypt
			testSplitTlsFrameRead
			testStreamAccept
			testStreamConnect
			testStreamTransfer
		)
	] ifFalse:[^#()].
]

{ #category : 'setup' }
SqueakSSLTest >> hasCertInfo [
	"Returns true if we have cert information available"

	^self class certName notNil
]

{ #category : 'setup' }
SqueakSSLTest >> port [
	^8844
]

{ #category : 'setup' }
SqueakSSLTest >> secureSocket [
	^SqueakSSL secureSocket
]

{ #category : 'setup' }
SqueakSSLTest >> secureSocketStream [
	^SqueakSSL secureSocketStream
]

{ #category : 'setup' }
SqueakSSLTest >> setUp [
	"The default setUp"

	self class ensureValidCert.

	clientReadQueue := serverWriteQueue := SharedQueue new.
	serverReadQueue := clientWriteQueue := SharedQueue new.
	
	sslClient := SqueakSSL new.
	sslClient readBlock:[:buffer| | inbuf |
		inbuf := clientReadQueue next.
		buffer replaceFrom: 1 to: inbuf size with: inbuf startingAt: 1.
		inbuf size.
	].
	sslClient writeBlock:[:buffer :count| 
		clientWriteQueue nextPut: (buffer copyFrom: 1 to: count)
	].

	sslServer := SqueakSSL new.
	sslServer certName: self certName.
	sslServer readBlock:[:buffer| | inbuf |
		inbuf := serverReadQueue next.
		buffer replaceFrom: 1 to: inbuf size with: inbuf startingAt: 1.
		inbuf size.
	].
	sslServer writeBlock:[:buffer :count| 
		serverWriteQueue nextPut: (buffer copyFrom: 1 to: count)
	].

]

{ #category : 'setup' }
SqueakSSLTest >> tearDown [
	"Shut down everything"

	clientProcess ifNotNil:[clientProcess terminate].
	serverProcess ifNotNil:[serverProcess].
	sslClient ifNotNil:[sslClient destroy].
	sslServer ifNotNil:[sslServer destroy].

]

{ #category : 'tests' }
SqueakSSLTest >> testConnectAccept [
	"Tests the SqueakSSL server and client handshake. "

	| buf process |
	process := Processor activeProcess.

	"Separate queues so we can watch the handshake"
	clientReadQueue := SharedQueue new.
	serverWriteQueue := SharedQueue new.
	serverReadQueue := SharedQueue new.
	clientWriteQueue := SharedQueue new.

	"Start the connect and accept loop"
	clientProcess := [
		[sslClient connect] 
			on: Error 
			do:[:ex| process signalException: ex]. "uncomment for debugging"
	] newProcess.
	clientProcess resumeAt: Processor activePriority + 1.
	serverProcess := [
		[sslServer accept]
			on: Error 
			do:[:ex| process signalException: ex]. "uncomment for debugging"
	] newProcess.
	serverProcess resumeAt: Processor activePriority + 1.

	"Do the handshake"
	buf := clientWriteQueue next.
	serverReadQueue nextPut: buf.
	buf := serverWriteQueue next.
	clientReadQueue nextPut: buf.

	buf := clientWriteQueue next.
	serverReadQueue nextPut: buf.
	buf := serverWriteQueue next.
	clientReadQueue nextPut: buf.

	"Both client and server should now be connected"
	self assert:(clientProcess isTerminated).
	self assert:(serverProcess isTerminated).

	self assert: sslClient isConnected.
	self assert: sslServer isConnected.

]

{ #category : 'tests' }
SqueakSSLTest >> testEncryptDecrypt [
	"Simple encrypt/decrypt test with a single frame of data.
	Ensures that the common case works properly."

	| encrypted decrypted |

	self testConnectAccept.

	encrypted := sslClient encrypt: 'Client to Server'.
	decrypted := sslServer decrypt: encrypted.

	self assert: decrypted = 'Client to Server'.

	encrypted := sslServer encrypt: 'Server to Client'.
	decrypted := sslClient decrypt: encrypted.

	self assert: decrypted = 'Server to Client'.

]

{ #category : 'tests' }
SqueakSSLTest >> testFaceBookAPI [
	"Facebook sends incomplete data during SSL handshake. 
	Useful for testing an edge condition in SqueakSSL."

	Smalltalk at: #WebClient ifPresent:[:webClient|
		self shouldnt:[
			[webClient httpGet: 'https://graph.facebook.com/oauth/access_token']
				"Allow certificate errors on the Mac since cert validation isn't
				implemented yet."
				on: SqueakSSLCertificateError do:[:ex|
					SqueakSSL platformName = 'Mac OS'
						ifTrue:[ex resume]
						ifFalse:[ex pass]].
		] raise: Error.
	]..

]

{ #category : 'tests' }
SqueakSSLTest >> testGooglePopStream [
	"This tests the dreaded data-in-last-handshake problem that some people
	have been seeing. Google mail (at times) sends the first data chunk together
	with the last handshake and the Windows SSL code did not handle that correctly"

	"self run: #testGooglePopStream"
	| hostName address socket response stream |
	hostName := 'pop.gmail.com'.
	address := NetNameResolver addressForName: hostName.
	socket := Socket newTCP.
	socket connectTo: address port: 995.
	socket waitForConnectionFor: 10.
	stream := self secureSocketStream on: socket.
	[
		stream sslConnect.
		response := stream upToAll: String crlfString.
		self assert: response notEmpty.
	] ensure:[stream destroy].

]

{ #category : 'tests' }
SqueakSSLTest >> testMultiFrameDecrypt [
	"A test verifying that even if we feed multiple encrypted frames at once
	we get them one-by-one out of the decryptor. Mainly a test to ensure
	consistent plugin behavior."

	| encrypted decrypted |

	"Also does setup"
	self testConnectAccept.

	"Encrypt the text"
	encrypted := #(
		'Hello World'
		'This is a test'
		'How do you do'
	) collect:[:each| sslClient encrypt: each].

	"Now feed the the encrypted contents at once to the decryptor"
	decrypted := sslServer decrypt: (encrypted inject:'' into:[:a :b| a, b]).

	"This should only decrypt the first frame"
	self assert: decrypted = 'Hello World'.

	"The second time (with no input) we should get the second piece."
	decrypted := sslServer decrypt: ''.
	self assert: decrypted = 'This is a test'.

	"The third time (with extra input) we should get the last piece from the first round."
	encrypted := sslClient encrypt: 'More data is coming'.
	decrypted := sslServer decrypt: encrypted.
	self assert: decrypted = 'How do you do'.

	"And finally the last piece"
	decrypted := sslServer decrypt: ''.
	self assert: decrypted = 'More data is coming'.

]

{ #category : 'tests' }
SqueakSSLTest >> testSSLSockets [
	"Connect client and server"
	| client listener server sema connectProcess |
	[listener := SecureSocket newTCP.
	listener listenOn: self port backlogSize: 4.
	client := SecureSocket newTCP.
	client connectTo: #[127 0 0 1] port: self port.
	server := listener waitForAcceptFor: 1.

	"Perform SSL handshake"
	sema := Semaphore new.
	[connectProcess := Processor activeProcess.
	 client sslConnect.
	 sema signal] fork.
	server sslAccept: self certName.
	sema wait.

	"Send data"
	client sendData: 'Hello World'.
	server waitForDataFor: 1.
	self assert: server receiveData = 'Hello World']
		ensure:
			[listener ifNotNil:[listener destroy].
			client ifNotNil:[client destroy].
			server ifNotNil:[server destroy].
			connectProcess ifNotNil: [connectProcess terminate]]
]

{ #category : 'tests' }
SqueakSSLTest >> testSingleByteDecrypt [
	"A test verifying that even if we feed the decryptor with single bytes it 
	produces the correct output. Mainly a test that the underlying plugin 
	deals with corner cases correctly."

	| encrypted decrypted |

	"Also does setup"
	self testConnectAccept.

	"Encrypt the text"
	encrypted := sslClient encrypt: 'Hello World'.

	"Now feed the encrypted contents byte-by-byte into the decryptor"
	1 to: encrypted size-1 do:[:i|
		decrypted := sslServer decrypt: (encrypted copyFrom: i to: i).
		self assert: decrypted isEmpty.
	].

	"And upon feeding the last byte we expect the result"
	decrypted := sslServer decrypt: (encrypted last: 1).
	self assert: decrypted = 'Hello World'.
]

{ #category : 'tests' }
SqueakSSLTest >> testSocketAccept [
	"Tests the SecureSocketStream server handshake. "

	| process listener clientSocket serverSocket |
	process := Processor activeProcess.

	[listener := self secureSocket newTCP.
	listener listenOn: self port backlogSize: 4.
	clientSocket := Socket newTCP.
	clientSocket connectTo: #[127 0 0 1] port: self port.
	clientSocket waitForConnectionFor: 1.
	serverSocket := listener waitForAcceptFor: 1.
	self assert: clientSocket isConnected.
	self assert: serverSocket notNil.
	self assert: serverSocket isConnected.

	"Set up the client for the handshake"
	sslClient on: clientSocket.
	clientProcess := [
		[sslClient connect]
			on: Error 
			do:[:ex| process signalException: ex].
	] newProcess.
	clientProcess resumeAt: Processor activePriority + 1.

	"Set up the server"
	serverSocket sslAccept: self certName.
	self assert: serverSocket isConnected.
	] ensure:[
		listener ifNotNil:[listener destroy].
		clientSocket ifNotNil:[clientSocket destroy].
		serverSocket ifNotNil:[serverSocket destroy].
	].
]

{ #category : 'tests' }
SqueakSSLTest >> testSocketConnect [
	"Tests the SecureSocket client handshake. "

	| process listener clientSocket serverSocket |
	process := Processor activeProcess.

	[listener := Socket newTCP.
	listener listenOn: self port backlogSize: 4.
	clientSocket := self secureSocket newTCP.
	clientSocket connectTo: #[127 0 0 1] port: self port.
	clientSocket waitForConnectionFor: 1.
	serverSocket := listener waitForAcceptFor: 1.
	self assert: clientSocket isConnected.
	self assert: serverSocket notNil.
	self assert: serverSocket isConnected.

	"Set up the server for the handshake"
	sslServer on: serverSocket.
	serverProcess := [
		[sslServer accept]
			on: Error 
			do:[:ex| process signalException: ex]. "uncomment for debugging"
	] newProcess.
	serverProcess resumeAt: Processor activePriority + 1.

	"Set up the client using SecureSocketStream"
	clientSocket sslConnect.
	clientSocket isConnected.
	] ensure:[
		listener ifNotNil:[listener destroy].
		clientSocket ifNotNil:[clientSocket destroy].
		serverSocket ifNotNil:[serverSocket destroy].
	].
]

{ #category : 'tests' }
SqueakSSLTest >> testSplitTlsFrameRead [
	"Tests the SecureSocketStream client handshake. "

	| process listener clientSocket serverSocket secureStream char |
	process := Processor activeProcess.

	[listener := Socket newTCP.
	listener listenOn: self port backlogSize: 4.
	clientSocket := Socket newTCP.
	clientSocket connectTo: #[127 0 0 1] port: self port.
	clientSocket waitForConnectionFor: 1.
	serverSocket := listener waitForAcceptFor: 1.
	self assert: clientSocket isConnected.
	self assert: serverSocket notNil.
	self assert: serverSocket isConnected.

	"Set up the server for the handshake"
	sslServer on: serverSocket.
	serverProcess := [ | encrypted |
		[sslServer accept.
		encrypted := sslServer encrypt: 'Hello World'.
		1 to: encrypted size do:[:i|
			sslServer writeData: (encrypted copyFrom: i to: i) count: 1.
			(Delay forMilliseconds: 10) wait.
		].
		] on: Error 
			do:[:ex| process signalException: ex]. "uncomment for debugging"
	] newProcess.
	serverProcess resumeAt: Processor activePriority + 1.

	"Set up the client using SecureSocketStream"
	secureStream := SecureSocketStream on: clientSocket.
	secureStream sslConnect.
	self assert: secureStream isConnected.
	char := secureStream next.
	self assert: char = $H.
	] ensure:[
		listener ifNotNil:[listener destroy].
		clientSocket ifNotNil:[clientSocket destroy].
		serverSocket ifNotNil:[serverSocket destroy].
		secureStream ifNotNil:[secureStream destroy].
	].
]

{ #category : 'tests' }
SqueakSSLTest >> testStreamAccept [
	"Tests the SecureSocketStream server handshake. "

	| process listener clientSocket serverSocket secureStream |
	process := Processor activeProcess.

	[listener := Socket newTCP.
	listener listenOn: self port backlogSize: 4.
	clientSocket := Socket newTCP.
	clientSocket connectTo: #[127 0 0 1] port: self port.
	clientSocket waitForConnectionFor: 1.
	serverSocket := listener waitForAcceptFor: 1.
	self assert: clientSocket isConnected.
	self assert: serverSocket notNil.
	self assert: serverSocket isConnected.

	"Set up the client for the handshake"
	sslClient on: clientSocket.
	clientProcess := [
		[sslClient connect]
			on: Error 
			do:[:ex| process signalException: ex].
	] newProcess.
	clientProcess resumeAt: Processor activePriority + 1.

	"Set up the client using SecureSocketStream"
	secureStream := SecureSocketStream on: serverSocket.
	secureStream sslAccept: self certName.
	self assert: secureStream isConnected.
	] ensure:[
		listener ifNotNil:[listener destroy].
		clientSocket ifNotNil:[clientSocket destroy].
		serverSocket ifNotNil:[serverSocket destroy].
		secureStream ifNotNil:[secureStream destroy].
	].
]

{ #category : 'tests' }
SqueakSSLTest >> testStreamConnect [
	"Tests the SecureSocketStream client handshake. "

	| process listener clientSocket serverSocket secureStream |
	process := Processor activeProcess.

	[listener := Socket newTCP.
	listener listenOn: self port backlogSize: 4.
	clientSocket := Socket newTCP.
	clientSocket connectTo: #[127 0 0 1] port: self port.
	clientSocket waitForConnectionFor: 1.
	serverSocket := listener waitForAcceptFor: 1.
	self assert: clientSocket isConnected.
	self assert: serverSocket notNil.
	self assert: serverSocket isConnected.

	"Set up the server for the handshake"
	sslServer on: serverSocket.
	serverProcess := [
		[sslServer accept]
			on: Error 
			do:[:ex| process signalException: ex]. "uncomment for debugging"
	] newProcess.
	serverProcess resumeAt: Processor activePriority + 1.

	"Set up the client using SecureSocketStream"
	secureStream := SecureSocketStream on: clientSocket.
	secureStream sslConnect.
	self assert: secureStream isConnected.
	] ensure:[
		listener ifNotNil:[listener destroy].
		clientSocket ifNotNil:[clientSocket destroy].
		serverSocket ifNotNil:[serverSocket destroy].
		secureStream ifNotNil:[secureStream destroy].
	].
]

{ #category : 'tests' }
SqueakSSLTest >> testStreamTransfer [
	"Tests the SecureSocketStream data transfer"

	| listener clientSocket serverSocket serverStream clientStream |
	[listener := Socket newTCP.
	listener listenOn: self port backlogSize: 4.
	clientSocket := Socket newTCP.
	clientSocket connectTo: #[127 0 0 1] port: self port.
	clientSocket waitForConnectionFor: 1.
	serverSocket := listener waitForAcceptFor: 1.
	self assert: clientSocket isConnected.
	self assert: serverSocket notNil.
	self assert: serverSocket isConnected.

	"Set up client and server streams"
	serverStream := self secureSocketStream on: serverSocket.
	serverProcess := [
		[serverStream sslAccept: self certName] 
			on: Error do:[:ex| serverStream destroy].
	] newProcess.
	serverProcess resumeAt: Processor activePriority + 1.

	clientStream := self secureSocketStream on: clientSocket.
	clientStream sslConnect.
	self assert: clientStream isConnected.
	self assert: serverStream isConnected.
	clientStream nextPutAll: 'Hello World'; flush.
	self assert: (serverStream next: 11) = 'Hello World'.
	serverStream nextPutAll: 'The other way'; flush.
	self assert: (clientStream next: 13) = 'The other way'.

	] ensure:[
		listener ifNotNil:[listener destroy].
		clientSocket ifNotNil:[clientSocket destroy].
		serverSocket ifNotNil:[serverSocket destroy].
		clientStream ifNotNil:[clientStream destroy].
		serverStream ifNotNil:[serverStream destroy].
	].
]

{ #category : 'tests' }
SqueakSSLTest >> testYahooOpenID [
	"Yahoo sends an SSL shutdown sequence which we didn't handle in the past.
	Also, there were some issues with SecureSocketStream that were unearthed
	by using it via WebClient's chunking method (not easy to reproduce without WC)."

	Smalltalk at: #WebClient ifPresent:[:webClient|
		self shouldnt:[
			[webClient httpGet: 'https://open.login.yahooapis.com/openid/op/auth']
				"Allow certificate errors on the Mac since cert validation isn't
				implemented yet."
				on: SqueakSSLCertificateError do:[:ex|
					SqueakSSL platformName = 'Mac OS'
						ifTrue:[ex resume]
						ifFalse:[ex pass]].
		] raise: Error.
	].
]
