"
I'm an enhanced version of JMM's ExternalSemaphoreTable.
I'm responsible for maintaining the externalObjectsArray, which can be found at slot 39 of Smalltalk specialObjectsArray. Manipulating the array directly is highly discouraged.

My services are available via the methods of the "external objects" category of SmalltalkImage.

To register anObject simply use Smalltalk registerExternalObject: anObject. Use #unregisterExternalObject: to unregister it. It your responsibility to always unregister these objects.
If you'd like the create one or more new Semaphores, and register them for external use, then you should use one of #newExternalSemaphore, #newExternalSemaphoreDo: and #newExternalSemaphores:. If you want to unregister more than one external objects at the same time, then #unregisterExternalObjects: is the method you're looking for.

Implementation details:
I maintain a single instance (#current), which can automatically synchronize with externalObjectsArray.
All accesses are protected by the semaphore instance variable.
To ensure fast access, I keep track of the indexes of the external objects in the externalObjectArray in my indexesByObjects IdentityDictionary.
To ensure fast insertion, I keep track of the free slots of the externalObjectsArray in the freeSlotIndexes OrderedCollection. The access pattern is LIFO to avoid unnecessary growth and reordering of the OrderedCollection.
I can grow the externalObjectsArray (see #ensureFreeSlot), but I never shrink it.
"
Class {
	#name : 'ExternalObjectTable',
	#superclass : 'Object',
	#instVars : [
		'semaphore',
		'externalObjectsArray',
		'freeSlotIndexes',
		'indexesByObjects'
	],
	#classInstVars : [
		'current'
	],
	#category : 'Network-Kernel',
	#package : 'Network',
	#tag : 'Kernel'
}

