"
Signals that a name lookup operation failed.

	hostName	hostName for which the name loopup failed

"
Class {
	#name : 'NameLookupFailure',
	#superclass : 'NetworkError',
	#instVars : [
		'hostName'
	],
	#category : 'Network-Kernel',
	#package : 'Network',
	#tag : 'Kernel'
}

{ #category : 'instance creation' }
NameLookupFailure class >> hostName: aString [
	^ self new hostName: aString
]

{ #category : 'accessing' }
NameLookupFailure >> defaultAction [
	"Backward compatibility"
	| response |
	response _ (PopUpMenu labels: 'Retry\Give Up' withNewLines)
			startUpWithCaption: self messageText.
	^ response = 2
		ifFalse: [self retry]
]

{ #category : 'accessing' }
NameLookupFailure >> hostName [
	^ hostName
]

{ #category : 'accessing' }
NameLookupFailure >> hostName: aString [
	hostName _ aString
]
