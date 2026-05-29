Class {
	#name : 'McpCompileMethodTool',
	#superclass : 'McpTool',
	#category : 'McpServer-Tools',
	#package : 'McpServer',
	#tag : 'Tools'
}

{ #category : 'private' }
McpCompileMethodTool >> compileMethodFrom: aString [
	| spec category className source targetClass selector |
	spec := self parseMethodSpec: aString.
	category := spec first.
	className := spec second.
	source := spec third.
	targetClass := self resolveClassReference: className.
	selector := targetClass compile: source classified: category.
	^ 'Compiled: ' , targetClass name , '>>' , selector
]

{ #category : 'accessing' }
McpCompileMethodTool >> description [
	^ 'Compile one or more methods into the live image. Each entry uses Tonel-like format: first line is { #category : ''protocolName'' }, followed by ClassName >> methodSource (or ClassName class >> for class-side).'
]

{ #category : 'executing' }
McpCompileMethodTool >> execute: args [
	| methods |
	methods := self decodeArrayParam: (args at: 'methods').
	^ self executeBatch: methods action: [:spec | self compileMethodFrom: spec]
]

{ #category : 'accessing' }
McpCompileMethodTool >> inputSchema [
	^ McpServer json:
		{
			'type' -> 'object'. 
			'properties' ->
				{
					'methods' ->
						{
							'type' -> 'array'. 
							'items' ->
								{'type' -> 'string'}. 
							'description' -> 'Array of method strings in Tonel-like format: { #category : ''protocol'' } header line followed by ClassName >> source'
						}
				}. 
			'required' -> #('methods')
		}
]

{ #category : 'accessing' }
McpCompileMethodTool >> name [
	^ 'compile-method'
]

{ #category : 'private' }
McpCompileMethodTool >> parseCategoryFrom: aLine [
	"Extract category from { #category : 'xxx' } header"
	| start end |
	start := aLine indexOf: $' ifAbsent: [ ^ nil ].
	end := aLine indexOf: $' startingAt: start + 1 ifAbsent: [ ^ nil ].
	^ aLine copyFrom: start + 1 to: end - 1
]

{ #category : 'private' }
McpCompileMethodTool >> parseMethodSpec: aString [
	"Split into { category. classReference. sourceCode }"
	| lines category rest parts |
	lines := aString lines.
	lines size < 2 ifTrue: [ Error signal: 'Method spec too short' ].
	category := self parseCategoryFrom: lines first.
	category ifNil: [ Error signal: 'Missing or malformed category header: ' , lines first ].
	rest := (String with: Character lf) join: lines allButFirst.
	parts := self split: rest at: ' >> ' otherwise: [ Error signal: 'Missing >> separator' ].
	^ { category. parts first withBlanksTrimmed. parts second }
]
