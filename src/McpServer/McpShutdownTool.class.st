Class {
	#name : 'McpShutdownTool',
	#superclass : 'McpTool',
	#category : 'McpServer-Tools',
	#package : 'McpServer',
	#tag : 'Tools'
}

{ #category : 'accessing' }
McpShutdownTool >> description [
	^ 'Gracefully stops the MCP server and exits the image after this response is delivered.'
]

{ #category : 'executing' }
McpShutdownTool >> execute: args [
	(McpServer shutdownGracefully)
		ifTrue: [^ 'Shutdown scheduled. The server and image will stop after this response.'].
	^ 'Shutdown ignored. No running MCP server was registered.'
]

{ #category : 'accessing' }
McpShutdownTool >> inputSchema [
	^ McpServer json: {
		'type' -> 'object'.
		'properties' -> OrderedDictionary new
	}
]

{ #category : 'accessing' }
McpShutdownTool >> name [
	^ 'shutdown'
]
