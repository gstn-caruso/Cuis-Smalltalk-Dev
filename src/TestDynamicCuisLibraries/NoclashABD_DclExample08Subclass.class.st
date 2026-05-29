Class {
	#name : 'NoclashABD_DclExample08Subclass',
	#superclass : 'NoclashAB_DclExample08',
	#instVars : [
		'd'
	],
	#category : 'TestDynamicCuisLibraries-SubjectClasses08',
	#package : 'TestDynamicCuisLibraries',
	#tag : 'SubjectClasses08'
}

{ #category : 'other' }
NoclashABD_DclExample08Subclass >> combined [
	 ^ a * 10 + b * 10 + d + super combined
]

{ #category : 'accessing' }
NoclashABD_DclExample08Subclass >> d [
	^d
]

{ #category : 'initialization' }
NoclashABD_DclExample08Subclass >> initialize [
	super initialize.
	d := 4.
]
