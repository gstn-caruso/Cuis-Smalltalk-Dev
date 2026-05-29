"
ExternalTypePuncuator is a general scheme for handling the specific case of a "..." optional/variadic arguments in an ExternalFunciton deifnition. Instances are created from definitions like this potential printf definition.

	printf: format with: arg1 with: arg2
		"int printf(const char *format, ...);"

		<cdecl: int32 'printf' (void* ... uint3264 uint3264)>
		^ self externalCallFailed

They are laid out like ExternalTypes so they can be parsed by the SqueakFFIPrims plugin when marshalling call-outs. But they do not function like types. See FFIFlagVariadic from FFIConstants.
"
Class {
	#name : 'ExternalTypePunctuator',
	#superclass : 'Object',
	#instVars : [
		'compiledSpec',
		'referentClass',
		'referencedType',
		'token'
	],
	#pools : [
		'FFIConstants'
	],
	#category : 'FFI-Kernel',
	#package : 'FFI',
	#tag : 'Kernel'
}

{ #category : 'testing' }
ExternalTypePunctuator >> isPointerType [
	^false
]

{ #category : 'testing' }
ExternalTypePunctuator >> isPunctuator [
	^true
]

{ #category : 'testing' }
ExternalTypePunctuator >> isVoid [
	^false
]

{ #category : 'printing' }
ExternalTypePunctuator >> printOn: aStream [
	token isSymbol ifFalse:
		[^super printOn: aStream].
	aStream nextPutAll: token
]

{ #category : 'accessing' }
ExternalTypePunctuator >> token [

	^ token
]

{ #category : 'accessing' }
ExternalTypePunctuator >> token: anObject [

	token := anObject.
	token == #'...' ifTrue:
		[compiledSpec := WordArray with: FFIFlagVariadic]
]
