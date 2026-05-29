Class {
	#name : 'XMLPI',
	#superclass : 'XMLNode',
	#instVars : [
		'target',
		'data'
	],
	#category : 'YAXO',
	#package : 'YAXO'
}

{ #category : 'instance creation' }
XMLPI class >> new [
	"Call #target:data: instead"
	self shouldNotImplement.
]

{ #category : 'instance creation' }
XMLPI class >> target: targetName data: aString [
	^ self basicNew
		target: targetName;
		data: aString.
]

{ #category : 'accessing' }
XMLPI >> data [
	^data
]

{ #category : 'accessing' }
XMLPI >> data: aString [
	data _ aString
]

{ #category : 'testing' }
XMLPI >> isProcessingInstruction [
	^true
]

{ #category : 'printing' }
XMLPI >> printXMLOn: writer [
	writer pi: self target data: self data
]

{ #category : 'accessing' }
XMLPI >> target [
	^target
]

{ #category : 'accessing' }
XMLPI >> target: aString [
	target _ aString
]
