Class {
	#name : 'NoclashABD_DclExample09Subclass',
	#superclass : 'NoclashAB_DclExample09',
	#instVars : [
		'd'
	],
	#category : 'TestDynamicCuisLibraries-SubjectClasses09',
	#package : 'TestDynamicCuisLibraries',
	#tag : 'SubjectClasses09'
}

{ #category : 'other' }
NoclashABD_DclExample09Subclass >> combined [
	 ^ a * 10 + b * 10 + d + super combined
]

{ #category : 'accessing' }
NoclashABD_DclExample09Subclass >> d [
	^d
]

{ #category : 'initialization' }
NoclashABD_DclExample09Subclass >> initialize [
	super initialize.
	d := 4.
]
