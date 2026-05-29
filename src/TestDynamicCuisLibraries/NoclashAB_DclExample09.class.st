Class {
	#name : 'NoclashAB_DclExample09',
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
	#category : 'TestDynamicCuisLibraries-SubjectClasses09',
	#package : 'TestDynamicCuisLibraries',
	#tag : 'SubjectClasses09'
}

{ #category : 'instance creation' }
NoclashAB_DclExample09 class >> new [
	^ self basicNew initialize.
]

{ #category : 'accessing' }
NoclashAB_DclExample09 >> b [
	^ b.
]

{ #category : 'other' }
NoclashAB_DclExample09 >> combined [
	 ^ a * 10 + b
]

{ #category : 'initialization' }
NoclashAB_DclExample09 >> initialize [
	a := 7.
	b := 9.
]

{ #category : 'other' }
NoclashAB_DclExample09 >> xk47 [
	^'xk47'
]
