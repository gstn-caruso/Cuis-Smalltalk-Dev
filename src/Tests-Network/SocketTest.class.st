Class {
	#name : 'SocketTest',
	#superclass : 'TestCase',
	#instVars : [
		'listenerSocket',
		'clientSocket',
		'serverSocket'
	],
	#category : 'Tests-Network-Kernel',
	#package : 'Tests',
	#tag : 'Network-Kernel'
}

{ #category : 'failures' }
SocketTest >> expectedFailures [

	^ Smalltalk platformName = 'Win32'
		ifTrue: [#(testSocketReuse testTCPSocketReuse)]
		ifFalse: [#()]
]

{ #category : 'fixtures' }
SocketTest >> listenerAddress [
	^NetNameResolver addressForName: 'localhost'

]

{ #category : 'fixtures' }
SocketTest >> listenerAddressForFamily: addressFamily [
	^NetNameResolver addressForName: 'localhost' family: addressFamily
]

{ #category : 'fixtures' }
SocketTest >> listenerPort [
	^42324

]

{ #category : 'running' }
SocketTest >> setUp [

	listenerSocket := Socket newTCP listenOn: self listenerPort backlogSize: 4 interface: self listenerAddress.

]

{ #category : 'running' }
SocketTest >> tearDown [

	listenerSocket ifNotNil:[listenerSocket destroy].
	clientSocket ifNotNil:[clientSocket destroy].
	serverSocket ifNotNil:[serverSocket destroy].

]

{ #category : 'tests' }
SocketTest >> testClientConnect [
	"Tests a client socket connection"

	clientSocket := Socket newTCP.
	clientSocket connectTo: (self listenerAddressForFamily: clientSocket addressFamily) port: self listenerPort.
	clientSocket waitForConnectionFor: 2.
	self assert: clientSocket isConnected
]

{ #category : 'tests' }
SocketTest >> testDataReceive [
	"Test data transfer and related methods"

	self testDataSending.
	"It can take a tad for the status change to be visible"
	(Delay forMilliseconds: 200) wait.
	self assert: serverSocket dataAvailable.
	self assert: (serverSocket receiveData = 'Hello World').
	self deny: (serverSocket dataAvailable).

]

{ #category : 'tests' }
SocketTest >> testDataSending [
	"Test data transfer and related methods"

	self testServerAccept.
	clientSocket sendData: 'Hello World'.
	clientSocket waitForSendDoneFor: 2.
	self assert: clientSocket sendDone.


]

{ #category : 'tests' }
SocketTest >> testLocalAddress [
	"Tests the various localAddress values for sockets"

	self testServerAccept.
	self assert: listenerSocket localAddress equals: (self listenerAddressForFamily: listenerSocket addressFamily).
	self assert: clientSocket localAddress equals: (self listenerAddressForFamily: clientSocket addressFamily).
	self assert: serverSocket localAddress equals: (self listenerAddressForFamily: serverSocket addressFamily)
]

{ #category : 'tests' }
SocketTest >> testLocalPort [
	"Tests the various localPort values for sockets"

	self testServerAccept.
	self assert: listenerSocket localPort = self listenerPort.
	self assert: clientSocket localPort > 0.
	self assert: serverSocket localPort > 0.

]

{ #category : 'tests' }
SocketTest >> testPeerName [
	"None of these should throw an exception."
	"This can actually take a while, depending on networks availability"
	<timeout: 30>

	Socket new peerName.
	self testServerAccept.
	listenerSocket peerName.
	clientSocket peerName.
	serverSocket peerName.
]

{ #category : 'tests' }
SocketTest >> testReceiveTimeout [
	"Test data transfer and related methods"

	self testServerAccept.
	self assert: (serverSocket receiveDataTimeout: 1) isEmpty.
]

{ #category : 'tests' }
SocketTest >> testRemoteAddress [
	"Tests the various remoteAddress values for sockets"

	self testServerAccept.
	self assert: listenerSocket remoteAddress asByteArray = #[0 0 0 0].
	self assert: clientSocket remoteAddress = self listenerAddress.
	self assert: serverSocket remoteAddress = self listenerAddress.

]

{ #category : 'tests' }
SocketTest >> testRemotePort [
	"Tests the various remoteAddress values for sockets"

	self testServerAccept.
	self assert: listenerSocket remotePort = 0.
	self assert: clientSocket remotePort = self listenerPort.
	self assert: serverSocket remotePort > 0.

]

{ #category : 'tests' }
SocketTest >> testSendTimeout [
	"Test data transfer and related methods"

	| buffer ex |
	self testServerAccept.
	buffer := ByteArray new: 1000.

	"Write to the socket until the platform reports that sending is not complete."
	[serverSocket sendDone] whileTrue:[
		serverSocket sendSomeData: buffer.
	].

	"The network layer is now either blocked or in the process of sending data in its buffers.
	It may or may not be able buffer additional write requests, depending on the platform
	implemention. Keep sending data until the network reports that it is unable to process
	the request, at which time a exception will be raised. On Windows, the exception will
	be raised on the next write request, while unix platforms may provide additional buffering
	that permit write requests to continue being accepted."
	ex := nil.
	[[serverSocket sendSomeData: buffer startIndex: 1 count: buffer size for: 1]
		on: ConnectionTimedOut
		do: [ :e | ex := e ].
	ex isNil] whileTrue: [].
	self assert: ex notNil.

]

{ #category : 'tests' }
SocketTest >> testServerAccept [
	"Tests a server-side accept"

	self testClientConnect.
	serverSocket := listenerSocket waitForAcceptFor: 2.
	self assert: (serverSocket notNil).
	self assert: (serverSocket isConnected).

]

{ #category : 'tests' }
SocketTest >> testSocketReuse [
	"Test for SO_REUSEADDR/SO_REUSEPORT. Should probably be called testUDPSocketReuse.
	 c.f. testTCPSocketReuse"

	| udp1 udp2 sendProc recvProc  |
	[
		| address port opt send1 recv2 received sent |
		address := #[255 255 255 255]. "broadcast"
		port := 31259.
		udp1 := Socket newUDP.
		udp1 setOption: 'SO_REUSEADDR' value: 1.
		self assert: 0 equals: udp1 socketError description: 'Error occured while setting SO_REUSEADDR'.
		opt := udp1 getOption: 'SO_REUSEADDR'.
		self assert: opt first isZero & opt last isZero not description: 'SO_REUSEADDR couldn''t be set'.
		udp1 setOption: 'SO_REUSEPORT' value: 1.
		self assert: 0 equals: udp1 socketError description: 'Error occured while setting SO_REUSEPORT'.
		opt := udp1 getOption: 'SO_REUSEPORT'.
		self assert: opt first isZero & opt last isZero not description: 'SO_REUSEPORT couldn''t be set'.
		udp1 setPort: port.
		self assert: port equals: udp1 localPort.
		udp1 setOption: 'SO_BROADCAST' value: 1.
		send1 := UUID new.

		udp2 := Socket newUDP.
		udp2 setOption: 'SO_REUSEADDR' value: 1.
		self assert: 0 equals: udp2 socketError.
		udp2 setOption: 'SO_REUSEPORT' value: 1.
		self assert: 0 equals: udp2 socketError.
		udp2 setPort: port.
		self assert: port equals: udp2 localPort.
		udp2 setOption: 'SO_BROADCAST' value: 1.
		recv2 := UUID new.

		received := 0.
		recvProc := [
			[received < 16] whileTrue:[
				received := received + (udp2 receiveDataInto: recv2 startingAt: received + 1)
				"No need to yield here, because #receiveDataInto:startingAt: will either wait on the readSemaphore of the socket or signal an error." ]
			] newProcess.
		sendProc := [
			udp1 setPeer: address port: port.
			sent := (udp1 sendSomeData: send1 startIndex: 1 count: 16 for: 1).
		] newProcess.
		recvProc resume.
		sendProc resume.
		(Delay forMilliseconds: 200) wait.
		self 
			assert: sendProc isTerminated description: 'sendProc hasn''t terminated till the deadline';
			assert: recvProc isTerminated description: 'recvProc hasn''t terminated till the deadline';
			assert: 16 equals: sent description: ('{1} bytes were sent instead of 16' format: { sent });
			assert: send1 equals: recv2  description: 'sent and received bytes differ'
	] ensure:[ 
		udp1 ifNotNil: [ udp1 destroy ].
		udp2 ifNotNil: [ udp2 destroy ].
		sendProc ifNotNil: [ sendProc terminate ].
		recvProc ifNotNil: [ recvProc terminate ]
	].

]

{ #category : 'tests' }
SocketTest >> testStringFromAddress [
	"Addresses are represented by a ByteArray if NetNameResolver useOldNetwork
	is true, or by by SocketAddress otherwise. Ensure the #stringFromAddress: works
	in either case. Older versions of SocketPlugin in the VM do not provide support
	for SocketAddress, and ByteArray addresses are used in that case."

	| localAddress localAddressBytes localName1 localName2 |
	localAddress := NetNameResolver localHostAddress. "ByteArray or SocketAddress"
	localAddressBytes := localAddress asByteArray.
	localName1 := NetNameResolver stringFromAddress: localAddress.
	localName2 := NetNameResolver stringFromAddress: localAddressBytes.
	self assert: localName1 = localName2

]

{ #category : 'tests' }
SocketTest >> testTCPSocketReuse [
	"Test for SO_REUSEADDR/SO_REUSEPORT using TCP sockets.  c.f. testSocketReuse"

	| tcpSend tcpRecv sendProcess recvProcess  |
	[
		|  address port opt send1 recv2 sent |
		address := NetNameResolver addressForName: '127.0.0.1' timeout: 20.
		port := 31259.
		tcpSend := Socket newTCP.
		tcpSend setOption: 'SO_REUSEADDR' value: 1.
		self assert: 0 equals: tcpSend socketError description: 'Error occured while setting SO_REUSEADDR'.
		opt := tcpSend getOption: 'SO_REUSEADDR'.
		self assert: opt first isZero & opt last isZero not description: 'SO_REUSEADDR couldn''t be set'.
		tcpSend setOption: 'SO_REUSEPORT' value: 1.
		self assert: 0 equals: tcpSend socketError description: 'Error occured while setting SO_REUSEPORT'.
		opt := tcpSend getOption: 'SO_REUSEPORT'.
		self assert: opt first isZero & opt last isZero not description: 'SO_REUSEPORT couldn''t be set'.
		"tcpSend setOption: 'TCP_NODELAY' value: 1."
		send1 := UUID new.

		tcpRecv := Socket newTCP.
		tcpRecv setOption: 'SO_REUSEADDR' value: 1.
		self assert: 0 equals: tcpRecv socketError.
		tcpRecv setOption: 'SO_REUSEPORT' value: 1.
		self assert: 0 equals: tcpRecv socketError.
		tcpRecv setPort: port.
		self assert: port equals: tcpRecv localPort.
		recv2 := UUID new.

		[| received |
		 recvProcess := Processor activeProcess.
		 received := 0.
		 tcpRecv waitForConnectionFor: 200.
		 [received < 16] whileTrue:
			["No need to yield here, because #receiveDataInto:startingAt: will either wait on the readSemaphore of the socket or signal an error." 
			 received := received + (tcpRecv receiveDataInto: recv2 startingAt: received + 1)]] fork.
		[sendProcess := Processor activeProcess.
		 tcpSend connectTo: address port: port.
		 sent := tcpSend sendData: send1] fork.
		(Delay forMilliseconds: 200) wait.
		self 
			assert: sendProcess isTerminated description: 'sendProc hasn''t terminated till the deadline';
			assert: recvProcess isTerminated description: 'recvProc hasn''t terminated till the deadline';
			assert: 16 equals: sent description: ('{1} bytes were sent instead of 16' format: { sent });
			assert: send1 equals: recv2  description: 'sent and received bytes differ']
	ensure:
		[tcpSend ifNotNil: [ tcpSend destroy ].
		tcpRecv ifNotNil: [ tcpRecv destroy ].
		sendProcess ifNotNil: [ sendProcess terminate ].
		recvProcess ifNotNil: [ recvProcess terminate ]]
]

{ #category : 'tests' }
SocketTest >> testUDP [
	"Test udp recv() and send() functionality"

	serverSocket := Socket newUDP.
	serverSocket setPort: 54321.

	clientSocket := Socket newUDP.
	clientSocket setPeer: NetNameResolver localHostAddress port: serverSocket port.
	clientSocket sendData: 'Hello World'.

	(Delay forMilliseconds: 200) wait.

	self assert: (serverSocket dataAvailable).
	self assert: (serverSocket receiveData = 'Hello World').

]
