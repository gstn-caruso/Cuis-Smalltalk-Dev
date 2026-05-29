"
McpSocket listens for MCP connections over TCP using line-delimited JSON. To use with MCP clients that expect a stdio transport, a small shell script can bridge stdin/stdout to the TCP socket.
"
Class {
	#name : 'McpSocket',
	#superclass : 'Object',
	#instVars : [
		'mcpServer',
		'process',
		'connectionQueue'
	],
	#category : 'McpServer-Kernel',
	#package : 'McpServer',
	#tag : 'Kernel'
}

{ #category : 'instance creation' }
McpSocket class >> newForServer: anMcpServer  [
	
	^ self new initializeWithServer: anMcpServer
]

{ #category : 'private' }
McpSocket >> handleConnection: clientSocket [
	| stream |
	stream := SocketStream on: clientSocket.
	stream noTimeout.
	[
		[
			[
				stream nextLineLf
					ifNil: [^ nil]
					ifNotNil: [:line | self handleRequestLine: line from: stream]
			] repeat
		] on: NetworkError do: [^ nil]
	] ensure: [stream close]
]

{ #category : 'private' }
McpSocket >> handleRequestLine: line from: stream [
	| decoded request response |
	decoded := CharacterSequence fromUtf8Bytes: line asByteArray.
	request := [ Json readFrom: decoded readStream ]
		on: JsonSyntaxError do: [:e |
			^ self respondWith: (mcpServer errorResponse: JsonRpcError parseError id: nil) on: stream
		].
	response := mcpServer dispatch: request.
	response ifNotNil: [
		self respondWith: response on: stream
	]
]

{ #category : 'initialization' }
McpSocket >> initializeWithServer: anMcpServer  [
	
	mcpServer := anMcpServer
]

{ #category : 'private' }
McpSocket >> respondWith: response on: stream [

	stream nextPutAll:
		((Json render: response) select: [:c | c isLineSeparator not]) asUtf8Bytes asString.
	stream nextPut: Character lf.
	stream flush.
	mcpServer consumeShutdownRequest ifTrue: [
		McpServer stop.
		Smalltalk snapshot: false andQuit: true embedded: false clearAllClassState: false]
]

{ #category : 'operations' }
McpSocket >> startOn: port [

	self stop.
	process := [
		connectionQueue := ConnectionQueue portNumber: port queueLength: 1.
		
		[
				[ connectionQueue notNil and: [ connectionQueue isValid ] ] whileTrue: [
				| queue |
				queue := connectionQueue.
				queue ifNil: [
					(Delay forMilliseconds: 10) wait.
				] ifNotNil: [
					(queue getConnectionOrNilLenient) ifNotNil: [:clientSocket |
					[ self handleConnection: clientSocket ] fork
					] ifNil: [
						(Delay forMilliseconds: 50) wait
					]
				]
			]
		] ensure: [
			connectionQueue ifNotNil: [
				connectionQueue destroy.
				connectionQueue := nil].
			process := nil.
		]
	] newProcess
		resume;
		yourself
]

{ #category : 'operations' }
McpSocket >> stop [

	| runningProcess |
	connectionQueue ifNotNil: [
		connectionQueue destroy.
		connectionQueue := nil].
	runningProcess := process.
	process := nil.
	runningProcess ifNotNil: [
		runningProcess terminate
	]
]
