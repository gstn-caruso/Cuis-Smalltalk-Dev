Extension { #name : 'SystemDictionary' }

{ #category : '*Network-Kernel' }
SystemDictionary >> clearExternalObjects [
	"Clear the array of objects that have been registered for use in non-Smalltalk code."
	"Smalltalk clearExternalObjects"

	ExternalObjectTable current clearExternalObjects

]

{ #category : '*Network-Kernel' }
SystemDictionary >> externalObjectAt: index ifAbsent: errorBlock [
	"Answer the externalObject at index, or the result of errorBlock if none."

	^ExternalObjectTable current externalObjectAt: index ifAbsent: errorBlock
]

{ #category : '*Network-Kernel' }
SystemDictionary >> externalObjects [
	"Return an array of objects that have been registered for use in non-Smalltalk code. Smalltalk objects should be referrenced by external code only via indirection through this array, thus allowing the objects to move during compaction. This array can be cleared when the VM re-starts, since variables in external code do not survive snapshots. Note that external code should not attempt to access a Smalltalk object, even via this mechanism, while garbage collection is in progress."
	"Note that this is just a copy of the array used by the VM."
	"Smalltalk externalObjects"

	^ExternalObjectTable current externalObjects

]

{ #category : '*Network-Kernel' }
SystemDictionary >> newExternalSemaphore [
	"Create and register a new Semaphore, and return an array containing itself and its index."

	^ExternalObjectTable current newExternalSemaphore
]

{ #category : '*Network-Kernel' }
SystemDictionary >> newExternalSemaphoreDo: aBlock  [
	"Create and register a new Semaphore, then evaluate aBlock with it and its index."

	^ExternalObjectTable current newExternalSemaphoreDo: aBlock
]

{ #category : '*Network-Kernel' }
SystemDictionary >> newExternalSemaphores: count  [
	"Create and register multiple Semaphores, and return an array containing the semaphores and their indexes in separate arrays."

	^ExternalObjectTable current newExternalSemaphores: count
]

{ #category : '*Network-Kernel' }
SystemDictionary >> registerExternalObject: anObject [
	"Register the given object in the external objects array and return its index. If it is already there, just return its index."

	^ExternalObjectTable current registerExternalObject: anObject
]

{ #category : '*Network-Kernel' }
SystemDictionary >> unregisterExternalObject: anObject [
	"Unregister the given object in the external objects array. Do nothing if it isn't registered."

	ExternalObjectTable current unregisterExternalObject: anObject
]

{ #category : '*Network-Kernel' }
SystemDictionary >> unregisterExternalObjects: aCollection [
	"Unregister the given objects from the external objects array. Do nothing if they aren't registered."

	ExternalObjectTable current unregisterExternalObjects: aCollection
]
