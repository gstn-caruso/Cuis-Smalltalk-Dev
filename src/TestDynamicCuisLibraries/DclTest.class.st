Class {
	#name : 'DclTest',
	#superclass : 'TestCase',
	#category : 'TestDynamicCuisLibraries-Tests',
	#package : 'TestDynamicCuisLibraries',
	#tag : 'Tests'
}

{ #category : 'class initialization' }
DclTest class >> initialize [

	Smalltalk at: #LogCompilerUse put: false.
	Smalltalk at: #CompilerWasUsed put: false.
]

{ #category : 'failing' }
DclTest >> expectedFailures [
	"Answer an array o selectors that are expected to fail.
	Usually this is done for tests that document incorrect behavior for which there is not yet a proper fix available."

	^CompiledMethod preferredBytecodeSetEncoderClass name == #EncoderForSistaV1
		ifTrue: [#()]
		ifFalse: [#(test08EExistingClassOldIvarMissingShouldConvertNewMethods)]
]

{ #category : 'setUp/tearDown' }
DclTest >> setUp [
	Smalltalk at: #LogCompilerUse put: true.
	Smalltalk at: #CompilerWasUsed put: false.
]

{ #category : 'setUp/tearDown' }
DclTest >> tearDown [
	LogCompilerUse := false
]

{ #category : 'tests 01' }
DclTest >> test01NewClass [
	"The library includes only a single class.
	Test creation of a simple class with a few instance variables and methods that access them"

	| sourceForLibrary lib installedFromLibrary |
	Smalltalk at: #DclExample01 ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
	sourceForLibrary := Noclash_DclExample01.
	lib := DynamicCuisLibrary
		withClasses: { sourceForLibrary }
		classSelectors: { sourceForLibrary class selectors }
		instanceSelectors: { sourceForLibrary selectors }.

	self assert: lib canBeInstalled.
	lib installLibrary.
	self deny: CompilerWasUsed description: 'Should not use Compiler. Usually it will not be available.'.

	installedFromLibrary := Smalltalk at: #DclExample01.
	self assert: installedFromLibrary superclass == Object.
	self assert: installedFromLibrary instVarNames equals: sourceForLibrary instVarNames.
	self assert: installedFromLibrary classVarNames equals: sourceForLibrary classVarNames.
	self assert: installedFromLibrary class instVarNames equals: sourceForLibrary class instVarNames.
	self assert: installedFromLibrary selectors equals: sourceForLibrary selectors.
	self assert: installedFromLibrary class selectors equals: sourceForLibrary class selectors.
	self assert: installedFromLibrary class >> #new equals: sourceForLibrary class >> #new.
	self assert: installedFromLibrary class >> #processor equals: sourceForLibrary class >> #processor.
	self assert: installedFromLibrary >> #initialize equals: sourceForLibrary >> #initialize.
	self assert: installedFromLibrary >> #a equals: sourceForLibrary >> #a.
	self assert: installedFromLibrary >> #b equals: sourceForLibrary >> #b.
	self assert: installedFromLibrary >> #c equals: sourceForLibrary >> #c.
	self assert: installedFromLibrary >> #combined equals: sourceForLibrary >> #combined.
	self assert: installedFromLibrary >> #maxVal equals: sourceForLibrary >> #maxVal.
	self assert: installedFromLibrary >> #someLiteral equals: sourceForLibrary >> #someLiteral.
	self assert: installedFromLibrary new combined equals: 123.
	self assert: installedFromLibrary new maxVal equals: SmallInteger maxVal.
	self assert: installedFromLibrary new someLiteral equals: sourceForLibrary new someLiteral.
	self assert: installedFromLibrary processor equals: Processor.
	installedFromLibrary setClassIVars.
	self assert: installedFromLibrary combinedCIvars equals: 57.

	installedFromLibrary removeFromSystemUnlogged.
]

{ #category : 'tests 02' }
DclTest >> test02ExistingClassSameShape [
	"The library includes only a single class.
	The class already exist before loading the library, and with the same shape.
	Any existing methods are exactly the same.
	Test that class shape and methods are healthy."

	| sourceForExisting existing sourceForLibrary lib installedFromLibrary |
	"Create pre-existing version of the class"
	Smalltalk at: #DclExample02 ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
	sourceForExisting := NoclashExisting_DclExample02.
	(DynamicCuisLibrary
		withClasses: { sourceForExisting }
		classSelectors: { sourceForExisting class selectors }
		instanceSelectors: { sourceForExisting selectors }) installLibrary.

	existing := Smalltalk at: #DclExample02.
	self assert: existing new combined equals: 47.
	self assert: existing new maxVal equals: SmallInteger maxVal-1.
	self assert: existing new someLiteral equals: #(22 33).
	self assert: existing processor equals: nil.
	existing setClassIVars.
	self assert: existing combinedCIvars equals: 7.

	"Create library"
	sourceForLibrary := Noclash_DclExample02.
	lib := DynamicCuisLibrary
		withClasses: { sourceForLibrary }
		classSelectors: { sourceForLibrary class selectors }
		instanceSelectors: { sourceForLibrary selectors }.

	self assert: lib canBeInstalled.
	lib installLibrary.
	self deny: CompilerWasUsed description: 'Should not use Compiler. Usually it will not be available.'.

	installedFromLibrary := Smalltalk at: #DclExample02.
	self assert: installedFromLibrary instVarNames equals: sourceForLibrary instVarNames.
	self assert: installedFromLibrary selectors asSet equals: (sourceForExisting selectors, sourceForLibrary selectors) asSet.
	self assert: installedFromLibrary class selectors equals: sourceForLibrary class selectors.
	self assert: installedFromLibrary class >> #new equals: sourceForLibrary class >> #new.
	self assert: installedFromLibrary class >> #processor equals: sourceForLibrary class >> #processor.
	self assert: installedFromLibrary >> #initialize equals: sourceForLibrary >> #initialize.
	self assert: installedFromLibrary >> #a equals: sourceForLibrary >> #a.
	self assert: installedFromLibrary >> #b equals: sourceForLibrary >> #b.
	self assert: installedFromLibrary >> #c equals: sourceForLibrary >> #c.
	self assert: (installedFromLibrary >> #combined) ~= (sourceForExisting >> #combined).
	self assert: installedFromLibrary >> #combined equals: sourceForLibrary >> #combined.
	self assert: installedFromLibrary >> #maxVal equals: sourceForLibrary >> #maxVal.
	self assert: installedFromLibrary >> #someLiteral equals: sourceForLibrary >> #someLiteral.
	self assert: installedFromLibrary new combined equals: 123.
	self assert: installedFromLibrary new maxVal equals: SmallInteger maxVal.
	self assert: installedFromLibrary new someLiteral equals: sourceForLibrary new someLiteral.
	self assert: installedFromLibrary processor equals: Processor.
	self assert: installedFromLibrary class instVarNames equals: sourceForLibrary class instVarNames.
	installedFromLibrary setClassIVars.
	self assert: installedFromLibrary combinedCIvars equals: 57.

	"Cleanup"
	Smalltalk at: #DclExample02 ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
]

{ #category : 'tests 03' }
DclTest >> test03AExistingClassNewClassIVars [
	"The existing class and its definition in the library differ in classInstanceVariables
	Installation should fail."

	| sourceForExisting existing sourceForLibrary lib |

	"Create pre-existing version of the class"
	Smalltalk at: #DclExample03 ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
	sourceForExisting := NoclashABCnoClassIvars_DclExample03.
	(DynamicCuisLibrary
		withClasses: { sourceForExisting }
		classSelectors: { sourceForExisting class selectors }
		instanceSelectors: { sourceForExisting selectors }) installLibrary.
	existing := Smalltalk at: #DclExample03.
	self assert: existing instVarNames equals: sourceForExisting instVarNames.
	self assert: existing class allClassInstVarNames equals: sourceForExisting class allClassInstVarNames.

	"Create library"
	sourceForLibrary := NoclashABC_DclExample03.
	lib := DynamicCuisLibrary
		withClasses: { sourceForLibrary }
		classSelectors: { sourceForLibrary class selectors }
		instanceSelectors: { sourceForLibrary selectors }.

	self deny: lib canBeInstalled.

	self deny: CompilerWasUsed description: 'Should not use Compiler. Usually it will not be available.'.

	Smalltalk at: #DclExample03 ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
]

{ #category : 'tests 03' }
DclTest >> test03AExistingClassNewIVarsExistingInstances [
	"The library adds an instance variable to a class that has existing instances.
	Installation should fail."

	| sourceForExisting existing sourceForLibrary lib anInstance |

	"Create pre-existing version of the class"
	Smalltalk at: #DclExample03 ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
	sourceForExisting := NoclashAB_DclExample03.
	(DynamicCuisLibrary
		withClasses: { sourceForExisting }
		classSelectors: { sourceForExisting class selectors }
		instanceSelectors: { sourceForExisting selectors }) installLibrary.
	existing := Smalltalk at: #DclExample03.
	self assert: existing instVarNames equals: sourceForExisting instVarNames.
	anInstance := existing new.
	self assert: anInstance combined equals: 79.

	"Create library"
	sourceForLibrary := NoclashABC_DclExample03.
	lib := DynamicCuisLibrary
		withClasses: { sourceForLibrary }
		classSelectors: { sourceForLibrary class selectors }
		instanceSelectors: { sourceForLibrary selectors }.

	self deny: lib canBeInstalled.
	"Ensure that the instance is still around"
	self assert: anInstance notNil.

	self deny: CompilerWasUsed description: 'Should not use Compiler. Usually it will not be available.'.

	Smalltalk at: #DclExample03 ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
]

{ #category : 'tests 03' }
DclTest >> test03BExistingClassNewIVarsShouldMerge [
	"The library adds an instance variable to a class.
	Installation should succeed.
	The new instance variable will be added after the existing ones."

	| sourceForExistingSuperclass sourceForExistingSubclass existingSuperclass existingSubclass
	 sourceForLibrary lib installedSuperclass installedSubclass |

	"Create pre-existing version of classes."
	Smalltalk at: #DclExample03Subclass ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
	Smalltalk at: #DclExample03 ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
	sourceForExistingSuperclass := NoclashAB_DclExample03.
	sourceForExistingSubclass := NoclashABD_DclExample03Subclass.
	(DynamicCuisLibrary
		withClasses: { sourceForExistingSuperclass. sourceForExistingSubclass }
		classSelectors: { sourceForExistingSuperclass class selectors. sourceForExistingSubclass class selectors }
		instanceSelectors: { sourceForExistingSuperclass selectors. sourceForExistingSubclass selectors }) installLibrary.
	existingSuperclass := Smalltalk at: #DclExample03.
	existingSubclass := Smalltalk at: #DclExample03Subclass.
	self assert: existingSuperclass allInstVarNames equals: #('a' 'b').
	self assert: existingSubclass allInstVarNames equals: #('a' 'b' 'd').
	self assert: existingSuperclass new b equals: 9.
	self assert: existingSuperclass new combined equals: 79.
	self assert: existingSubclass new b equals: 9.
	self assert: existingSubclass new d equals: 4.
	self assert: existingSubclass new combined equals: 794 + 79.

	"Create library"
	sourceForLibrary := NoclashABC_DclExample03.
	lib := DynamicCuisLibrary
		withClasses: { sourceForLibrary }
		classSelectors: { sourceForLibrary class selectors }
		instanceSelectors: { sourceForLibrary selectors }.

	self assert: lib canBeInstalled.
	lib installLibrary.
	self deny: CompilerWasUsed description: 'Should not use Compiler. Usually it will not be available.'.

	installedSuperclass := Smalltalk at: #DclExample03.
	installedSubclass := Smalltalk at: #DclExample03Subclass.
	self assert: installedSuperclass allInstVarNames equals: #('a' 'b' 'c').
	self assert: installedSubclass allInstVarNames equals: #('a' 'b' 'c' 'd').

	Smalltalk at: #DclExample03Subclass ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
	Smalltalk at: #DclExample03 ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
]

{ #category : 'tests 03' }
DclTest >> test03CExistingClassNewIVarsShouldConvertExistingMethods [
	"The library adds an instance variable to a class.
	Installation should succeed.
	The new instance variable will be added after the existing ones.
	Existing methods in the subclass should be converted to access the correct instance variables.
	Existing methods in the superclass should remain unchanged, as new instance variables are added at the end."

	| sourceForExistingSuperclass sourceForExistingSubclass existingSuperclass existingSubclass
	 sourceForLibrary lib installedSuperclass installedSubclass |

	"Create pre-existing version of classes."
	Smalltalk at: #DclExample03Subclass ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
	Smalltalk at: #DclExample03 ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
	sourceForExistingSuperclass := NoclashAB_DclExample03.
	sourceForExistingSubclass := NoclashABD_DclExample03Subclass.
	(DynamicCuisLibrary
		withClasses: { sourceForExistingSuperclass. sourceForExistingSubclass }
		classSelectors: { sourceForExistingSuperclass class selectors. sourceForExistingSubclass class selectors }
		instanceSelectors: { sourceForExistingSuperclass selectors. sourceForExistingSubclass selectors }) installLibrary.
	existingSuperclass := Smalltalk at: #DclExample03.
	existingSubclass := Smalltalk at: #DclExample03Subclass.
	self assert: existingSuperclass allInstVarNames equals: #('a' 'b').
	self assert: existingSubclass allInstVarNames equals: #('a' 'b' 'd').
	self assert: existingSuperclass new b equals: 9.
	self assert: existingSuperclass new combined equals: 79.
	self assert: existingSuperclass new xk47 equals: 'xk47'.
	self assert: existingSubclass new b equals: 9.
	self assert: existingSubclass new d equals: 4.
	self assert: existingSubclass new combined equals: 794 + 79.
	self assert: existingSubclass new xk47 equals: 'xk47'.

	"Create library"
	sourceForLibrary := NoclashABC_DclExample03.
	lib := DynamicCuisLibrary
		withClasses: { sourceForLibrary }
		classSelectors: { sourceForLibrary class selectors }
		instanceSelectors: { sourceForLibrary selectors }.

	self assert: lib canBeInstalled.
	lib installLibrary.
	self deny: CompilerWasUsed description: 'Should not use Compiler. Usually it will not be available.'.

	installedSuperclass := Smalltalk at: #DclExample03.
	installedSubclass := Smalltalk at: #DclExample03Subclass.

	self assert: installedSuperclass allInstVarNames equals: #('a' 'b' 'c').
	self assert: installedSubclass allInstVarNames equals: #('a' 'b' 'c' 'd').

	self assert: installedSuperclass selectors asSet equals:
		(sourceForExistingSuperclass selectors, sourceForLibrary selectors) asSet.
	self assert: installedSuperclass class selectors asSet equals:
		(sourceForExistingSuperclass class selectors, sourceForLibrary class selectors) asSet.
	self assert: installedSuperclass class >> #new equals: sourceForLibrary class >> #new.
	self assert: installedSuperclass >> #initialize equals: sourceForLibrary >> #initialize.
	self assert: installedSuperclass >> #a equals: sourceForLibrary >> #a.
	self assert: installedSuperclass >> #b equals: sourceForLibrary >> #b.
	self assert: installedSuperclass >> #c equals: sourceForLibrary >> #c.
	self deny: (installedSuperclass >> #combined) = (sourceForExistingSuperclass >> #combined).
	self assert: installedSuperclass >> #combined equals: sourceForLibrary >> #combined.
	self assert: installedSuperclass >> #maxVal equals: sourceForLibrary >> #maxVal.
	self assert: installedSuperclass >> #someLiteral equals: sourceForLibrary >> #someLiteral.
	self assert: installedSuperclass >> #xk47 equals: sourceForExistingSuperclass >> #xk47.

	self assert: installedSubclass selectors equals: sourceForExistingSubclass selectors.
	self assert: installedSubclass class selectors equals: sourceForExistingSubclass class selectors.
	self deny: (installedSubclass >> #initialize) = (sourceForExistingSubclass >> #initialize)
		description: 'Methods should be corrected for class shape due to new instance variable in superclass'.
	self deny: (installedSubclass >> #d) = (sourceForExistingSubclass >> #d)
		description: 'Methods should be corrected for class shape due to new instance variable in superclass'.
	self deny: (installedSubclass >> #combined) = (sourceForExistingSubclass >> #combined)
		description: 'Methods should be corrected for class shape due to new instance variable in superclass'.

	self assert: installedSuperclass new a equals: 1.
	self assert: installedSuperclass new b equals: 2.
	self assert: installedSuperclass new c equals: 3.
	self assert: installedSuperclass new combined equals: 123.
	self assert: installedSuperclass new maxVal equals: SmallInteger maxVal.
	self assert: installedSuperclass new someLiteral equals: sourceForLibrary new someLiteral.
	self assert: installedSuperclass new xk47 equals: 'xk47'.

	self assert: installedSubclass new a equals: 1.
	self assert: installedSubclass new b equals: 2.
	self assert: installedSubclass new c equals: 3.
	self assert: installedSubclass new d equals: 4.
	self assert: installedSubclass new combined equals: 124 + 123.
	self assert: installedSubclass new maxVal equals: SmallInteger maxVal.
	self assert: installedSubclass new someLiteral equals: sourceForLibrary new someLiteral.
	self assert: installedSubclass new xk47 equals: 'xk47'.

	Smalltalk at: #DclExample03Subclass ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
	Smalltalk at: #DclExample03 ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
]

{ #category : 'tests 03' }
DclTest >> test03DExistingClassOldIvarMissingShouldKeepShape [
	"The library is unaware of one of the instance variables in the existing class.
	Installation should succeed.
	Shape of the class should not change."

	| sourceForExistingSuperclass sourceForExistingSubclass existingSuperclass existingSubclass
	 sourceForLibrarySubclass lib installedSubclass |

	"Create pre-existing version of classes."
	Smalltalk at: #DclExample03Subclass ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
	Smalltalk at: #DclExample03 ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
	sourceForExistingSuperclass := NoclashABC_DclExample03.
	sourceForExistingSubclass := NoclashABCD_DclExample03Subclass.
	(DynamicCuisLibrary
		withClasses: { sourceForExistingSuperclass. sourceForExistingSubclass }
		classSelectors: { sourceForExistingSuperclass class selectors. sourceForExistingSubclass class selectors }
		instanceSelectors: { sourceForExistingSuperclass selectors. sourceForExistingSubclass selectors }) installLibrary.
	existingSuperclass := Smalltalk at: #DclExample03.
	existingSubclass := Smalltalk at: #DclExample03Subclass.
	self assert: existingSuperclass allInstVarNames equals: #('a' 'b' 'c').
	self assert: existingSubclass allInstVarNames equals: #('a' 'b' 'c' 'd').
	self assert: existingSuperclass new a equals: 1.
	self assert: existingSuperclass new b equals: 2.
	self assert: existingSuperclass new c equals: 3.
	self assert: existingSuperclass new combined equals: 123.
	self assert: existingSubclass new a equals: 1.
	self assert: existingSubclass new b equals: 2.
	self assert: existingSubclass new c equals: 3.
	self assert: existingSubclass new d equals: 4.
	self assert: existingSubclass new combined equals: 1234 + 123.

	"Create library. Class we are installed misses one instance variable."
	sourceForLibrarySubclass := NoclashABD_DclExample03Subclass.
	lib := DynamicCuisLibrary
		withClasses: { sourceForLibrarySubclass }
		classSelectors: { sourceForLibrarySubclass class selectors }
		instanceSelectors: { sourceForLibrarySubclass selectors }.
	
	self assert: lib canBeInstalled.
	lib installLibrary.
	self deny: CompilerWasUsed description: 'Should not use Compiler. Usually it will not be available.'.

	installedSubclass := Smalltalk at: #DclExample03Subclass.
	self assert: installedSubclass allInstVarNames equals: #('a' 'b' 'c' 'd').

	Smalltalk at: #DclExample03Subclass ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
	Smalltalk at: #DclExample03 ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
]

{ #category : 'tests 03' }
DclTest >> test03EExistingClassOldIvarMissingShouldConvertNewMethods [
	"The library is unaware of one of the instance variables in the existing class.
	Installation should succeed.
	Methods in the subclass that came from the library should be adjusted to access the correct instance variables,
		because they were created unaware of the 'missing' instance variable."

	| sourceForExistingSuperclass sourceForExistingSubclass existingSuperclass existingSubclass
	 sourceForLibrarySubclass lib installedSubclass |

	"Create pre-existing version of classes."
	Smalltalk at: #DclExample03Subclass ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
	Smalltalk at: #DclExample03 ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
	sourceForExistingSuperclass := NoclashABC_DclExample03.
	sourceForExistingSubclass := NoclashABCD_DclExample03Subclass.
	(DynamicCuisLibrary
		withClasses: { sourceForExistingSuperclass. sourceForExistingSubclass }
		classSelectors: { sourceForExistingSuperclass class selectors. sourceForExistingSubclass class selectors }
		instanceSelectors: { sourceForExistingSuperclass selectors. sourceForExistingSubclass selectors }) installLibrary.
	existingSuperclass := Smalltalk at: #DclExample03.
	existingSubclass := Smalltalk at: #DclExample03Subclass.
	self assert: existingSuperclass allInstVarNames equals: #('a' 'b' 'c').
	self assert: existingSubclass allInstVarNames equals: #('a' 'b' 'c' 'd').
	self assert: existingSuperclass new a equals: 1.
	self assert: existingSuperclass new b equals: 2.
	self assert: existingSuperclass new c equals: 3.
	self assert: existingSuperclass new combined equals: 123.
	self assert: existingSubclass new a equals: 1.
	self assert: existingSubclass new b equals: 2.
	self assert: existingSubclass new c equals: 3.
	self assert: existingSubclass new d equals: 4.
	self assert: existingSubclass new combined equals: 1234 + 123.

	"Create library. Class we are installed misses one instance variable (in the superclass actually).
	Neither class shape should be modified."
	sourceForLibrarySubclass := NoclashABD_DclExample03Subclass.
	lib := DynamicCuisLibrary
		withClasses: { sourceForLibrarySubclass }
		classSelectors: { sourceForLibrarySubclass class selectors }
		instanceSelectors: { sourceForLibrarySubclass selectors }.

	self assert: lib canBeInstalled.
	lib installLibrary.
	self deny: CompilerWasUsed description: 'Should not use Compiler. Usually it will not be available.'.

	installedSubclass := Smalltalk at: #DclExample03Subclass.
	self assert: existingSuperclass allInstVarNames equals: #('a' 'b' 'c').
	self assert: installedSubclass allInstVarNames equals: #('a' 'b' 'c' 'd').
	self assert: existingSuperclass new a equals: 1.
	self assert: existingSuperclass new b equals: 2.
	self assert: existingSuperclass new c equals: 3.
	self assert: existingSuperclass new combined equals: 123.
	self assert: installedSubclass new a equals: 1.
	self assert: installedSubclass new b equals: 2.
	self assert: installedSubclass new c equals: 3.
	self assert: installedSubclass new d equals: 4.
	self assert: installedSubclass new combined equals: 124 + 123.

	Smalltalk at: #DclExample03Subclass ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
	Smalltalk at: #DclExample03 ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
]

{ #category : 'tests 03' }
DclTest >> test03FExistingClassReorderedIVarsShouldConvertNewMethods [
	"The library adds an instance variable to a class.
	Installation should succeed.
	The new instance variable will be added after the existing ones.
	Existing methods in the subclass should be converted to access the correct instance variables."

	| sourceForExisting existingClass sourceForLibrary lib installedFromLibrary |

	"Create pre-existing version of the class."
	Smalltalk at: #DclExample03 ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
	sourceForExisting := NoclashACB_DclExample03.
	(DynamicCuisLibrary
		withClasses: { sourceForExisting }
		classSelectors: { sourceForExisting class selectors }
		instanceSelectors: { sourceForExisting selectors }) installLibrary.
	existingClass := Smalltalk at: #DclExample03.
	self assert: existingClass allInstVarNames equals: #('a' 'c' 'b').

	"Create library"
	sourceForLibrary := NoclashABC_DclExample03.
	lib := DynamicCuisLibrary
		withClasses: { sourceForLibrary }
		classSelectors: { sourceForLibrary class selectors }
		instanceSelectors: { sourceForLibrary selectors }.

	self assert: lib canBeInstalled.
	lib installLibrary.
	self deny: CompilerWasUsed description: 'Should not use Compiler. Usually it will not be available.'.

	installedFromLibrary := Smalltalk at: #DclExample03.

	self assert: installedFromLibrary allInstVarNames equals: #('a' 'c' 'b').
	self assert: installedFromLibrary new initialize2 a equals: 1.
	self assert: installedFromLibrary new initialize2 b equals: 2.
	self assert: installedFromLibrary new initialize2 c equals: 3.
	self assert: installedFromLibrary new initialize2 combined equals: 123.

	Smalltalk at: #DclExample03 ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
]

{ #category : 'tests 04' }
DclTest >> test04AExistingClassNewIVarsAlreadyInSuper [
	"The library includes an instance variable that is already defined in a superclass in the image.
	Installation should fail."

	| sourceForExisting existing sourceForLibrarySuperclass sourceForLibrarySubclass lib |

	"Create pre-existing version of the class"
	Smalltalk at: #DclExample04 ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
	sourceForExisting := NoclashABC_DclExample04.
	(DynamicCuisLibrary
		withClasses: { sourceForExisting }
		classSelectors: { {} }
		instanceSelectors: { {} }) installLibrary.
	existing := Smalltalk at: #DclExample04.
	self assert: existing instVarNames equals: sourceForExisting instVarNames.

	"Create library"
	sourceForLibrarySuperclass := NoclashAC_DclExample04.
	sourceForLibrarySubclass := NoclashB_DclExample04Sub.
	lib := DynamicCuisLibrary
		withClasses: { sourceForLibrarySuperclass.  sourceForLibrarySubclass }
		classSelectors: { {}. {} }
		instanceSelectors: { {}. {} }.

	self deny: lib canBeInstalled.
	self deny: CompilerWasUsed description: 'Should not use Compiler. Usually it will not be available.'.

	Smalltalk at: #DclExample04 ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
]

{ #category : 'tests 04' }
DclTest >> test04BExistingClassNewIVarsAlreadyInSub [
	"The library includes an instance variable that is already defined in a subclass in the image.
	Installation should fail."

	| sourceForExistingSuperclass sourceForExistingSubclass existingSuperclass existingSubclass sourceForLibrary lib |

	"Create pre-existing version of the classes"
	Smalltalk at: #DclExample04Sub ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
	Smalltalk at: #DclExample04 ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
	sourceForExistingSuperclass := NoclashAC_DclExample04.
	sourceForExistingSubclass := NoclashB_DclExample04Sub.
	(DynamicCuisLibrary
		withClasses: { sourceForExistingSuperclass.  sourceForExistingSubclass }
		classSelectors: { {}. {} }
		instanceSelectors: { {}. {} }) installLibrary.
	existingSuperclass := Smalltalk at: #DclExample04.
	existingSubclass := Smalltalk at: #DclExample04Sub.
	self assert: existingSuperclass instVarNames equals: sourceForExistingSuperclass instVarNames.
	self assert: existingSubclass instVarNames equals: sourceForExistingSubclass instVarNames.

	"Create library"
	sourceForLibrary := NoclashABC_DclExample04.
	lib := DynamicCuisLibrary
		withClasses: { sourceForLibrary }
		classSelectors: { {} }
		instanceSelectors: { {} }.

	self deny: lib canBeInstalled.
	self deny: CompilerWasUsed description: 'Should not use Compiler. Usually it will not be available.'.

	Smalltalk at: #DclExample04Sub ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
	Smalltalk at: #DclExample04 ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
]

{ #category : 'tests 05' }
DclTest >> test05ADifferentSuperclass [
	"Existing class in different hierarchy.
	Installation should fail."

	| lib |

	"Create pre-existing version of the class"
	Smalltalk at: #DclExample05 ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
	(DynamicCuisLibrary
		withClasses: { NoclashObject_DclExample05 }
		classSelectors: { {} }
		instanceSelectors: { {} }) installLibrary.

	"Create library"
	lib := DynamicCuisLibrary
		withClasses: { Noclash_DclExample05Super.  NoclashSub_DclExample05 }
		classSelectors: { {}. {} }
		instanceSelectors: { {}. {} }.

	self deny: lib canBeInstalled.
	self deny: CompilerWasUsed description: 'Should not use Compiler. Usually it will not be available.'.

	Smalltalk at: #DclExample05 ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
]

{ #category : 'tests 05' }
DclTest >> test05BDifferentSuperclass [
	"Existing class in different hierarchy.
	Installation should fail."

	| lib |

	"Create pre-existing version of the class"
	Smalltalk at: #DclExample05 ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
	(DynamicCuisLibrary
		withClasses: { NoclashProtoObject_DclExample05 }
		classSelectors: { {} }
		instanceSelectors: { {} }) installLibrary.

	"Create library"
	lib := DynamicCuisLibrary
		withClasses: { Noclash_DclExample05Super.  NoclashSub_DclExample05 }
		classSelectors: { {}. {} }
		instanceSelectors: { {}. {} }.

	self deny: lib canBeInstalled.
	self deny: CompilerWasUsed description: 'Should not use Compiler. Usually it will not be available.'.

	Smalltalk at: #DclExample05 ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
]

{ #category : 'tests 05' }
DclTest >> test05CDifferentSuperclass [
	"Existing class in different hierarchy.
	Installation should fail."

	| lib |

	"Create pre-existing version of the class"
	Smalltalk at: #DclExample05 ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
	Smalltalk at: #DclExample05Super ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
	(DynamicCuisLibrary
		withClasses: { Noclash_DclExample05Super.  NoclashSub_DclExample05 }
		classSelectors: { {}. {} }
		instanceSelectors: { {}. {} }) installLibrary.

	"Create library"
	lib := DynamicCuisLibrary
		withClasses: { NoclashObject_DclExample05 }
		classSelectors: { {} }
		instanceSelectors: { {} }.

	self deny: lib canBeInstalled.
	self deny: CompilerWasUsed description: 'Should not use Compiler. Usually it will not be available.'.

	Smalltalk at: #DclExample05 ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
	Smalltalk at: #DclExample05Super ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
]

{ #category : 'tests 05' }
DclTest >> test05DDifferentSuperclass [
	"Existing class in different hierarchy.
	Installation should fail."

	| lib |

	"Create pre-existing version of the class"
	Smalltalk at: #DclExample05 ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
	Smalltalk at: #DclExample05Super ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
	(DynamicCuisLibrary
		withClasses: { Noclash_DclExample05Super.  NoclashSub_DclExample05 }
		classSelectors: { {}. {} }
		instanceSelectors: { {}. {} }) installLibrary.

	"Create library"
	lib := DynamicCuisLibrary
		withClasses: { NoclashProtoObject_DclExample05 }
		classSelectors: { {} }
		instanceSelectors: { {} }.

	self deny: lib canBeInstalled.
	self deny: CompilerWasUsed description: 'Should not use Compiler. Usually it will not be available.'.

	Smalltalk at: #DclExample05 ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
	Smalltalk at: #DclExample05Super ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
]

{ #category : 'tests 05' }
DclTest >> test05EDifferentSuperclass [
	"Existing class in different hierarchy.
	Installation should fail."

	| lib |

	"Create pre-existing version of the class"
	Smalltalk at: #DclExample05 ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
	(DynamicCuisLibrary
		withClasses: { NoclashObject_DclExample05 }
		classSelectors: { {} }
		instanceSelectors: { {} }) installLibrary.
	(Smalltalk at: #DclExample05) superclass: nil.

	"Create library"
	lib := DynamicCuisLibrary
		withClasses: { NoclashObject_DclExample05 }
		classSelectors: { {} }
		instanceSelectors: { {} }.

	self deny: lib canBeInstalled.
	self deny: CompilerWasUsed description: 'Should not use Compiler. Usually it will not be available.'.

	Smalltalk at: #DclExample05 ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
]

{ #category : 'tests 05' }
DclTest >> test05FDifferentType [
	"Existing class is different type.
	Installation should fail."

	| lib |

	"Create pre-existing version of the class"
	Smalltalk at: #DclExample05 ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
	(DynamicCuisLibrary
		withClasses: { NoclashObject_DclExample05 }
		classSelectors: { {} }
		instanceSelectors: { {} }) installLibrary.

	"Create library"
	lib := DynamicCuisLibrary
		withClasses: { NoclashIndexed_DclExample05 }
		classSelectors: { {} }
		instanceSelectors: { {} }.
	self deny: lib canBeInstalled.
	self deny: CompilerWasUsed description: 'Should not use Compiler. Usually it will not be available.'.

	"Create library"
	lib := DynamicCuisLibrary
		withClasses: { NoclashByte_DclExample05 }
		classSelectors: { {} }
		instanceSelectors: { {} }.
	self deny: lib canBeInstalled.
	self deny: CompilerWasUsed description: 'Should not use Compiler. Usually it will not be available.'.

	"Create library"
	lib := DynamicCuisLibrary
		withClasses: { NoclashDoubleByte_DclExample05 }
		classSelectors: { {} }
		instanceSelectors: { {} }.
	self deny: lib canBeInstalled.
	self deny: CompilerWasUsed description: 'Should not use Compiler. Usually it will not be available.'.

	"Create library"
	lib := DynamicCuisLibrary
		withClasses: { NoclashWord_DclExample05 }
		classSelectors: { {} }
		instanceSelectors: { {} }.
	self deny: lib canBeInstalled.
	self deny: CompilerWasUsed description: 'Should not use Compiler. Usually it will not be available.'.

	"Create library"
	lib := DynamicCuisLibrary
		withClasses: { NoclashDoubleWord_DclExample05 }
		classSelectors: { {} }
		instanceSelectors: { {} }.
	self deny: lib canBeInstalled.
	self deny: CompilerWasUsed description: 'Should not use Compiler. Usually it will not be available.'.

	"Create library"
	lib := DynamicCuisLibrary
		withClasses: { NoclashWeak_DclExample05 }
		classSelectors: { {} }
		instanceSelectors: { {} }.
	self deny: lib canBeInstalled.
	self deny: CompilerWasUsed description: 'Should not use Compiler. Usually it will not be available.'.

	Smalltalk at: #DclExample05 ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
]

{ #category : 'tests 05' }
DclTest >> test05GDifferentType [
	"Existing class is different type.
	Installation should fail."

	| lib |

	"Create pre-existing version of the class"
	Smalltalk at: #DclExample05 ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
	(DynamicCuisLibrary
		withClasses: { NoclashIndexed_DclExample05 }
		classSelectors: { {} }
		instanceSelectors: { {} }) installLibrary.

	"Create library"
	lib := DynamicCuisLibrary
		withClasses: { NoclashObject_DclExample05 }
		classSelectors: { {} }
		instanceSelectors: { {} }.
	self deny: lib canBeInstalled.
	self deny: CompilerWasUsed description: 'Should not use Compiler. Usually it will not be available.'.

	"Create library"
	lib := DynamicCuisLibrary
		withClasses: { NoclashByte_DclExample05 }
		classSelectors: { {} }
		instanceSelectors: { {} }.
	self deny: lib canBeInstalled.
	self deny: CompilerWasUsed description: 'Should not use Compiler. Usually it will not be available.'.

	"Create library"
	lib := DynamicCuisLibrary
		withClasses: { NoclashDoubleByte_DclExample05 }
		classSelectors: { {} }
		instanceSelectors: { {} }.
	self deny: lib canBeInstalled.
	self deny: CompilerWasUsed description: 'Should not use Compiler. Usually it will not be available.'.

	"Create library"
	lib := DynamicCuisLibrary
		withClasses: { NoclashWord_DclExample05 }
		classSelectors: { {} }
		instanceSelectors: { {} }.
	self deny: lib canBeInstalled.
	self deny: CompilerWasUsed description: 'Should not use Compiler. Usually it will not be available.'.

	"Create library"
	lib := DynamicCuisLibrary
		withClasses: { NoclashDoubleWord_DclExample05 }
		classSelectors: { {} }
		instanceSelectors: { {} }.
	self deny: lib canBeInstalled.
	self deny: CompilerWasUsed description: 'Should not use Compiler. Usually it will not be available.'.

	"Create library"
	lib := DynamicCuisLibrary
		withClasses: { NoclashWeak_DclExample05 }
		classSelectors: { {} }
		instanceSelectors: { {} }.
	self deny: lib canBeInstalled.
	self deny: CompilerWasUsed description: 'Should not use Compiler. Usually it will not be available.'.

	Smalltalk at: #DclExample05 ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
]

{ #category : 'tests 05' }
DclTest >> test05HDifferentType [
	"Existing class is different type.
	Installation should fail."

	| lib |

	"Create pre-existing version of the class"
	Smalltalk at: #DclExample05 ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
	(DynamicCuisLibrary
		withClasses: { NoclashByte_DclExample05 }
		classSelectors: { {} }
		instanceSelectors: { {} }) installLibrary.

	"Create library"
	lib := DynamicCuisLibrary
		withClasses: { NoclashObject_DclExample05 }
		classSelectors: { {} }
		instanceSelectors: { {} }.
	self deny: lib canBeInstalled.
	self deny: CompilerWasUsed description: 'Should not use Compiler. Usually it will not be available.'.

	"Create library"
	lib := DynamicCuisLibrary
		withClasses: { NoclashIndexed_DclExample05 }
		classSelectors: { {} }
		instanceSelectors: { {} }.
	self deny: lib canBeInstalled.
	self deny: CompilerWasUsed description: 'Should not use Compiler. Usually it will not be available.'.

	"Create library"
	lib := DynamicCuisLibrary
		withClasses: { NoclashDoubleByte_DclExample05 }
		classSelectors: { {} }
		instanceSelectors: { {} }.
	self deny: lib canBeInstalled.
	self deny: CompilerWasUsed description: 'Should not use Compiler. Usually it will not be available.'.

	"Create library"
	lib := DynamicCuisLibrary
		withClasses: { NoclashWord_DclExample05 }
		classSelectors: { {} }
		instanceSelectors: { {} }.
	self deny: lib canBeInstalled.
	self deny: CompilerWasUsed description: 'Should not use Compiler. Usually it will not be available.'.

	"Create library"
	lib := DynamicCuisLibrary
		withClasses: { NoclashDoubleWord_DclExample05 }
		classSelectors: { {} }
		instanceSelectors: { {} }.
	self deny: lib canBeInstalled.
	self deny: CompilerWasUsed description: 'Should not use Compiler. Usually it will not be available.'.

	"Create library"
	lib := DynamicCuisLibrary
		withClasses: { NoclashWeak_DclExample05 }
		classSelectors: { {} }
		instanceSelectors: { {} }.
	self deny: lib canBeInstalled.
	self deny: CompilerWasUsed description: 'Should not use Compiler. Usually it will not be available.'.

	Smalltalk at: #DclExample05 ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
]

{ #category : 'tests 05' }
DclTest >> test05IDifferentType [
	"Existing class is different type.
	Installation should fail."

	| lib |

	"Create pre-existing version of the class"
	Smalltalk at: #DclExample05 ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
	(DynamicCuisLibrary
		withClasses: { NoclashDoubleByte_DclExample05 }
		classSelectors: { {} }
		instanceSelectors: { {} }) installLibrary.

	"Create library"
	lib := DynamicCuisLibrary
		withClasses: { NoclashObject_DclExample05 }
		classSelectors: { {} }
		instanceSelectors: { {} }.
	self deny: lib canBeInstalled.
	self deny: CompilerWasUsed description: 'Should not use Compiler. Usually it will not be available.'.

	"Create library"
	lib := DynamicCuisLibrary
		withClasses: { NoclashIndexed_DclExample05 }
		classSelectors: { {} }
		instanceSelectors: { {} }.
	self deny: lib canBeInstalled.
	self deny: CompilerWasUsed description: 'Should not use Compiler. Usually it will not be available.'.

	"Create library"
	lib := DynamicCuisLibrary
		withClasses: { NoclashByte_DclExample05 }
		classSelectors: { {} }
		instanceSelectors: { {} }.
	self deny: lib canBeInstalled.
	self deny: CompilerWasUsed description: 'Should not use Compiler. Usually it will not be available.'.

	"Create library"
	lib := DynamicCuisLibrary
		withClasses: { NoclashWord_DclExample05 }
		classSelectors: { {} }
		instanceSelectors: { {} }.
	self deny: lib canBeInstalled.
	self deny: CompilerWasUsed description: 'Should not use Compiler. Usually it will not be available.'.

	"Create library"
	lib := DynamicCuisLibrary
		withClasses: { NoclashDoubleWord_DclExample05 }
		classSelectors: { {} }
		instanceSelectors: { {} }.
	self deny: lib canBeInstalled.
	self deny: CompilerWasUsed description: 'Should not use Compiler. Usually it will not be available.'.

	"Create library"
	lib := DynamicCuisLibrary
		withClasses: { NoclashWeak_DclExample05 }
		classSelectors: { {} }
		instanceSelectors: { {} }.
	self deny: lib canBeInstalled.
	self deny: CompilerWasUsed description: 'Should not use Compiler. Usually it will not be available.'.

	Smalltalk at: #DclExample05 ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
]

{ #category : 'tests 05' }
DclTest >> test05JDifferentType [
	"Existing class is different type.
	Installation should fail."

	| lib |

	"Create pre-existing version of the class"
	Smalltalk at: #DclExample05 ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
	(DynamicCuisLibrary
		withClasses: { NoclashWord_DclExample05 }
		classSelectors: { {} }
		instanceSelectors: { {} }) installLibrary.

	"Create library"
	lib := DynamicCuisLibrary
		withClasses: { NoclashObject_DclExample05 }
		classSelectors: { {} }
		instanceSelectors: { {} }.
	self deny: lib canBeInstalled.
	self deny: CompilerWasUsed description: 'Should not use Compiler. Usually it will not be available.'.

	"Create library"
	lib := DynamicCuisLibrary
		withClasses: { NoclashIndexed_DclExample05 }
		classSelectors: { {} }
		instanceSelectors: { {} }.
	self deny: lib canBeInstalled.
	self deny: CompilerWasUsed description: 'Should not use Compiler. Usually it will not be available.'.

	"Create library"
	lib := DynamicCuisLibrary
		withClasses: { NoclashByte_DclExample05 }
		classSelectors: { {} }
		instanceSelectors: { {} }.
	self deny: lib canBeInstalled.
	self deny: CompilerWasUsed description: 'Should not use Compiler. Usually it will not be available.'.

	"Create library"
	lib := DynamicCuisLibrary
		withClasses: { NoclashDoubleByte_DclExample05 }
		classSelectors: { {} }
		instanceSelectors: { {} }.
	self deny: lib canBeInstalled.
	self deny: CompilerWasUsed description: 'Should not use Compiler. Usually it will not be available.'.

	"Create library"
	lib := DynamicCuisLibrary
		withClasses: { NoclashDoubleWord_DclExample05 }
		classSelectors: { {} }
		instanceSelectors: { {} }.
	self deny: lib canBeInstalled.
	self deny: CompilerWasUsed description: 'Should not use Compiler. Usually it will not be available.'.

	"Create library"
	lib := DynamicCuisLibrary
		withClasses: { NoclashWeak_DclExample05 }
		classSelectors: { {} }
		instanceSelectors: { {} }.
	self deny: lib canBeInstalled.
	self deny: CompilerWasUsed description: 'Should not use Compiler. Usually it will not be available.'.

	Smalltalk at: #DclExample05 ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
]

{ #category : 'tests 05' }
DclTest >> test05KDifferentType [
	"Existing class is different type.
	Installation should fail."

	| lib |

	"Create pre-existing version of the class"
	Smalltalk at: #DclExample05 ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
	(DynamicCuisLibrary
		withClasses: { NoclashDoubleWord_DclExample05 }
		classSelectors: { {} }
		instanceSelectors: { {} }) installLibrary.

	"Create library"
	lib := DynamicCuisLibrary
		withClasses: { NoclashObject_DclExample05 }
		classSelectors: { {} }
		instanceSelectors: { {} }.
	self deny: lib canBeInstalled.
	self deny: CompilerWasUsed description: 'Should not use Compiler. Usually it will not be available.'.

	"Create library"
	lib := DynamicCuisLibrary
		withClasses: { NoclashIndexed_DclExample05 }
		classSelectors: { {} }
		instanceSelectors: { {} }.
	self deny: lib canBeInstalled.
	self deny: CompilerWasUsed description: 'Should not use Compiler. Usually it will not be available.'.

	"Create library"
	lib := DynamicCuisLibrary
		withClasses: { NoclashByte_DclExample05 }
		classSelectors: { {} }
		instanceSelectors: { {} }.
	self deny: lib canBeInstalled.
	self deny: CompilerWasUsed description: 'Should not use Compiler. Usually it will not be available.'.

	"Create library"
	lib := DynamicCuisLibrary
		withClasses: { NoclashDoubleByte_DclExample05 }
		classSelectors: { {} }
		instanceSelectors: { {} }.
	self deny: lib canBeInstalled.
	self deny: CompilerWasUsed description: 'Should not use Compiler. Usually it will not be available.'.

	"Create library"
	lib := DynamicCuisLibrary
		withClasses: { NoclashWord_DclExample05 }
		classSelectors: { {} }
		instanceSelectors: { {} }.
	self deny: lib canBeInstalled.
	self deny: CompilerWasUsed description: 'Should not use Compiler. Usually it will not be available.'.

	"Create library"
	lib := DynamicCuisLibrary
		withClasses: { NoclashWeak_DclExample05 }
		classSelectors: { {} }
		instanceSelectors: { {} }.
	self deny: lib canBeInstalled.
	self deny: CompilerWasUsed description: 'Should not use Compiler. Usually it will not be available.'.

	Smalltalk at: #DclExample05 ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
]

{ #category : 'tests 05' }
DclTest >> test05LDifferentType [
	"Existing class is different type.
	Installation should fail."

	| lib |

	"Create pre-existing version of the class"
	Smalltalk at: #DclExample05 ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
	(DynamicCuisLibrary
		withClasses: { NoclashWeak_DclExample05 }
		classSelectors: { {} }
		instanceSelectors: { {} }) installLibrary.

	"Create library"
	lib := DynamicCuisLibrary
		withClasses: { NoclashObject_DclExample05 }
		classSelectors: { {} }
		instanceSelectors: { {} }.
	self deny: lib canBeInstalled.
	self deny: CompilerWasUsed description: 'Should not use Compiler. Usually it will not be available.'.

	"Create library"
	lib := DynamicCuisLibrary
		withClasses: { NoclashIndexed_DclExample05 }
		classSelectors: { {} }
		instanceSelectors: { {} }.
	self deny: lib canBeInstalled.
	self deny: CompilerWasUsed description: 'Should not use Compiler. Usually it will not be available.'.

	"Create library"
	lib := DynamicCuisLibrary
		withClasses: { NoclashByte_DclExample05 }
		classSelectors: { {} }
		instanceSelectors: { {} }.
	self deny: lib canBeInstalled.
	self deny: CompilerWasUsed description: 'Should not use Compiler. Usually it will not be available.'.

	"Create library"
	lib := DynamicCuisLibrary
		withClasses: { NoclashDoubleByte_DclExample05 }
		classSelectors: { {} }
		instanceSelectors: { {} }.
	self deny: lib canBeInstalled.
	self deny: CompilerWasUsed description: 'Should not use Compiler. Usually it will not be available.'.

	"Create library"
	lib := DynamicCuisLibrary
		withClasses: { NoclashWord_DclExample05 }
		classSelectors: { {} }
		instanceSelectors: { {} }.
	self deny: lib canBeInstalled.
	self deny: CompilerWasUsed description: 'Should not use Compiler. Usually it will not be available.'.

	"Create library"
	lib := DynamicCuisLibrary
		withClasses: { NoclashDoubleWord_DclExample05 }
		classSelectors: { {} }
		instanceSelectors: { {} }.
	self deny: lib canBeInstalled.
	self deny: CompilerWasUsed description: 'Should not use Compiler. Usually it will not be available.'.

	Smalltalk at: #DclExample05 ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
]

{ #category : 'tests 06' }
DclTest >> test06MissingGlobal [
	"Verify that unknown variables are created as Globals (not as Undeclared), with a nil value."

	| rsg lib installedFromLibrary |
	Smalltalk at: #DclExample06 ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
	Smalltalk removeKey: #DclExample06Global ifAbsent: nil.
	Smalltalk cleanOutUndeclared.

	Smalltalk at: #DclExample06Global put: 123.4.
	rsg := Smalltalk at: #LogCompilerUse.
	Smalltalk at: #LogCompilerUse put: false.
	Object subclass: #DclExample06
		instanceVariableNames: ''
		classVariableNames: ''
		poolDictionaries: ''
		category: 'TestDynamicCuisLibraries-Transient'.
	(Smalltalk at: #DclExample06) compile: 'a1 ^DclExample06Global'.
	Smalltalk at: #LogCompilerUse put: rsg.
	self assert: (Smalltalk at: #DclExample06) new a1 = 123.4.	

	"Create library"
	lib := DynamicCuisLibrary
		withClasses: { #DclExample06 }
		classSelectors: { {} }
		instanceSelectors: { {#a1} }.

	(Smalltalk at: #DclExample06) removeFromSystemUnlogged.
	Smalltalk removeKey: #DclExample06Global.
	Smalltalk cleanOutUndeclared.

	self deny: (Smalltalk includesKey: #DclExample06Global) description: 'Precondition for this test failed. Please check test itself.'.

	self assert: lib canBeInstalled.
	lib installLibrary.
	self deny: CompilerWasUsed description: 'Should not use Compiler. Usually it will not be available.'.

	installedFromLibrary := Smalltalk at: #DclExample06.
	self assert: (Smalltalk includesKey: #DclExample06Global) description: 'Global should have been created automatically on method materialization'.
	self assert: installedFromLibrary new a1 equals: nil.	
	Smalltalk at: #DclExample06Global put: 1234.56.
	self assert: installedFromLibrary new a1 equals: 1234.56.	

	Smalltalk at: #DclExample06 ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
	Smalltalk removeKey: #DclExample06Global ifAbsent: nil.
	Smalltalk cleanOutUndeclared.
]

{ #category : 'tests 06' }
DclTest >> test06NewClassVar [
	| sourceForExisting existing sourceForLibrary lib anInstance installedFromLibrary |

	"Create pre-existing version of the class"
	Smalltalk at: #DclExample06 ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
	sourceForExisting := NoclashABC_DclExample06.
	(DynamicCuisLibrary
		withClasses: { sourceForExisting }
		classSelectors: { sourceForExisting class selectors }
		instanceSelectors: { sourceForExisting selectors }) installLibrary.
	existing := Smalltalk at: #DclExample06.
	self assert: existing instVarNames equals: sourceForExisting instVarNames.
	self assert: existing selectors equals: sourceForExisting selectors.
	self assert: existing class selectors equals: existing class selectors.
	self assert: existing >> #initialize equals: sourceForExisting >> #initialize.
	self assert: existing >> #a equals: sourceForExisting >> #a.
	self assert: existing >> #b equals: sourceForExisting >> #b.
	self assert: existing >> #c equals: sourceForExisting >> #c.
	self assert: existing >> #combined equals: sourceForExisting >> #combined.
	self assert: existing >> #maxVal equals: sourceForExisting >> #maxVal.
	self assert: existing >> #someLiteral equals: sourceForExisting >> #someLiteral.

	anInstance := existing new.
	self assert: anInstance a equals: 1.
	self assert: anInstance b equals: 2.
	self assert: anInstance c equals: 3.
	self assert: anInstance combined equals: 123.
	self assert: anInstance maxVal equals: SmallInteger maxVal.
	self assert: anInstance someLiteral equals: NoclashABC_DclExample06 new someLiteral.

	"Create library"
	sourceForLibrary := NoclashABCclasVarZZ_DclExample06.
	lib := DynamicCuisLibrary
		withClasses: { sourceForLibrary }
		classSelectors: { sourceForLibrary class selectors }
		instanceSelectors: { sourceForLibrary selectors }.

	self assert: lib canBeInstalled.
	lib installLibrary.
	"Ensure that the instance is still around"
	self assert: anInstance notNil.
	self deny: CompilerWasUsed description: 'Should not use Compiler. Usually it will not be available.'.

	installedFromLibrary := Smalltalk at: #DclExample06.
	self assert: installedFromLibrary instVarNames equals: sourceForLibrary instVarNames.
	self assert: installedFromLibrary selectors asSet equals:
		(sourceForExisting selectors, sourceForLibrary selectors) asSet.
	self assert: installedFromLibrary class selectors asSet equals:
		(sourceForExisting class selectors, sourceForLibrary class selectors) asSet.
	self assert: installedFromLibrary >> #initialize equals: sourceForExisting >> #initialize.
	self assert: installedFromLibrary >> #a equals: sourceForExisting >> #a.
	self assert: installedFromLibrary >> #b equals: sourceForExisting >> #b.
	self assert: installedFromLibrary >> #c equals: sourceForExisting >> #c.
	self assert: installedFromLibrary >> #combined equals: sourceForExisting >> #combined.
	self assert: installedFromLibrary >> #maxVal equals: sourceForExisting >> #maxVal.
	self assert: installedFromLibrary >> #someLiteral equals: sourceForExisting >> #someLiteral.
	self assert: installedFromLibrary >> #setAndAnswerZZ equals: sourceForLibrary >> #setAndAnswerZZ.

	self assert: installedFromLibrary setAndAnswerZZ2 = 12742.
	self assert: anInstance setAndAnswerZZ = 1274.
	self assert: anInstance a equals: 1.
	self assert: anInstance b equals: 2.
	self assert: anInstance c equals: 3.
	self assert: anInstance combined equals: 123.
	self assert: anInstance maxVal equals: SmallInteger maxVal.
	self assert: anInstance someLiteral equals: NoclashABC_DclExample06 new someLiteral.

	Smalltalk at: #DclExample06 ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
]

{ #category : 'tests 07' }
DclTest >> test07CExistingClassNewIVarsShouldConvertExistingMethods [
	"The library adds an instance variable to a class.
	Installation should succeed.
	The new instance variable will be added after the existing ones.
	Existing methods in the subclass should be converted to access the correct instance variables.
	Existing methods in the superclass should remain unchanged, as new instance variables are added at the end.
	Similar to test03CExistingClassNewIVarsShouldConvertExistingMethods, but exercising the full 1 byte index range."

	| sourceForExistingSuperclass sourceForExistingSubclass existingSuperclass existingSubclass
	 sourceForLibrary lib installedSuperclass installedSubclass |

	"Create pre-existing version of classes."
	Smalltalk at: #DclExample07Subclass ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
	Smalltalk at: #DclExample07 ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
	sourceForExistingSuperclass := NoclashAB_DclExample07.
	sourceForExistingSubclass := NoclashABD_DclExample07Subclass.
	(DynamicCuisLibrary
		withClasses: { sourceForExistingSuperclass. sourceForExistingSubclass }
		classSelectors: { sourceForExistingSuperclass class selectors. sourceForExistingSubclass class selectors }
		instanceSelectors: { sourceForExistingSuperclass selectors. sourceForExistingSubclass selectors }) installLibrary.
	existingSuperclass := Smalltalk at: #DclExample07.
	existingSubclass := Smalltalk at: #DclExample07Subclass.
	self assert: existingSuperclass allInstVarNames equals: #('z1' 'z2' 'z3' 'z4' 'z5' 'z6' 'z7' 'z8' 'z9' 'a' 'b' 'a1' 'a2' 'a3' 'a4' 'a5' 'a6' 'a7' 'a8' 'a9' 'a10' 'a11' 'a12' 'a13' 'a14' 'a15' 'a16' 'a17' 'a18' 'a19' 'a20' 'a21' 'a22' 'a23' 'a24' 'a25' 'a26' 'a27' 'a28' 'a29' 'a30' 'a31' 'a32' 'a33' 'a34' 'a35' 'a36' 'a37' 'a38' 'a39' 'a40' 'a41' 'a42' 'a43' 'a44' 'a45' 'a46' 'a47' 'a48' 'a49' 'a50' 'a51' 'a52' 'a53' 'a54' 'a55' 'a56' 'a57' 'a58' 'a59' 'a60' 'a61' 'a62' 'a63' 'a64' 'a65' 'a66' 'a67' 'a68' 'a69' 'a70' 'a71' 'a72' 'a73' 'a74' 'a75' 'a76' 'a77' 'a78' 'a79' 'a80' 'a81' 'a82' 'a83' 'a84' 'a85' 'a86' 'a87' 'a88' 'a89' 'a90' 'a91' 'a92' 'a93' 'a94' 'a95' 'a96' 'a97' 'a98' 'a99' 'a100' 'a101' 'a102' 'a103' 'a104' 'a105' 'a106' 'a107' 'a108' 'a109' 'a110' 'a111' 'a112' 'a113' 'a114' 'a115' 'a116' 'a117' 'a118' 'a119' 'a120' 'a121' 'a122' 'a123' 'a124' 'a125' 'a126' 'a127' 'a128' 'a129' 'a130' 'a131' 'a132' 'a133' 'a134' 'a135' 'a136' 'a137' 'a138' 'a139' 'a140' 'a141' 'a142' 'a143' 'a144' 'a145' 'a146' 'a147' 'a148' 'a149' 'a150' 'a151' 'a152' 'a153' 'a154' 'a155' 'a156' 'a157' 'a158' 'a159' 'a160' 'a161' 'a162' 'a163' 'a164' 'a165' 'a166' 'a167' 'a168' 'a169' 'a170' 'a171' 'a172' 'a173' 'a174' 'a175' 'a176' 'a177' 'a178' 'a179' 'a180' 'a181' 'a182' 'a183' 'a184' 'a185' 'a186' 'a187' 'a188' 'a189' 'a190' 'a191' 'a192' 'a193' 'a194' 'a195' 'a196' 'a197' 'a198' 'a199' 'a200' 'a201' 'a202' 'a203' 'a204' 'a205' 'a206' 'a207' 'a208' 'a209' 'a210' 'a211' 'a212' 'a213' 'a214' 'a215' 'a216' 'a217' 'a218' 'a219' 'a220' 'a221' 'a222' 'a223' 'a224' 'a225' 'a226' 'a227' 'a228' 'a229' 'a230' 'a231' 'a232' 'a233' 'a234' 'a235' 'a236' 'a237' 'a238' 'a239' 'a240').
	self assert: existingSubclass allInstVarNames equals: #('z1' 'z2' 'z3' 'z4' 'z5' 'z6' 'z7' 'z8' 'z9' 'a' 'b' 'a1' 'a2' 'a3' 'a4' 'a5' 'a6' 'a7' 'a8' 'a9' 'a10' 'a11' 'a12' 'a13' 'a14' 'a15' 'a16' 'a17' 'a18' 'a19' 'a20' 'a21' 'a22' 'a23' 'a24' 'a25' 'a26' 'a27' 'a28' 'a29' 'a30' 'a31' 'a32' 'a33' 'a34' 'a35' 'a36' 'a37' 'a38' 'a39' 'a40' 'a41' 'a42' 'a43' 'a44' 'a45' 'a46' 'a47' 'a48' 'a49' 'a50' 'a51' 'a52' 'a53' 'a54' 'a55' 'a56' 'a57' 'a58' 'a59' 'a60' 'a61' 'a62' 'a63' 'a64' 'a65' 'a66' 'a67' 'a68' 'a69' 'a70' 'a71' 'a72' 'a73' 'a74' 'a75' 'a76' 'a77' 'a78' 'a79' 'a80' 'a81' 'a82' 'a83' 'a84' 'a85' 'a86' 'a87' 'a88' 'a89' 'a90' 'a91' 'a92' 'a93' 'a94' 'a95' 'a96' 'a97' 'a98' 'a99' 'a100' 'a101' 'a102' 'a103' 'a104' 'a105' 'a106' 'a107' 'a108' 'a109' 'a110' 'a111' 'a112' 'a113' 'a114' 'a115' 'a116' 'a117' 'a118' 'a119' 'a120' 'a121' 'a122' 'a123' 'a124' 'a125' 'a126' 'a127' 'a128' 'a129' 'a130' 'a131' 'a132' 'a133' 'a134' 'a135' 'a136' 'a137' 'a138' 'a139' 'a140' 'a141' 'a142' 'a143' 'a144' 'a145' 'a146' 'a147' 'a148' 'a149' 'a150' 'a151' 'a152' 'a153' 'a154' 'a155' 'a156' 'a157' 'a158' 'a159' 'a160' 'a161' 'a162' 'a163' 'a164' 'a165' 'a166' 'a167' 'a168' 'a169' 'a170' 'a171' 'a172' 'a173' 'a174' 'a175' 'a176' 'a177' 'a178' 'a179' 'a180' 'a181' 'a182' 'a183' 'a184' 'a185' 'a186' 'a187' 'a188' 'a189' 'a190' 'a191' 'a192' 'a193' 'a194' 'a195' 'a196' 'a197' 'a198' 'a199' 'a200' 'a201' 'a202' 'a203' 'a204' 'a205' 'a206' 'a207' 'a208' 'a209' 'a210' 'a211' 'a212' 'a213' 'a214' 'a215' 'a216' 'a217' 'a218' 'a219' 'a220' 'a221' 'a222' 'a223' 'a224' 'a225' 'a226' 'a227' 'a228' 'a229' 'a230' 'a231' 'a232' 'a233' 'a234' 'a235' 'a236' 'a237' 'a238' 'a239' 'a240' 'd').
	self assert: existingSuperclass new b equals: 9.
	self assert: existingSuperclass new combined equals: 79.
	self assert: existingSuperclass new xk47 equals: 'xk47'.
	self assert: existingSubclass new b equals: 9.
	self assert: existingSubclass new d equals: 4.
	self assert: existingSubclass new combined equals: 794 + 79.
	self assert: existingSubclass new xk47 equals: 'xk47'.

	"Create library"
	sourceForLibrary := NoclashABC_DclExample07.
	lib := DynamicCuisLibrary
		withClasses: { sourceForLibrary }
		classSelectors: { sourceForLibrary class selectors }
		instanceSelectors: { sourceForLibrary selectors }.

	self assert: lib canBeInstalled.
	lib installLibrary.
	self deny: CompilerWasUsed description: 'Should not use Compiler. Usually it will not be available.'.

	installedSuperclass := Smalltalk at: #DclExample07.
	installedSubclass := Smalltalk at: #DclExample07Subclass.

	self assert: installedSuperclass allInstVarNames equals: #('z1' 'z2' 'z3' 'z4' 'z5' 'z6' 'z7' 'z8' 'z9' 'a' 'b' 'a1' 'a2' 'a3' 'a4' 'a5' 'a6' 'a7' 'a8' 'a9' 'a10' 'a11' 'a12' 'a13' 'a14' 'a15' 'a16' 'a17' 'a18' 'a19' 'a20' 'a21' 'a22' 'a23' 'a24' 'a25' 'a26' 'a27' 'a28' 'a29' 'a30' 'a31' 'a32' 'a33' 'a34' 'a35' 'a36' 'a37' 'a38' 'a39' 'a40' 'a41' 'a42' 'a43' 'a44' 'a45' 'a46' 'a47' 'a48' 'a49' 'a50' 'a51' 'a52' 'a53' 'a54' 'a55' 'a56' 'a57' 'a58' 'a59' 'a60' 'a61' 'a62' 'a63' 'a64' 'a65' 'a66' 'a67' 'a68' 'a69' 'a70' 'a71' 'a72' 'a73' 'a74' 'a75' 'a76' 'a77' 'a78' 'a79' 'a80' 'a81' 'a82' 'a83' 'a84' 'a85' 'a86' 'a87' 'a88' 'a89' 'a90' 'a91' 'a92' 'a93' 'a94' 'a95' 'a96' 'a97' 'a98' 'a99' 'a100' 'a101' 'a102' 'a103' 'a104' 'a105' 'a106' 'a107' 'a108' 'a109' 'a110' 'a111' 'a112' 'a113' 'a114' 'a115' 'a116' 'a117' 'a118' 'a119' 'a120' 'a121' 'a122' 'a123' 'a124' 'a125' 'a126' 'a127' 'a128' 'a129' 'a130' 'a131' 'a132' 'a133' 'a134' 'a135' 'a136' 'a137' 'a138' 'a139' 'a140' 'a141' 'a142' 'a143' 'a144' 'a145' 'a146' 'a147' 'a148' 'a149' 'a150' 'a151' 'a152' 'a153' 'a154' 'a155' 'a156' 'a157' 'a158' 'a159' 'a160' 'a161' 'a162' 'a163' 'a164' 'a165' 'a166' 'a167' 'a168' 'a169' 'a170' 'a171' 'a172' 'a173' 'a174' 'a175' 'a176' 'a177' 'a178' 'a179' 'a180' 'a181' 'a182' 'a183' 'a184' 'a185' 'a186' 'a187' 'a188' 'a189' 'a190' 'a191' 'a192' 'a193' 'a194' 'a195' 'a196' 'a197' 'a198' 'a199' 'a200' 'a201' 'a202' 'a203' 'a204' 'a205' 'a206' 'a207' 'a208' 'a209' 'a210' 'a211' 'a212' 'a213' 'a214' 'a215' 'a216' 'a217' 'a218' 'a219' 'a220' 'a221' 'a222' 'a223' 'a224' 'a225' 'a226' 'a227' 'a228' 'a229' 'a230' 'a231' 'a232' 'a233' 'a234' 'a235' 'a236' 'a237' 'a238' 'a239' 'a240' 'c').
	self assert: installedSubclass allInstVarNames equals: #('z1' 'z2' 'z3' 'z4' 'z5' 'z6' 'z7' 'z8' 'z9' 'a' 'b' 'a1' 'a2' 'a3' 'a4' 'a5' 'a6' 'a7' 'a8' 'a9' 'a10' 'a11' 'a12' 'a13' 'a14' 'a15' 'a16' 'a17' 'a18' 'a19' 'a20' 'a21' 'a22' 'a23' 'a24' 'a25' 'a26' 'a27' 'a28' 'a29' 'a30' 'a31' 'a32' 'a33' 'a34' 'a35' 'a36' 'a37' 'a38' 'a39' 'a40' 'a41' 'a42' 'a43' 'a44' 'a45' 'a46' 'a47' 'a48' 'a49' 'a50' 'a51' 'a52' 'a53' 'a54' 'a55' 'a56' 'a57' 'a58' 'a59' 'a60' 'a61' 'a62' 'a63' 'a64' 'a65' 'a66' 'a67' 'a68' 'a69' 'a70' 'a71' 'a72' 'a73' 'a74' 'a75' 'a76' 'a77' 'a78' 'a79' 'a80' 'a81' 'a82' 'a83' 'a84' 'a85' 'a86' 'a87' 'a88' 'a89' 'a90' 'a91' 'a92' 'a93' 'a94' 'a95' 'a96' 'a97' 'a98' 'a99' 'a100' 'a101' 'a102' 'a103' 'a104' 'a105' 'a106' 'a107' 'a108' 'a109' 'a110' 'a111' 'a112' 'a113' 'a114' 'a115' 'a116' 'a117' 'a118' 'a119' 'a120' 'a121' 'a122' 'a123' 'a124' 'a125' 'a126' 'a127' 'a128' 'a129' 'a130' 'a131' 'a132' 'a133' 'a134' 'a135' 'a136' 'a137' 'a138' 'a139' 'a140' 'a141' 'a142' 'a143' 'a144' 'a145' 'a146' 'a147' 'a148' 'a149' 'a150' 'a151' 'a152' 'a153' 'a154' 'a155' 'a156' 'a157' 'a158' 'a159' 'a160' 'a161' 'a162' 'a163' 'a164' 'a165' 'a166' 'a167' 'a168' 'a169' 'a170' 'a171' 'a172' 'a173' 'a174' 'a175' 'a176' 'a177' 'a178' 'a179' 'a180' 'a181' 'a182' 'a183' 'a184' 'a185' 'a186' 'a187' 'a188' 'a189' 'a190' 'a191' 'a192' 'a193' 'a194' 'a195' 'a196' 'a197' 'a198' 'a199' 'a200' 'a201' 'a202' 'a203' 'a204' 'a205' 'a206' 'a207' 'a208' 'a209' 'a210' 'a211' 'a212' 'a213' 'a214' 'a215' 'a216' 'a217' 'a218' 'a219' 'a220' 'a221' 'a222' 'a223' 'a224' 'a225' 'a226' 'a227' 'a228' 'a229' 'a230' 'a231' 'a232' 'a233' 'a234' 'a235' 'a236' 'a237' 'a238' 'a239' 'a240' 'c' 'd').

	self assert: installedSuperclass selectors asSet equals:
		(sourceForExistingSuperclass selectors, sourceForLibrary selectors) asSet.
	self assert: installedSuperclass class selectors asSet equals:
		(sourceForExistingSuperclass class selectors, sourceForLibrary class selectors) asSet.
	self assert: installedSuperclass class >> #new equals: sourceForLibrary class >> #new.
	self assert: installedSuperclass >> #initialize equals: sourceForLibrary >> #initialize.
	self assert: installedSuperclass >> #a equals: sourceForLibrary >> #a.
	self assert: installedSuperclass >> #b equals: sourceForLibrary >> #b.
	self assert: installedSuperclass >> #c equals: sourceForLibrary >> #c.
	self deny: (installedSuperclass >> #combined) = (sourceForExistingSuperclass >> #combined).
	self assert: installedSuperclass >> #combined equals: sourceForLibrary >> #combined.
	self assert: installedSuperclass >> #maxVal equals: sourceForLibrary >> #maxVal.
	self assert: installedSuperclass >> #someLiteral equals: sourceForLibrary >> #someLiteral.
	self assert: installedSuperclass >> #xk47 equals: sourceForExistingSuperclass >> #xk47.

	self assert: installedSubclass selectors equals: sourceForExistingSubclass selectors.
	self assert: installedSubclass class selectors equals: sourceForExistingSubclass class selectors.
	self deny: (installedSubclass >> #initialize) = (sourceForExistingSubclass >> #initialize)
		description: 'Methods should be corrected for class shape due to new instance variable in superclass'.
	self deny: (installedSubclass >> #d) = (sourceForExistingSubclass >> #d)
		description: 'Methods should be corrected for class shape due to new instance variable in superclass'.
	self deny: (installedSubclass >> #combined) = (sourceForExistingSubclass >> #combined)
		description: 'Methods should be corrected for class shape due to new instance variable in superclass'.

	self assert: installedSuperclass new a equals: 1.
	self assert: installedSuperclass new b equals: 2.
	self assert: installedSuperclass new c equals: 3.
	self assert: installedSuperclass new combined equals: 123.
	self assert: installedSuperclass new maxVal equals: SmallInteger maxVal.
	self assert: installedSuperclass new someLiteral equals: sourceForLibrary new someLiteral.
	self assert: installedSuperclass new xk47 equals: 'xk47'.

	self assert: installedSubclass new a equals: 1.
	self assert: installedSubclass new b equals: 2.
	self assert: installedSubclass new c equals: 3.
	self assert: installedSubclass new d equals: 4.
	self assert: installedSubclass new combined equals: 124 + 123.
	self assert: installedSubclass new maxVal equals: SmallInteger maxVal.
	self assert: installedSubclass new someLiteral equals: sourceForLibrary new someLiteral.
	self assert: installedSubclass new xk47 equals: 'xk47'.

	Smalltalk at: #DclExample07Subclass ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
	Smalltalk at: #DclExample07 ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
]

{ #category : 'tests 07' }
DclTest >> test07EExistingClassOldIvarMissingShouldConvertNewMethods [
	"The library is unaware of one of the instance variables in the existing class.
	Installation should succeed.
	Methods in the subclass that came from the library should be adjusted to access the correct instance variables,
		because they were created unaware of the 'missing' instance variable.
	Similar to test03EExistingClassOldIvarMissingShouldConvertNewMethods, but exercising the full 1 byte index range."

	| sourceForExistingSuperclass sourceForExistingSubclass existingSuperclass existingSubclass
	 sourceForLibrarySubclass lib installedSubclass |

	"Create pre-existing version of classes."
	Smalltalk at: #DclExample07Subclass ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
	Smalltalk at: #DclExample07 ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
	sourceForExistingSuperclass := NoclashABC_DclExample07.
	sourceForExistingSubclass := NoclashABCD_DclExample07Subclass.
	(DynamicCuisLibrary
		withClasses: { sourceForExistingSuperclass. sourceForExistingSubclass }
		classSelectors: { sourceForExistingSuperclass class selectors. sourceForExistingSubclass class selectors }
		instanceSelectors: { sourceForExistingSuperclass selectors. sourceForExistingSubclass selectors }) installLibrary.
	existingSuperclass := Smalltalk at: #DclExample07.
	existingSubclass := Smalltalk at: #DclExample07Subclass.
	self assert: existingSuperclass allInstVarNames equals: #('z1' 'z2' 'z3' 'z4' 'z5' 'z6' 'z7' 'z8' 'z9' 'a' 'b' 'a1' 'a2' 'a3' 'a4' 'a5' 'a6' 'a7' 'a8' 'a9' 'a10' 'a11' 'a12' 'a13' 'a14' 'a15' 'a16' 'a17' 'a18' 'a19' 'a20' 'a21' 'a22' 'a23' 'a24' 'a25' 'a26' 'a27' 'a28' 'a29' 'a30' 'a31' 'a32' 'a33' 'a34' 'a35' 'a36' 'a37' 'a38' 'a39' 'a40' 'a41' 'a42' 'a43' 'a44' 'a45' 'a46' 'a47' 'a48' 'a49' 'a50' 'a51' 'a52' 'a53' 'a54' 'a55' 'a56' 'a57' 'a58' 'a59' 'a60' 'a61' 'a62' 'a63' 'a64' 'a65' 'a66' 'a67' 'a68' 'a69' 'a70' 'a71' 'a72' 'a73' 'a74' 'a75' 'a76' 'a77' 'a78' 'a79' 'a80' 'a81' 'a82' 'a83' 'a84' 'a85' 'a86' 'a87' 'a88' 'a89' 'a90' 'a91' 'a92' 'a93' 'a94' 'a95' 'a96' 'a97' 'a98' 'a99' 'a100' 'a101' 'a102' 'a103' 'a104' 'a105' 'a106' 'a107' 'a108' 'a109' 'a110' 'a111' 'a112' 'a113' 'a114' 'a115' 'a116' 'a117' 'a118' 'a119' 'a120' 'a121' 'a122' 'a123' 'a124' 'a125' 'a126' 'a127' 'a128' 'a129' 'a130' 'a131' 'a132' 'a133' 'a134' 'a135' 'a136' 'a137' 'a138' 'a139' 'a140' 'a141' 'a142' 'a143' 'a144' 'a145' 'a146' 'a147' 'a148' 'a149' 'a150' 'a151' 'a152' 'a153' 'a154' 'a155' 'a156' 'a157' 'a158' 'a159' 'a160' 'a161' 'a162' 'a163' 'a164' 'a165' 'a166' 'a167' 'a168' 'a169' 'a170' 'a171' 'a172' 'a173' 'a174' 'a175' 'a176' 'a177' 'a178' 'a179' 'a180' 'a181' 'a182' 'a183' 'a184' 'a185' 'a186' 'a187' 'a188' 'a189' 'a190' 'a191' 'a192' 'a193' 'a194' 'a195' 'a196' 'a197' 'a198' 'a199' 'a200' 'a201' 'a202' 'a203' 'a204' 'a205' 'a206' 'a207' 'a208' 'a209' 'a210' 'a211' 'a212' 'a213' 'a214' 'a215' 'a216' 'a217' 'a218' 'a219' 'a220' 'a221' 'a222' 'a223' 'a224' 'a225' 'a226' 'a227' 'a228' 'a229' 'a230' 'a231' 'a232' 'a233' 'a234' 'a235' 'a236' 'a237' 'a238' 'a239' 'a240' 'c').
	self assert: existingSubclass allInstVarNames equals: #('z1' 'z2' 'z3' 'z4' 'z5' 'z6' 'z7' 'z8' 'z9' 'a' 'b' 'a1' 'a2' 'a3' 'a4' 'a5' 'a6' 'a7' 'a8' 'a9' 'a10' 'a11' 'a12' 'a13' 'a14' 'a15' 'a16' 'a17' 'a18' 'a19' 'a20' 'a21' 'a22' 'a23' 'a24' 'a25' 'a26' 'a27' 'a28' 'a29' 'a30' 'a31' 'a32' 'a33' 'a34' 'a35' 'a36' 'a37' 'a38' 'a39' 'a40' 'a41' 'a42' 'a43' 'a44' 'a45' 'a46' 'a47' 'a48' 'a49' 'a50' 'a51' 'a52' 'a53' 'a54' 'a55' 'a56' 'a57' 'a58' 'a59' 'a60' 'a61' 'a62' 'a63' 'a64' 'a65' 'a66' 'a67' 'a68' 'a69' 'a70' 'a71' 'a72' 'a73' 'a74' 'a75' 'a76' 'a77' 'a78' 'a79' 'a80' 'a81' 'a82' 'a83' 'a84' 'a85' 'a86' 'a87' 'a88' 'a89' 'a90' 'a91' 'a92' 'a93' 'a94' 'a95' 'a96' 'a97' 'a98' 'a99' 'a100' 'a101' 'a102' 'a103' 'a104' 'a105' 'a106' 'a107' 'a108' 'a109' 'a110' 'a111' 'a112' 'a113' 'a114' 'a115' 'a116' 'a117' 'a118' 'a119' 'a120' 'a121' 'a122' 'a123' 'a124' 'a125' 'a126' 'a127' 'a128' 'a129' 'a130' 'a131' 'a132' 'a133' 'a134' 'a135' 'a136' 'a137' 'a138' 'a139' 'a140' 'a141' 'a142' 'a143' 'a144' 'a145' 'a146' 'a147' 'a148' 'a149' 'a150' 'a151' 'a152' 'a153' 'a154' 'a155' 'a156' 'a157' 'a158' 'a159' 'a160' 'a161' 'a162' 'a163' 'a164' 'a165' 'a166' 'a167' 'a168' 'a169' 'a170' 'a171' 'a172' 'a173' 'a174' 'a175' 'a176' 'a177' 'a178' 'a179' 'a180' 'a181' 'a182' 'a183' 'a184' 'a185' 'a186' 'a187' 'a188' 'a189' 'a190' 'a191' 'a192' 'a193' 'a194' 'a195' 'a196' 'a197' 'a198' 'a199' 'a200' 'a201' 'a202' 'a203' 'a204' 'a205' 'a206' 'a207' 'a208' 'a209' 'a210' 'a211' 'a212' 'a213' 'a214' 'a215' 'a216' 'a217' 'a218' 'a219' 'a220' 'a221' 'a222' 'a223' 'a224' 'a225' 'a226' 'a227' 'a228' 'a229' 'a230' 'a231' 'a232' 'a233' 'a234' 'a235' 'a236' 'a237' 'a238' 'a239' 'a240' 'c' 'd').
	self assert: existingSuperclass new a equals: 1.
	self assert: existingSuperclass new b equals: 2.
	self assert: existingSuperclass new c equals: 3.
	self assert: existingSuperclass new combined equals: 123.
	self assert: existingSubclass new a equals: 1.
	self assert: existingSubclass new b equals: 2.
	self assert: existingSubclass new c equals: 3.
	self assert: existingSubclass new d equals: 4.
	self assert: existingSubclass new combined equals: 1234 + 123.

	"Create library. Class we are installed misses one instance variable (in the superclass actually).
	Neither class shape should be modified."
	sourceForLibrarySubclass := NoclashABD_DclExample07Subclass.
	lib := DynamicCuisLibrary
		withClasses: { sourceForLibrarySubclass }
		classSelectors: { sourceForLibrarySubclass class selectors }
		instanceSelectors: { sourceForLibrarySubclass selectors }.

	self assert: lib canBeInstalled.
	lib installLibrary.
	self deny: CompilerWasUsed description: 'Should not use Compiler. Usually it will not be available.'.

	installedSubclass := Smalltalk at: #DclExample07Subclass.
	self assert: existingSuperclass allInstVarNames equals: #('z1' 'z2' 'z3' 'z4' 'z5' 'z6' 'z7' 'z8' 'z9' 'a' 'b' 'a1' 'a2' 'a3' 'a4' 'a5' 'a6' 'a7' 'a8' 'a9' 'a10' 'a11' 'a12' 'a13' 'a14' 'a15' 'a16' 'a17' 'a18' 'a19' 'a20' 'a21' 'a22' 'a23' 'a24' 'a25' 'a26' 'a27' 'a28' 'a29' 'a30' 'a31' 'a32' 'a33' 'a34' 'a35' 'a36' 'a37' 'a38' 'a39' 'a40' 'a41' 'a42' 'a43' 'a44' 'a45' 'a46' 'a47' 'a48' 'a49' 'a50' 'a51' 'a52' 'a53' 'a54' 'a55' 'a56' 'a57' 'a58' 'a59' 'a60' 'a61' 'a62' 'a63' 'a64' 'a65' 'a66' 'a67' 'a68' 'a69' 'a70' 'a71' 'a72' 'a73' 'a74' 'a75' 'a76' 'a77' 'a78' 'a79' 'a80' 'a81' 'a82' 'a83' 'a84' 'a85' 'a86' 'a87' 'a88' 'a89' 'a90' 'a91' 'a92' 'a93' 'a94' 'a95' 'a96' 'a97' 'a98' 'a99' 'a100' 'a101' 'a102' 'a103' 'a104' 'a105' 'a106' 'a107' 'a108' 'a109' 'a110' 'a111' 'a112' 'a113' 'a114' 'a115' 'a116' 'a117' 'a118' 'a119' 'a120' 'a121' 'a122' 'a123' 'a124' 'a125' 'a126' 'a127' 'a128' 'a129' 'a130' 'a131' 'a132' 'a133' 'a134' 'a135' 'a136' 'a137' 'a138' 'a139' 'a140' 'a141' 'a142' 'a143' 'a144' 'a145' 'a146' 'a147' 'a148' 'a149' 'a150' 'a151' 'a152' 'a153' 'a154' 'a155' 'a156' 'a157' 'a158' 'a159' 'a160' 'a161' 'a162' 'a163' 'a164' 'a165' 'a166' 'a167' 'a168' 'a169' 'a170' 'a171' 'a172' 'a173' 'a174' 'a175' 'a176' 'a177' 'a178' 'a179' 'a180' 'a181' 'a182' 'a183' 'a184' 'a185' 'a186' 'a187' 'a188' 'a189' 'a190' 'a191' 'a192' 'a193' 'a194' 'a195' 'a196' 'a197' 'a198' 'a199' 'a200' 'a201' 'a202' 'a203' 'a204' 'a205' 'a206' 'a207' 'a208' 'a209' 'a210' 'a211' 'a212' 'a213' 'a214' 'a215' 'a216' 'a217' 'a218' 'a219' 'a220' 'a221' 'a222' 'a223' 'a224' 'a225' 'a226' 'a227' 'a228' 'a229' 'a230' 'a231' 'a232' 'a233' 'a234' 'a235' 'a236' 'a237' 'a238' 'a239' 'a240' 'c').
	self assert: installedSubclass allInstVarNames equals: #('z1' 'z2' 'z3' 'z4' 'z5' 'z6' 'z7' 'z8' 'z9' 'a' 'b' 'a1' 'a2' 'a3' 'a4' 'a5' 'a6' 'a7' 'a8' 'a9' 'a10' 'a11' 'a12' 'a13' 'a14' 'a15' 'a16' 'a17' 'a18' 'a19' 'a20' 'a21' 'a22' 'a23' 'a24' 'a25' 'a26' 'a27' 'a28' 'a29' 'a30' 'a31' 'a32' 'a33' 'a34' 'a35' 'a36' 'a37' 'a38' 'a39' 'a40' 'a41' 'a42' 'a43' 'a44' 'a45' 'a46' 'a47' 'a48' 'a49' 'a50' 'a51' 'a52' 'a53' 'a54' 'a55' 'a56' 'a57' 'a58' 'a59' 'a60' 'a61' 'a62' 'a63' 'a64' 'a65' 'a66' 'a67' 'a68' 'a69' 'a70' 'a71' 'a72' 'a73' 'a74' 'a75' 'a76' 'a77' 'a78' 'a79' 'a80' 'a81' 'a82' 'a83' 'a84' 'a85' 'a86' 'a87' 'a88' 'a89' 'a90' 'a91' 'a92' 'a93' 'a94' 'a95' 'a96' 'a97' 'a98' 'a99' 'a100' 'a101' 'a102' 'a103' 'a104' 'a105' 'a106' 'a107' 'a108' 'a109' 'a110' 'a111' 'a112' 'a113' 'a114' 'a115' 'a116' 'a117' 'a118' 'a119' 'a120' 'a121' 'a122' 'a123' 'a124' 'a125' 'a126' 'a127' 'a128' 'a129' 'a130' 'a131' 'a132' 'a133' 'a134' 'a135' 'a136' 'a137' 'a138' 'a139' 'a140' 'a141' 'a142' 'a143' 'a144' 'a145' 'a146' 'a147' 'a148' 'a149' 'a150' 'a151' 'a152' 'a153' 'a154' 'a155' 'a156' 'a157' 'a158' 'a159' 'a160' 'a161' 'a162' 'a163' 'a164' 'a165' 'a166' 'a167' 'a168' 'a169' 'a170' 'a171' 'a172' 'a173' 'a174' 'a175' 'a176' 'a177' 'a178' 'a179' 'a180' 'a181' 'a182' 'a183' 'a184' 'a185' 'a186' 'a187' 'a188' 'a189' 'a190' 'a191' 'a192' 'a193' 'a194' 'a195' 'a196' 'a197' 'a198' 'a199' 'a200' 'a201' 'a202' 'a203' 'a204' 'a205' 'a206' 'a207' 'a208' 'a209' 'a210' 'a211' 'a212' 'a213' 'a214' 'a215' 'a216' 'a217' 'a218' 'a219' 'a220' 'a221' 'a222' 'a223' 'a224' 'a225' 'a226' 'a227' 'a228' 'a229' 'a230' 'a231' 'a232' 'a233' 'a234' 'a235' 'a236' 'a237' 'a238' 'a239' 'a240' 'c' 'd').
	self assert: existingSuperclass new a equals: 1.
	self assert: existingSuperclass new b equals: 2.
	self assert: existingSuperclass new c equals: 3.
	self assert: existingSuperclass new combined equals: 123.
	self assert: installedSubclass new a equals: 1.
	self assert: installedSubclass new b equals: 2.
	self assert: installedSubclass new c equals: 3.
	self assert: installedSubclass new d equals: 4.
	self assert: installedSubclass new combined equals: 124 + 123.

	Smalltalk at: #DclExample07Subclass ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
	Smalltalk at: #DclExample07 ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
]

{ #category : 'tests 08' }
DclTest >> test08CExistingClassNewIVarsShouldConvertExistingMethods [
	"The library adds an instance variable to a class.
	Installation should succeed.
	The new instance variable will be added after the existing ones.
	Existing methods in the subclass should be converted to access the correct instance variables.
	Existing methods in the superclass should remain unchanged, as new instance variables are added at the end.
	Similar to test07CExistingClassNewIVarsShouldConvertExistingMethods, but converting between 1-byte and 2-byte opcodes,
	something that can only be done with the Sista Bytecodes Set."

	| sourceForExistingSuperclass sourceForExistingSubclass existingSuperclass existingSubclass
	 sourceForLibrary lib installedSuperclass installedSubclass |

	"Create pre-existing version of classes."
	Smalltalk at: #DclExample08Subclass ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
	Smalltalk at: #DclExample08 ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
	sourceForExistingSuperclass := NoclashAB_DclExample08.
	sourceForExistingSubclass := NoclashABD_DclExample08Subclass.
	(DynamicCuisLibrary
		withClasses: { sourceForExistingSuperclass. sourceForExistingSubclass }
		classSelectors: { sourceForExistingSuperclass class selectors. sourceForExistingSubclass class selectors }
		instanceSelectors: { sourceForExistingSuperclass selectors. sourceForExistingSubclass selectors }) installLibrary.
	existingSuperclass := Smalltalk at: #DclExample08.
	existingSubclass := Smalltalk at: #DclExample08Subclass.
	self assert: existingSuperclass allInstVarNames equals: #('a' 'b' 'a1' 'a2' 'a3' 'a4' 'a5' 'a6' 'a7' 'a8' 'a9' 'a10').
	self assert: existingSubclass allInstVarNames equals: #('a' 'b' 'a1' 'a2' 'a3' 'a4' 'a5' 'a6' 'a7' 'a8' 'a9' 'a10' 'd').
	self assert: existingSuperclass new b equals: 9.
	self assert: existingSuperclass new combined equals: 79.
	self assert: existingSuperclass new xk47 equals: 'xk47'.
	self assert: existingSubclass new b equals: 9.
	self assert: existingSubclass new d equals: 4.
	self assert: existingSubclass new combined equals: 794 + 79.
	self assert: existingSubclass new xk47 equals: 'xk47'.

	"Create library"
	sourceForLibrary := NoclashABC_DclExample08.
	lib := DynamicCuisLibrary
		withClasses: { sourceForLibrary }
		classSelectors: { sourceForLibrary class selectors }
		instanceSelectors: { sourceForLibrary selectors }.

	self assert: lib canBeInstalled.
	lib installLibrary.
	self deny: CompilerWasUsed description: 'Should not use Compiler. Usually it will not be available.'.

	installedSuperclass := Smalltalk at: #DclExample08.
	installedSubclass := Smalltalk at: #DclExample08Subclass.

	self assert: installedSuperclass allInstVarNames equals: #('a' 'b' 'a1' 'a2' 'a3' 'a4' 'a5' 'a6' 'a7' 'a8' 'a9' 'a10' 'a11' 'a12' 'a13' 'a14' 'a15' 'a16' 'a17' 'a18' 'a19' 'a20' 'a21' 'a22' 'a23' 'a24' 'a25' 'a26' 'a27' 'a28' 'a29' 'a30' 'a31' 'a32' 'a33' 'a34' 'a35' 'a36' 'a37' 'a38' 'a39' 'a40' 'a41' 'a42' 'a43' 'a44' 'a45' 'a46' 'a47' 'a48' 'a49' 'a50' 'a51' 'a52' 'a53' 'a54' 'a55' 'a56' 'a57' 'a58' 'a59' 'a60' 'a61' 'a62' 'a63' 'a64' 'a65' 'a66' 'a67' 'a68' 'a69' 'a70' 'a71' 'a72' 'a73' 'a74' 'a75' 'a76' 'a77' 'a78' 'a79' 'a80' 'a81' 'a82' 'a83' 'a84' 'a85' 'a86' 'a87' 'a88' 'a89' 'a90' 'a91' 'a92' 'a93' 'a94' 'a95' 'a96' 'a97' 'a98' 'a99' 'a100' 'a101' 'a102' 'a103' 'a104' 'a105' 'a106' 'a107' 'a108' 'a109' 'a110' 'a111' 'a112' 'a113' 'a114' 'a115' 'a116' 'a117' 'a118' 'a119' 'a120' 'a121' 'a122' 'a123' 'a124' 'a125' 'a126' 'a127' 'a128' 'a129' 'a130' 'a131' 'a132' 'a133' 'a134' 'a135' 'a136' 'a137' 'a138' 'a139' 'a140' 'a141' 'a142' 'a143' 'a144' 'a145' 'a146' 'a147' 'a148' 'a149' 'a150' 'a151' 'a152' 'a153' 'a154' 'a155' 'a156' 'a157' 'a158' 'a159' 'a160' 'a161' 'a162' 'a163' 'a164' 'a165' 'a166' 'a167' 'a168' 'a169' 'a170' 'a171' 'a172' 'a173' 'a174' 'a175' 'a176' 'a177' 'a178' 'a179' 'a180' 'a181' 'a182' 'a183' 'a184' 'a185' 'a186' 'a187' 'a188' 'a189' 'a190' 'a191' 'a192' 'a193' 'a194' 'a195' 'a196' 'a197' 'a198' 'a199' 'a200' 'a201' 'a202' 'a203' 'a204' 'a205' 'a206' 'a207' 'a208' 'a209' 'a210' 'a211' 'a212' 'a213' 'a214' 'a215' 'a216' 'a217' 'a218' 'a219' 'a220' 'a221' 'a222' 'a223' 'a224' 'a225' 'a226' 'a227' 'a228' 'a229' 'a230' 'a231' 'a232' 'a233' 'a234' 'a235' 'a236' 'a237' 'a238' 'a239' 'a240' 'c').
	self assert: installedSubclass allInstVarNames equals: #('a' 'b' 'a1' 'a2' 'a3' 'a4' 'a5' 'a6' 'a7' 'a8' 'a9' 'a10' 'a11' 'a12' 'a13' 'a14' 'a15' 'a16' 'a17' 'a18' 'a19' 'a20' 'a21' 'a22' 'a23' 'a24' 'a25' 'a26' 'a27' 'a28' 'a29' 'a30' 'a31' 'a32' 'a33' 'a34' 'a35' 'a36' 'a37' 'a38' 'a39' 'a40' 'a41' 'a42' 'a43' 'a44' 'a45' 'a46' 'a47' 'a48' 'a49' 'a50' 'a51' 'a52' 'a53' 'a54' 'a55' 'a56' 'a57' 'a58' 'a59' 'a60' 'a61' 'a62' 'a63' 'a64' 'a65' 'a66' 'a67' 'a68' 'a69' 'a70' 'a71' 'a72' 'a73' 'a74' 'a75' 'a76' 'a77' 'a78' 'a79' 'a80' 'a81' 'a82' 'a83' 'a84' 'a85' 'a86' 'a87' 'a88' 'a89' 'a90' 'a91' 'a92' 'a93' 'a94' 'a95' 'a96' 'a97' 'a98' 'a99' 'a100' 'a101' 'a102' 'a103' 'a104' 'a105' 'a106' 'a107' 'a108' 'a109' 'a110' 'a111' 'a112' 'a113' 'a114' 'a115' 'a116' 'a117' 'a118' 'a119' 'a120' 'a121' 'a122' 'a123' 'a124' 'a125' 'a126' 'a127' 'a128' 'a129' 'a130' 'a131' 'a132' 'a133' 'a134' 'a135' 'a136' 'a137' 'a138' 'a139' 'a140' 'a141' 'a142' 'a143' 'a144' 'a145' 'a146' 'a147' 'a148' 'a149' 'a150' 'a151' 'a152' 'a153' 'a154' 'a155' 'a156' 'a157' 'a158' 'a159' 'a160' 'a161' 'a162' 'a163' 'a164' 'a165' 'a166' 'a167' 'a168' 'a169' 'a170' 'a171' 'a172' 'a173' 'a174' 'a175' 'a176' 'a177' 'a178' 'a179' 'a180' 'a181' 'a182' 'a183' 'a184' 'a185' 'a186' 'a187' 'a188' 'a189' 'a190' 'a191' 'a192' 'a193' 'a194' 'a195' 'a196' 'a197' 'a198' 'a199' 'a200' 'a201' 'a202' 'a203' 'a204' 'a205' 'a206' 'a207' 'a208' 'a209' 'a210' 'a211' 'a212' 'a213' 'a214' 'a215' 'a216' 'a217' 'a218' 'a219' 'a220' 'a221' 'a222' 'a223' 'a224' 'a225' 'a226' 'a227' 'a228' 'a229' 'a230' 'a231' 'a232' 'a233' 'a234' 'a235' 'a236' 'a237' 'a238' 'a239' 'a240' 'c' 'd').

	self assert: installedSuperclass selectors asSet equals:
		(sourceForExistingSuperclass selectors, sourceForLibrary selectors) asSet.
	self assert: installedSuperclass class selectors asSet equals:
		(sourceForExistingSuperclass class selectors, sourceForLibrary class selectors) asSet.
	self assert: installedSuperclass class >> #new equals: sourceForLibrary class >> #new.
	self deny: (installedSuperclass >> #initialize) = (sourceForLibrary >> #initialize)
		description: 'Installed methods should be corrected for class shape due to different shape if base system'.
	self assert: installedSuperclass >> #a equals: sourceForLibrary >> #a.
	self assert: installedSuperclass >> #c equals: sourceForLibrary >> #c.
	self deny: (installedSuperclass >> #combined) = (sourceForExistingSuperclass >> #combined).
	self deny: (installedSuperclass >> #combined) = (sourceForLibrary >> #combined)
		description: 'Installed methods should be corrected for class shape due to different shape if base system'.
	self assert: installedSuperclass >> #maxVal equals: sourceForLibrary >> #maxVal.
	self assert: installedSuperclass >> #someLiteral equals: sourceForLibrary >> #someLiteral.
	self assert: installedSuperclass >> #xk47 equals: sourceForExistingSuperclass >> #xk47.

	self assert: installedSubclass selectors equals: sourceForExistingSubclass selectors.
	self assert: installedSubclass class selectors equals: sourceForExistingSubclass class selectors.
	self deny: (installedSubclass >> #initialize) = (sourceForExistingSubclass >> #initialize)
		description: 'Methods should be corrected for class shape due to new instance variable in superclass'.
	self deny: (installedSubclass >> #d) = (sourceForExistingSubclass >> #d)
		description: 'Methods should be corrected for class shape due to new instance variable in superclass'.
	self deny: (installedSubclass >> #combined) = (sourceForExistingSubclass >> #combined)
		description: 'Methods should be corrected for class shape due to new instance variable in superclass'.

	self assert: installedSuperclass new a equals: 1.
	self assert: installedSuperclass new b equals: 2.
	self assert: installedSuperclass new c equals: 3.
	self assert: installedSuperclass new combined equals: 123.
	self assert: installedSuperclass new maxVal equals: SmallInteger maxVal.
	self assert: installedSuperclass new someLiteral equals: sourceForLibrary new someLiteral.
	self assert: installedSuperclass new xk47 equals: 'xk47'.

	self assert: installedSubclass new a equals: 1.
	self assert: installedSubclass new b equals: 2.
	self assert: installedSubclass new c equals: 3.
	self assert: installedSubclass new d equals: 4.
	self assert: installedSubclass new combined equals: 124 + 123.
	self assert: installedSubclass new maxVal equals: SmallInteger maxVal.
	self assert: installedSubclass new someLiteral equals: sourceForLibrary new someLiteral.
	self assert: installedSubclass new xk47 equals: 'xk47'.

	Smalltalk at: #DclExample08Subclass ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
	Smalltalk at: #DclExample08 ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
]

{ #category : 'tests 08' }
DclTest >> test08EExistingClassOldIvarMissingShouldConvertNewMethods [
	"The library is unaware of one of the instance variables in the existing class.
	Installation should succeed.
	Methods in the subclass that came from the library should be adjusted to access the correct instance variables,
		because they were created unaware of the 'missing' instance variable.
	Similar to test07EExistingClassOldIvarMissingShouldConvertNewMethods, but converting between 1-byte and 2-byte opcodes,
	something that can only be done with the Sista Bytecodes Set."

	| sourceForExistingSuperclass sourceForExistingSubclass existingSuperclass existingSubclass
	 sourceForLibrarySubclass lib installedSubclass |

	"Create pre-existing version of classes."
	Smalltalk at: #DclExample08Subclass ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
	Smalltalk at: #DclExample08 ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
	sourceForExistingSuperclass := NoclashABC_DclExample08.
	sourceForExistingSubclass := NoclashABCD_DclExample08Subclass.
	(DynamicCuisLibrary
		withClasses: { sourceForExistingSuperclass. sourceForExistingSubclass }
		classSelectors: { sourceForExistingSuperclass class selectors. sourceForExistingSubclass class selectors }
		instanceSelectors: { sourceForExistingSuperclass selectors. sourceForExistingSubclass selectors }) installLibrary.
	existingSuperclass := Smalltalk at: #DclExample08.
	existingSubclass := Smalltalk at: #DclExample08Subclass.
	self assert: existingSuperclass allInstVarNames equals: #('a' 'a1' 'a2' 'a3' 'a4' 'a5' 'a6' 'a7' 'a8' 'a9' 'a10' 'a11' 'a12' 'a13' 'a14' 'a15' 'a16' 'a17' 'a18' 'a19' 'a20' 'a21' 'a22' 'a23' 'a24' 'a25' 'a26' 'a27' 'a28' 'a29' 'a30' 'a31' 'a32' 'a33' 'a34' 'a35' 'a36' 'a37' 'a38' 'a39' 'a40' 'a41' 'a42' 'a43' 'a44' 'a45' 'a46' 'a47' 'a48' 'a49' 'a50' 'a51' 'a52' 'a53' 'a54' 'a55' 'a56' 'a57' 'a58' 'a59' 'a60' 'a61' 'a62' 'a63' 'a64' 'a65' 'a66' 'a67' 'a68' 'a69' 'a70' 'a71' 'a72' 'a73' 'a74' 'a75' 'a76' 'a77' 'a78' 'a79' 'a80' 'a81' 'a82' 'a83' 'a84' 'a85' 'a86' 'a87' 'a88' 'a89' 'a90' 'a91' 'a92' 'a93' 'a94' 'a95' 'a96' 'a97' 'a98' 'a99' 'a100' 'a101' 'a102' 'a103' 'a104' 'a105' 'a106' 'a107' 'a108' 'a109' 'a110' 'a111' 'a112' 'a113' 'a114' 'a115' 'a116' 'a117' 'a118' 'a119' 'a120' 'a121' 'a122' 'a123' 'a124' 'a125' 'a126' 'a127' 'a128' 'a129' 'a130' 'a131' 'a132' 'a133' 'a134' 'a135' 'a136' 'a137' 'a138' 'a139' 'a140' 'a141' 'a142' 'a143' 'a144' 'a145' 'a146' 'a147' 'a148' 'a149' 'a150' 'a151' 'a152' 'a153' 'a154' 'a155' 'a156' 'a157' 'a158' 'a159' 'a160' 'a161' 'a162' 'a163' 'a164' 'a165' 'a166' 'a167' 'a168' 'a169' 'a170' 'a171' 'a172' 'a173' 'a174' 'a175' 'a176' 'a177' 'a178' 'a179' 'a180' 'a181' 'a182' 'a183' 'a184' 'a185' 'a186' 'a187' 'a188' 'a189' 'a190' 'a191' 'a192' 'a193' 'a194' 'a195' 'a196' 'a197' 'a198' 'a199' 'a200' 'a201' 'a202' 'a203' 'a204' 'a205' 'a206' 'a207' 'a208' 'a209' 'a210' 'a211' 'a212' 'a213' 'a214' 'a215' 'a216' 'a217' 'a218' 'a219' 'a220' 'a221' 'a222' 'a223' 'a224' 'a225' 'a226' 'a227' 'a228' 'a229' 'a230' 'a231' 'a232' 'a233' 'a234' 'a235' 'a236' 'a237' 'a238' 'a239' 'a240' 'b' 'c').
	self assert: existingSubclass allInstVarNames equals: #('a' 'a1' 'a2' 'a3' 'a4' 'a5' 'a6' 'a7' 'a8' 'a9' 'a10' 'a11' 'a12' 'a13' 'a14' 'a15' 'a16' 'a17' 'a18' 'a19' 'a20' 'a21' 'a22' 'a23' 'a24' 'a25' 'a26' 'a27' 'a28' 'a29' 'a30' 'a31' 'a32' 'a33' 'a34' 'a35' 'a36' 'a37' 'a38' 'a39' 'a40' 'a41' 'a42' 'a43' 'a44' 'a45' 'a46' 'a47' 'a48' 'a49' 'a50' 'a51' 'a52' 'a53' 'a54' 'a55' 'a56' 'a57' 'a58' 'a59' 'a60' 'a61' 'a62' 'a63' 'a64' 'a65' 'a66' 'a67' 'a68' 'a69' 'a70' 'a71' 'a72' 'a73' 'a74' 'a75' 'a76' 'a77' 'a78' 'a79' 'a80' 'a81' 'a82' 'a83' 'a84' 'a85' 'a86' 'a87' 'a88' 'a89' 'a90' 'a91' 'a92' 'a93' 'a94' 'a95' 'a96' 'a97' 'a98' 'a99' 'a100' 'a101' 'a102' 'a103' 'a104' 'a105' 'a106' 'a107' 'a108' 'a109' 'a110' 'a111' 'a112' 'a113' 'a114' 'a115' 'a116' 'a117' 'a118' 'a119' 'a120' 'a121' 'a122' 'a123' 'a124' 'a125' 'a126' 'a127' 'a128' 'a129' 'a130' 'a131' 'a132' 'a133' 'a134' 'a135' 'a136' 'a137' 'a138' 'a139' 'a140' 'a141' 'a142' 'a143' 'a144' 'a145' 'a146' 'a147' 'a148' 'a149' 'a150' 'a151' 'a152' 'a153' 'a154' 'a155' 'a156' 'a157' 'a158' 'a159' 'a160' 'a161' 'a162' 'a163' 'a164' 'a165' 'a166' 'a167' 'a168' 'a169' 'a170' 'a171' 'a172' 'a173' 'a174' 'a175' 'a176' 'a177' 'a178' 'a179' 'a180' 'a181' 'a182' 'a183' 'a184' 'a185' 'a186' 'a187' 'a188' 'a189' 'a190' 'a191' 'a192' 'a193' 'a194' 'a195' 'a196' 'a197' 'a198' 'a199' 'a200' 'a201' 'a202' 'a203' 'a204' 'a205' 'a206' 'a207' 'a208' 'a209' 'a210' 'a211' 'a212' 'a213' 'a214' 'a215' 'a216' 'a217' 'a218' 'a219' 'a220' 'a221' 'a222' 'a223' 'a224' 'a225' 'a226' 'a227' 'a228' 'a229' 'a230' 'a231' 'a232' 'a233' 'a234' 'a235' 'a236' 'a237' 'a238' 'a239' 'a240' 'b' 'c' 'd').
	self assert: existingSuperclass new a equals: 1.
	self assert: existingSuperclass new c equals: 3.
	self assert: existingSuperclass new combined equals: 123.
	self assert: existingSubclass new a equals: 1.
	self assert: existingSubclass new c equals: 3.
	self assert: existingSubclass new d equals: 4.
	self assert: existingSubclass new combined equals: 1234 + 123.

	"Create library. Class we are installed misses one instance variable (in the superclass actually).
	Neither class shape should be modified."
	sourceForLibrarySubclass := NoclashABD_DclExample08Subclass.
	lib := DynamicCuisLibrary
		withClasses: { sourceForLibrarySubclass }
		classSelectors: { sourceForLibrarySubclass class selectors }
		instanceSelectors: { sourceForLibrarySubclass selectors }.

	self assert: lib canBeInstalled.
	lib installLibrary.
	self deny: CompilerWasUsed description: 'Should not use Compiler. Usually it will not be available.'.

	installedSubclass := Smalltalk at: #DclExample08Subclass.
	self assert: existingSuperclass allInstVarNames equals: #('a' 'a1' 'a2' 'a3' 'a4' 'a5' 'a6' 'a7' 'a8' 'a9' 'a10' 'a11' 'a12' 'a13' 'a14' 'a15' 'a16' 'a17' 'a18' 'a19' 'a20' 'a21' 'a22' 'a23' 'a24' 'a25' 'a26' 'a27' 'a28' 'a29' 'a30' 'a31' 'a32' 'a33' 'a34' 'a35' 'a36' 'a37' 'a38' 'a39' 'a40' 'a41' 'a42' 'a43' 'a44' 'a45' 'a46' 'a47' 'a48' 'a49' 'a50' 'a51' 'a52' 'a53' 'a54' 'a55' 'a56' 'a57' 'a58' 'a59' 'a60' 'a61' 'a62' 'a63' 'a64' 'a65' 'a66' 'a67' 'a68' 'a69' 'a70' 'a71' 'a72' 'a73' 'a74' 'a75' 'a76' 'a77' 'a78' 'a79' 'a80' 'a81' 'a82' 'a83' 'a84' 'a85' 'a86' 'a87' 'a88' 'a89' 'a90' 'a91' 'a92' 'a93' 'a94' 'a95' 'a96' 'a97' 'a98' 'a99' 'a100' 'a101' 'a102' 'a103' 'a104' 'a105' 'a106' 'a107' 'a108' 'a109' 'a110' 'a111' 'a112' 'a113' 'a114' 'a115' 'a116' 'a117' 'a118' 'a119' 'a120' 'a121' 'a122' 'a123' 'a124' 'a125' 'a126' 'a127' 'a128' 'a129' 'a130' 'a131' 'a132' 'a133' 'a134' 'a135' 'a136' 'a137' 'a138' 'a139' 'a140' 'a141' 'a142' 'a143' 'a144' 'a145' 'a146' 'a147' 'a148' 'a149' 'a150' 'a151' 'a152' 'a153' 'a154' 'a155' 'a156' 'a157' 'a158' 'a159' 'a160' 'a161' 'a162' 'a163' 'a164' 'a165' 'a166' 'a167' 'a168' 'a169' 'a170' 'a171' 'a172' 'a173' 'a174' 'a175' 'a176' 'a177' 'a178' 'a179' 'a180' 'a181' 'a182' 'a183' 'a184' 'a185' 'a186' 'a187' 'a188' 'a189' 'a190' 'a191' 'a192' 'a193' 'a194' 'a195' 'a196' 'a197' 'a198' 'a199' 'a200' 'a201' 'a202' 'a203' 'a204' 'a205' 'a206' 'a207' 'a208' 'a209' 'a210' 'a211' 'a212' 'a213' 'a214' 'a215' 'a216' 'a217' 'a218' 'a219' 'a220' 'a221' 'a222' 'a223' 'a224' 'a225' 'a226' 'a227' 'a228' 'a229' 'a230' 'a231' 'a232' 'a233' 'a234' 'a235' 'a236' 'a237' 'a238' 'a239' 'a240' 'b' 'c').
	self assert: installedSubclass allInstVarNames equals: #('a' 'a1' 'a2' 'a3' 'a4' 'a5' 'a6' 'a7' 'a8' 'a9' 'a10' 'a11' 'a12' 'a13' 'a14' 'a15' 'a16' 'a17' 'a18' 'a19' 'a20' 'a21' 'a22' 'a23' 'a24' 'a25' 'a26' 'a27' 'a28' 'a29' 'a30' 'a31' 'a32' 'a33' 'a34' 'a35' 'a36' 'a37' 'a38' 'a39' 'a40' 'a41' 'a42' 'a43' 'a44' 'a45' 'a46' 'a47' 'a48' 'a49' 'a50' 'a51' 'a52' 'a53' 'a54' 'a55' 'a56' 'a57' 'a58' 'a59' 'a60' 'a61' 'a62' 'a63' 'a64' 'a65' 'a66' 'a67' 'a68' 'a69' 'a70' 'a71' 'a72' 'a73' 'a74' 'a75' 'a76' 'a77' 'a78' 'a79' 'a80' 'a81' 'a82' 'a83' 'a84' 'a85' 'a86' 'a87' 'a88' 'a89' 'a90' 'a91' 'a92' 'a93' 'a94' 'a95' 'a96' 'a97' 'a98' 'a99' 'a100' 'a101' 'a102' 'a103' 'a104' 'a105' 'a106' 'a107' 'a108' 'a109' 'a110' 'a111' 'a112' 'a113' 'a114' 'a115' 'a116' 'a117' 'a118' 'a119' 'a120' 'a121' 'a122' 'a123' 'a124' 'a125' 'a126' 'a127' 'a128' 'a129' 'a130' 'a131' 'a132' 'a133' 'a134' 'a135' 'a136' 'a137' 'a138' 'a139' 'a140' 'a141' 'a142' 'a143' 'a144' 'a145' 'a146' 'a147' 'a148' 'a149' 'a150' 'a151' 'a152' 'a153' 'a154' 'a155' 'a156' 'a157' 'a158' 'a159' 'a160' 'a161' 'a162' 'a163' 'a164' 'a165' 'a166' 'a167' 'a168' 'a169' 'a170' 'a171' 'a172' 'a173' 'a174' 'a175' 'a176' 'a177' 'a178' 'a179' 'a180' 'a181' 'a182' 'a183' 'a184' 'a185' 'a186' 'a187' 'a188' 'a189' 'a190' 'a191' 'a192' 'a193' 'a194' 'a195' 'a196' 'a197' 'a198' 'a199' 'a200' 'a201' 'a202' 'a203' 'a204' 'a205' 'a206' 'a207' 'a208' 'a209' 'a210' 'a211' 'a212' 'a213' 'a214' 'a215' 'a216' 'a217' 'a218' 'a219' 'a220' 'a221' 'a222' 'a223' 'a224' 'a225' 'a226' 'a227' 'a228' 'a229' 'a230' 'a231' 'a232' 'a233' 'a234' 'a235' 'a236' 'a237' 'a238' 'a239' 'a240' 'b' 'c' 'd').
	self assert: existingSuperclass new a equals: 1.
	self assert: existingSuperclass new c equals: 3.
	self assert: existingSuperclass new combined equals: 123.
	self assert: installedSubclass new a equals: 1.
	self assert: installedSubclass new b equals: 2.
	self assert: installedSubclass new c equals: 3.
	self assert: installedSubclass new d equals: 4.
	self assert: installedSubclass new combined equals: 124 + 123.

	Smalltalk at: #DclExample08Subclass ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
	Smalltalk at: #DclExample08 ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
]

{ #category : 'tests 09' }
DclTest >> test09CExistingClassNewIVarsShouldConvertExistingMethods [
	"The library adds an instance variable to a class.
	Installation should succeed.
	The new instance variable will be added after the existing ones.
	Existing methods in the subclass should be converted to access the correct instance variables.
	Existing methods in the superclass should remain unchanged, as new instance variables are added at the end.
	Similar to test08CExistingClassNewIVarsShouldConvertExistingMethods, but converting between 1-byte and 4-byte opcodes,
	something that can only be done with the Sista Bytecodes Set."

	| sourceForExistingSuperclass sourceForExistingSubclass existingSuperclass existingSubclass
	 sourceForLibrary lib installedSuperclass installedSubclass |

	"Create pre-existing version of classes."
	Smalltalk at: #DclExample09Subclass ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
	Smalltalk at: #DclExample09 ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
	sourceForExistingSuperclass := NoclashAB_DclExample09.
	sourceForExistingSubclass := NoclashABD_DclExample09Subclass.
	(DynamicCuisLibrary
		withClasses: { sourceForExistingSuperclass. sourceForExistingSubclass }
		classSelectors: { sourceForExistingSuperclass class selectors. sourceForExistingSubclass class selectors }
		instanceSelectors: { sourceForExistingSuperclass selectors. sourceForExistingSubclass selectors }) installLibrary.
	existingSuperclass := Smalltalk at: #DclExample09.
	existingSubclass := Smalltalk at: #DclExample09Subclass.
	self assert: existingSuperclass allInstVarNames equals: #('a' 'b' 'a1' 'a2' 'a3' 'a4' 'a5' 'a6' 'a7' 'a8' 'a9' 'a10').
	self assert: existingSubclass allInstVarNames equals: #('a' 'b' 'a1' 'a2' 'a3' 'a4' 'a5' 'a6' 'a7' 'a8' 'a9' 'a10' 'd').
	self assert: existingSuperclass new b equals: 9.
	self assert: existingSuperclass new combined equals: 79.
	self assert: existingSuperclass new xk47 equals: 'xk47'.
	self assert: existingSubclass new b equals: 9.
	self assert: existingSubclass new d equals: 4.
	self assert: existingSubclass new combined equals: 794 + 79.
	self assert: existingSubclass new xk47 equals: 'xk47'.

	"Create library"
	sourceForLibrary := NoclashABC_DclExample09.
	lib := DynamicCuisLibrary
		withClasses: { sourceForLibrary }
		classSelectors: { sourceForLibrary class selectors }
		instanceSelectors: { sourceForLibrary selectors }.

	self assert: lib canBeInstalled.
	lib installLibrary.
	self deny: CompilerWasUsed description: 'Should not use Compiler. Usually it will not be available.'.

	installedSuperclass := Smalltalk at: #DclExample09.
	installedSubclass := Smalltalk at: #DclExample09Subclass.

	self assert: installedSuperclass allInstVarNames equals: #('a' 'b' 'a1' 'a2' 'a3' 'a4' 'a5' 'a6' 'a7' 'a8' 'a9' 'a10' 'a11' 'a12' 'a13' 'a14' 'a15' 'a16' 'a17' 'a18' 'a19' 'a20' 'a21' 'a22' 'a23' 'a24' 'a25' 'a26' 'a27' 'a28' 'a29' 'a30' 'a31' 'a32' 'a33' 'a34' 'a35' 'a36' 'a37' 'a38' 'a39' 'a40' 'a41' 'a42' 'a43' 'a44' 'a45' 'a46' 'a47' 'a48' 'a49' 'a50' 'a51' 'a52' 'a53' 'a54' 'a55' 'a56' 'a57' 'a58' 'a59' 'a60' 'a61' 'a62' 'a63' 'a64' 'a65' 'a66' 'a67' 'a68' 'a69' 'a70' 'a71' 'a72' 'a73' 'a74' 'a75' 'a76' 'a77' 'a78' 'a79' 'a80' 'a81' 'a82' 'a83' 'a84' 'a85' 'a86' 'a87' 'a88' 'a89' 'a90' 'a91' 'a92' 'a93' 'a94' 'a95' 'a96' 'a97' 'a98' 'a99' 'a100' 'a101' 'a102' 'a103' 'a104' 'a105' 'a106' 'a107' 'a108' 'a109' 'a110' 'a111' 'a112' 'a113' 'a114' 'a115' 'a116' 'a117' 'a118' 'a119' 'a120' 'a121' 'a122' 'a123' 'a124' 'a125' 'a126' 'a127' 'a128' 'a129' 'a130' 'a131' 'a132' 'a133' 'a134' 'a135' 'a136' 'a137' 'a138' 'a139' 'a140' 'a141' 'a142' 'a143' 'a144' 'a145' 'a146' 'a147' 'a148' 'a149' 'a150' 'a151' 'a152' 'a153' 'a154' 'a155' 'a156' 'a157' 'a158' 'a159' 'a160' 'a161' 'a162' 'a163' 'a164' 'a165' 'a166' 'a167' 'a168' 'a169' 'a170' 'a171' 'a172' 'a173' 'a174' 'a175' 'a176' 'a177' 'a178' 'a179' 'a180' 'a181' 'a182' 'a183' 'a184' 'a185' 'a186' 'a187' 'a188' 'a189' 'a190' 'a191' 'a192' 'a193' 'a194' 'a195' 'a196' 'a197' 'a198' 'a199' 'a200' 'a201' 'a202' 'a203' 'a204' 'a205' 'a206' 'a207' 'a208' 'a209' 'a210' 'a211' 'a212' 'a213' 'a214' 'a215' 'a216' 'a217' 'a218' 'a219' 'a220' 'a221' 'a222' 'a223' 'a224' 'a225' 'a226' 'a227' 'a228' 'a229' 'a230' 'a231' 'a232' 'a233' 'a234' 'a235' 'a236' 'a237' 'a238' 'a239' 'a240' 'a241' 'a242' 'a243' 'a244' 'a245' 'a246' 'a247' 'a248' 'a249' 'a250' 'a251' 'a252' 'a253' 'a254' 'c').
	self assert: installedSubclass allInstVarNames equals: #('a' 'b' 'a1' 'a2' 'a3' 'a4' 'a5' 'a6' 'a7' 'a8' 'a9' 'a10' 'a11' 'a12' 'a13' 'a14' 'a15' 'a16' 'a17' 'a18' 'a19' 'a20' 'a21' 'a22' 'a23' 'a24' 'a25' 'a26' 'a27' 'a28' 'a29' 'a30' 'a31' 'a32' 'a33' 'a34' 'a35' 'a36' 'a37' 'a38' 'a39' 'a40' 'a41' 'a42' 'a43' 'a44' 'a45' 'a46' 'a47' 'a48' 'a49' 'a50' 'a51' 'a52' 'a53' 'a54' 'a55' 'a56' 'a57' 'a58' 'a59' 'a60' 'a61' 'a62' 'a63' 'a64' 'a65' 'a66' 'a67' 'a68' 'a69' 'a70' 'a71' 'a72' 'a73' 'a74' 'a75' 'a76' 'a77' 'a78' 'a79' 'a80' 'a81' 'a82' 'a83' 'a84' 'a85' 'a86' 'a87' 'a88' 'a89' 'a90' 'a91' 'a92' 'a93' 'a94' 'a95' 'a96' 'a97' 'a98' 'a99' 'a100' 'a101' 'a102' 'a103' 'a104' 'a105' 'a106' 'a107' 'a108' 'a109' 'a110' 'a111' 'a112' 'a113' 'a114' 'a115' 'a116' 'a117' 'a118' 'a119' 'a120' 'a121' 'a122' 'a123' 'a124' 'a125' 'a126' 'a127' 'a128' 'a129' 'a130' 'a131' 'a132' 'a133' 'a134' 'a135' 'a136' 'a137' 'a138' 'a139' 'a140' 'a141' 'a142' 'a143' 'a144' 'a145' 'a146' 'a147' 'a148' 'a149' 'a150' 'a151' 'a152' 'a153' 'a154' 'a155' 'a156' 'a157' 'a158' 'a159' 'a160' 'a161' 'a162' 'a163' 'a164' 'a165' 'a166' 'a167' 'a168' 'a169' 'a170' 'a171' 'a172' 'a173' 'a174' 'a175' 'a176' 'a177' 'a178' 'a179' 'a180' 'a181' 'a182' 'a183' 'a184' 'a185' 'a186' 'a187' 'a188' 'a189' 'a190' 'a191' 'a192' 'a193' 'a194' 'a195' 'a196' 'a197' 'a198' 'a199' 'a200' 'a201' 'a202' 'a203' 'a204' 'a205' 'a206' 'a207' 'a208' 'a209' 'a210' 'a211' 'a212' 'a213' 'a214' 'a215' 'a216' 'a217' 'a218' 'a219' 'a220' 'a221' 'a222' 'a223' 'a224' 'a225' 'a226' 'a227' 'a228' 'a229' 'a230' 'a231' 'a232' 'a233' 'a234' 'a235' 'a236' 'a237' 'a238' 'a239' 'a240' 'a241' 'a242' 'a243' 'a244' 'a245' 'a246' 'a247' 'a248' 'a249' 'a250' 'a251' 'a252' 'a253' 'a254' 'c' 'd').

	self assert: installedSuperclass selectors asSet equals:
		(sourceForExistingSuperclass selectors, sourceForLibrary selectors) asSet.
	self assert: installedSuperclass class selectors asSet equals:
		(sourceForExistingSuperclass class selectors, sourceForLibrary class selectors) asSet.
	self assert: installedSuperclass class >> #new equals: sourceForLibrary class >> #new.
	self deny: (installedSuperclass >> #initialize) = (sourceForLibrary >> #initialize)
		description: 'Installed methods should be corrected for class shape due to different shape if base system'.
	self assert: installedSuperclass >> #a equals: sourceForLibrary >> #a.
	self assert: installedSuperclass >> #c equals: sourceForLibrary >> #c.
	self deny: (installedSuperclass >> #combined) = (sourceForExistingSuperclass >> #combined).
	self deny: (installedSuperclass >> #combined) = (sourceForLibrary >> #combined)
		description: 'Installed methods should be corrected for class shape due to different shape if base system'.
	self assert: installedSuperclass >> #maxVal equals: sourceForLibrary >> #maxVal.
	self assert: installedSuperclass >> #someLiteral equals: sourceForLibrary >> #someLiteral.
	self assert: installedSuperclass >> #xk47 equals: sourceForExistingSuperclass >> #xk47.

	self assert: installedSubclass selectors equals: sourceForExistingSubclass selectors.
	self assert: installedSubclass class selectors equals: sourceForExistingSubclass class selectors.
	self deny: (installedSubclass >> #initialize) = (sourceForExistingSubclass >> #initialize)
		description: 'Methods should be corrected for class shape due to new instance variable in superclass'.
	self deny: (installedSubclass >> #d) = (sourceForExistingSubclass >> #d)
		description: 'Methods should be corrected for class shape due to new instance variable in superclass'.
	self deny: (installedSubclass >> #combined) = (sourceForExistingSubclass >> #combined)
		description: 'Methods should be corrected for class shape due to new instance variable in superclass'.

	self assert: installedSuperclass new a equals: 1.
	self assert: installedSuperclass new b equals: 2.
	self assert: installedSuperclass new c equals: 3.
	self assert: (installedSuperclass new instVarNamed: 'a') equals: 1.
	self assert: (installedSuperclass new instVarNamed: 'b') equals: 2.
	self assert: (installedSuperclass new instVarNamed: 'c') equals: 3.
	self assert: installedSuperclass new combined equals: 123.
	self assert: installedSuperclass new maxVal equals: SmallInteger maxVal.
	self assert: installedSuperclass new someLiteral equals: sourceForLibrary new someLiteral.
	self assert: installedSuperclass new xk47 equals: 'xk47'.

	self assert: installedSubclass new a equals: 1.
	self assert: installedSubclass new b equals: 2.
	self assert: installedSubclass new c equals: 3.
	self assert: installedSubclass new d equals: 4.
	self assert: (installedSubclass new instVarNamed: 'a') equals: 1.
	self assert: (installedSubclass new instVarNamed: 'b') equals: 2.
	self assert: (installedSubclass new instVarNamed: 'c') equals: 3.
	self assert: (installedSubclass new instVarNamed: 'd') equals: 4.
	self assert: installedSubclass new combined equals: 124 + 123.
	self assert: installedSubclass new maxVal equals: SmallInteger maxVal.
	self assert: installedSubclass new someLiteral equals: sourceForLibrary new someLiteral.
	self assert: installedSubclass new xk47 equals: 'xk47'.

	Smalltalk at: #DclExample09Subclass ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
	Smalltalk at: #DclExample09 ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
]

{ #category : 'tests 09' }
DclTest >> test09EExistingClassOldIvarMissingShouldConvertNewMethods [
	"The library is unaware of one of the instance variables in the existing class.
	Installation should succeed.
	Methods in the subclass that came from the library should be adjusted to access the correct instance variables,
		because they were created unaware of the 'missing' instance variable.
	Similar to test08EExistingClassOldIvarMissingShouldConvertNewMethods, but converting between 1-byte and 4-byte opcodes,
	something that can only be done with the Sista Bytecodes Set."

	| sourceForExistingSuperclass sourceForExistingSubclass existingSuperclass existingSubclass
	 sourceForLibrarySubclass lib installedSubclass |

	"Create pre-existing version of classes."
	Smalltalk at: #DclExample09Subclass ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
	Smalltalk at: #DclExample09 ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
	sourceForExistingSuperclass := NoclashABC_DclExample09.
	sourceForExistingSubclass := NoclashABCD_DclExample09Subclass.
	(DynamicCuisLibrary
		withClasses: { sourceForExistingSuperclass. sourceForExistingSubclass }
		classSelectors: { sourceForExistingSuperclass class selectors. sourceForExistingSubclass class selectors }
		instanceSelectors: { sourceForExistingSuperclass selectors. sourceForExistingSubclass selectors }) installLibrary.
	existingSuperclass := Smalltalk at: #DclExample09.
	existingSubclass := Smalltalk at: #DclExample09Subclass.
	self assert: existingSuperclass allInstVarNames equals: #('a' 'a1' 'a2' 'a3' 'a4' 'a5' 'a6' 'a7' 'a8' 'a9' 'a10' 'a11' 'a12' 'a13' 'a14' 'a15' 'a16' 'a17' 'a18' 'a19' 'a20' 'a21' 'a22' 'a23' 'a24' 'a25' 'a26' 'a27' 'a28' 'a29' 'a30' 'a31' 'a32' 'a33' 'a34' 'a35' 'a36' 'a37' 'a38' 'a39' 'a40' 'a41' 'a42' 'a43' 'a44' 'a45' 'a46' 'a47' 'a48' 'a49' 'a50' 'a51' 'a52' 'a53' 'a54' 'a55' 'a56' 'a57' 'a58' 'a59' 'a60' 'a61' 'a62' 'a63' 'a64' 'a65' 'a66' 'a67' 'a68' 'a69' 'a70' 'a71' 'a72' 'a73' 'a74' 'a75' 'a76' 'a77' 'a78' 'a79' 'a80' 'a81' 'a82' 'a83' 'a84' 'a85' 'a86' 'a87' 'a88' 'a89' 'a90' 'a91' 'a92' 'a93' 'a94' 'a95' 'a96' 'a97' 'a98' 'a99' 'a100' 'a101' 'a102' 'a103' 'a104' 'a105' 'a106' 'a107' 'a108' 'a109' 'a110' 'a111' 'a112' 'a113' 'a114' 'a115' 'a116' 'a117' 'a118' 'a119' 'a120' 'a121' 'a122' 'a123' 'a124' 'a125' 'a126' 'a127' 'a128' 'a129' 'a130' 'a131' 'a132' 'a133' 'a134' 'a135' 'a136' 'a137' 'a138' 'a139' 'a140' 'a141' 'a142' 'a143' 'a144' 'a145' 'a146' 'a147' 'a148' 'a149' 'a150' 'a151' 'a152' 'a153' 'a154' 'a155' 'a156' 'a157' 'a158' 'a159' 'a160' 'a161' 'a162' 'a163' 'a164' 'a165' 'a166' 'a167' 'a168' 'a169' 'a170' 'a171' 'a172' 'a173' 'a174' 'a175' 'a176' 'a177' 'a178' 'a179' 'a180' 'a181' 'a182' 'a183' 'a184' 'a185' 'a186' 'a187' 'a188' 'a189' 'a190' 'a191' 'a192' 'a193' 'a194' 'a195' 'a196' 'a197' 'a198' 'a199' 'a200' 'a201' 'a202' 'a203' 'a204' 'a205' 'a206' 'a207' 'a208' 'a209' 'a210' 'a211' 'a212' 'a213' 'a214' 'a215' 'a216' 'a217' 'a218' 'a219' 'a220' 'a221' 'a222' 'a223' 'a224' 'a225' 'a226' 'a227' 'a228' 'a229' 'a230' 'a231' 'a232' 'a233' 'a234' 'a235' 'a236' 'a237' 'a238' 'a239' 'a240' 'a241' 'a242' 'a243' 'a244' 'a245' 'a246' 'a247' 'a248' 'a249' 'a250' 'a251' 'a252' 'a253' 'a254' 'b' 'c').
	self assert: existingSubclass allInstVarNames equals: #('a' 'a1' 'a2' 'a3' 'a4' 'a5' 'a6' 'a7' 'a8' 'a9' 'a10' 'a11' 'a12' 'a13' 'a14' 'a15' 'a16' 'a17' 'a18' 'a19' 'a20' 'a21' 'a22' 'a23' 'a24' 'a25' 'a26' 'a27' 'a28' 'a29' 'a30' 'a31' 'a32' 'a33' 'a34' 'a35' 'a36' 'a37' 'a38' 'a39' 'a40' 'a41' 'a42' 'a43' 'a44' 'a45' 'a46' 'a47' 'a48' 'a49' 'a50' 'a51' 'a52' 'a53' 'a54' 'a55' 'a56' 'a57' 'a58' 'a59' 'a60' 'a61' 'a62' 'a63' 'a64' 'a65' 'a66' 'a67' 'a68' 'a69' 'a70' 'a71' 'a72' 'a73' 'a74' 'a75' 'a76' 'a77' 'a78' 'a79' 'a80' 'a81' 'a82' 'a83' 'a84' 'a85' 'a86' 'a87' 'a88' 'a89' 'a90' 'a91' 'a92' 'a93' 'a94' 'a95' 'a96' 'a97' 'a98' 'a99' 'a100' 'a101' 'a102' 'a103' 'a104' 'a105' 'a106' 'a107' 'a108' 'a109' 'a110' 'a111' 'a112' 'a113' 'a114' 'a115' 'a116' 'a117' 'a118' 'a119' 'a120' 'a121' 'a122' 'a123' 'a124' 'a125' 'a126' 'a127' 'a128' 'a129' 'a130' 'a131' 'a132' 'a133' 'a134' 'a135' 'a136' 'a137' 'a138' 'a139' 'a140' 'a141' 'a142' 'a143' 'a144' 'a145' 'a146' 'a147' 'a148' 'a149' 'a150' 'a151' 'a152' 'a153' 'a154' 'a155' 'a156' 'a157' 'a158' 'a159' 'a160' 'a161' 'a162' 'a163' 'a164' 'a165' 'a166' 'a167' 'a168' 'a169' 'a170' 'a171' 'a172' 'a173' 'a174' 'a175' 'a176' 'a177' 'a178' 'a179' 'a180' 'a181' 'a182' 'a183' 'a184' 'a185' 'a186' 'a187' 'a188' 'a189' 'a190' 'a191' 'a192' 'a193' 'a194' 'a195' 'a196' 'a197' 'a198' 'a199' 'a200' 'a201' 'a202' 'a203' 'a204' 'a205' 'a206' 'a207' 'a208' 'a209' 'a210' 'a211' 'a212' 'a213' 'a214' 'a215' 'a216' 'a217' 'a218' 'a219' 'a220' 'a221' 'a222' 'a223' 'a224' 'a225' 'a226' 'a227' 'a228' 'a229' 'a230' 'a231' 'a232' 'a233' 'a234' 'a235' 'a236' 'a237' 'a238' 'a239' 'a240' 'a241' 'a242' 'a243' 'a244' 'a245' 'a246' 'a247' 'a248' 'a249' 'a250' 'a251' 'a252' 'a253' 'a254' 'b' 'c' 'd').
	self assert: existingSuperclass new a equals: 1.
	self assert: existingSuperclass new c equals: 3.
	self assert: existingSuperclass new combined equals: 123.
	self assert: existingSubclass new a equals: 1.
	self assert: existingSubclass new c equals: 3.
	self assert: existingSubclass new d equals: 4.
	self assert: existingSubclass new combined equals: 1234 + 123.

	"Create library. Class we are installed misses one instance variable (in the superclass actually).
	Neither class shape should be modified."
	sourceForLibrarySubclass := NoclashABD_DclExample09Subclass.
	lib := DynamicCuisLibrary
		withClasses: { sourceForLibrarySubclass }
		classSelectors: { sourceForLibrarySubclass class selectors }
		instanceSelectors: { sourceForLibrarySubclass selectors }.

	self assert: lib canBeInstalled.
	lib installLibrary.
	self deny: CompilerWasUsed description: 'Should not use Compiler. Usually it will not be available.'.

	installedSubclass := Smalltalk at: #DclExample09Subclass.
	self assert: existingSuperclass allInstVarNames equals: #('a' 'a1' 'a2' 'a3' 'a4' 'a5' 'a6' 'a7' 'a8' 'a9' 'a10' 'a11' 'a12' 'a13' 'a14' 'a15' 'a16' 'a17' 'a18' 'a19' 'a20' 'a21' 'a22' 'a23' 'a24' 'a25' 'a26' 'a27' 'a28' 'a29' 'a30' 'a31' 'a32' 'a33' 'a34' 'a35' 'a36' 'a37' 'a38' 'a39' 'a40' 'a41' 'a42' 'a43' 'a44' 'a45' 'a46' 'a47' 'a48' 'a49' 'a50' 'a51' 'a52' 'a53' 'a54' 'a55' 'a56' 'a57' 'a58' 'a59' 'a60' 'a61' 'a62' 'a63' 'a64' 'a65' 'a66' 'a67' 'a68' 'a69' 'a70' 'a71' 'a72' 'a73' 'a74' 'a75' 'a76' 'a77' 'a78' 'a79' 'a80' 'a81' 'a82' 'a83' 'a84' 'a85' 'a86' 'a87' 'a88' 'a89' 'a90' 'a91' 'a92' 'a93' 'a94' 'a95' 'a96' 'a97' 'a98' 'a99' 'a100' 'a101' 'a102' 'a103' 'a104' 'a105' 'a106' 'a107' 'a108' 'a109' 'a110' 'a111' 'a112' 'a113' 'a114' 'a115' 'a116' 'a117' 'a118' 'a119' 'a120' 'a121' 'a122' 'a123' 'a124' 'a125' 'a126' 'a127' 'a128' 'a129' 'a130' 'a131' 'a132' 'a133' 'a134' 'a135' 'a136' 'a137' 'a138' 'a139' 'a140' 'a141' 'a142' 'a143' 'a144' 'a145' 'a146' 'a147' 'a148' 'a149' 'a150' 'a151' 'a152' 'a153' 'a154' 'a155' 'a156' 'a157' 'a158' 'a159' 'a160' 'a161' 'a162' 'a163' 'a164' 'a165' 'a166' 'a167' 'a168' 'a169' 'a170' 'a171' 'a172' 'a173' 'a174' 'a175' 'a176' 'a177' 'a178' 'a179' 'a180' 'a181' 'a182' 'a183' 'a184' 'a185' 'a186' 'a187' 'a188' 'a189' 'a190' 'a191' 'a192' 'a193' 'a194' 'a195' 'a196' 'a197' 'a198' 'a199' 'a200' 'a201' 'a202' 'a203' 'a204' 'a205' 'a206' 'a207' 'a208' 'a209' 'a210' 'a211' 'a212' 'a213' 'a214' 'a215' 'a216' 'a217' 'a218' 'a219' 'a220' 'a221' 'a222' 'a223' 'a224' 'a225' 'a226' 'a227' 'a228' 'a229' 'a230' 'a231' 'a232' 'a233' 'a234' 'a235' 'a236' 'a237' 'a238' 'a239' 'a240' 'a241' 'a242' 'a243' 'a244' 'a245' 'a246' 'a247' 'a248' 'a249' 'a250' 'a251' 'a252' 'a253' 'a254' 'b' 'c').
	self assert: installedSubclass allInstVarNames equals: #('a' 'a1' 'a2' 'a3' 'a4' 'a5' 'a6' 'a7' 'a8' 'a9' 'a10' 'a11' 'a12' 'a13' 'a14' 'a15' 'a16' 'a17' 'a18' 'a19' 'a20' 'a21' 'a22' 'a23' 'a24' 'a25' 'a26' 'a27' 'a28' 'a29' 'a30' 'a31' 'a32' 'a33' 'a34' 'a35' 'a36' 'a37' 'a38' 'a39' 'a40' 'a41' 'a42' 'a43' 'a44' 'a45' 'a46' 'a47' 'a48' 'a49' 'a50' 'a51' 'a52' 'a53' 'a54' 'a55' 'a56' 'a57' 'a58' 'a59' 'a60' 'a61' 'a62' 'a63' 'a64' 'a65' 'a66' 'a67' 'a68' 'a69' 'a70' 'a71' 'a72' 'a73' 'a74' 'a75' 'a76' 'a77' 'a78' 'a79' 'a80' 'a81' 'a82' 'a83' 'a84' 'a85' 'a86' 'a87' 'a88' 'a89' 'a90' 'a91' 'a92' 'a93' 'a94' 'a95' 'a96' 'a97' 'a98' 'a99' 'a100' 'a101' 'a102' 'a103' 'a104' 'a105' 'a106' 'a107' 'a108' 'a109' 'a110' 'a111' 'a112' 'a113' 'a114' 'a115' 'a116' 'a117' 'a118' 'a119' 'a120' 'a121' 'a122' 'a123' 'a124' 'a125' 'a126' 'a127' 'a128' 'a129' 'a130' 'a131' 'a132' 'a133' 'a134' 'a135' 'a136' 'a137' 'a138' 'a139' 'a140' 'a141' 'a142' 'a143' 'a144' 'a145' 'a146' 'a147' 'a148' 'a149' 'a150' 'a151' 'a152' 'a153' 'a154' 'a155' 'a156' 'a157' 'a158' 'a159' 'a160' 'a161' 'a162' 'a163' 'a164' 'a165' 'a166' 'a167' 'a168' 'a169' 'a170' 'a171' 'a172' 'a173' 'a174' 'a175' 'a176' 'a177' 'a178' 'a179' 'a180' 'a181' 'a182' 'a183' 'a184' 'a185' 'a186' 'a187' 'a188' 'a189' 'a190' 'a191' 'a192' 'a193' 'a194' 'a195' 'a196' 'a197' 'a198' 'a199' 'a200' 'a201' 'a202' 'a203' 'a204' 'a205' 'a206' 'a207' 'a208' 'a209' 'a210' 'a211' 'a212' 'a213' 'a214' 'a215' 'a216' 'a217' 'a218' 'a219' 'a220' 'a221' 'a222' 'a223' 'a224' 'a225' 'a226' 'a227' 'a228' 'a229' 'a230' 'a231' 'a232' 'a233' 'a234' 'a235' 'a236' 'a237' 'a238' 'a239' 'a240' 'a241' 'a242' 'a243' 'a244' 'a245' 'a246' 'a247' 'a248' 'a249' 'a250' 'a251' 'a252' 'a253' 'a254' 'b' 'c' 'd').
	self assert: existingSuperclass new a equals: 1.
	self assert: existingSuperclass new c equals: 3.
	self assert: (existingSuperclass new instVarNamed: 'a') equals: 1.
	self assert: (existingSuperclass new instVarNamed: 'b') equals: 2.
	self assert: (existingSuperclass new instVarNamed: 'c') equals: 3.
	self assert: existingSuperclass new combined equals: 123.
	self assert: installedSubclass new a equals: 1.
	self assert: installedSubclass new b equals: 2.
	self assert: installedSubclass new c equals: 3.
	self assert: installedSubclass new d equals: 4.
	self assert: (installedSubclass new instVarNamed: 'a') equals: 1.
	self assert: (installedSubclass new instVarNamed: 'b') equals: 2.
	self assert: (installedSubclass new instVarNamed: 'c') equals: 3.
	self assert: (installedSubclass new instVarNamed: 'd') equals: 4.
	self assert: installedSubclass new combined equals: 124 + 123.

	Smalltalk at: #DclExample09Subclass ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
	Smalltalk at: #DclExample09 ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
]
