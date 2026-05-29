Class {
	#name : 'NoclashABCD_DclExample07Subclass',
	#superclass : 'NoclashABC_DclExample07',
	#instVars : [
		'd'
	],
	#category : 'TestDynamicCuisLibraries-SubjectClasses07',
	#package : 'TestDynamicCuisLibraries',
	#tag : 'SubjectClasses07'
}

{ #category : 'other' }
NoclashABCD_DclExample07Subclass >> combined [
	 ^ a * 10 + b * 10 + c * 10 + d + super combined
]

{ #category : 'accessing' }
NoclashABCD_DclExample07Subclass >> d [
	^d
]

{ #category : 'initialization' }
NoclashABCD_DclExample07Subclass >> initialize [
	super initialize.
	d := 4.
]
