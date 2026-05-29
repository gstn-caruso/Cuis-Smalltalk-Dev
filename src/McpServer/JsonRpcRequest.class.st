Class {
	#name : 'JsonRpcRequest',
	#superclass : 'Object',
	#instVars : [
		'data'
	],
	#category : 'McpServer-JsonRpc',
	#package : 'McpServer',
	#tag : 'JsonRpc'
}

{ #category : 'instance creation' }
JsonRpcRequest class >> fromDictionary: aDictionary [

	aDictionary at: 'method' ifAbsent: [ JsonRpcError signalInvalidRequest ].

	^ self new initializeFrom: aDictionary
]

{ #category : 'accessing' }
JsonRpcRequest >> id [
	^ data at: 'id' ifAbsent: [ nil ]
]

{ #category : 'initialization' }
JsonRpcRequest >> initializeFrom: aDictionary [
	data := aDictionary
]

{ #category : 'testing' }
JsonRpcRequest >> isNotification [
	^ (data includesKey: 'id') not
]

{ #category : 'accessing' }
JsonRpcRequest >> method [
	^ data at: 'method'
]

{ #category : 'accessing' }
JsonRpcRequest >> paramAt: key [
	^ self params at: key ifAbsent: [
		JsonRpcError signalInvalidParams
	]
]

{ #category : 'accessing' }
JsonRpcRequest >> paramAt: key ifAbsent: aBlock [
	^ self params at: key ifAbsent: aBlock
]

{ #category : 'accessing' }
JsonRpcRequest >> params [
	^ data at: 'params' ifAbsent: [
		JsonRpcError signalInvalidParams
	]
]

{ #category : 'private' }
JsonRpcRequest >> requireParams: expectedParameters  [
	expectedParameters do: [:parameter |
		self paramAt: parameter
	]
]
