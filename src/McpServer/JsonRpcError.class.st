Class {
	#name : 'JsonRpcError',
	#superclass : 'Error',
	#instVars : [
		'code'
	],
	#category : 'McpServer-JsonRpc',
	#package : 'McpServer',
	#tag : 'JsonRpc'
}

{ #category : 'instance creation' }
JsonRpcError class >> invalidParams [
	^ self new initializeWithCode: -32602 message: 'Invalid params'
]

{ #category : 'instance creation' }
JsonRpcError class >> invalidRequest [
	^ self new initializeWithCode: -32600 message: 'Invalid Request'
]

{ #category : 'instance creation' }
JsonRpcError class >> methodNotFound [
	^ self new initializeWithCode: -32601 message: 'Method not found'
]

{ #category : 'instance creation' }
JsonRpcError class >> newWithCode: anInteger message: aString [
	^ self new initializeWithCode: anInteger message: aString
]

{ #category : 'instance creation' }
JsonRpcError class >> parseError [
	^ self new initializeWithCode: -32700 message: 'Parse error'
]

{ #category : 'instance creation' }
JsonRpcError class >> resourceNotFound [
	^ self new initializeWithCode: -32002 message: 'Resource not found'
]

{ #category : 'signaling' }
JsonRpcError class >> signal: aMessage code: anInteger [
	(self newWithCode: anInteger message: aMessage) signal
]

{ #category : 'signaling' }
JsonRpcError class >> signalInvalidParams [
	self invalidParams signal
]

{ #category : 'signaling' }
JsonRpcError class >> signalInvalidRequest [
	self invalidRequest signal
]

{ #category : 'signaling' }
JsonRpcError class >> signalMethodNotFound [
	self methodNotFound signal
]

{ #category : 'signaling' }
JsonRpcError class >> signalResourceNotFound [
	self resourceNotFound signal
]

{ #category : 'signaling' }
JsonRpcError class >> signalToolNotFound [
	self toolNotFound signal
]

{ #category : 'instance creation' }
JsonRpcError class >> toolNotFound [
	^ self new initializeWithCode: -32602 message: 'Tool not found'
]

{ #category : 'accessing' }
JsonRpcError >> code [
	^ code
]

{ #category : 'initialization' }
JsonRpcError >> initializeWithCode: anInteger message: aString [
	code := anInteger.
	self messageText: aString
]
