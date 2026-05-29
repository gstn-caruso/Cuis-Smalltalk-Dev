Class {
	#name : 'SmallFloat64ForeignObject',
	#superclass : 'ImmediateForeignObject',
	#category : 'Bootstrap-Foreign Objects',
	#package : 'Bootstrap',
	#tag : 'Foreign Objects'
}

{ #category : 'subclass selection' }
SmallFloat64ForeignObject class >> canRepresent: anObject [
	"Floats are handled in a special way. See #foreignObjectClassFor:"

	^super canRepresent: anObject
]

{ #category : 'accessing' }
SmallFloat64ForeignObject >> foreignIdentityHashFor: anImageBuilder [
	"IdentityHash to be used in the newly created image.
	Depends, as a minimum, on the image format. Perhaps the builder can know.
	Is it possible that some VMs answer differently? I guess not, but where is that contract written?"

	^self error: 'must implement?'
]

{ #category : 'accessing' }
SmallFloat64ForeignObject >> foreignOopFor: anImageBuilder [
	"The oop is computed by the builder, based on our represented object"

	^anImageBuilder foreignOopOfSmallFloat64: representedObject.
]

{ #category : 'accessing' }
SmallFloat64ForeignObject >> representedObject: aLocalObject [

	representedObject := aLocalObject.
	nameOfClassToInstantiate := #SmallFloat64.
]
