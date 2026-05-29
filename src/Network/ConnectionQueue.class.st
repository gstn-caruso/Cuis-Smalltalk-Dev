"
A ConnectionQueue listens on a given port number and collects a queue of client connections. In order to handle state changes quickly, a ConnectionQueue has its own process that: (a) tries to keep a socket listening on the port whenever the queue isn't already full of connections and (b) prunes stale connections out of the queue to make room for fresh ones.

The portNumber can be initialized to a collection, in which case all ports will be probed to create a listening socket. Once successfull, the portNumber is set to the chosen port.
"
Class {
	#name : 'ConnectionQueue',
	#superclass : 'Object',
	#instVars : [
		'portNumber',
		'maxQueueLength',
		'connections',
		'accessSema',
		'socket',
		'process'
	],
	#category : 'Network-Kernel',
	#package : 'Network',
	#tag : 'Kernel'
}

{ #category : 'instance creation' }
ConnectionQueue class >> portNumber: anInteger queueLength: queueLength [

	^ self new initPortNumber: anInteger queueLength: queueLength

]

{ #category : 'public' }
ConnectionQueue >> connectionCount [
	"Return an estimate of the number of currently queued connections. This is only an estimate since a new connection could be made, or an existing one aborted, at any moment."

	self pruneStaleConnections.
	^accessSema critical: [connections size]
]

{ #category : 'private' }
ConnectionQueue >> createListeningSocketWithBacklog: aNumber [
	| addressInfo sock |
	self portNumbers do: [:trialportNumber | 
		addressInfo := SocketAddressInformation
			forHost: ''
			service: trialportNumber asString
			flags: SocketAddressInformation passiveFlag
			addressFamily: SocketAddressInformation addressFamilyINET4
			socketType: SocketAddressInformation socketTypeStream
			protocol: SocketAddressInformation protocolTCP.
		sock := [addressInfo first listenWithBacklog: aNumber] ifError: [nil].
		sock ifNotNil: [
			portNumber := trialportNumber.
			^ sock]].
	^ nil
]

{ #category : 'public' }
ConnectionQueue >> destroy [
	"Terminate the listener process and destroy all sockets in my possesion."

	process ifNotNil: [
		process terminate.
		process := nil].
	socket ifNotNil: [
		socket destroy.
		socket := nil].
	connections do: [:s | s destroy].
	connections := OrderedCollection new.

]

{ #category : 'public' }
ConnectionQueue >> getConnectionOrNil [
	"Return a connected socket, or nil if no connection has been established."

	^accessSema critical: [
		| result |
		connections isEmpty
			ifTrue: [result := nil]
			ifFalse: [
				result := connections removeFirst.
				((result isValid) and: [result isConnected]) ifFalse: [  "stale connection"
					result destroy.
					result := nil]].
		result]
]

{ #category : 'public' }
ConnectionQueue >> getConnectionOrNilLenient [
	"Return a connected socket, or nil if no connection has been established."

	^accessSema critical: [
		| result |
		connections isEmpty ifTrue: [
			result := nil
		] ifFalse: [
			result := connections removeFirst.
			(result isValid and: [result isConnected or: [result isOtherEndClosed]]) ifFalse: [
				"stale connection"
				result destroy.
				result := nil
			]
		].
		result
	].

]

{ #category : 'private' }
ConnectionQueue >> initPortNumber: anInteger queueLength: queueLength [
	"Private! Initialize the receiver to listen on the given port number. Up to queueLength connections will be queued."

	portNumber := anInteger.
	maxQueueLength := queueLength.
	connections := OrderedCollection new.
	accessSema := Semaphore forMutualExclusion.
	socket := nil.
	process := [self listenLoop] newProcess.
	process priority: Processor highIOPriority.
	process name: 'ConnectionQueue'.
	process resume.

]

{ #category : 'public' }
ConnectionQueue >> isValid [
	^process notNil
]

{ #category : 'private' }
ConnectionQueue >> listenLoop [
	"Private! This loop is run in a separate process. It will establish up to maxQueueLength connections on the given port."
	"Details: When out of sockets or queue is full, retry more frequently, since a socket may become available, space may open in the queue, or a previously queued connection may be aborted by the client, making it available for a fresh connection."
	"Note: If the machine is disconnected from the network while the server is running, the currently waiting socket will go from 'isWaitingForConnection' to 'unconnected', and attempts to create new sockets will fail. When this happens, delete the broken socket and keep trying to create a socket in case the network connection is re-established. Connecting and disconnecting was tested under PPP on Mac system 8.1. It is not if this will work on other platforms."


	| newConnection |
	"We'll accept four simultanous connections at the same time"
	NetNameResolver useOldNetwork
		ifFalse: [ socket := self createListeningSocketWithBacklog: 4 ]
		ifTrue: [
			socket := Socket newTCP.
			socket listenOn: portNumber backlogSize: 4 ].
	"If the listener is not valid then the we cannot use the
	BSD style accept() mechanism."
	socket isValid ifFalse: [^self oldStyleListenLoop].
	[
		socket isValid ifFalse: [
			"socket has stopped listening for some reason"
			socket destroy.
			(Delay forMilliseconds: 10) wait.
			^self listenLoop ].
		newConnection := socket 
			waitForAcceptFor: 10
			ifTimedOut: [ nil ].
		(newConnection notNil and: [newConnection isConnected]) ifTrue: [
			accessSema critical: [connections addLast: newConnection.].
			newConnection := nil.
			self changed].
		self pruneStaleConnections] repeat
]

{ #category : 'private' }
ConnectionQueue >> oldStyleListenLoop [
	"Private! This loop is run in a separate process. It will establish up to maxQueueLength connections on the given port."
	"Details: When out of sockets or queue is full, retry more frequently, since a socket may become available, space may open in the queue, or a previously queued connection may be aborted by the client, making it available for a fresh connection."
	"Note: If the machine is disconnected from the network while the server is running, the currently waiting socket will go from 'isWaitingForConnection' to 'unconnected', and attempts to create new sockets will fail. When this happens, delete the broken socket and keep trying to create a socket in case the network connection is re-established. Connecting and disconnecting was tested under PPP on Mac system 8.1. It is not if this will work on other platforms."

	[
		((socket == nil) and: [connections size < maxQueueLength]) ifTrue: [
			"try to create a new socket for listening"
			socket := Socket createIfFail: [nil]].

		socket == nil
			ifTrue: [(Delay forMilliseconds: 100) wait]
			ifFalse: [
				socket isUnconnected ifTrue: [socket listenOn: portNumber].
				socket 
					waitForConnectionFor: 10
					ifTimedOut: [
						socket isConnected
							ifTrue: [  "connection established"
								accessSema critical: [connections addLast: socket].
								socket := nil]
							ifFalse: [
								socket isWaitingForConnection
									ifFalse: [socket destroy. socket := nil]]]].  "broken socket; start over"
		self pruneStaleConnections] repeat

]

{ #category : 'public' }
ConnectionQueue >> portNumber [
	^ portNumber isCollection
		ifTrue: [portNumber first]
		ifFalse: [portNumber]
]

{ #category : 'public' }
ConnectionQueue >> portNumberOrNil [
	"Answer nil while actual port has not been established"
	^ portNumber isCollection
		ifFalse: [portNumber]
]

{ #category : 'public' }
ConnectionQueue >> portNumbers [
	^ portNumber isCollection
		ifTrue: [portNumber]
		ifFalse: [{portNumber}]
]

{ #category : 'private' }
ConnectionQueue >> pruneStaleConnections [
	"Private! The client may establish a connection and then disconnect while it is still in the connection queue. This method is called periodically to prune such sockets out of the connection queue and make room for fresh connections."

	accessSema critical: [
		| foundStaleConnection |
		foundStaleConnection := false.
		connections do: [:s |
			s isUnconnected ifTrue: [
				s destroy.
				foundStaleConnection := true]].
		foundStaleConnection ifTrue: [
			connections := connections select: [:s | s isValid]]].

]
