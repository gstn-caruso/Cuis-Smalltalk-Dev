Class {
	#name : 'Noclash_DclExample01',
	#superclass : 'Object',
	#instVars : [
		'a',
		'b',
		'c'
	],
	#classVars : [
		'A',
		'B'
	],
	#classInstVars : [
		'aa',
		'bb'
	],
	#category : 'TestDynamicCuisLibraries-SubjectClasses01',
	#package : 'TestDynamicCuisLibraries',
	#tag : 'SubjectClasses01'
}

{ #category : 'other' }
Noclash_DclExample01 class >> combinedCIvars [
	^aa *10 + bb
]

{ #category : 'instance creation' }
Noclash_DclExample01 class >> new [
	^ self basicNew initialize
]

{ #category : 'other' }
Noclash_DclExample01 class >> processor [
	^Processor
]

{ #category : 'other' }
Noclash_DclExample01 class >> setClassIVars [
	aa := 5.
	bb := 7.
]

{ #category : 'accessing' }
Noclash_DclExample01 >> a [
	^a
]

{ #category : 'accessing' }
Noclash_DclExample01 >> b [
	^b
]

{ #category : 'accessing' }
Noclash_DclExample01 >> c [
	^c
]

{ #category : 'other' }
Noclash_DclExample01 >> combined [
	^ self a * 10 + self b * 10 + self c.
]

{ #category : 'initialization' }
Noclash_DclExample01 >> initialize [
	a := 1.
	b := 2.
	c := 3.
]

{ #category : 'other' }
Noclash_DclExample01 >> maxVal [
	^SmallInteger maxVal.
]

{ #category : 'other' }
Noclash_DclExample01 >> someLiteral [
	^#(1 31 #aSymbol #otherSymbol)
]
