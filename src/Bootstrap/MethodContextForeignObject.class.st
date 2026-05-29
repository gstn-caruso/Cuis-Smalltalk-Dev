Class {
	#name : 'MethodContextForeignObject',
	#superclass : 'AllocatedForeignObject',
	#category : 'Bootstrap-Foreign Objects',
	#package : 'Bootstrap',
	#tag : 'Foreign Objects'
}

{ #category : 'subclass selection' }
MethodContextForeignObject class >> canRepresent: anObject [

	anObject class == MethodContext ifTrue: [ ^true ].
	^false
]

{ #category : 'private' }
MethodContextForeignObject >> contextFrameSize [
	"Valid in mother image. We'd need to get correct value for any seed image."

	^ representedObject method
		ifNotNil: [ :method | method frameSize]
		ifNil: [CompiledMethod fullFrameSize]
]

{ #category : 'compatibility' }
MethodContextForeignObject >> isDone [
	"This is done so our Process instance is not taken for runnable processes.
	See #isTerminated	"
	^true
]

{ #category : 'accessing' }
MethodContextForeignObject >> slotCount [
	"Answer the number of slots used by our representedObject"

	^self contextFrameSize + representedObject class instSize
]

{ #category : 'accessing' }
MethodContextForeignObject >> slotWidth [
	"Answer the size of each slot, in bytes, used by our representedObject.
	Answer nil. Our slots are oops."

	^nil
]

{ #category : 'accessing' }
MethodContextForeignObject >> spurObjectFormat [
	"Answer the format 5 bit field for Object Header in Spur."

	^3
]

{ #category : 'serialization' }
MethodContextForeignObject >> writeSlotsOn: byteStream forSpur: anImageBuilder [

	| nilForeignObject |
	nilForeignObject := (anImageBuilder findForeignObjectFor: nil) foreignOopFor: anImageBuilder.
	"Instance variables"
	1 to: representedObject class instSize do: [ :i | | each fo |
		each := representedObject instVarAt: i.
		fo := (each is: #ForeignObject)
			ifTrue: [ each ]
			ifFalse: [ anImageBuilder findForeignObjectFor: each ].
		anImageBuilder on: byteStream nexWordPut: (fo foreignOopFor: anImageBuilder) ].
	"Frame pointers"
	1 to: representedObject basicSize do: [ :i | | each fo |
		each := representedObject basicAt: i.
		fo := (each is: #ForeignObject)
			ifTrue: [ each ]
			ifFalse: [ anImageBuilder findForeignObjectFor: each ].
		anImageBuilder on: byteStream nexWordPut: (fo foreignOopFor: anImageBuilder) ].
	"nil beyond knowable end of stack"
	self contextFrameSize - representedObject basicSize timesRepeat: [
		anImageBuilder on: byteStream nexWordPut: nilForeignObject ].
]
