Class {
	#name : 'McpEvalTool',
	#superclass : 'McpTool',
	#category : 'McpServer-Tools',
	#package : 'McpServer',
	#tag : 'Tools'
}

{ #category : 'accessing' }
McpEvalTool >> description [
	^ 'Evaluates Smalltalk code in the live image and returns the result of the last expression as a printString (no need to call printString yourself).'
]

{ #category : 'executing' }
McpEvalTool >> execute: args [

	[
		^ (Compiler evaluate: (args at: 'code')) printString
	] on: Error do: [:e |
		McpError signal: (self serializeStackForError: e)
	]
]

{ #category : 'accessing' }
McpEvalTool >> inputSchema [
	^ McpServer json: {
		'type' -> 'object'.
		'properties' -> {
			'code' -> { 'type' -> 'string' }
		}
	}
]

{ #category : 'accessing' }
McpEvalTool >> name [
	^ 'eval'
]

{ #category : 'private' }
McpEvalTool >> serializeStackForError: anError [
	| stream ctx |
	stream := WriteStream on: String new.
	stream
		nextPutAll: anError description; lf;
		lf;
		nextPutAll: 'Stack:'; lf.
	ctx := anError signalerContext.
	[ctx isNil or: [ctx selector == Scanner doItSelector]] whileFalse: [
		stream nextPutAll: '  '; nextPutAll: ctx printString; lf.
		ctx := ctx sender].
	^ stream contents
]
