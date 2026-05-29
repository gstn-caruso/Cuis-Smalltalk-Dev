"
See class comment in ProtocolCatcher.

The only difference between ProtocolCatcher and ProtocolCatcher2 is that this is subclass of Object. This means it will not catch protocol inherited from Object. This is not usually a problem, and inspectors are more comfortable to use if the catcher is not that transparent.
"
Class {
	#name : 'ProtocolCatcher2',
	#superclass : 'Object',
	#instVars : [
		'realObject'
	],
	#classVars : [
		'Protocols',
		'Started'
	],
	#category : 'Goodies-Tools-Profiling',
	#package : 'Goodies',
	#tag : 'Tools-Profiling'
}

{ #category : 'services' }
ProtocolCatcher2 class >> clear [
	Protocols _ Dictionary new.
	Started _ false
]

{ #category : 'services' }
ProtocolCatcher2 class >> observedClasses [

	^Protocols keys
]

{ #category : 'instance creation' }
ProtocolCatcher2 class >> on: anObject [
	| catcher |
	catcher _ self new.
	catcher instVarNamed: 'realObject' put: anObject.
	^catcher
]

{ #category : 'services' }
ProtocolCatcher2 class >> protocolFor: aClass [

	^Protocols at: aClass
]

{ #category : 'services' }
ProtocolCatcher2 class >> start [
	Started _ true
]

{ #category : 'services' }
ProtocolCatcher2 class >> stop [
	Started _ false
]

{ #category : 'catching' }
ProtocolCatcher2 >> doesNotUnderstand: aMessage [

	| protocol object answer |
	Started ifTrue: [
		protocol _ Protocols at: realObject class ifAbsentPut: Set new.
		protocol add: aMessage selector ].
	realObject == self ifTrue: [
		self halt.
		^nil].
	object _ self realObject.
	answer _ aMessage sendTo: object.
	^answer == object 
		ifTrue: [ self ]
		ifFalse: [ answer ]
]

{ #category : 'services' }
ProtocolCatcher2 >> initialize [
	realObject _ self
]

{ #category : 'accessing' }
ProtocolCatcher2 >> realObject [
	realObject == self ifTrue: [^self halt].
	^realObject class == ProtocolCatcher2
		ifTrue: [ realObject realObject ]
		ifFalse: [ realObject ]
]
