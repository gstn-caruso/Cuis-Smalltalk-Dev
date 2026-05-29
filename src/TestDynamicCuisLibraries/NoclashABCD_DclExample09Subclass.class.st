Class {
	#name : 'NoclashABCD_DclExample09Subclass',
	#superclass : 'NoclashABC_DclExample09',
	#instVars : [
		'd'
	],
	#category : 'TestDynamicCuisLibraries-SubjectClasses09',
	#package : 'TestDynamicCuisLibraries',
	#tag : 'SubjectClasses09'
}

{ #category : 'accessing' }
NoclashABCD_DclExample09Subclass >> bb [
	^b
]

{ #category : 'other' }
NoclashABCD_DclExample09Subclass >> combined [
	 ^ a * 10 + b * 10 + c * 10 + d + super combined
]

{ #category : 'accessing' }
NoclashABCD_DclExample09Subclass >> d [
	^d
]

{ #category : 'initialization' }
NoclashABCD_DclExample09Subclass >> initialize [
	super initialize.
	d := 4.
]
