Class {
	#name : 'Noclash_PointCodeModelExperiment',
	#superclass : 'Object',
	#instVars : [
		'x',
		'y'
	],
	#category : 'TestDynamicCuisLibraries-SubjectClassesBasic',
	#package : 'TestDynamicCuisLibraries',
	#tag : 'SubjectClassesBasic'
}

{ #category : 'instance creation' }
Noclash_PointCodeModelExperiment class >> x: anX y: anY [
	"Answer an instance of me with supplied coordinates."

	^self new initializePvtX: anX y: anY
]

{ #category : 'private - initialization' }
Noclash_PointCodeModelExperiment >> initializePvtX: xValue y: yValue [
	"Points are immutable."
	x := xValue.
	y := yValue
]

{ #category : 'printing' }
Noclash_PointCodeModelExperiment >> printOn: aStream  [
	"The receiver prints on aStream in terms of infix notation."

	x printOn: aStream.
	aStream nextPut: $@.
	y negative ifTrue: [ aStream space ].
	y printOn: aStream
]

{ #category : 'accessing' }
Noclash_PointCodeModelExperiment >> x [
^x
]

{ #category : 'accessing' }
Noclash_PointCodeModelExperiment >> y [
^y
]
