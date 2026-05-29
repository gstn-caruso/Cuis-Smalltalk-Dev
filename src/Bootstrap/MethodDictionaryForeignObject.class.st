"
representedObject is nil.
We're not added to the ImageBuilder foreignObjects dictionary. But we are added to the foreignObjects list.
Any reference in a serialized object to a MethodDictionary must be handled specially and is most likely an error condition.
We do know all our MethodSpecs via their CompiledMethodForeignObjects.
No references to any object in the running image. This means we don't depend on the representation used in the image we're running in. We just need to know how to create a MethodDictionary in the format required for the new image.
Only when it is time to serialize ourselves in a new image, we gather all our methods and build suitable state for our new instance. This means that only at that moment we do #addForeignObjectFor: for the array.
"
Class {
	#name : 'MethodDictionaryForeignObject',
	#superclass : 'AllocatedForeignObject',
	#category : 'Bootstrap-Foreign Objects',
	#package : 'Bootstrap',
	#tag : 'Foreign Objects'
}

{ #category : 'subclass selection' }
MethodDictionaryForeignObject class >> canRepresent: anObject [
	"We can represent instances of 	MethodDictionary."

	^anObject class == MethodDictionary
]

{ #category : 'printing' }
MethodDictionaryForeignObject >> printRepresentedObjectOn: aStream [

]

{ #category : 'accessing' }
MethodDictionaryForeignObject >> slotCount [
	"Answer the number of slots used by our representedObject"

	^representedObject basicSize + representedObject class instSize
]

{ #category : 'accessing' }
MethodDictionaryForeignObject >> slotWidth [
	"Answer the size of each slot, in bytes, used by our representedObject.
	Answer nil. Our slots are oops."

	^nil
]

{ #category : 'accessing' }
MethodDictionaryForeignObject >> spurObjectFormat [
	"Answer the format 5 bit field for Object Header in Spur."

	^3
]

{ #category : 'serialization' }
MethodDictionaryForeignObject >> writeSlotsOn: byteStream forSpur: anImageBuilder [

	1 to: self slotCount do: [ :i | | each fo |
		each := representedObject instVarAt: i.
		fo := (each is: #ForeignObject)
			ifTrue: [ each ]
			ifFalse: [ anImageBuilder findForeignObjectFor: each ].
		anImageBuilder on: byteStream nexWordPut: (fo foreignOopFor: anImageBuilder) ].
]
