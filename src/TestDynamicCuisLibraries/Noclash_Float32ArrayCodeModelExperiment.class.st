Class {
	#name : 'Noclash_Float32ArrayCodeModelExperiment',
	#superclass : 'FloatArray',
	#category : 'TestDynamicCuisLibraries-SubjectClassesBasic',
	#package : 'TestDynamicCuisLibraries',
	#tag : 'SubjectClassesBasic'
}

{ #category : 'accessing' }
Noclash_Float32ArrayCodeModelExperiment >> floatAt: index [
	<primitive: 'primitiveAt' module: 'FloatArrayPlugin'>
]

{ #category : 'accessing' }
Noclash_Float32ArrayCodeModelExperiment >> floatAt: index put: value [
	<primitive: 'primitiveAtPut' module: 'FloatArrayPlugin'>
]
