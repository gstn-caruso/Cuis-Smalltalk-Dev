Class {
	#name : 'McpServerTest',
	#superclass : 'McpTestCase',
	#category : 'McpServer-Tests',
	#package : 'McpServer',
	#tag : 'Tests'
}

{ #category : 'tests' }
McpServerTest >> test001_Initialize [
	| response result |
	response := server dispatch: self initializeRequest.

	self assert: (response at: 'jsonrpc') equals: '2.0'.
	self assert: (response at: 'id') equals: 0.
	result := response at: 'result'.
	self assert: (result at: 'protocolVersion') equals: self protocolVersion.
	self assert: ((result at: 'serverInfo') isKindOf: Dictionary).
	self assert: ((result at: 'serverInfo') includesKey: 'name').
	self assert: ((result at: 'serverInfo') includesKey: 'version').
	self assert: ((result at: 'capabilities') isKindOf: Dictionary).
]

{ #category : 'tests' }
McpServerTest >> test002_NotificationsInitialized [
	| response |
	response := server dispatch: self initializedNotification.

	self assert: response isNil.
]

{ #category : 'tests' }
McpServerTest >> test003_MissingMethodReturnsError [
	| response |
	response := server dispatch: (self json: {
		'jsonrpc' -> '2.0'.
		'id' -> 0
	}).

	self assertError: response code: -32600 message: 'Invalid Request'.
]

{ #category : 'tests' }
McpServerTest >> test004_UnknownMethodReturnsError [
	| response |
	response := server dispatch: (self
		jsonRpcRequest: 'bogus/method'
		params: OrderedDictionary new).

	self assertError: response code: -32601 message: 'Method not found'.
]

{ #category : 'tests' }
McpServerTest >> test005_Ping [
	| response result |
	response := server dispatch: (self
		jsonRpcRequest: 'ping'
		params: OrderedDictionary new).

	self assert: (response at: 'jsonrpc') equals: '2.0'.
	result := response at: 'result'.
	self assert: (result isKindOf: Dictionary).
	self assert: result isEmpty.
]

{ #category : 'tests' }
McpServerTest >> test006_InitializeWithoutParamsReturnsError [
	| response |
	response := server dispatch: (self json: {
		'method' -> 'initialize'.
		'jsonrpc' -> '2.0'.
		'id' -> 0
	}).

	self assertError: response code: -32602 message: 'Invalid params'.
]

{ #category : 'tests' }
McpServerTest >> test007_NotificationForUnknownMethodIsIgnored [
	| response |
	response := server dispatch: (self jsonRpcNotification: 'bogus/notification').

	self assert: response isNil.
]

{ #category : 'tests' }
McpServerTest >> test008_ToolsListEmpty [
	| response result |
	response := server dispatch: self toolsListRequest.

	self assert: (response at: 'jsonrpc') equals: '2.0'.
	result := response at: 'result'.
	self assert: ((result at: 'tools') isKindOf: SequenceableCollection ).
	self assert: (result at: 'tools') isEmpty.
]

{ #category : 'tests' }
McpServerTest >> test009_ToolsListWithRegisteredTool [
	| response result toolEntry |
	server registerTool: (McpBlockTool
		name: 'echo'
		description: 'Echoes the input'
		inputSchema: (self json: {
			'type' -> 'object'.
			'properties' -> {
				'message' -> { 'type' -> 'string' }
			}
		})
		handler: [:args | args at: 'message']).

	response := server dispatch: self toolsListRequest.

	result := response at: 'result'.
	self assert: ((result at: 'tools') isKindOf: SequenceableCollection ).
	self assert: (result at: 'tools') size equals: 1.
	toolEntry := (result at: 'tools') first.
	self assert: (toolEntry at: 'name') equals: 'echo'.
	self assert: (toolEntry at: 'description') equals: 'Echoes the input'.
	self deny: (toolEntry includesKey: 'handler').
]

{ #category : 'tests' }
McpServerTest >> test010_ToolsCall [
	| response result content |
	server registerTool: (McpBlockTool
		name: 'echo'
		description: 'Echoes the input'
		inputSchema: (self json: {
			'type' -> 'object'.
			'properties' -> {
				'message' -> { 'type' -> 'string' }
			}
		})
		handler: [:args | args at: 'message']).

	response := server dispatch: (self
		toolsCallRequest: 'echo'
		arguments: { 'message' -> 'hello' }).

	self assert: (response at: 'jsonrpc') equals: '2.0'.
	result := response at: 'result'.
	content := (result at: 'content') first.
	self assert: (content at: 'type') equals: 'text'.
	self assert: (content at: 'text') equals: 'hello'.
]

{ #category : 'tests' }
McpServerTest >> test011_ToolsCallUnknownTool [
	| response |
	response := server dispatch: (self
		toolsCallRequest: 'nonexistent'
		arguments: OrderedDictionary new).

	self assertError: response code: -32602 message: 'Tool not found'.
]

{ #category : 'tests' }
McpServerTest >> test012_ToolsCallMissingParams [
	| response |
	response := server dispatch: (self json: {
		'method' -> 'tools/call'.
		'jsonrpc' -> '2.0'.
		'id' -> 0
	}).

	self assertError: response code: -32602 message: 'Invalid params'.
]

{ #category : 'tests' }
McpServerTest >> test013_ToolsCallHandlerErrorReturnsIsError [
	| response result content text |
	server registerTool: (McpBlockTool
		name: 'failing'
		description: 'Always fails'
		inputSchema: (self json: {
			'type' -> 'object'.
			'properties' -> OrderedDictionary new
		})
		handler: [:args | Error new signal: 'something went wrong']).

	response := server dispatch: (self
		toolsCallRequest: 'failing'
		arguments: OrderedDictionary new).

	self assert: (response at: 'jsonrpc') equals: '2.0'.
	self assert: (response includesKey: 'result').
	self deny: (response includesKey: 'error').
	result := response at: 'result'.
	self assert: (result at: 'isError') equals: true.
	content := (result at: 'content') first.
	self assert: (content at: 'type') equals: 'text'.
	text := content at: 'text'.
	self assert: (text includesSubString: 'something went wrong').
]

{ #category : 'tests' }
McpServerTest >> test014_ToolsCallSuccessHasNoIsError [
	| response result |
	server registerTool: (McpBlockTool
		name: 'echo'
		description: 'Echoes the input'
		inputSchema: (self json: {
			'type' -> 'object'.
			'properties' -> {
				'message' -> { 'type' -> 'string' }
			}
		})
		handler: [:args | args at: 'message']).

	response := server dispatch: (self
		toolsCallRequest: 'echo'
		arguments: { 'message' -> 'hello' }).

	result := response at: 'result'.
	self deny: (result includesKey: 'isError').
]

{ #category : 'tests' }
McpServerTest >> test015_ResourcesListEmpty [
	| response result |
	response := server dispatch: self resourcesListRequest.

	self assert: (response at: 'jsonrpc') equals: '2.0'.
	result := response at: 'result'.
	self assert: ((result at: 'resources') isKindOf: SequenceableCollection ).
	self assert: (result at: 'resources') isEmpty.
]

{ #category : 'tests' }
McpServerTest >> test016_ResourcesListWithRegisteredResource [
	| response result resourceEntry |
	server
		registerResource: 'test://example'
		name: 'Example'
		description: 'An example resource'
		mimeType: 'text/plain'
		handler: [:uri | 'hello world'].

	response := server dispatch: self resourcesListRequest.

	result := response at: 'result'.
	self assert: ((result at: 'resources') isKindOf: SequenceableCollection ).
	self assert: (result at: 'resources') size equals: 1.
	resourceEntry := (result at: 'resources') first.
	self assert: (resourceEntry at: 'uri') equals: 'test://example'.
	self assert: (resourceEntry at: 'name') equals: 'Example'.
	self assert: (resourceEntry at: 'description') equals: 'An example resource'.
	self assert: (resourceEntry at: 'mimeType') equals: 'text/plain'.
	self deny: (resourceEntry includesKey: 'handler').
]

{ #category : 'tests' }
McpServerTest >> test017_ResourcesRead [
	| response result content |
	server
		registerResource: 'test://greeting'
		name: 'Greeting'
		description: 'A greeting'
		mimeType: 'text/plain'
		handler: [:uri | 'hello world'].

	response := server dispatch: (self resourcesReadRequest: 'test://greeting').

	self assert: (response at: 'jsonrpc') equals: '2.0'.
	result := response at: 'result'.
	content := (result at: 'contents') first.
	self assert: (content at: 'uri') equals: 'test://greeting'.
	self assert: (content at: 'mimeType') equals: 'text/plain'.
	self assert: (content at: 'text') equals: 'hello world'.
]

{ #category : 'tests' }
McpServerTest >> test018_ResourcesReadUnknownResource [
	| response |
	response := server dispatch: (self resourcesReadRequest: 'test://nonexistent').

	self assertError: response code: -32002 message: 'Resource not found'.
]

{ #category : 'tests' }
McpServerTest >> test019_ResourcesReadMissingParams [
	| response |
	response := server dispatch: (self json: {
		'method' -> 'resources/read'.
		'jsonrpc' -> '2.0'.
		'id' -> 0
	}).

	self assertError: response code: -32602 message: 'Invalid params'.
]

{ #category : 'tests' }
McpServerTest >> test020_ResourcesReadHandlerError [
	| response |
	server
		registerResource: 'test://failing'
		name: 'Failing'
		description: 'Always fails'
		mimeType: 'text/plain'
		handler: [:uri | Error new signal: 'something went wrong'].

	response := server dispatch: (self resourcesReadRequest: 'test://failing').

	self assertError: response code: -32603 message: 'something went wrong'.
]

{ #category : 'tests' }
McpServerTest >> test021_ResourcesReadHandlerReceivesUri [
	| response result content receivedUri |
	receivedUri := nil.
	server
		registerResource: 'test://capture'
		name: 'Capture'
		description: 'Captures the URI'
		mimeType: 'text/plain'
		handler: [:uri | receivedUri := uri. 'ok'].

	response := server dispatch: (self resourcesReadRequest: 'test://capture').

	self assert: receivedUri equals: 'test://capture'.
	result := response at: 'result'.
	content := (result at: 'contents') first.
	self assert: (content at: 'text') equals: 'ok'.
]

{ #category : 'tests' }
McpServerTest >> test022_InitializeAdvertisesResourcesCapability [
	| response result capabilities |
	response := server dispatch: self initializeRequest.

	result := response at: 'result'.
	capabilities := result at: 'capabilities'.
	self assert: (capabilities includesKey: 'resources').
]

{ #category : 'tests' }
McpServerTest >> test023_ClearToolsEmptiesTools [
	| response |
	server registerTool: (McpBlockTool
		name: 'eval'
		description: 'Evaluates the input code'
		inputSchema: (server json: {'type' -> 'object'})
		handler: [:args | 'result']).

	server clearTools.

	response := server dispatch: self toolsListRequest.
	self assert: ((response at: 'result') at: 'tools') isEmpty.
]

{ #category : 'tests' }
McpServerTest >> test024_PingAfterFullHandshakeSucceeds [
	| response result |
	server dispatch: self initializeRequest.
	server dispatch: self initializedNotification.

	response := server dispatch: (self
		jsonRpcRequest: 'ping'
		params: OrderedDictionary new).

	self assert: (response at: 'jsonrpc') equals: '2.0'.
	result := response at: 'result'.
	self assert: (result isKindOf: Dictionary).
	self assert: result isEmpty.
]

{ #category : 'tests' }
McpServerTest >> test025_ToolCallWithUnknownArgReturnsHelpfulError [

	| response result text |
	server registerTool: (McpBlockTool
		name: 'echo'
		description: 'Echoes'
		inputSchema: (self json: {
			'type' -> 'object'.
			'properties' -> {
				'message' -> { 'type' -> 'string' }
			}
		})
		handler: [:args | args at: 'message']).

	response := server dispatch: (self
		toolsCallRequest: 'echo'
		arguments: { 'msg' -> 'hello' }).

	result := response at: 'result'.
	text := (result at: 'content') first at: 'text'.
	self assert: (result at: 'isError') equals: true.
	self assert: (text includesSubString: 'unknown argument(s): msg').
	self assert: (text includesSubString: 'expected: message').
	self assert: (text includesSubString: 'Schema:')
]

{ #category : 'tests' }
McpServerTest >> test026_ToolCallWithMissingRequiredArgReturnsHelpfulError [

	| response result text |
	server registerTool: (McpBlockTool
		name: 'greet'
		description: 'Greets'
		inputSchema: (self json: {
			'type' -> 'object'.
			'properties' -> {
				'name' -> { 'type' -> 'string' }
			}.
			'required' -> #('name')
		})
		handler: [:args | 'Hello, ' , (args at: 'name')]).

	response := server dispatch: (self
		toolsCallRequest: 'greet'
		arguments: OrderedDictionary new).

	result := response at: 'result'.
	text := (result at: 'content') first at: 'text'.
	self assert: (result at: 'isError') equals: true.
	self assert: (text includesSubString: 'missing required argument(s): name').
	self assert: (text includesSubString: 'Schema:')
]

{ #category : 'tests' }
McpServerTest >> test026a_ToolCallWithWrongStringTypeReturnsHelpfulError [
	server registerTool: (McpBlockTool
		name: 'greet'
		description: 'Greets'
		inputSchema: (self json: {
			'type' -> 'object'.
			'properties' -> { 'name' -> { 'type' -> 'string' } } })
		handler: [:args | '']).
	self
		assertToolCallError: 'greet'
		arguments: { 'name' -> 42 }
		includesAll: { 'type error(s)'. '''name'' must be a string'. 'Schema:' }
]

{ #category : 'tests' }
McpServerTest >> test026b_ToolCallWithWrongArrayItemTypeReturnsHelpfulError [
	server registerTool: (McpBlockTool
		name: 'batch'
		description: 'Batches strings'
		inputSchema: (self json: {
			'type' -> 'object'.
			'properties' -> { 'items' -> {
				'type' -> 'array'.
				'items' -> { 'type' -> 'string' } } } })
		handler: [:args | '']).
	self
		assertToolCallError: 'batch'
		arguments: { 'items' -> { (OrderedDictionary new at: 'x' put: 1; yourself) } }
		includesAll: { 'type error(s)'. '''items[1]'' must be a string'. 'Schema:' }
]

{ #category : 'tests' }
McpServerTest >> test026c_ToolCallWithNonArrayForArrayParamReturnsHelpfulError [
	server registerTool: (McpBlockTool
		name: 'batch'
		description: 'Batches strings'
		inputSchema: (self json: {
			'type' -> 'object'.
			'properties' -> { 'items' -> {
				'type' -> 'array'.
				'items' -> { 'type' -> 'string' } } } })
		handler: [:args | '']).
	self
		assertToolCallError: 'batch'
		arguments: { 'items' -> 42 }
		includesAll: { 'type error(s)'. '''items'' must be an array'. 'Schema:' }
]

{ #category : 'tests' }
McpServerTest >> test027_ResponsesAreSerializedAsSingleLine [
	| response stream socket schema |
	schema := self json: {
		'type' -> 'object'.
		'properties' -> {
			'x' -> { 'type' -> 'string' }
		}
	}.
	server registerTool: (McpBlockTool name: 'a' description: 'A' inputSchema: schema handler: [:args | '']).
	server registerTool: (McpBlockTool name: 'b' description: 'B' inputSchema: schema handler: [:args | '']).
	response := server dispatch: self toolsListRequest.

	stream := WriteStream on: String new.
	socket := McpSocket new initializeWithServer: server.
	socket respondWith: response on: stream.

	self deny: (stream contents allButLast anySatisfy: [:c | c isLineSeparator])
]

{ #category : 'tests' }
McpServerTest >> test028_RoundTripsUtf8InRequestAndResponse [
	| line received schema socket stream oAsUtf8 replyAsString |
	received := nil.
	schema := self json: {
		'type' -> 'object'.
		'properties' -> { 'text' -> { 'type' -> 'string' } }.
		'required' -> #('text')
	}.
	server registerTool: (McpBlockTool
		name: 'echo'
		description: 'echo'
		inputSchema: schema
		handler: [:args | received := args at: 'text'. received]).
	oAsUtf8 := String with: (Character value: 16rC3) with: (Character value: 16rB3).
	line := '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"echo","arguments":{"text":"',
		oAsUtf8, '"}}}'.
	stream := WriteStream on: String new.
	socket := McpSocket new initializeWithServer: server.
	socket handleRequestLine: line from: stream.
	replyAsString := stream contents asByteArray asString.
	self assert: received size equals: 1.
	self assert: (received at: 1) codePoint equals: 16rF3.
	self assert: (replyAsString includesSubString: oAsUtf8)
]
