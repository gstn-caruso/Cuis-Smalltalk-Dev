"
A class used for testing structures as arguments for the FFI.
"
Class {
	#name : 'FFITestPoint4',
	#superclass : 'ExternalStructure',
	#category : 'Tests-FFI',
	#package : 'Tests',
	#tag : 'FFI'
}

{ #category : 'field definition' }
FFITestPoint4 class >> fields [
	"FFITestPoint4 defineFields"
	^#(
		(x	'int32')
		(y	'int32')
		(z	'int32')
		(w	'int32')
	)
]

{ #category : 'class initialization' }
FFITestPoint4 class >> initialize [
	self compileFields
]

{ #category : 'accessing' }
FFITestPoint4 >> w [
	"This method was automatically generated. See FFITestPoint4 class>>fields."
	<generated>
	^handle int32At: 13
]

{ #category : 'accessing' }
FFITestPoint4 >> w: anObject [
	"This method was automatically generated. See FFITestPoint4 class>>fields."
	<generated>
	handle int32At: 13 put: anObject
]

{ #category : 'accessing' }
FFITestPoint4 >> x [
	"This method was automatically generated. See FFITestPoint4 class>>fields."
	<generated>
	^handle int32At: 1
]

{ #category : 'accessing' }
FFITestPoint4 >> x: anObject [
	"This method was automatically generated. See FFITestPoint4 class>>fields."
	<generated>
	handle int32At: 1 put: anObject
]

{ #category : 'accessing' }
FFITestPoint4 >> y [
	"This method was automatically generated. See FFITestPoint4 class>>fields."
	<generated>
	^handle int32At: 5
]

{ #category : 'accessing' }
FFITestPoint4 >> y: anObject [
	"This method was automatically generated. See FFITestPoint4 class>>fields."
	<generated>
	handle int32At: 5 put: anObject
]

{ #category : 'accessing' }
FFITestPoint4 >> z [
	"This method was automatically generated. See FFITestPoint4 class>>fields."
	<generated>
	^handle int32At: 9
]

{ #category : 'accessing' }
FFITestPoint4 >> z: anObject [
	"This method was automatically generated. See FFITestPoint4 class>>fields."
	<generated>
	handle int32At: 9 put: anObject
]
