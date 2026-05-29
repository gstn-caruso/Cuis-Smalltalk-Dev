Class {
	#name : 'ImmediateCharacterForeignObject',
	#superclass : 'ImmediateForeignObject',
	#category : 'Bootstrap-Foreign Objects',
	#package : 'Bootstrap',
	#tag : 'Foreign Objects'
}

{ #category : 'subclass selection' }
ImmediateCharacterForeignObject class >> canRepresent: anObject [
	"Characters are handled in a special way. See #foreignObjectClassFor:"

	^super canRepresent: anObject
]

{ #category : 'accessing' }
ImmediateCharacterForeignObject >> foreignIdentityHashFor: anImageBuilder [
	"IdentityHash to be used in the newly created image.
	Depends, as a minimum, on the image format. Perhaps the builder can know.
	Is it possible that some VMs answer differently? I guess not, but where is that contract written?"

	^self error: 'must implement?'
]

{ #category : 'accessing' }
ImmediateCharacterForeignObject >> foreignOopFor: anImageBuilder [
	"The oop is computed by the builder, based on our represented object"

	^anImageBuilder foreignOopOfImmediateCharacter: representedObject.
]

{ #category : 'accessing' }
ImmediateCharacterForeignObject >> representedObject: aLocalObject [

	representedObject := aLocalObject.
	nameOfClassToInstantiate := #Character.
]
