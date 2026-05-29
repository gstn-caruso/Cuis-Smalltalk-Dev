"
Used in FFI unit test(s)
"
Class {
	#name : 'FFITestBiggerStruct',
	#superclass : 'ExternalStructure',
	#category : 'Tests-FFI',
	#package : 'Tests',
	#tag : 'FFI'
}

{ #category : 'field definition' }
FFITestBiggerStruct class >> fields [
	"FFITestBiggerStruct defineFields"
	^#(
		(x	'int64')
		(y	'int64')
		(z	'int64')
		(w	'int64')
		(r  	'int64')
		(s  	'int64')
		(t  	'int64')
		(u  	'int64')
	)
]

{ #category : 'class initialization' }
FFITestBiggerStruct class >> initialize [
"
	self defineFields; compileFields.
"
	self compileFields
]

{ #category : 'accessing' }
FFITestBiggerStruct >> r [
	"This method was automatically generated. See FFITestBiggerStruct class>>fields."
	<generated>
	^handle int64At: 33
]

{ #category : 'accessing' }
FFITestBiggerStruct >> r: anObject [
	"This method was automatically generated. See FFITestBiggerStruct class>>fields."
	<generated>
	handle int64At: 33 put: anObject
]

{ #category : 'accessing' }
FFITestBiggerStruct >> s [
	"This method was automatically generated. See FFITestBiggerStruct class>>fields."
	<generated>
	^handle int64At: 41
]

{ #category : 'accessing' }
FFITestBiggerStruct >> s: anObject [
	"This method was automatically generated. See FFITestBiggerStruct class>>fields."
	<generated>
	handle int64At: 41 put: anObject
]

{ #category : 'accessing' }
FFITestBiggerStruct >> t [
	"This method was automatically generated. See FFITestBiggerStruct class>>fields."
	<generated>
	^handle int64At: 49
]

{ #category : 'accessing' }
FFITestBiggerStruct >> t: anObject [
	"This method was automatically generated. See FFITestBiggerStruct class>>fields."
	<generated>
	handle int64At: 49 put: anObject
]

{ #category : 'accessing' }
FFITestBiggerStruct >> u [
	"This method was automatically generated. See FFITestBiggerStruct class>>fields."
	<generated>
	^handle int64At: 57
]

{ #category : 'accessing' }
FFITestBiggerStruct >> u: anObject [
	"This method was automatically generated. See FFITestBiggerStruct class>>fields."
	<generated>
	handle int64At: 57 put: anObject
]

{ #category : 'accessing' }
FFITestBiggerStruct >> w [
	"This method was automatically generated. See FFITestBiggerStruct class>>fields."
	<generated>
	^handle int64At: 25
]

{ #category : 'accessing' }
FFITestBiggerStruct >> w: anObject [
	"This method was automatically generated. See FFITestBiggerStruct class>>fields."
	<generated>
	handle int64At: 25 put: anObject
]

{ #category : 'accessing' }
FFITestBiggerStruct >> x [
	"This method was automatically generated. See FFITestBiggerStruct class>>fields."
	<generated>
	^handle int64At: 1
]

{ #category : 'accessing' }
FFITestBiggerStruct >> x: anObject [
	"This method was automatically generated. See FFITestBiggerStruct class>>fields."
	<generated>
	handle int64At: 1 put: anObject
]

{ #category : 'accessing' }
FFITestBiggerStruct >> y [
	"This method was automatically generated. See FFITestBiggerStruct class>>fields."
	<generated>
	^handle int64At: 9
]

{ #category : 'accessing' }
FFITestBiggerStruct >> y: anObject [
	"This method was automatically generated. See FFITestBiggerStruct class>>fields."
	<generated>
	handle int64At: 9 put: anObject
]

{ #category : 'accessing' }
FFITestBiggerStruct >> z [
	"This method was automatically generated. See FFITestBiggerStruct class>>fields."
	<generated>
	^handle int64At: 17
]

{ #category : 'accessing' }
FFITestBiggerStruct >> z: anObject [
	"This method was automatically generated. See FFITestBiggerStruct class>>fields."
	<generated>
	handle int64At: 17 put: anObject
]
