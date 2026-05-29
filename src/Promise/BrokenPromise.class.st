"
I am signalled when, during a Promise>>wait, the promise is rejected.	promise:		the promise itself.
"
Class {
	#name : 'BrokenPromise',
	#superclass : 'Error',
	#instVars : [
		'promise'
	],
	#category : 'Promise',
	#package : 'Promise'
}

{ #category : 'as yet unclassified' }
BrokenPromise >> defaultAction [
	self messageText: 'Promise was rejected'.
	^super defaultAction
]

{ #category : 'as yet unclassified' }
BrokenPromise >> isResumable [
	^ true
]

{ #category : 'as yet unclassified' }
BrokenPromise >> promise [
	^ promise
]

{ #category : 'as yet unclassified' }
BrokenPromise >> promise: aPromise [
	promise := aPromise
]
