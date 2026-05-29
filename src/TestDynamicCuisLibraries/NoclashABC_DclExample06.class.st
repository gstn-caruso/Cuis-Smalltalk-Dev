Class {
	#name : 'NoclashABC_DclExample06',
	#superclass : 'Object',
	#instVars : [
		'a',
		'b',
		'c'
	],
	#category : 'TestDynamicCuisLibraries-SubjectClasses06',
	#package : 'TestDynamicCuisLibraries',
	#tag : 'SubjectClasses06'
}

{ #category : 'accessing' }
NoclashABC_DclExample06 >> a [
	^a
]

{ #category : 'accessing' }
NoclashABC_DclExample06 >> b [
	^b
]

{ #category : 'accessing' }
NoclashABC_DclExample06 >> c [
	^c
]

{ #category : 'other' }
NoclashABC_DclExample06 >> combined [
	 ^ a * 10 + b * 10 + c.
]

{ #category : 'initialization' }
NoclashABC_DclExample06 >> initialize [
	a := 1.
	b := 2.
	c := 3.
]

{ #category : 'other' }
NoclashABC_DclExample06 >> maxVal [
	^SmallInteger maxVal.
]

{ #category : 'other' }
NoclashABC_DclExample06 >> someLiteral [
	^#(1 31 #aSymbol #otherSymbol)
]
