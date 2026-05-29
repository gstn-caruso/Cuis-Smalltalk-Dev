"
representedObject is MethodSpec.
We're not added to the ImageBuilder foreignObjects dictionary. But we are added to the foreignObjects list.
Any reference in a serialized object to a compiled method must be handled specially.
No references to any real CompiledMethod. This means we don't depend on the representation used in the image we're running in. We just need to know how to create method in the format required for the new image.
"
Class {
	#name : 'CompiledMethodForeignObject',
	#superclass : 'AllocatedForeignObject',
	#instVars : [
		'methodClassForeignObject'
	],
	#category : 'Bootstrap-Foreign Objects',
	#package : 'Bootstrap',
	#tag : 'Foreign Objects'
}

{ #category : 'subclass selection' }
CompiledMethodForeignObject class >> canRepresent: anObject [
	"We can represent instances of 	MethodSpec."

	^anObject class == MethodSpec
]

{ #category : 'compatibility' }
CompiledMethodForeignObject >> flushCache [
	"Needed to enable adding us to MethodDictionaries"
]

{ #category : 'accessing' }
CompiledMethodForeignObject >> methodClassForeignObject: aForeignObject [
	"Argument is either a ClassForeignObject or a MetaclassForeignObject"
	methodClassForeignObject := aForeignObject.
]

{ #category : 'printing' }
CompiledMethodForeignObject >> printRepresentedObjectOn: aStream [
	aStream nextPutAll: representedObject classSpec name.
	representedObject isClassSide ifTrue: [
		aStream nextPutAll: ' class' ].
	aStream nextPutAll: '>>#'; nextPutAll: representedObject selector.
]

{ #category : 'accessing' }
CompiledMethodForeignObject >> representedObject: aLocalObject oop: newOop identityHash: newIdentityHash [
	super representedObject: aLocalObject oop: newOop identityHash: newIdentityHash.
	nameOfClassToInstantiate := #CompiledMethod
]

{ #category : 'accessing' }
CompiledMethodForeignObject >> slotCount [
	"Our number of slots depends also on the image format and builder.
	see #slotCountFor:
	"
	self shouldNotImplement
]

{ #category : 'accessing' }
CompiledMethodForeignObject >> slotCountFor: anImageBuilder [
	"Answer the number of slots used by our representedObject.
	Total number of bytes required by this CompiledMethod.
	Ask the imageBuilder. It depends on the image format!"

	^self usedBytesFor: anImageBuilder.
]

{ #category : 'accessing' }
CompiledMethodForeignObject >> slotWidth [
	"Answer the size of each slot, in bytes, used by our representedObject.
	Our slots are int8 or uint8."

	^1
]

{ #category : 'accessing' }
CompiledMethodForeignObject >> spurObjectFormatFor: aSpurImageBuilder [
	"Answer the format 5 bit field for Object Header in Spur.
	Use  or 3 2 low bits of size. Answer in #(24 25 26 27) for Spur32 and in #(24 25 26 27 28 29 30 31) for Spur64."

	| usedBytes oddBits bytesPerWord |
	usedBytes := self usedBytesFor: aSpurImageBuilder.
	bytesPerWord := aSpurImageBuilder wordSize.
	oddBits := ((usedBytes / bytesPerWord) ceiling * bytesPerWord) - usedBytes.
	^24 bitOr: oddBits
]

{ #category : 'accessing' }
CompiledMethodForeignObject >> usedBytesFor: anImageBuilder [
	"Answer the number of bytes used by our representedObject.
	Total number of bytes required by this CompiledMethod.
	Ask the imageBuilder. It depends on the image format!"
	
	^(representedObject spurNumLiterals + 1) * anImageBuilder wordSize
		+ representedObject bytecodes size
		+ 4.
]

{ #category : 'serialization' }
CompiledMethodForeignObject >> writeSlotsOn: byteStream forSpur: anImageBuilder [

	| classBinding methodSelectorForeignObject |

	"No habria que calcular esto? Es como que la Spec está atada a Spur, o a la imagen que la generó. Habrá que limpiar."
	anImageBuilder on: byteStream nexWordPut: (anImageBuilder foreignOopOfSmallInteger: representedObject header).

	"Regular literals (CompiledMethods have two special last literals, see below)"
	representedObject literals withIndexDo: [ :lit :i |
		(lit is: #LiteralVariableSpec)
			ifTrue: [
					"Add reference to variable binding:
					- the Association in the classPool (for class variables)
					- the Association in the SystemDictionary (for global variables)"
					(methodClassForeignObject localBindingOf: lit variableName for: anImageBuilder)
						ifNotNil: [ :assocForeignObject |
							"{'local binding'. lit variableName. assocForeignObject representedObject. assocForeignObject representedObject identityHash} print."
							anImageBuilder on: byteStream nexWordPut: (assocForeignObject foreignOopFor: anImageBuilder) ]
						ifNil: [
							(anImageBuilder findGlobalBindingNamed: lit variableName)
								ifNotNil: [ :assocForeignObject2 |
									"{'global binding'. lit variableName. assocForeignObject2 representedObject identityHash} print."
									anImageBuilder on: byteStream nexWordPut: (assocForeignObject2 foreignOopFor: anImageBuilder) ]
								ifNil: [
									self error: 'Could not bind variable name: ',  lit variableName printString ]]]
			ifFalse: [ | literalForeignObject |
				literalForeignObject := (lit is: #ForeignObject)
					ifTrue: [ lit halt: 'any? (shouldn"t)' ]
					ifFalse: [ anImageBuilder findForeignObjectFor: lit ].
				anImageBuilder on: byteStream nexWordPut: (literalForeignObject foreignOopFor: anImageBuilder) ]].

	"#penultimateLiteral, either method selector or an AdditionalMethodState that also holds Pragmas and/or Properties(Associations)"
	methodSelectorForeignObject := anImageBuilder findForeignObjectFor: representedObject selector.
	representedObject pragmaSpecs isEmpty
		ifTrue: [
			anImageBuilder on: byteStream nexWordPut: (methodSelectorForeignObject foreignOopFor: anImageBuilder) ]
		ifFalse: [ | additionalState additionalMethodStateForeignObject |
			"This assumes that the representation of AdditionalMethodState is the same as in the image we're running in.
			We may need to improve this for proper compatibility between different kinds of mother / child image.
			Same for Pragma."
			additionalState := AdditionalMethodState basicNew: representedObject pragmaSpecs size.
			additionalState selector: methodSelectorForeignObject.
			additionalState method: self.
			representedObject pragmaSpecs withIndexDo: [ :pragmaData :i |
				| pragma pragmaKeyword pragmaArguments |
				pragmaKeyword := pragmaData first.
				pragmaArguments := pragmaData copyFrom: 2 to: pragmaData size.
				"Or understand and implement!"
				self assert: pragmaArguments isLiteral.
				pragma := Pragma
					for: self
					selector: (anImageBuilder findOrAddLiteral: pragmaKeyword)
					arguments: (anImageBuilder findOrAddLiteral: pragmaArguments).
				additionalState basicAt: i put: (anImageBuilder createForeignObjectFor: pragma) ].
			additionalMethodStateForeignObject := anImageBuilder createForeignObjectFor: additionalState.
			anImageBuilder on: byteStream nexWordPut: (additionalMethodStateForeignObject foreignOopFor: anImageBuilder) ].

	"Last literal is #methodClass"
	self assert:({ClassForeignObject . MetaclassForeignObject} includes: 	methodClassForeignObject class).
	methodClassForeignObject class == ClassForeignObject ifTrue: [
		self assert: representedObject classSpec == methodClassForeignObject representedObject.
		self assert: (anImageBuilder findForeignObjectFor: representedObject classSpec) == methodClassForeignObject.
		"aClass binding"
		classBinding := anImageBuilder findGlobalBindingNamed: representedObject classSpec name.
		anImageBuilder on: byteStream nexWordPut: (classBinding foreignOopFor: anImageBuilder) ].
	methodClassForeignObject class == MetaclassForeignObject ifTrue: [
		self assert: representedObject classSpec == methodClassForeignObject thisClassForeignObject representedObject.
		self assert: (anImageBuilder findForeignObjectFor: representedObject classSpec) == methodClassForeignObject thisClassForeignObject.
		"aMetaclass binding"
		classBinding := anImageBuilder createForeignObjectFor: (Association key: nil value: methodClassForeignObject).
		anImageBuilder on: byteStream nexWordPut: (classBinding foreignOopFor: anImageBuilder) ].

	"Next add bytecodes"
	byteStream nextPutAll: representedObject bytecodes.

	"Method Trailer.
	Used for the source code pointer. See #setSourcePointer:
	Just zeros unless we add source code."
	byteStream nextPutAll: #(0 0 0 0).
]
