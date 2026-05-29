"
representedObject is ClassSpec.
We're not added to the ImageBuilder foreignObjects dictionary. But we are added to the foreignObjects list.
Any reference in a serialized object to a metaclass must be handled specially.
No references to any real Metaclass. This means we don't depend on the representation used in the image we're running in. We just need to know how to create the Metaclass in the format required for the new image.
"
Class {
	#name : 'MetaclassForeignObject',
	#superclass : 'AllocatedForeignObject',
	#instVars : [
		'thisClassForeignObject',
		'methodForeignObjects',
		'methodDictForeignObject',
		'instanceVariablesForeignObject'
	],
	#category : 'Bootstrap-Foreign Objects',
	#package : 'Bootstrap',
	#tag : 'Foreign Objects'
}

{ #category : 'accessing' }
MetaclassForeignObject >> addMethod: aMethodForeignObject [
	methodForeignObjects add: aMethodForeignObject 
]

{ #category : 'initialization' }
MetaclassForeignObject >> initialize [

	super initialize.
	methodForeignObjects := OrderedCollection new.
]

{ #category : 'accessing' }
MetaclassForeignObject >> instanceVariablesForeignObject: aForeignObject [
	instanceVariablesForeignObject := aForeignObject
]

{ #category : 'services' }
MetaclassForeignObject >> localBindingOf: varNameSymbol for: anImageBuilder [

	^thisClassForeignObject localBindingOf: varNameSymbol for: anImageBuilder
]

{ #category : 'accessing' }
MetaclassForeignObject >> methodDictForeignObject: aMethodDictionaryForeignObject [
	methodDictForeignObject := aMethodDictionaryForeignObject
]

{ #category : 'accessing' }
MetaclassForeignObject >> methodForeignObjects [
	^methodForeignObjects
]

{ #category : 'printing' }
MetaclassForeignObject >> printRepresentedObjectOn: aStream [
	aStream nextPutAll: representedObject name.
	aStream nextPutAll: ' class'.
]

{ #category : 'accessing' }
MetaclassForeignObject >> representedObject: aLocalObject oop: newOop identityHash: newIdentityHash [
	super representedObject: aLocalObject oop: newOop identityHash: newIdentityHash.
	nameOfClassToInstantiate := #Metaclass
]

{ #category : 'accessing' }
MetaclassForeignObject >> slotCount [
	"Answer the number of slots used by our representedObject"

	"Assuming standard representation in Cuis / Squeak.
	Refector as needed when this no longer true, to reflect the source code for the image being built!
	Metaclass allInstVarNames size = 6"
	^ 6
]

{ #category : 'accessing' }
MetaclassForeignObject >> slotWidth [
	"Answer the size of each slot, in bytes, used by our representedObject.
	Answer nil. Our slots are oops."

	^nil
]

{ #category : 'accessing' }
MetaclassForeignObject >> spurObjectFormat [
	"Answer the format 5 bit field for Object Header in Spur."

	^1
]

{ #category : 'accessing' }
MetaclassForeignObject >> thisClassForeignObject [
	^thisClassForeignObject
]

{ #category : 'accessing' }
MetaclassForeignObject >> thisClassForeignObject: aClassForeignObject [
	thisClassForeignObject := aClassForeignObject
]

{ #category : 'serialization' }
MetaclassForeignObject >> writeSlotsOn: byteStream forSpur: anImageBuilder [

	| superclassForeignObject format |
	
	"Superclass oop"
	superclassForeignObject := representedObject superclass
		ifNotNil: [ :superclass | (anImageBuilder findForeignObjectFor: superclass) metaclassForeignObject]
		ifNil: [ anImageBuilder findClassNamed: #Class ].
	anImageBuilder on: byteStream nexWordPut: (superclassForeignObject foreignOopFor: anImageBuilder).

	"methodDict oop"
	anImageBuilder on: byteStream nexWordPut: (methodDictForeignObject foreignOopFor: anImageBuilder).

	"format oop"
	 format := ClassBuilder new computeFormat: #normal fullInstancesSize: thisClassForeignObject slotCount.
"Only valid when exactly cloning classes, and running on Spur too"
self assert: (Smalltalk at: representedObject name) class format = format.
	anImageBuilder on: byteStream nexWordPut: (anImageBuilder foreignOopOfSmallInteger: format).

	"instanceVariables oop"
	anImageBuilder on: byteStream nexWordPut: (instanceVariablesForeignObject foreignOopFor: anImageBuilder).

	"organization oop"
	anImageBuilder on: byteStream nexWordPut: ((anImageBuilder findForeignObjectFor: nil) foreignOopFor: anImageBuilder).

	"thisClass oop"
	anImageBuilder on: byteStream nexWordPut: (thisClassForeignObject foreignOopFor: anImageBuilder).
]
