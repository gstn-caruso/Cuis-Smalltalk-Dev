Class {
	#name : 'NoclashAB_DclExample03',
	#superclass : 'Object',
	#instVars : [
		'a',
		'b'
	],
	#category : 'TestDynamicCuisLibraries-SubjectClasses03',
	#package : 'TestDynamicCuisLibraries',
	#tag : 'SubjectClasses03'
}

{ #category : 'instance creation' }
NoclashAB_DclExample03 class >> new [
	^ self basicNew initialize.
]

{ #category : 'accessing' }
NoclashAB_DclExample03 >> b [
	^ b.
]

{ #category : 'other' }
NoclashAB_DclExample03 >> combined [
	 ^ a * 10 + b
]

{ #category : 'initialization' }
NoclashAB_DclExample03 >> initialize [
	a := 7.
	b := 9.
]

{ #category : 'other' }
NoclashAB_DclExample03 >> xk47 [
	^'xk47'
]
