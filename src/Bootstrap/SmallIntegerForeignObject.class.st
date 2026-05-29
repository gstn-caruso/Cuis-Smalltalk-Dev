Class {
	#name : 'SmallIntegerForeignObject',
	#superclass : 'ImmediateForeignObject',
	#category : 'Bootstrap-Foreign Objects',
	#package : 'Bootstrap',
	#tag : 'Foreign Objects'
}

{ #category : 'subclass selection' }
SmallIntegerForeignObject class >> canRepresent: anObject [
	"Integers are handled in a special way. See #foreignObjectClassFor:"

	^super canRepresent: anObject
]

{ #category : 'accessing' }
SmallIntegerForeignObject >> foreignIdentityHashFor: anImageBuilder [
	"IdentityHash to be used in the newly created image.
	SmallIntegers are always (?) their own identityHash."

	^representedObject
]

{ #category : 'accessing' }
SmallIntegerForeignObject >> foreignOopFor: anImageBuilder [
	"The oop is computed by the builder, based on our represented object"

	^anImageBuilder foreignOopOfSmallInteger: representedObject.
]

{ #category : 'accessing' }
SmallIntegerForeignObject >> representedObject: aLocalObject [

	representedObject := aLocalObject.
	nameOfClassToInstantiate := #SmallInteger.
]
