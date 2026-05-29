Class {
	#name : 'NoclashExisting_DclExample02',
	#superclass : 'Object',
	#instVars : [
		'a',
		'b',
		'c'
	],
	#classInstVars : [
		'aa',
		'bb'
	],
	#category : 'TestDynamicCuisLibraries-SubjectClasses02',
	#package : 'TestDynamicCuisLibraries',
	#tag : 'SubjectClasses02'
}

{ #category : 'other' }
NoclashExisting_DclExample02 class >> combinedCIvars [
	^aa + bb
]

{ #category : 'instance creation' }
NoclashExisting_DclExample02 class >> new [
	^ self basicNew initialize.
]

{ #category : 'other' }
NoclashExisting_DclExample02 class >> processor [
	^ nil.
]

{ #category : 'other' }
NoclashExisting_DclExample02 class >> setClassIVars [
	aa := 3.
	bb := 4.
]

{ #category : 'accessing' }
NoclashExisting_DclExample02 >> b [
	^ b.
]

{ #category : 'other' }
NoclashExisting_DclExample02 >> combined [
	^ 47
]

{ #category : 'initialization' }
NoclashExisting_DclExample02 >> initialize [
	a _ 1.
	b _ 2.
	c _ 3.
]

{ #category : 'other' }
NoclashExisting_DclExample02 >> maxVal [
	^ SmallInteger maxVal-1.
]

{ #category : 'other' }
NoclashExisting_DclExample02 >> someLiteral [
	^#(22 33)
]
