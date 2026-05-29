Class {
	#name : 'DclBasicTest',
	#superclass : 'TestCase',
	#category : 'TestDynamicCuisLibraries-Tests',
	#package : 'TestDynamicCuisLibraries',
	#tag : 'Tests'
}

{ #category : 'testing' }
DclBasicTest >> testCodeModelExperiment [
	| lib oldClass newClass |
	Smalltalk at: #CodeModelExperiment ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
	oldClass := Noclash_CodeModelExperiment.
	lib := DynamicCuisLibrary
		withClasses: { oldClass name }
		classSelectors: #( #() )
		instanceSelectors: #( #( method01) ).
	self assert: lib canBeInstalled.
	lib installLibrary.
	newClass := Smalltalk at: #CodeModelExperiment.
	self assert: (oldClass compiledMethodAt: #method01) =
		(newClass compiledMethodAt: #method01).
	self assert: Noclash_CodeModelExperiment new method01 = newClass new method01.
	newClass removeFromSystemUnlogged.
]

{ #category : 'testing' }
DclBasicTest >> testFloatArray [
	| lib oldClass newClass |
	Smalltalk at: #Float32ArrayCodeModelExperiment ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
	oldClass := Noclash_Float32ArrayCodeModelExperiment.
	lib := DynamicCuisLibrary
		withClasses: { oldClass name }
		classSelectors: #( #() )
		instanceSelectors: #( #(floatAt: floatAt:put:) ).	
	self assert: lib canBeInstalled.
	lib installLibrary.
	newClass := Smalltalk at: #Float32ArrayCodeModelExperiment.
	self assert: (oldClass compiledMethodAt: #floatAt:) =
		(newClass compiledMethodAt: #floatAt:).
	self assert: ((newClass with: 1.23) + (newClass with: 2.77)) first = 4.0.
	self assert: (newClass with: 1.23 with: 2.77) sum = 4.0.
	newClass removeFromSystemUnlogged.
]

{ #category : 'testing' }
DclBasicTest >> testPoint [
	| lib oldClass newClass |
	Smalltalk at: #PointCodeModelExperiment ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
	oldClass := Noclash_PointCodeModelExperiment.
	lib := DynamicCuisLibrary
		withClasses: { oldClass name }
		classSelectors: #( #(x:y:) )
		instanceSelectors: #( #( initializePvtX:y: x y #printOn:) ).
	self assert: lib canBeInstalled.
	lib installLibrary.
	newClass := Smalltalk at: #PointCodeModelExperiment.
	self assert: (oldClass compiledMethodAt: #initializePvtX:y:) =
		(newClass compiledMethodAt: #initializePvtX:y:).
	self assert: (newClass x: 99 y: 86) printString = '99@86'.
	self assert: (newClass x: 99 y: 86) x = 99.
	self assert: (newClass x: 99 y: 86) y = 86.
	newClass removeFromSystemUnlogged.
]
