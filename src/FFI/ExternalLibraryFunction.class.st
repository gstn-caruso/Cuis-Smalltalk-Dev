"
An ExternalLibraryFunction specifies a fully qualified function from an external library.

Instance Variables
	errorCodeName:	<String | nil>
	errorReaper:		<ExternalLibraryFunction | ExternalVariable | nil>
	module:			<String | nil>
	name:			<String | Integer>

errorCodeName
	- name of temp receiving error code, if any

errorReaper
	- function or variable supplying an error code to be invoked immediately after the receivers function to collect any potential error before any potential preemtion point

module
	- name of module (nil if bound in the VM)

name
	- name or ordinal of function
"
Class {
	#name : 'ExternalLibraryFunction',
	#superclass : 'ExternalFunction',
	#instVars : [
		'name',
		'module',
		'errorReaper',
		'errorCodeName'
	],
	#category : 'FFI-Kernel',
	#package : 'FFI',
	#tag : 'Kernel'
}

{ #category : 'instance creation' }
ExternalLibraryFunction class >> name: aName module: aModule callType: callType returnType: retType argumentTypes: argTypes [
	^self new
		name: aName
		module: aModule
		flags: callType
		argTypes: (Array with: retType), argTypes
]

{ #category : 'comparing' }
ExternalLibraryFunction >> analogousCodeTo: anObject [
	^(anObject isKindOf: ExternalLibraryFunction)
	and: [flags = anObject flags
	and: [argTypes = anObject argTypes
	and: [self name = anObject name
	and: [self module = anObject module
	and: [errorCodeName = anObject errorCodeName]]]]]
]

{ #category : 'accessing' }
ExternalLibraryFunction >> errorCodeName [
	^errorCodeName
]

{ #category : 'accessing' }
ExternalLibraryFunction >> module [
	^(module is: #ByteArray)
		ifTrue: [UnicodeString fromUtf8Bytes: module]
		ifFalse: [module] 
]

{ #category : 'accessing' }
ExternalLibraryFunction >> name [
	^(name is: #ByteArray)
		ifTrue: [UnicodeString fromUtf8Bytes: name]
		ifFalse: [name] 
]

{ #category : 'private' }
ExternalLibraryFunction >> name: aName module: aModule flags: anInteger argTypes: argTypeArray [

	name := aName asUtf8BytesOrByteString.
	module := aModule ifNotNil: [ aModule asUtf8BytesOrByteString ].
	flags := anInteger.
	argTypes := argTypeArray.
]

{ #category : 'accessing' }
ExternalLibraryFunction >> setErrorCodeName: aString [
	errorCodeName := aString
]

{ #category : 'accessing' }
ExternalLibraryFunction >> setErrorReaper: anExternalLibraryFunctionOrNamedExternalDatumOrNil [
	"Set or clear the errorreaper"
	errorReaper := anExternalLibraryFunctionOrNamedExternalDatumOrNil.
	flags := anExternalLibraryFunctionOrNamedExternalDatumOrNil
				ifNil: [flags bitClear: FFICallFlagExternalFunctionHasErrorReaper]
				ifNotNil: [flags bitOr: FFICallFlagExternalFunctionHasErrorReaper]
]

{ #category : 'accessing' }
ExternalLibraryFunction >> setModule: aString [
	"Private. Hack the module"
	module := aString asUtf8BytesOrByteString
]
