"
AllocatedForeignObjects represent objects that are allocated in the heap.
"
Class {
	#name : 'AllocatedForeignObject',
	#superclass : 'ForeignObject',
	#instVars : [
		'oop',
		'identityHash',
		'nextInList'
	],
	#category : 'Bootstrap-Foreign Objects',
	#package : 'Bootstrap',
	#tag : 'Foreign Objects'
}

{ #category : 'testing' }
AllocatedForeignObject class >> instancesAreForImmediateObjects [
	"Answer true if our instances represent objects that will not be allocated in a new image,
	because they will be immediate, and fully encoded in their OOP."

	^false
]

{ #category : 'instance creation' }
AllocatedForeignObject class >> newFor: aLocalObject oop: newOop identityHash: newIdentityHash [
	"Answer an instance of the correct subclass."

	^self new representedObject: aLocalObject oop: newOop identityHash: newIdentityHash
]

{ #category : 'accessing' }
AllocatedForeignObject >> foreignIdentityHashFor: anImageBuilder [
	"IdentityHash to be used in the newly created image."

	^identityHash
]

{ #category : 'accessing' }
AllocatedForeignObject >> foreignOop: aNumber [
	oop := aNumber
]

{ #category : 'accessing' }
AllocatedForeignObject >> foreignOopFor: anImageBuilder [

	^oop
]

{ #category : 'accessing' }
AllocatedForeignObject >> nextInList [
	^nextInList
]

{ #category : 'accessing' }
AllocatedForeignObject >> nextInList: aForeignObject [
	nextInList := aForeignObject
]

{ #category : 'accessing' }
AllocatedForeignObject >> representedObject: aLocalObject oop: newOop identityHash: newIdentityHash [

	representedObject := aLocalObject.
	nameOfClassToInstantiate := aLocalObject class name.
	oop := newOop.
	identityHash := newIdentityHash.
	nextInList := nil.
]
