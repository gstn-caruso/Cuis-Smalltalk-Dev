"
A class used for testing structures as arguments for the FFI.
"
Class {
	#name : 'FFITestPoint2',
	#superclass : 'ExternalStructure',
	#category : 'Tests-FFI',
	#package : 'Tests',
	#tag : 'FFI'
}

{ #category : 'field definition' }
FFITestPoint2 class >> fields [
	"FFITestPoint2 defineFields"
	^#(
		(x	'int32')
		(y	'int32')
	)
]

{ #category : 'class initialization' }
FFITestPoint2 class >> initialize [
	self compileFields
]

{ #category : 'accessing' }
FFITestPoint2 >> x [
	"This method was automatically generated. See FFITestPoint2 class>>fields."
	<generated>
	^handle int32At: 1
]

{ #category : 'accessing' }
FFITestPoint2 >> x: anObject [
	"This method was automatically generated. See FFITestPoint2 class>>fields."
	<generated>
	handle int32At: 1 put: anObject
]

{ #category : 'accessing' }
FFITestPoint2 >> y [
	"This method was automatically generated. See FFITestPoint2 class>>fields."
	<generated>
	^handle int32At: 5
]

{ #category : 'accessing' }
FFITestPoint2 >> y: anObject [
	"This method was automatically generated. See FFITestPoint2 class>>fields."
	<generated>
	handle int32At: 5 put: anObject
]
