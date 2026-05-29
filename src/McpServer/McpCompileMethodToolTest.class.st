Class {
	#name : 'McpCompileMethodToolTest',
	#superclass : 'McpTestCase',
	#category : 'McpServer-Tests',
	#package : 'McpServer',
	#tag : 'Tests'
}

{ #category : 'setUp/tearDown' }
McpCompileMethodToolTest >> setUp [
	super setUp.
	server registerTool: McpCompileMethodTool new
]

{ #category : 'tests' }
McpCompileMethodToolTest >> test001_CompileMethodInstanceSide [
	| response result text targetClass |
	self createClassNamed: #McpTestTarget.
	response := server dispatch:
		(self
			toolsCallRequest: 'compile-method'
			arguments:
				{'methods' -> {'{ #category : ''testing'' }
McpTestTarget >> foo
	^ 42'}}).

	result := response at: 'result'.
	text := (result at: 'content') first at: 'text'.
	targetClass := Smalltalk classNamed: 'McpTestTarget'.
	self assert: (text includesSubString: 'Compiled').
	self assert: (targetClass canUnderstand: #foo).
	self assert: targetClass new foo equals: 42
]

{ #category : 'tests' }
McpCompileMethodToolTest >> test002_CompileMethodClassSide [
	| response result text targetClass |
	self createClassNamed: #McpTestTarget.
	response := server dispatch:
		(self
			toolsCallRequest: 'compile-method'
			arguments:
				{'methods' -> {'{ #category : ''testing'' }
McpTestTarget class >> bar
	^ 99'}}).

	result := response at: 'result'.
	text := (result at: 'content') first at: 'text'.
	targetClass := Smalltalk classNamed: 'McpTestTarget'.
	self assert: (text includesSubString: 'Compiled').
	self assert: (targetClass class canUnderstand: #bar).
	self assert: targetClass bar equals: 99
]

{ #category : 'tests' }
McpCompileMethodToolTest >> test003_CompileMultipleMethods [
	| response targetClass |
	self createClassNamed: #McpTestTarget.
	response := server dispatch:
		(self
			toolsCallRequest: 'compile-method'
			arguments:
				{'methods' -> {
					'{ #category : ''testing'' }
McpTestTarget >> a
	^ 1'.
					'{ #category : ''testing'' }
McpTestTarget >> b
	^ 2'}}).

	targetClass := Smalltalk classNamed: 'McpTestTarget'.
	self assert: (targetClass canUnderstand: #a).
	self assert: (targetClass canUnderstand: #b).
	self assert: targetClass new a equals: 1.
	self assert: targetClass new b equals: 2
]

{ #category : 'tests' }
McpCompileMethodToolTest >> test004_CompileMethodBadClassName [
	| response result text |
	response := server dispatch:
		(self
			toolsCallRequest: 'compile-method'
			arguments:
				{'methods' -> {'{ #category : ''testing'' }
NoSuchClass99 >> foo
	^ 1'}}).

	result := response at: 'result'.
	text := (result at: 'content') first at: 'text'.
	self assert: (result at: 'isError') equals: true.
	self assert: (text includesSubString: 'NoSuchClass99')
]

{ #category : 'tests' }
McpCompileMethodToolTest >> test005_CompileMethodSyntaxError [
	| response result text |
	self createClassNamed: #McpTestTarget.
	response := server dispatch:
		(self
			toolsCallRequest: 'compile-method'
			arguments:
				{'methods' -> {'{ #category : ''testing'' }
McpTestTarget >> bad
	^ 1 ++'}}).

	result := response at: 'result'.
	text := (result at: 'content') first at: 'text'.
	self assert: (result at: 'isError') equals: true.
	self assert: (text includesSubString: 'ERROR')
]

{ #category : 'tests' }
McpCompileMethodToolTest >> test006_CompileMethodPartialSuccess [
	| response result text targetClass |
	self createClassNamed: #McpTestTarget.
	response := server dispatch:
		(self
			toolsCallRequest: 'compile-method'
			arguments:
				{'methods' -> {
					'{ #category : ''testing'' }
McpTestTarget >> good
	^ 7'.
					'{ #category : ''testing'' }
NoSuchClass99 >> bad
	^ 0'}}).

	result := response at: 'result'.
	text := (result at: 'content') first at: 'text'.
	targetClass := Smalltalk classNamed: 'McpTestTarget'.
	self assert: (result at: 'isError') equals: true.
	self assert: (text includesSubString: 'Compiled').
	self assert: (text includesSubString: 'NoSuchClass99').
	self assert: (targetClass canUnderstand: #good)
]

{ #category : 'tests' }
McpCompileMethodToolTest >> test007_CompileMethodMissingCategoryHeader [
	| response result text |
	self createClassNamed: #McpTestTarget.
	response := server dispatch:
		(self
			toolsCallRequest: 'compile-method'
			arguments:
				{'methods' -> {'McpTestTarget >> foo
	^ 1'}}).

	result := response at: 'result'.
	text := (result at: 'content') first at: 'text'.
	self assert: (result at: 'isError') equals: true.
	self assert: (text includesSubString: 'category')
]

{ #category : 'tests' }
McpCompileMethodToolTest >> test008_CompileMethodWithDoubleEncodedArray [
	| response result text targetClass |
	self createClassNamed: #McpTestTarget.
	response := server dispatch:
		(self
			toolsCallRequest: 'compile-method'
			arguments:
				{'methods' -> (Json render: {'{ #category : ''accessing'' }
McpTestTarget >> foo
	^ 42'})}).

	result := response at: 'result'.
	text := (result at: 'content') first at: 'text'.
	targetClass := Smalltalk classNamed: 'McpTestTarget'.
	self assert: (text includesSubString: 'Compiled').
	self assert: (targetClass canUnderstand: #foo).
	self assert: targetClass new foo equals: 42
]

{ #category : 'tests' }
McpCompileMethodToolTest >> test009_CompileMethodReportsFullKeywordSelector [
	| response result text |
	self createClassNamed: #McpTestTarget.
	response := server dispatch:
		(self
			toolsCallRequest: 'compile-method'
			arguments:
				{'methods' -> {'{ #category : ''testing'' }
McpTestTarget >> at: key put: value
	^ key -> value'}}).

	result := response at: 'result'.
	text := (result at: 'content') first at: 'text'.
	self assert: text equals: 'Compiled: McpTestTarget>>at:put:'.
]