{ #category : 'initialize-release' }
ExternalObjectTable class >> cleanUp: aggressive [
	"It's safe to release the instance"

	self reset
]

{ #category : 'accessing' }
ExternalObjectTable class >> current [

	^current ifNil: [
		| newInstance |
		newInstance := self new.
		" Check again, because another process might have registered another instance. "
		current ifNil: [ current := newInstance ] ]
]

{ #category : 'accessing' }
ExternalObjectTable class >> reset [

	current := nil
]

{ #category : 'accessing' }
ExternalObjectTable >> clearExternalObjects [
	"Clear the array of objects that have been registered for use in non-Smalltalk code."

	semaphore critical: [
		Smalltalk specialObjectsArray at: 39 put: Array new.
		self 
			initializeCaches;
			synchronizeExternalObjectsArrayAndForceUpdate: true ]
]

{ #category : 'private' }
ExternalObjectTable >> ensureFreeSlot [
	"Make sure there's at least one free slot."

	| oldSize newSize newExternalObjectsArray specialObjectsArray |
	freeSlotIndexes isEmpty ifFalse: [ ^self ].
	oldSize := externalObjectsArray size.
	newSize := oldSize + 20. "Linear growth is not really a problem, because we never shrink the array."
	newExternalObjectsArray := externalObjectsArray species new: newSize.
	newExternalObjectsArray
		replaceFrom: 1
		to: oldSize
		with: externalObjectsArray
		startingAt: 1.
	specialObjectsArray := Smalltalk specialObjectsArray.
	(specialObjectsArray at: 39) == externalObjectsArray
		ifFalse: [
			"We're not in sync. Try again."
			^self
				synchronizeExternalObjectsArrayAndForceUpdate: true;
				ensureFreeSlot ].
	specialObjectsArray at: 39 put: newExternalObjectsArray.
	externalObjectsArray := newExternalObjectsArray.
	newSize to: oldSize + 1 by: -1 do: [ :each |
		freeSlotIndexes addFirst: each ].
	Smalltalk maxExternalSemaphores ifNotNil: [ :maxExternalSemaphores |
		"Make sure that those new external semaphores can be signaled by the VM. This is not entirely safe, but not incrementing at all is worse."
		newSize > maxExternalSemaphores ifTrue: [
			Smalltalk maxExternalSemaphores: newSize ] ]	

	
]

{ #category : 'accessing' }
ExternalObjectTable >> externalObjectAt: index ifAbsent: errorBlock [
	"Answer the externalObject at index, or the result of errorBlock if none."

	^(semaphore critical: [externalObjectsArray at: index ifAbsent: nil]) ifNil:
		[errorBlock value]
]

{ #category : 'accessing' }
ExternalObjectTable >> externalObjects [
	"Return a copy of the externalObjectsArray."

	^semaphore critical: [
		self synchronizeExternalObjectsArrayAndForceUpdate: false.
		externalObjectsArray copy ]
]

{ #category : 'private' }
ExternalObjectTable >> externalObjectsArray: anArray [
	"Update the index mapping using anArray as the new externalObjectsArray."

	externalObjectsArray := anArray.
	freeSlotIndexes reset.
	indexesByObjects removeAll.
	1 to: externalObjectsArray size do: [ :index |
		(anArray at: index) 
			ifNil: [ freeSlotIndexes addFirst: index ]
			ifNotNil: [ :object | indexesByObjects at: object put: index ] ]
]

{ #category : 'initialize-release' }
ExternalObjectTable >> initialize [

	semaphore := Semaphore forMutualExclusion.
	self initializeCaches
]

{ #category : 'private' }
ExternalObjectTable >> initializeCaches [

	freeSlotIndexes := OrderedCollection new.
	indexesByObjects := IdentityDictionary new
]

{ #category : 'accessing' }
ExternalObjectTable >> newExternalSemaphore [
	"Create and register a new Semaphore, and return an array containing itself and its index."

	| newSemaphore |
	^{
		newSemaphore := Semaphore new.
		semaphore critical: [
			self 
				synchronizeExternalObjectsArrayAndForceUpdate: false;
				safelyRegisterNewExternalObject: newSemaphore ] }
]

{ #category : 'accessing' }
ExternalObjectTable >> newExternalSemaphoreDo: aBlock [
	"Create and register a new Semaphore, then evaluate aBlock with it and its index."

	| newSemaphore |
	^aBlock
		value: (newSemaphore := Semaphore new)
		value: (semaphore critical: [
			self 
				synchronizeExternalObjectsArrayAndForceUpdate: false;
				safelyRegisterNewExternalObject: newSemaphore ])
]

{ #category : 'accessing' }
ExternalObjectTable >> newExternalSemaphores: count [
	"Create and register multiple Semaphores, and return an array containing the semaphores and their indexes in separate arrays."

	| semaphores indexes |
	semaphores := Array new: count.
	1 to: count do: [ :index | semaphores at: index put: Semaphore new ].
	indexes := Array new: count.
	semaphore critical: [
		self synchronizeExternalObjectsArrayAndForceUpdate: false.
		1 to: count do: [ :index |
			indexes at: index put: (
				self safelyRegisterNewExternalObject: (semaphores at: index)) ] ].
	^{ semaphores. indexes }
]

{ #category : 'accessing' }
ExternalObjectTable >> registerExternalObject: anObject [
	"Register the given object in the external objects array and return its index. If it is already there, just return its index."

	anObject ifNil: [ ^nil ].
	^semaphore critical: [
		self 
			synchronizeExternalObjectsArrayAndForceUpdate: false;
			safelyRegisterExternalObject: anObject ]
]

{ #category : 'private' }
ExternalObjectTable >> safelyRegisterExternalObject: anObject [

	| index |
	(index := indexesByObjects at: anObject ifAbsent: nil) ifNotNil: [
		(externalObjectsArray at: index) == anObject ifTrue: [ ^index ].
		"indexesByObjects is out of sync. Try again."
		^self
			synchronizeExternalObjectsArrayAndForceUpdate: true;
			safelyRegisterExternalObject: anObject ].
	^self safelyRegisterNewExternalObject: anObject
]

{ #category : 'private' }
ExternalObjectTable >> safelyRegisterNewExternalObject: anObject [

	| index |
	self ensureFreeSlot.
	index := freeSlotIndexes removeLast.
	(externalObjectsArray at: index) ifNotNil: [
		"Free slot is not empty. Try again."
		^self 
			synchronizeExternalObjectsArrayAndForceUpdate: true;
			safelyRegisterNewExternalObject: anObject ].
	externalObjectsArray at: index put: anObject.
	indexesByObjects at: anObject put: index.
	^index
]

{ #category : 'private' }
ExternalObjectTable >> safelyUnregisterExternalObject: anObject [

	(indexesByObjects removeKey: anObject ifAbsent: nil)
		ifNotNil: [ :index |
			(externalObjectsArray at: index) == anObject ifFalse: [
				"We're not in sync. Try again."
				^self
					synchronizeExternalObjectsArrayAndForceUpdate: true;
					safelyUnregisterExternalObject: anObject ].
			externalObjectsArray at: index put: nil.
			freeSlotIndexes add: index ]
		ifNil: [
			"Check if we're just out of sync."
			(externalObjectsArray statePointsTo: anObject) ifFalse: [ ^self ].
			"We're not in sync. Try again."
			^self
				synchronizeExternalObjectsArrayAndForceUpdate: true;
				safelyUnregisterExternalObject: anObject ]
]

{ #category : 'private' }
ExternalObjectTable >> synchronizeExternalObjectsArrayAndForceUpdate: forceUpdate [

	| actualExternalObjectsArray |
	actualExternalObjectsArray := Smalltalk specialObjectsArray at: 39.
	(actualExternalObjectsArray == externalObjectsArray and: [ forceUpdate not ])
		ifTrue: [ ^self ].
	self externalObjectsArray: actualExternalObjectsArray
]

{ #category : 'accessing' }
ExternalObjectTable >> unregisterExternalObject: anObject [
	"Unregister the given object from the external objects array. Do nothing if it isn't registered."

	anObject ifNil: [ ^self ].
	semaphore critical: [
		self 
			synchronizeExternalObjectsArrayAndForceUpdate: false;
			safelyUnregisterExternalObject: anObject ]
]

{ #category : 'accessing' }
ExternalObjectTable >> unregisterExternalObjects: aCollection [
	"Unregister the given objects from the external objects array. Do nothing if they aren't registered."

	semaphore critical: [
		self synchronizeExternalObjectsArrayAndForceUpdate: false.
		aCollection do: [ :each |
			each ifNotNil: [
				self safelyUnregisterExternalObject: each ] ] ]
]
