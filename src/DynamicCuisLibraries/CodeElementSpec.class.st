"
CodeElementSpec is an abstract class that groups classes that represent Smalltalk code. See subclasses for details.
"
Class {
	#name : 'CodeElementSpec',
	#superclass : 'Object',
	#category : 'DynamicCuisLibraries-Code Model',
	#package : 'DynamicCuisLibraries',
	#tag : 'Code Model'
}

{ #category : 'testing' }
CodeElementSpec >> is: aSymbol [
	^aSymbol == #CodeElementSpec or: [ super is: aSymbol]
]
