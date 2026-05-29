Class {
	#name : 'IvarsAndIndexedOopsForeignObject',
	#superclass : 'AllocatedForeignObject',
	#category : 'Bootstrap-Foreign Objects',
	#package : 'Bootstrap',
	#tag : 'Foreign Objects'
}

{ #category : 'subclass selection' }
IvarsAndIndexedOopsForeignObject class >> canRepresent: anObject [
	"We can work classes that are indexable and also include instance variables,
		like BlockClosure and AdditionalMethodState.
	But not MethodDictionary or MethodContext."

	anObject class == MethodDictionary ifTrue: [ ^false ].
	anObject class == MethodContext ifTrue: [ ^false ].
	^anObject class instSpec = 3
]

{ #category : 'accessing' }
IvarsAndIndexedOopsForeignObject >> slotCount [
	"Answer the number of slots used by our representedObject"

	^representedObject basicSize + representedObject class instSize
]

{ #category : 'accessing' }
IvarsAndIndexedOopsForeignObject >> slotWidth [
	"Answer the size of each slot, in bytes, used by our representedObject.
	Answer nil. Our slots are oops."

	^nil
]

{ #category : 'accessing' }
IvarsAndIndexedOopsForeignObject >> spurObjectFormat [
	"Answer the format 5 bit field for Object Header in Spur."

	^3
]

{ #category : 'serialization' }
IvarsAndIndexedOopsForeignObject >> writeSlotsOn: byteStream forSpur: anImageBuilder [

	1 to: self slotCount do: [ :i | | each fo |
		each := representedObject instVarAt: i.
		fo := (each is: #ForeignObject)
			ifTrue: [ each ]
			ifFalse: [ anImageBuilder findForeignObjectFor: each ].
		anImageBuilder on: byteStream nexWordPut: (fo foreignOopFor: anImageBuilder) ].
]
