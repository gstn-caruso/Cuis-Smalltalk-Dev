Class {
	#name : 'McpReadMethodSourceTool',
	#superclass : 'McpTool',
	#category : 'McpServer-Tools',
	#package : 'McpServer',
	#tag : 'Tools'
}

{ #category : 'accessing' }
McpReadMethodSourceTool >> description [
	^ 'Read the source code of one or more methods. Specify each method as "ClassName>>selector" for instance-side or "ClassName class>>selector" for class-side.'
]

{ #category : 'executing' }
McpReadMethodSourceTool >> execute: args [
	| methodRefs |
	methodRefs := self decodeArrayParam: (args at: 'methods').
	^ self executeBatch: methodRefs action: [:ref | self sourceTextFor: ref]
]

{ #category : 'private' }
McpReadMethodSourceTool >> formatMethod: aCompiledMethod [
	| category |
	category := aCompiledMethod category.
	^ '{ #category : ''' , category , ''' }' , (String with: Character lf)
		, aCompiledMethod methodClass name , ' >> ' , aCompiledMethod sourceCode
]

{ #category : 'accessing' }
McpReadMethodSourceTool >> inputSchema [
	^ McpServer json: {
		'type' -> 'object'.
		'properties' -> {
			'methods' -> {
				'type' -> 'array'.
				'items' -> { 'type' -> 'string' }.
				'description' -> 'Array of method references in the form "ClassName>>selector" or "ClassName class>>selector"'
			}
		}.
		'required' -> #('methods')
	}
]

{ #category : 'accessing' }
McpReadMethodSourceTool >> name [
	^ 'read-method-source'
]

{ #category : 'private' }
McpReadMethodSourceTool >> sourceTextFor: ref [
	| parts theClass selector cm |
	parts := (self
		split: ref
		at: '>>'
		otherwise: [Error signal: 'Invalid method reference (expected ClassName>>selector): ' , ref]
	) collect: [:p | p withBlanksTrimmed].
	theClass := self resolveClassReference: parts first.
	selector := parts last asSymbol.
	cm := theClass compiledMethodAt: selector ifAbsent: [nil].
	cm ifNotNil: [^ self formatMethod: cm].
	cm := theClass lookupSelector: selector.
	cm ifNotNil: [
		Error signal: 'Method not found: ' , ref , '; but ' , cm methodClass name , ' >> ' , selector , ' exists in the hierarchy:' , (String with: Character lf)
			, (self formatMethod: cm)].
	Error signal: 'Method not found: ' , ref
]
