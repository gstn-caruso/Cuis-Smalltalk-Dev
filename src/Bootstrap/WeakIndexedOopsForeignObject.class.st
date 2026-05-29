Class {
	#name : 'WeakIndexedOopsForeignObject',
	#superclass : 'AllocatedForeignObject',
	#category : 'Bootstrap-Foreign Objects',
	#package : 'Bootstrap',
	#tag : 'Foreign Objects'
}

{ #category : 'subclass selection' }
WeakIndexedOopsForeignObject class >> canRepresent: anObject [
	"We can work classes that are indexable and that reference weakely, like WeakArray."

	^anObject class instSpec = 4
]

{ #category : 'accessing' }
WeakIndexedOopsForeignObject >> slotCount [
	"Answer the number of slots used by our representedObject"

	^representedObject basicSize
]

{ #category : 'accessing' }
WeakIndexedOopsForeignObject >> slotWidth [
	"Answer the size of each slot, in bytes, used by our representedObject.
	Answer nil. Our slots are oops."

	^nil
]

{ #category : 'accessing' }
WeakIndexedOopsForeignObject >> spurObjectFormat [
	"Answer the format 5 bit field for Object Header in Spur."

	^4
]
