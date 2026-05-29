Class {
	#name : 'Noclash_DclExample02',
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
Noclash_DclExample02 class >> combinedCIvars [
	^aa *10 + bb
]

{ #category : 'instance creation' }
Noclash_DclExample02 class >> new [
	^ self basicNew initialize
]

{ #category : 'other' }
Noclash_DclExample02 class >> processor [
	^Processor
]

{ #category : 'other' }
Noclash_DclExample02 class >> setClassIVars [
	aa := 5.
	bb := 7.
]

{ #category : 'accessing' }
Noclash_DclExample02 >> a [
	^a
]

{ #category : 'accessing' }
Noclash_DclExample02 >> b [
	^b
]

{ #category : 'accessing' }
Noclash_DclExample02 >> c [
	^c
]

{ #category : 'other' }
Noclash_DclExample02 >> combined [
	^ self a * 10 + self b * 10 + self c.
]

{ #category : 'initialization' }
Noclash_DclExample02 >> initialize [
	a := 1.
	b := 2.
	c := 3.
]

{ #category : 'other' }
Noclash_DclExample02 >> maxVal [
	^SmallInteger maxVal.
]

{ #category : 'other' }
Noclash_DclExample02 >> someLiteral [
	^#(1 31 #aSymbol #otherSymbol)
]
