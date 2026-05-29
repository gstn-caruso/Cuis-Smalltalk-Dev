Class {
	#name : 'McpReadMethodSourceToolTest',
	#superclass : 'McpTestCase',
	#category : 'McpServer-Tests',
	#package : 'McpServer',
	#tag : 'Tests'
}

{ #category : 'setUp/tearDown' }
McpReadMethodSourceToolTest >> setUp [
	super setUp.
	server registerTool: McpReadMethodSourceTool new
]

{ #category : 'tests' }
McpReadMethodSourceToolTest >> test001_ReadMethodSourceInstanceSide [
	| response text |

	response := server dispatch: (self toolsCallRequest: 'read-method-source' arguments: {
		'methods' -> #('False>>not') }).

	text := (((response at: 'result') at: 'content') first) at: 'text'.
	self assert: text equals: '{ #category : ''[mk] logical operations'' }
False >> not
	"Negation -- answer true since the receiver is false."

	^true'.
]

{ #category : 'tests' }
McpReadMethodSourceToolTest >> test002_ReadMethodSourceClassSide [
	| response text |

	response := server dispatch: (self toolsCallRequest: 'read-method-source' arguments: {
		'methods' -> #('McpBlockTool class>>name:description:inputSchema:handler:') }).

	text := (((response at: 'result') at: 'content') first) at: 'text'.
	self assert: (text includesSubString: 'McpBlockTool class >> name: aName description: aDescription inputSchema: aSchema handler: aBlock').
	self assert: (text includesSubString: 'initName:').
]

{ #category : 'tests' }
McpReadMethodSourceToolTest >> test003_ReadMethodSourceUnknownClassReturnsIsError [
	| response result |

	response := server dispatch: (self toolsCallRequest: 'read-method-source' arguments: {
		'methods' -> #('NoSuchClass99>>someMethod') }).

	result := response at: 'result'.
	self assert: (result at: 'isError') equals: true.
	self assert: (((result at: 'content') first at: 'text') includesSubString: 'NoSuchClass99').
]

{ #category : 'tests' }
McpReadMethodSourceToolTest >> test004_ReadMethodSourceInvalidFormatReturnsIsError [
	| response result |

	response := server dispatch: (self toolsCallRequest: 'read-method-source' arguments: {
		'methods' -> #('McpEvalToolname') }).

	result := response at: 'result'.
	self assert: (result at: 'isError') equals: true.
	self assert: (((result at: 'content') first at: 'text') includesSubString: 'McpEvalToolname').
]

{ #category : 'tests' }
McpReadMethodSourceToolTest >> test005_ReadMethodSourceMixedReturnsPartialResults [
	| response result text |

	response := server dispatch: (self toolsCallRequest: 'read-method-source' arguments: {
		'methods' -> #(
			'NoSuchClass99>>someMethod'
			'McpEvalTool>>toolName') }).

	result := response at: 'result'.
	text := (result at: 'content') first at: 'text'.
	self assert: (result at: 'isError') equals: true.
	self assert: (text includesSubString: 'NoSuchClass99').
	self assert: (text includesSubString: 'toolName').
]

{ #category : 'tests' }
McpReadMethodSourceToolTest >> test006_ReadMethodNotFoundButExistsInHierarchyReturnsIsError [
	| response result text |

	response := server dispatch: (self toolsCallRequest: 'read-method-source' arguments: {
		'methods' -> #('McpReadMethodSourceTool>>printOn:') }).

	result := response at: 'result'.
	text := (result at: 'content') first at: 'text'.
	self assert: (result at: 'isError') equals: true.
	self assert: (text includesSubString: 'Method not found: McpReadMethodSourceTool>>printOn:').
	self assert: (text includesSubString: 'Object >> printOn:').
]

{ #category : 'tests' }
McpReadMethodSourceToolTest >> test007_ReadMethodSourceWithDoubleEncodedArray [
	| response text |

	response := server dispatch: (self toolsCallRequest: 'read-method-source' arguments: {
		'methods' -> (Json render: #('McpReadMethodSourceTool>>execute:')) }).

	text := (((response at: 'result') at: 'content') first) at: 'text'.
	self assert: (text includesSubString: 'McpReadMethodSourceTool').
]
