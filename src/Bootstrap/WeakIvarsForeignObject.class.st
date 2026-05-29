Class {
	#name : 'WeakIvarsForeignObject',
	#superclass : 'AllocatedForeignObject',
	#category : 'Bootstrap-Foreign Objects',
	#package : 'Bootstrap',
	#tag : 'Foreign Objects'
}

{ #category : 'subclass selection' }
WeakIvarsForeignObject class >> canRepresent: anObject [
	"We can work classes that have ivars and that reference weakely, like Ephemeron."

	^anObject class instSpec = 5
]

{ #category : 'accessing' }
WeakIvarsForeignObject >> slotCount [
	"Answer the number of slots used by our representedObject"

	^representedObject class instSize
]

{ #category : 'accessing' }
WeakIvarsForeignObject >> slotWidth [
	"Answer the size of each slot, in bytes, used by our representedObject.
	Answer nil. Our slots are oops."

	^nil
]

{ #category : 'accessing' }
WeakIvarsForeignObject >> spurObjectFormat [
	"Answer the format 5 bit field for Object Header in Spur."

	^5
]
