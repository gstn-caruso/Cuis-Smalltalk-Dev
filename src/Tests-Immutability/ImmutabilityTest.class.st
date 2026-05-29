Class {
	#name : 'ImmutabilityTest',
	#superclass : 'TestCase',
	#instVars : [
		'instVar1'
	],
	#category : 'Tests-Immutability',
	#package : 'Tests',
	#tag : 'Immutability'
}

{ #category : 'test support' }
ImmutabilityTest >> instVar1 [
	
	^instVar1
]

{ #category : 'test support' }
ImmutabilityTest >> instVar1: anObject [

	instVar1 := anObject 
]

{ #category : 'tests' }
ImmutabilityTest >> test01AnObjectCanBeMarkAsImmutable [

	| testObject |
	
	testObject := self class new.
	testObject beImmutable.
	
	self assert: testObject isImmutable
]

{ #category : 'tests' }
ImmutabilityTest >> test02beImmutableReturnsThePreviousMutableState [

	| testObject wasImmutable |
	
	testObject := self class new.
	wasImmutable := testObject beImmutable.
	
	self deny: wasImmutable
]

{ #category : 'tests' }
ImmutabilityTest >> test03ImmutableObjectCanBeTurnMutable [

	| testObject |
	
	testObject := self class new.
	testObject 
		beImmutable;
		beMutable.
	
	self deny: testObject isImmutable.
]

{ #category : 'tests' }
ImmutabilityTest >> test04beMutableReturnsThePreviousMutableState [

	| testObject wasImmutable |
	
	testObject := self class new.
	wasImmutable := testObject 
		beImmutable;
		beMutable.
	
	self assert: wasImmutable
]

{ #category : 'tests' }
ImmutabilityTest >> test05InstanceVariablesOfImmutableObjectsCanNotBeModified [

	| testObject newValue |
	
	testObject := self class new.
	testObject beImmutable.
	newValue := 'something'.
	
	self 
		should: [ testObject instVar1: newValue ]
		raise: ModificationForbidden 
		withExceptionDo: [ :modificationForbidden |
			self assert: testObject instVar1 isNil.
			self assert: ModificationForbidden messageText equals: modificationForbidden messageText.
			self assert: testObject == modificationForbidden object.
			self assert: (self class indexOfInstanceVariable: 'instVar1') equals: modificationForbidden fieldIndex.
			self assert: newValue equals: modificationForbidden newValue.
			self assert: #instVarAt:put: equals: modificationForbidden retrySelector ]
]

{ #category : 'tests' }
ImmutabilityTest >> test06retryModificationMutatesTheObjectIfMadeMutable [

	| testObject newValue |
	
	testObject := self class new.
	testObject beImmutable.
	newValue := 'something'.
	
	[ testObject instVar1: newValue ]
		on: ModificationForbidden 
		do: [ :modificationForbidden |
			testObject beMutable.
			modificationForbidden retryModification ].
		
	self assert: newValue equals: testObject instVar1 
]

{ #category : 'tests' }
ImmutabilityTest >> test07atPutInformsModificationForbiddenForImmutableObjects [

	| testObject newValue |
	
	testObject := Array new: 1.
	testObject beImmutable.
	newValue := 'something'.
	
	self 
		should: [ testObject at: 1 put: newValue ]
		raise: ModificationForbidden 
		withExceptionDo: [ :modificationForbidden |
			self assert: testObject first isNil.
			self assert: #at:put: equals: modificationForbidden retrySelector ]		
	
]

{ #category : 'tests' }
ImmutabilityTest >> test08retryModificationWorkAsExpectedWhenSentatPut [

	| testObject newValue |
	
	testObject := Array new: 1.
	testObject beImmutable.
	newValue := 'something'.
	
	[ testObject at: 1 put: newValue ]
		on: ModificationForbidden 
		do: [ :modificationForbidden |
			testObject beMutable.
			modificationForbidden retryModification ].
		
	self assert: newValue equals: testObject first
]

{ #category : 'tests' }
ImmutabilityTest >> test09basicAtPutInformsModificationForbiddenForImmutableObjects [

	| testObject newValue |
	
	testObject := Array new: 1.
	testObject beImmutable.
	newValue := 'something'.
	
	self 
		should: [ testObject basicAt: 1 put: newValue ]
		raise: ModificationForbidden 
		withExceptionDo: [ :modificationForbidden |
			self assert: testObject first isNil.
			self assert: #basicAt:put: equals: modificationForbidden retrySelector ]		
	
]

{ #category : 'tests' }
ImmutabilityTest >> test10rawBasicAtPutInformsModificationForbiddenForImmutableObjects [

	| testObject newValue |
	
	testObject := Array new: 1.
	testObject beImmutable.
	newValue := 'something'.
	
	self 
		should: [ testObject rawBasicAt: 1 put: newValue ]
		raise: ModificationForbidden 
		withExceptionDo: [ :modificationForbidden |
			self assert: testObject first isNil.
			self assert: #rawBasicAt:put: equals: modificationForbidden retrySelector ]		
	
]

{ #category : 'tests' }
ImmutabilityTest >> test11AnArray2DCanBeImmutable [

	| testObject newValue |
	
	testObject := Array2D height: 2 width: 2.
	testObject beImmutable.
	newValue := 'something'.
	
	self 
		should: [ testObject i: 1 j: 1 put: newValue ]
		raise: ModificationForbidden 
		withExceptionDo: [ :modificationForbidden |
			self assert: (testObject i: 1 j: 1) isNil.
			"Currently informs elements as the object to modify instead of the Array2D instance
			This should be changed but more work is needed and I'm not sure it is worth at this time - Hernan"
			self assert: #at:put: equals: modificationForbidden retrySelector.
			self assert: testObject elements == modificationForbidden object ]		
	
]

{ #category : 'tests' }
ImmutabilityTest >> test12retryModificationWorksAsExpectedWithAnArray2D [

	| testObject newValue |
	
	testObject := Array2D height: 2 width: 2.
	testObject beImmutable.
	newValue := 'something'.
	
	[ testObject i: 1 j: 1 put: newValue ]
		on: ModificationForbidden 
		do: [ :modificationForbidden |
			testObject beMutable.
			modificationForbidden retryModification ].
		
	self assert: newValue equals: (testObject i: 1 j: 1)		
	
]

{ #category : 'tests' }
ImmutabilityTest >> test13DictionariesCanBeImmutable [

	| testObject newValue |
	
	testObject := Dictionary new.
	testObject beImmutable.
	newValue := 'something'.
	
	self 
		should: [ testObject at: 1 put: newValue ]
		raise: ModificationForbidden 
		withExceptionDo: [ :modificationForbidden |
			self assert: (testObject at:1 ifAbsent: [ nil ]) isNil.
			"Currently informs the inst var array as the object to modify instead of the Dictionary instance
			This should be changed but more work is needed and I'm not sure it is worth at this time - Hernan"
			self assert: #at:put: equals: modificationForbidden retrySelector.
			self assert: testObject array == modificationForbidden object ]		
	
]

{ #category : 'tests' }
ImmutabilityTest >> test14retryModificationWorksAsExpectedWithDictionaries [

	| testObject newValue |
	
	testObject := Dictionary new.
	testObject beImmutable.
	newValue := 'something'.
	
	[ testObject at: 1 put: newValue ]
		on: ModificationForbidden 
		do: [ :modificationForbidden |
			testObject beMutable.
			modificationForbidden retryModification ].
		
	self assert: newValue equals: (testObject at: 1).
	self assert: 1 equals: testObject size		
	
]

{ #category : 'tests' }
ImmutabilityTest >> test15SetsCanBeImmutable [

	| testObject newValue |
	
	testObject := Set new.
	testObject beImmutable.
	newValue := 'something'.
	
	self 
		should: [ testObject add: newValue ]
		raise: ModificationForbidden 
		withExceptionDo: [ :modificationForbidden |
			self deny: (testObject includes: newValue).
			"Currently informs the inst var array as the object to modify instead of the Set instance
			This should be changed but more work is needed and I'm not sure it is worth at this time - Hernan"
			self assert: #at:put: equals: modificationForbidden retrySelector.
			self assert: testObject array == modificationForbidden object ]		
	
]

{ #category : 'tests' }
ImmutabilityTest >> test16retryModificationWorksAsExpectedWithSets [

	| testObject newValue |
	
	testObject := Set new.
	testObject beImmutable.
	newValue := 'something'.
	
	[ testObject add: newValue ]
		on: ModificationForbidden 
		do: [ :modificationForbidden |
			testObject beMutable.
			modificationForbidden retryModification ].
		
	self assert: (testObject includes: newValue).
	self assert: 1 equals: testObject size		
	
]

{ #category : 'tests' }
ImmutabilityTest >> test17OrderedCollectionsCanBeImmutable [

	| testObject newValue |
	
	testObject := OrderedCollection new.
	testObject beImmutable.
	newValue := 'something'.
	
	self 
		should: [ testObject add: newValue ]
		raise: ModificationForbidden 
		withExceptionDo: [ :modificationForbidden |
			self deny: (testObject includes: newValue).
			self assert: #instVarAt:put: equals: modificationForbidden retrySelector.
			self assert: testObject == modificationForbidden object ]		
	
]

{ #category : 'tests' }
ImmutabilityTest >> test18retryModificationWorksAsExpectedWithOrderedCollections [

	| testObject newValue |
	
	testObject := OrderedCollection new.
	testObject beImmutable.
	newValue := 'something'.
	
	[ testObject add: newValue ]
		on: ModificationForbidden 
		do: [ :modificationForbidden |
			testObject beMutable.
			modificationForbidden retryModification ].
		
	self assert: newValue equals: testObject first.
	self assert: 1 equals: testObject size		
	
]

{ #category : 'tests' }
ImmutabilityTest >> test19StringsCanBeImmutable [

	| testObject newValue |
	
	testObject := 'aString'.
	testObject beImmutable.
	newValue := $x.
	
	self 
		should: [ testObject at: 1 put: newValue ]
		raise: ModificationForbidden 
		withExceptionDo: [ :modificationForbidden |
			self assert: $a equals: testObject first.
			self assert: #at:put: equals: modificationForbidden retrySelector.
			self assert: testObject == modificationForbidden object ]		
	
]

{ #category : 'tests' }
ImmutabilityTest >> test20retryModificationWorksAsExpectedWithStrings [

	| testObject newValue |
	
	testObject := 'aString' asByteString.
	testObject beImmutable.
	newValue := $x.
	
	[ testObject at: 1 put: newValue ]
		on: ModificationForbidden 
		do: [ :modificationForbidden |
			testObject beMutable.
			modificationForbidden retryModification ].
		
	self assert: newValue equals: testObject first.
		
]

{ #category : 'tests' }
ImmutabilityTest >> test21InstVarAtPutSignalModificationForbiddenWhenObjectIsImmutable [

	| testObject newValue instVar1Index |
	
	testObject := self class new.
	testObject beImmutable.
	newValue := 'something'.
	instVar1Index := self class indexOfInstanceVariable: 'instVar1'.
	
	self 
		should: [ testObject instVarAt: instVar1Index put: newValue ]
		raise: ModificationForbidden 
		withExceptionDo: [ :modificationForbidden |
			self assert: (testObject instVarAt: instVar1Index) isNil.
			self assert: #instVarAt:put: equals: modificationForbidden retrySelector.
			self assert: testObject == modificationForbidden object ]			
]

{ #category : 'tests' }
ImmutabilityTest >> test22retyModificationWorksAsExpectedWithInstVarAtPut [

	| testObject newValue instVar1Index |
	
	testObject := self class new.
	testObject beImmutable.
	newValue := 'something'.
	instVar1Index := self class indexOfInstanceVariable: 'instVar1'.
	
	[ testObject instVarAt: instVar1Index put: newValue ]
		on: ModificationForbidden 
		do: [ :modificationForbidden |
			testObject beMutable.
			modificationForbidden retryModification ].
		
	self assert: newValue equals: (testObject instVarAt: instVar1Index).

]
