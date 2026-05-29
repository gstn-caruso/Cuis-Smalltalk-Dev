"
Protocol catchers use #doesNotUnderstand: to detect the protocol actually used for classes under study. The subject of study is classes, not particular objects. And all instances of ProtocolCatcher work as a team. The captured protocols are stored in a class variable. In this way, you can do the following, anytime, without worrying of keeping track of each instance of ProtocolCatcher:

"Standard way to change existing instances to catchers: As ivar realObject is initialized with self, after the #become: it points to the observed object, and it is the solely reference to it (at that moment!)"
| objects catchers |
ProtocolCatcher clear.
objects _ ParagraphEditor allSubInstances asArray.
catchers _ Array new: objects size.
1 to: catchers size do: [ :i |
	catchers at: i put: ProtocolCatcher new ].
objects elementsExchangeIdentityWith: catchers

The other way to use it is to replace 'ObservedClass new' to 'ProtocolCatcher on: ObservedClass new'. In this pattern, as there is no #become:, we must set the observed object explicitly.

After that you can use:

ProtocolCatcher clear
ProtocolCatcher start
ProtocolCatcher stop
ProtocolCatcher observedClasses
ProtocolCatcher protocolFor: ParagraphEditor

Finally, this class also serves as an example on how to do a ProtocolCatcher. Sometimes, when replacing an existing class in the system, it is useful to know the actually used protocol. But it can also be useful to keep the forwarding mechanism available after the new class has been installed. This way it is easier to add behavior that is still missing.
"
Class {
	#name : 'ProtocolCatcher',
	#superclass : 'ProtoObject',
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
ProtocolCatcher class >> clear [
	Protocols _ Dictionary new.
	Started _ false
]

{ #category : 'services' }
ProtocolCatcher class >> observedClasses [

	^Protocols keys
]

{ #category : 'instance creation' }
ProtocolCatcher class >> on: anObject [
	| catcher |
	catcher _ self new.
	catcher realObject: anObject.
	^catcher
]

{ #category : 'services' }
ProtocolCatcher class >> protocolFor: aClass [

	^Protocols at: aClass
]

{ #category : 'services' }
ProtocolCatcher class >> start [
	Started _ true
]

{ #category : 'services' }
ProtocolCatcher class >> stop [
	Started _ false
]

{ #category : 'catching' }
ProtocolCatcher >> doesNotUnderstand: aMessage [

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
ProtocolCatcher >> initialize [
	realObject _ self
]

{ #category : 'accessing' }
ProtocolCatcher >> realObject [
	realObject == self ifTrue: [^self halt].
	^realObject class == ProtocolCatcher
		ifTrue: [ realObject realObject ]
		ifFalse: [ realObject ]
]

{ #category : 'accessing' }
ProtocolCatcher >> realObject: anObject [
	realObject _ anObject
]
