Class {
	#name : 'CodeModelTest1',
	#superclass : 'TestCase',
	#category : 'TestDynamicCuisLibraries-Tests',
	#package : 'TestDynamicCuisLibraries',
	#tag : 'Tests'
}

{ #category : 'testing' }
CodeModelTest1 >> testAllInstanceSideMethods [
	| classSpecs cmSpecs methods newMethods |
	classSpecs := OrderedDictionary new.
	Object withAllSubclassesDo: [ :cls |
		cls isMeta ifFalse: [
			"Methods in libraries will answer false just for that."
			methods := (cls methodDict select: [ :cm | (cm propertyValueAt: #libraryName) isNil ]) asArray.
			cmSpecs := OrderedCollection new.
			methods do: [ :cm |
				cmSpecs add: (MethodSpec for: cm addClassesTo: classSpecs) ].
			newMethods := cmSpecs collect: [ :methodSpec | methodSpec materializeIn: cls ].
			newMethods with: methods do: [ :newCm :cm |
				self assert: newCm = cm ]]]
]
