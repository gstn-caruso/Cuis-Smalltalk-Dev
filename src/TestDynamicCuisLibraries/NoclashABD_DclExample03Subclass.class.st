Class {
	#name : 'NoclashABD_DclExample03Subclass',
	#superclass : 'NoclashAB_DclExample03',
	#instVars : [
		'd'
	],
	#category : 'TestDynamicCuisLibraries-SubjectClasses03',
	#package : 'TestDynamicCuisLibraries',
	#tag : 'SubjectClasses03'
}

{ #category : 'other' }
NoclashABD_DclExample03Subclass >> combined [
	 ^ a * 10 + b * 10 + d + super combined
]

{ #category : 'accessing' }
NoclashABD_DclExample03Subclass >> d [
	^d
]

{ #category : 'initialization' }
NoclashABD_DclExample03Subclass >> initialize [
	super initialize.
	d := 4.
]
