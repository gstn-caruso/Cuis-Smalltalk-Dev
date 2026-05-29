"
ImmediateForeignObjects represent objects that don't need to be created in the heap, as all the information required is encoded in the Oop.
"
Class {
	#name : 'ImmediateForeignObject',
	#superclass : 'ForeignObject',
	#category : 'Bootstrap-Foreign Objects',
	#package : 'Bootstrap',
	#tag : 'Foreign Objects'
}

{ #category : 'testing' }
ImmediateForeignObject class >> instancesAreForImmediateObjects [
	"Answer true if our instances represent objects that will not be allocated in a new image,
	because they will be immediate, and fully encoded in their OOP."

	^true
]

{ #category : 'instance creation' }
ImmediateForeignObject class >> newFor: aLocalObject [
	"Answer an instance of the correct subclass."

	^self new representedObject: aLocalObject
]

{ #category : 'accessing' }
ImmediateForeignObject >> foreignOopFor: anImageBuilder [
	"Oop (Object Pointer) to be used in the newly created image.
	Ask to Builder for it!"

	^self subclassResponsibility
]

{ #category : 'services' }
ImmediateForeignObject >> referencedObjectsDo: aBlock [
	"Evaluate aBlock for each object our representedObject points to.
	We don't reference any other objects."
]

{ #category : 'accessing' }
ImmediateForeignObject >> representedObject: aLocalObject [

	self subclassResponsibility
]
