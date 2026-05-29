Class {
	#name : 'McpBlockTool',
	#superclass : 'McpTool',
	#instVars : [
		'name',
		'description',
		'inputSchema',
		'block'
	],
	#category : 'McpServer-Tools',
	#package : 'McpServer',
	#tag : 'Tools'
}

{ #category : 'instance creation' }
McpBlockTool class >> name: aName description: aDescription inputSchema: aSchema handler: aBlock [
	^ self new initName: aName description: aDescription inputSchema: aSchema handler: aBlock
]

{ #category : 'accessing' }
McpBlockTool >> description [
	^ description
]

{ #category : 'executing' }
McpBlockTool >> execute: args [
	^ block value: args
]

{ #category : 'initialize-release' }
McpBlockTool >> initName: aName description: aDescription inputSchema: aSchema handler: aBlock [
	name := aName.
	description := aDescription.
	inputSchema := aSchema.
	block := aBlock
]

{ #category : 'accessing' }
McpBlockTool >> inputSchema [
	^ inputSchema
]

{ #category : 'accessing' }
McpBlockTool >> name [
	^ name
]
