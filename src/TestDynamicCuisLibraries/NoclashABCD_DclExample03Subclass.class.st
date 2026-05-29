Class {
	#name : 'NoclashABCD_DclExample03Subclass',
	#superclass : 'NoclashABC_DclExample03',
	#instVars : [
		'd'
	],
	#category : 'TestDynamicCuisLibraries-SubjectClasses03',
	#package : 'TestDynamicCuisLibraries',
	#tag : 'SubjectClasses03'
}

{ #category : 'other' }
NoclashABCD_DclExample03Subclass >> combined [
	 ^ a * 10 + b * 10 + c * 10 + d + super combined
]

{ #category : 'accessing' }
NoclashABCD_DclExample03Subclass >> d [
	^d
]

{ #category : 'initialization' }
NoclashABCD_DclExample03Subclass >> initialize [
	super initialize.
	d := 4.
]
