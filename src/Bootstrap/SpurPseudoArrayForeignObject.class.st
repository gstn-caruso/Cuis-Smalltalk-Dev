"
The Spur Class Table and Class Table Page objects ar pretty special. They are very much like a regular Smalltalk Array. But they are is not visible from the Smalltalk side. So, they are not an instance of any class. ClassIndex is set to 16, which is not a real class index and doesn't refer to any class.
See VMMaker SpurMemoryManager>>#arrayClassIndexPun.

However, our representedObject is a regular Array, that holds the required information (oops) that are needed to create the pseudo-Array in the image being built.

The purpose of this class is to create correctly these objects in a new Spur image.
"
Class {
	#name : 'SpurPseudoArrayForeignObject',
	#superclass : 'AllocatedForeignObject',
	#category : 'Bootstrap-Foreign Objects',
	#package : 'Bootstrap',
	#tag : 'Foreign Objects'
}

{ #category : 'printing' }
SpurPseudoArrayForeignObject >> printRepresentedObjectOn: aStream [

]

{ #category : 'accessing' }
SpurPseudoArrayForeignObject >> slotCount [
	"Answer the number of slots used by our representedObject.
	In the new image, we'll be a special object with an special class pointer"

	^representedObject basicSize
]

{ #category : 'accessing' }
SpurPseudoArrayForeignObject >> slotWidth [
	"Answer the size of each slot, in bytes, used by our representedObject.
	Answer nil. Our slots are oops."

	^nil
]

{ #category : 'accessing' }
SpurPseudoArrayForeignObject >> spurClassIndexFor: aSpurImageBuilder [
	"Not a regular Smalltalk object.
	See class comment."

	^ 16
]

{ #category : 'accessing' }
SpurPseudoArrayForeignObject >> spurObjectFormat [
	"Answer the format 5 bit field for Object Header in Spur."

	^2
]

{ #category : 'serialization' }
SpurPseudoArrayForeignObject >> writeSlotsOn: byteStream forSpur: anImageBuilder [

	representedObject do: [ :pageOrClassOrMetaclassForeignObjectOrNil | | fo |
		fo := pageOrClassOrMetaclassForeignObjectOrNil
			ifNil: [ anImageBuilder findForeignObjectFor: nil ].
		anImageBuilder on: byteStream nexWordPut: (fo foreignOopFor: anImageBuilder) ].
]
