"
An ExternalVariable is a named variable in some module. The classic example is unix's errno, of type int, a.k.a. FFITypeSignedInt32.

Instance Variables
	module:	<ByteString>
	name:		<ByteString>
	type:		<ExternalAtomicType>

module
	- the name of the module containing the variable name

name
	- the name of the variable within the module

type
	- the type of the variable
"
Class {
	#name : 'ExternalVariable',
	#superclass : 'ExternalObject',
	#instVars : [
		'type',
		'name',
		'module'
	],
	#pools : [
		'FFIConstants'
	],
	#category : 'FFI-Kernel',
	#package : 'FFI',
	#tag : 'Kernel'
}

{ #category : 'instance creation' }
ExternalVariable class >> name: aName module: aModule type: aType [
	^self new
		name: aName
		module: aModule
		type: aType
]

{ #category : 'accessing' }
ExternalVariable >> module [
	^module
]

{ #category : 'accessing' }
ExternalVariable >> name [
	^name
]

{ #category : 'instance initialization' }
ExternalVariable >> name: aName module: aModule type: aType [

	handle := ExternalAddress new.
	name := aName.
	module := aModule.
	type := aType.
]

{ #category : 'accessing' }
ExternalVariable >> type [
	^type
]
