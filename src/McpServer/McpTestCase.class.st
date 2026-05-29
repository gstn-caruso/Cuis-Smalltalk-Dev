Class {
	#name : 'McpTestCase',
	#superclass : 'TestCase',
	#instVars : [
		'server',
		'nextId',
		'testClassCategories'
	],
	#category : 'McpServer-Tests',
	#package : 'McpServer',
	#tag : 'Tests'
}

{ #category : 'testing' }
McpTestCase class >> isAbstract [
	^ self == McpTestCase
]

{ #category : 'assertions' }
McpTestCase >> assertError: response code: expectedCode message: expectedMessage [

	self assert: (response at: 'jsonrpc') equals: '2.0'.
	self assert: ((response at: 'error') at: 'code') equals: expectedCode.
	self assert: ((response at: 'error') at: 'message') equals: expectedMessage.
]

{ #category : 'assertions' }
McpTestCase >> assertToolCallError: toolName arguments: args includesAll: substrings [
	| response result text |
	response := server dispatch: (self toolsCallRequest: toolName arguments: args).
	result := response at: 'result'.
	self assert: (result at: 'isError') equals: true.
	text := (result at: 'content') first at: 'text'.
	substrings do: [:s | self assert: (text includesSubString: s)].
	^ text
]

{ #category : 'test support' }
McpTestCase >> createClassNamed: aSymbol [
	| category |
	category := '__MCP-TestData__'.
	self assert: (Smalltalk classNamed: aSymbol) isNil description: 'Class ' , aSymbol , ' already exists'.
	testClassCategories add: category.
	^ Object subclass: aSymbol
		instanceVariableNames: ''
		classVariableNames: ''
		poolDictionaries: ''
		category: category
]

{ #category : 'json rpc' }
McpTestCase >> initializeRequest [
	^ self
		jsonRpcRequest: 'initialize'
		params: {
			'protocolVersion' -> self protocolVersion.
			'capabilities' -> {
				'roots' -> OrderedDictionary new
			}.
			'clientInfo' -> {
				'name' -> 'claude-code'.
				'version' -> '2.1.70'
			}
		}
]

{ #category : 'json rpc' }
McpTestCase >> initializedNotification [
	^ self jsonRpcNotification: 'notifications/initialized'
]

{ #category : 'json rpc' }
McpTestCase >> json: anObject [
	^ McpServer json: anObject
]

{ #category : 'json rpc' }
McpTestCase >> jsonRpcNotification: method [
	^ self json: {
		'method' -> method.
		'jsonrpc' -> '2.0'
	}
]

{ #category : 'json rpc' }
McpTestCase >> jsonRpcRequest: method params: params [
	| id |
	id := nextId.
	nextId := nextId + 1.

	^ self json: {
		'method' -> method.
		'params' -> params.
		'jsonrpc' -> '2.0'.
		'id' -> id
	}
]

{ #category : 'json rpc' }
McpTestCase >> protocolVersion [

	^ McpServer protocolVersion
]

{ #category : 'json rpc' }
McpTestCase >> resourcesListRequest [
	^ self
		jsonRpcRequest: 'resources/list'
		params: OrderedDictionary new
]

{ #category : 'json rpc' }
McpTestCase >> resourcesReadRequest: uri [
	^ self
		jsonRpcRequest: 'resources/read'
		params: { 'uri' -> uri }
]

{ #category : 'setUp/tearDown' }
McpTestCase >> setUp [
	server := McpServer new.
	nextId := 0.
	testClassCategories := Set new
]

{ #category : 'setUp/tearDown' }
McpTestCase >> tearDown [
	McpServer stop.
	testClassCategories do: [:cat |
		(SystemOrganization listAtCategoryNamed: cat) do: [:className |
			(Smalltalk classNamed: className) ifNotNil: [:cls | cls removeFromSystem]].
		SystemOrganization removeSystemCategory: cat].
	super tearDown
]

{ #category : 'json rpc' }
McpTestCase >> toolsCallRequest: toolName arguments: arguments [
	^ self
		jsonRpcRequest: 'tools/call'
		params: {
			'name' -> toolName.
			'arguments' -> arguments
		}
]

{ #category : 'json rpc' }
McpTestCase >> toolsListRequest [
	^ self
		jsonRpcRequest: 'tools/list'
		params: OrderedDictionary new
]
