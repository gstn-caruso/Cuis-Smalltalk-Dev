"
representedObject is ClassSpec.
We are  added to the ImageBuilder foreignObjects dictionary, with the ClassSpec as key. This is useful for building the class hierarchy. But we are added to the foreignObjects list.
Any reference in a serialized object to a class must be handled specially.
No references to any real Class. This means we don't depend on the representation used in the image we're running in. We just need to know how to create the class in the format required for the new image.
"
Class {
	#name : 'ClassForeignObject',
	#superclass : 'AllocatedForeignObject',
	#instVars : [
		'metaclassForeignObject',
		'methodForeignObjects',
		'subclassForeignObjects',
		'methodDictForeignObject',
		'instanceVariablesForeignObject',
		'subclassesForeignObject',
		'nameForeignObject',
		'classPoolForeignObject',
		'sharedPoolsForeignObject'
	],
	#category : 'Bootstrap-Foreign Objects',
	#package : 'Bootstrap',
	#tag : 'Foreign Objects'
}

{ #category : 'accessing' }
ClassForeignObject >> addMethod: aMethodForeignObject [
	methodForeignObjects add: aMethodForeignObject 
]

{ #category : 'accessing' }
ClassForeignObject >> addSubclass: aClassForeignObject [
	subclassForeignObjects add: aClassForeignObject 
]

{ #category : 'accessing' }
ClassForeignObject >> classPoolForeignObject: aForeignObject [
	classPoolForeignObject := aForeignObject
]

{ #category : 'initialization' }
ClassForeignObject >> initialize [

	super initialize.
	methodForeignObjects := OrderedCollection new.
	subclassForeignObjects := OrderedCollection new.
]

{ #category : 'accessing' }
ClassForeignObject >> instanceVariablesForeignObject: aForeignObject [
	instanceVariablesForeignObject := aForeignObject
]

{ #category : 'services' }
ClassForeignObject >> localBindingOf: varNameSymbol for: anImageBuilder [
	"Answer the foreign object for the Association that holds class var named as the argument.
	Answer nil if no such class variable.
	We assume that the class pool object is both valid here and in the new image. That means that
	Symbol >> #hash will answer the same in both. This is quite an assumption!"

	(classPoolForeignObject representedObject array representedObject  								"its #array"
			detect: [ :associationForeignObject |
				associationForeignObject notNil and: [
					associationForeignObject representedObject key
						= varNameSymbol ] ]
			ifNone: nil) ifNotNil: [ :bindingForeignObject |
				^ bindingForeignObject ].

	"Finally look higher up the superclass chain and fail at the end."
	^representedObject superclass ifNotNil: [ :superclassSpec |
		(anImageBuilder findForeignObjectFor: superclassSpec)
			localBindingOf: varNameSymbol for: anImageBuilder ]
]

{ #category : 'accessing' }
ClassForeignObject >> metaclassForeignObject [
	^metaclassForeignObject
]

{ #category : 'accessing' }
ClassForeignObject >> metaclassForeignObject: aMetaclassForeignObject [
	metaclassForeignObject := aMetaclassForeignObject
]

{ #category : 'accessing' }
ClassForeignObject >> methodDictForeignObject: aMethodDictionaryForeignObject [
	methodDictForeignObject := aMethodDictionaryForeignObject
]

{ #category : 'accessing' }
ClassForeignObject >> methodForeignObjects [
	^methodForeignObjects
]

{ #category : 'accessing' }
ClassForeignObject >> nameForeignObject: aForeignObject [
	nameForeignObject := aForeignObject
]

{ #category : 'printing' }
ClassForeignObject >> printRepresentedObjectOn: aStream [
	aStream nextPutAll: representedObject name.
]

{ #category : 'accessing' }
ClassForeignObject >> representedObject: aLocalObject oop: newOop identityHash: newIdentityHash [
	super representedObject: aLocalObject oop: newOop identityHash: newIdentityHash.
	nameOfClassToInstantiate := aLocalObject name, ' class'.
]

{ #category : 'accessing' }
ClassForeignObject >> sharedPoolsForeignObject: aForeignObject [
	sharedPoolsForeignObject := aForeignObject
]

{ #category : 'accessing' }
ClassForeignObject >> slotCount [
	"Answer the number of slots used by our representedObject"

	"Assuming standard representation in Cuis / Squeak.
	Refector as needed when this no longer true, to reflect the source code for the image being built!
	Class allInstVarNames size = 9"
	^ 9 + representedObject totalClassInstVarCountInSpec
]

{ #category : 'accessing' }
ClassForeignObject >> slotWidth [
	"Answer the size of each slot, in bytes, used by our representedObject.
	Answer nil. Our slots are oops."

	^nil
]

{ #category : 'accessing' }
ClassForeignObject >> spurClassIndexFor: aSpurImageBuilder [
	"We already know the foreign object for our metaclass"

	^metaclassForeignObject foreignIdentityHashFor: aSpurImageBuilder
]

{ #category : 'accessing' }
ClassForeignObject >> spurObjectFormat [
	"Answer the format 5 bit field for Object Header in Spur."

	^1
]

{ #category : 'accessing' }
ClassForeignObject >> subclassForeignObjects [
	^subclassForeignObjects
]

{ #category : 'accessing' }
ClassForeignObject >> subclassesForeignObject: aForeignObject [
	subclassesForeignObject := aForeignObject
]

{ #category : 'serialization' }
ClassForeignObject >> writeSlotsOn: byteStream forSpur: anImageBuilder [

	| superclassForeignObject format |

	"Superclass oop"
	superclassForeignObject := anImageBuilder findForeignObjectFor: representedObject superclass.
	anImageBuilder on: byteStream nexWordPut: (superclassForeignObject foreignOopFor: anImageBuilder).

	"methodDict oop"
	anImageBuilder on: byteStream nexWordPut: (methodDictForeignObject foreignOopFor: anImageBuilder).

	"format oop"
	 format := ClassBuilder new computeFormat: representedObject typeOfClass fullInstancesSize: representedObject allInstVarCountInSpec.
"Only valid when exactly cloning classes, and running on Spur too"
self assert: (Smalltalk at: representedObject name) format = format.
	anImageBuilder on: byteStream nexWordPut: (anImageBuilder foreignOopOfSmallInteger: format).

	"instanceVariables oop"
	anImageBuilder on: byteStream nexWordPut: (instanceVariablesForeignObject foreignOopFor: anImageBuilder).

	"organization oop"
	anImageBuilder on: byteStream nexWordPut: ((anImageBuilder findForeignObjectFor: nil) foreignOopFor: anImageBuilder).

	"subclasses oop"
	anImageBuilder on: byteStream nexWordPut: (subclassesForeignObject foreignOopFor: anImageBuilder).

	"name oop"
	anImageBuilder on: byteStream nexWordPut: (nameForeignObject foreignOopFor: anImageBuilder).

	"classPool oop"
	anImageBuilder on: byteStream nexWordPut: (classPoolForeignObject foreignOopFor: anImageBuilder).

	"sharedPools oop"
	anImageBuilder on: byteStream nexWordPut: (sharedPoolsForeignObject foreignOopFor: anImageBuilder).

	"class instance variables oops
	Initialize them to nil"
	representedObject classInstVarNames size timesRepeat: [
		anImageBuilder on: byteStream nexWordPut: ((anImageBuilder findForeignObjectFor: nil) foreignOopFor: anImageBuilder) ].
]
