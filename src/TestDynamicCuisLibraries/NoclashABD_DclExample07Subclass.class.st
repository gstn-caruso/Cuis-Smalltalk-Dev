Class {
	#name : 'NoclashABD_DclExample07Subclass',
	#superclass : 'NoclashAB_DclExample07',
	#instVars : [
		'd'
	],
	#category : 'TestDynamicCuisLibraries-SubjectClasses07',
	#package : 'TestDynamicCuisLibraries',
	#tag : 'SubjectClasses07'
}

{ #category : 'other' }
NoclashABD_DclExample07Subclass >> combined [
	 ^ a * 10 + b * 10 + d + super combined
]

{ #category : 'accessing' }
NoclashABD_DclExample07Subclass >> d [
	^d
]

{ #category : 'initialization' }
NoclashABD_DclExample07Subclass >> initialize [
	super initialize.
	d := 4.
]
