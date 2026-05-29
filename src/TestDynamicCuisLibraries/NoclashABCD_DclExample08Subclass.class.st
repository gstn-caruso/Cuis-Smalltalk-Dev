Class {
	#name : 'NoclashABCD_DclExample08Subclass',
	#superclass : 'NoclashABC_DclExample08',
	#instVars : [
		'd'
	],
	#category : 'TestDynamicCuisLibraries-SubjectClasses08',
	#package : 'TestDynamicCuisLibraries',
	#tag : 'SubjectClasses08'
}

{ #category : 'other' }
NoclashABCD_DclExample08Subclass >> combined [
	 ^ a * 10 + b * 10 + c * 10 + d + super combined
]

{ #category : 'accessing' }
NoclashABCD_DclExample08Subclass >> d [
	^d
]

{ #category : 'initialization' }
NoclashABCD_DclExample08Subclass >> initialize [
	super initialize.
	d := 4.
]
