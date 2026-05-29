Class {
	#name : 'McpShutdownToolTest',
	#superclass : 'McpTestCase',
	#category : 'McpServer-Tests',
	#package : 'McpServer',
	#tag : 'Tests'
}

{ #category : 'setUp/tearDown' }
McpShutdownToolTest >> setUp [
	super setUp.
	server registerTool: McpShutdownTool new
]

{ #category : 'tests' }
McpShutdownToolTest >> test001_ShutdownToolReturnsConfirmationWhenNoServerIsRunning [
	| response result text |
	response := server dispatch: (self toolsCallRequest: 'shutdown' arguments: OrderedDictionary new).
	result := response at: 'result'.
	text := (result at: 'content') first at: 'text'.
	self assert: text equals: 'Shutdown ignored. No running MCP server was registered.'
]

{ #category : 'tests' }
McpShutdownToolTest >> test002_ShutdownGracefullyMarksCurrentServerForShutdown [
	| started response text |
	started := McpServer startDefault.
	self assert: started == McpServer current.
	response := started dispatch: (self toolsCallRequest: 'shutdown' arguments: OrderedDictionary new).
	text := (response at: 'result') at: 'content'.
	self assert: (text first at: 'text') equals: 'Shutdown scheduled. The server and image will stop after this response.'.
	self assert: started consumeShutdownRequest.
	self deny: started consumeShutdownRequest.
	McpServer stop.
	self assert: McpServer current isNil.
]
