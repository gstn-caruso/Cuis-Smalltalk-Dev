Class {
	#name : 'McpEvalToolTest',
	#superclass : 'McpTestCase',
	#category : 'McpServer-Tests',
	#package : 'McpServer',
	#tag : 'Tests'
}

{ #category : 'setUp/tearDown' }
McpEvalToolTest >> setUp [
	super setUp.
	server registerTool: McpEvalTool new
]

{ #category : 'tests' }
McpEvalToolTest >> test001_EvalToolReturnsExpressionResult [
	| response content |

	response := server dispatch: (self toolsCallRequest: 'eval' arguments: { 'code' -> '3 + 4' }).

	content := ((response at: 'result') at: 'content') first.
	self assert: (content at: 'type') equals: 'text'.
	self assert: (content at: 'text') equals: '7'.
]

{ #category : 'tests' }
McpEvalToolTest >> test002_EvalToolErrorReturnsIsError [
	| response result |

	response := server dispatch: (self toolsCallRequest: 'eval' arguments: { 'code' -> '1/0' }).

	result := response at: 'result'.
	self assert: (result at: 'isError') equals: true.
]
