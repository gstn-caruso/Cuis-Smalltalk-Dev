Class {
	#name : 'McpServer',
	#superclass : 'Object',
	#instVars : [
		'tools',
		'resources',
		'resourceHandlers',
		'shutdownRequested'
	],
	#classInstVars : [
		'current',
		'socket'
	],
	#category : 'McpServer-Kernel',
	#package : 'McpServer',
	#tag : 'Kernel'
}

{ #category : 'accessing' }
McpServer class >> current [
	^ current

]

{ #category : 'converting' }
McpServer class >> json: anObject [
	"Recursively convert arrays of associations into OrderedDictionaries."

	(anObject isKindOf: OrderedDictionary) ifTrue: [^ anObject].

	(anObject isArray and: [anObject notEmpty and: [anObject allSatisfy: [:e | e isKindOf: Association]]]) ifTrue: [
		^ (anObject collect: [:assoc |
			assoc key -> (self json: assoc value)
		]) as: OrderedDictionary
	].

	anObject isString ifTrue: [^ anObject].

	anObject isCollection ifTrue: [
		^ anObject collect: [:e | self json: e]
	].

	^ anObject
]

{ #category : 'configuration' }
McpServer class >> protocolVersion [
	^ '2025-11-25'
]

{ #category : 'tools' }
McpServer class >> refreshTools [
	current clearTools.
	current registerTool: McpEvalTool new.
	current registerTool: McpReadMethodSourceTool new.
	current registerTool: McpCompileMethodTool new.
	current registerTool: McpShutdownTool new.
]

{ #category : 'instance creation' }
McpServer class >> shutdownGracefully [
	current ifNil: [^ false].
	current requestShutdown.
	^ true
]

{ #category : 'instance creation' }
McpServer class >> startDefault [
	socket ifNotNil: [ socket stop ].
	
	current := self new.
	self refreshTools.
	
	socket := McpSocket newForServer: current.
	socket startOn: 1470.
	
	^ current
]

{ #category : 'instance creation' }
McpServer class >> stop [
	socket ifNotNil: [
		socket stop.
		socket := nil].
	current := nil
]

{ #category : 'tools' }
McpServer >> clearTools [
	tools := Dictionary new
]

{ #category : 'lifecycle' }
McpServer >> consumeShutdownRequest [
	| wasRequested |
	wasRequested := shutdownRequested.
	shutdownRequested := false.
	^ wasRequested
]

{ #category : 'request handling' }
McpServer >> dispatch: aDictionary [
	[ | request handlerSelector |
		request := JsonRpcRequest fromDictionary: aDictionary.
		
		request isNotification ifTrue: [
			self handleNotification: request.
			^ nil
		].

		handlerSelector := `{
			'initialize' -> #handleInitialize:.
			'ping' -> #handlePing:.
			'tools/list' -> #handleToolsList:.
			'tools/call' -> #handleToolsCall:.
			'resources/list' -> #handleResourcesList:.
			'resources/read' -> #handleResourcesRead:.
		} asDictionary` at: request method ifAbsent: [ JsonRpcError signalMethodNotFound ].

		^ self perform: handlerSelector with: request
	] on: JsonRpcError do: [:e |
		^ self errorResponse: e id: (aDictionary at: 'id' ifAbsent: [ nil ])
	]

]

{ #category : 'responses' }
McpServer >> errorResponse: aJsonRpcError id: id [
	^ self json: {
		'jsonrpc' -> '2.0'.
		'id' -> id.
		'error' -> {
			'code' -> aJsonRpcError code.
			'message' -> aJsonRpcError messageText
		}
	}
]

{ #category : 'responses' }
McpServer >> errorResponseWithDescription: aDescription forRequest: aRequest [
	^ self
		response: {
			self textContent: aDescription.
			'isError' -> true
		}
		id: aRequest id
]

{ #category : 'request handling' }
McpServer >> handleInitialize: request [

	request requireParams: {'protocolVersion'. 'clientInfo'}.

	^ self
		response: {
			'protocolVersion' -> self protocolVersion.
			'capabilities' -> {
				'tools' -> OrderedDictionary new.
				'resources' -> OrderedDictionary new
			}.
			'serverInfo' -> {
				'name' -> 'cuis-mcp'.
				'version' -> '0.1.0'
			}
		}
		id: request id
]

{ #category : 'handlers' }
McpServer >> handleNotification: request [
	
]

{ #category : 'handlers' }
McpServer >> handlePing: request [
	^ self
		response: OrderedDictionary new
		id: request id
]

{ #category : 'handlers' }
McpServer >> handleResourcesList: request [
	^ self
		response: { 'resources' -> resources values }
		id: request id
]

{ #category : 'handlers' }
McpServer >> handleResourcesRead: request [
	| uri resource handler result |
	uri := request paramAt: 'uri'.

	resource := resources at: uri ifAbsent: [
		JsonRpcError signalResourceNotFound
	].

	handler := resourceHandlers at: uri.

	[
		result := handler value: uri.
	] on: Error do: [:e |
		JsonRpcError signal: e messageText code: -32603
	].

	^ self
		response: {
			'contents' -> {
				{
					'uri' -> uri.
					'mimeType' -> (resource at: 'mimeType').
					'text' -> result
				}
			}
		}
		id: request id
]

{ #category : 'dispatching' }
McpServer >> handleToolsCall: request [

	| toolName tool arguments result |
	toolName := request paramAt: 'name'.
	tool := tools at: toolName ifAbsent: [
		JsonRpcError signalToolNotFound
	].
	arguments := request paramAt: 'arguments' ifAbsent: [ Dictionary new ].
	
	[
		tool validateArguments: arguments.
		result := tool execute: arguments
	] on: Error do: [:e |
		^ self errorResponseWithDescription: e messageText forRequest: request
	].

	^ self
		response: { self textContent: result }
		id: request id
]

{ #category : 'dispatching' }
McpServer >> handleToolsList: request [
	^ self
		response: { 'tools' -> (tools values collect: [:tool | tool asJsonDescription]) }
		id: request id
]

{ #category : 'initialization' }
McpServer >> initialize [
	tools := Dictionary new.
	resources := Dictionary new.
	resourceHandlers := Dictionary new.
	shutdownRequested := false.
]

{ #category : 'private' }
McpServer >> json: anObject [
	^ self class json: anObject
]

{ #category : 'configuration' }
McpServer >> protocolVersion [
	^ self class protocolVersion
]

{ #category : 'resource registration' }
McpServer >> registerResource: uri name: name description: description mimeType: mimeType handler: aBlock [
	resources at: uri put: (self json: {
		'uri' -> uri.
		'name' -> name.
		'description' -> description.
		'mimeType' -> mimeType
	}).
	resourceHandlers at: uri put: aBlock
]

{ #category : 'tools' }
McpServer >> registerTool: aTool [
	tools at: aTool name put: aTool
]

{ #category : 'lifecycle' }
McpServer >> requestShutdown [
	shutdownRequested := true
]

{ #category : 'responses' }
McpServer >> response: result id: id [
	^ self json: {
		'jsonrpc' -> '2.0'.
		'id' -> id.
		'result' -> result
	}
]

{ #category : 'responses' }
McpServer >> textContent: aString [
	^ 'content' -> {
		{
			'type' -> 'text'.
			'text' -> aString
		}
	}
]
