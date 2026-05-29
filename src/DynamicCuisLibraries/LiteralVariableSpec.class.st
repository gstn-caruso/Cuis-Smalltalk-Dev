"
A LiteralVariableSpec represent a Class variable, SharedPool variable or Global variable.
It is stored in MethodSpec literals, instead of the original Association or ReadOnlyVariableBinding, that could refer to any Global or other object we'd rather not refer to from ClassSpec / MethodSpec.
"
Class {
	#name : 'LiteralVariableSpec',
	#superclass : 'CodeElementSpec',
	#instVars : [
		'variableName'
	],
	#category : 'DynamicCuisLibraries-Code Model',
	#package : 'DynamicCuisLibraries',
	#tag : 'Code Model'
}

{ #category : 'instance creation' }
LiteralVariableSpec class >> variableName: aSymbol [
	^self basicNew variableName: aSymbol
]

{ #category : 'testing' }
LiteralVariableSpec >> is: aSymbol [
	^aSymbol == #LiteralVariableSpec or: [ super is: aSymbol]
]

{ #category : 'printing' }
LiteralVariableSpec >> printOn: stream [

	stream nextPut: $[; nextPutAll: variableName class name ; nextPut: $ ; nextPutAll: 'literal spec -> '; nextPutAll: variableName; nextPut: $]
]

{ #category : 'accessing' }
LiteralVariableSpec >> variableName [
	^variableName
]

{ #category : 'private' }
LiteralVariableSpec >> variableName: aSymbol [
	variableName := aSymbol
]
