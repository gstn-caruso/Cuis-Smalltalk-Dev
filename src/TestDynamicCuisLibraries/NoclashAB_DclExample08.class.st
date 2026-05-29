Class {
	#name : 'NoclashAB_DclExample08',
	#superclass : 'Object',
	#instVars : [
		'a',
		'b',
		'a1',
		'a2',
		'a3',
		'a4',
		'a5',
		'a6',
		'a7',
		'a8',
		'a9',
		'a10'
	],
	#category : 'TestDynamicCuisLibraries-SubjectClasses08',
	#package : 'TestDynamicCuisLibraries',
	#tag : 'SubjectClasses08'
}

{ #category : 'instance creation' }
NoclashAB_DclExample08 class >> new [
	^ self basicNew initialize.
]

{ #category : 'accessing' }
NoclashAB_DclExample08 >> b [
	^ b.
]

{ #category : 'other' }
NoclashAB_DclExample08 >> combined [
	 ^ a * 10 + b
]

{ #category : 'initialization' }
NoclashAB_DclExample08 >> initialize [
	a := 7.
	b := 9.
]

{ #category : 'other' }
NoclashAB_DclExample08 >> xk47 [
	^'xk47'
]
