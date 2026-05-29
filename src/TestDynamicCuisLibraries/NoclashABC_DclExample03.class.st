Class {
	#name : 'NoclashABC_DclExample03',
	#superclass : 'Object',
	#instVars : [
		'a',
		'b',
		'c'
	],
	#category : 'TestDynamicCuisLibraries-SubjectClasses03',
	#package : 'TestDynamicCuisLibraries',
	#tag : 'SubjectClasses03'
}

{ #category : 'instance creation' }
NoclashABC_DclExample03 class >> new [
	^ self basicNew initialize
]

{ #category : 'accessing' }
NoclashABC_DclExample03 >> a [
	^a
]

{ #category : 'accessing' }
NoclashABC_DclExample03 >> b [
	^b
]

{ #category : 'accessing' }
NoclashABC_DclExample03 >> c [
	^c
]

{ #category : 'other' }
NoclashABC_DclExample03 >> combined [
	 ^ a * 10 + b * 10 + c.
]

{ #category : 'initialization' }
NoclashABC_DclExample03 >> initialize [
	a := 1.
	b := 2.
	c := 3.
]

{ #category : 'other' }
NoclashABC_DclExample03 >> maxVal [
	^SmallInteger maxVal.
]

{ #category : 'other' }
NoclashABC_DclExample03 >> someLiteral [
	^#(1 31 #aSymbol #otherSymbol)
]
