Class {
	#name : 'FFISmallStruct1',
	#superclass : 'ExternalStructure',
	#category : 'Tests-FFI',
	#package : 'Tests',
	#tag : 'FFI'
}

{ #category : 'as yet unclassified' }
FFISmallStruct1 class >> fields [
	"FFISmallStruct1 defineFields"
	^#(
		(x	'uint8')
		(y	'uint8')
	)
]

{ #category : 'class initialization' }
FFISmallStruct1 class >> initialize [
	self compileFields
]

{ #category : 'accessing' }
FFISmallStruct1 >> x [
	"This method was automatically generated. See FFISmallStruct1 class>>fields."
	<generated>
	^handle uint8At: 1
]

{ #category : 'accessing' }
FFISmallStruct1 >> x: anObject [
	"This method was automatically generated. See FFISmallStruct1 class>>fields."
	<generated>
	handle uint8At: 1 put: anObject
]

{ #category : 'accessing' }
FFISmallStruct1 >> y [
	"This method was automatically generated. See FFISmallStruct1 class>>fields."
	<generated>
	^handle uint8At: 2
]

{ #category : 'accessing' }
FFISmallStruct1 >> y: anObject [
	"This method was automatically generated. See FFISmallStruct1 class>>fields."
	<generated>
	handle uint8At: 2 put: anObject
]
