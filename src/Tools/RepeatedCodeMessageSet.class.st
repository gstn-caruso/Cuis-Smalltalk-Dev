Class {
	#name : 'RepeatedCodeMessageSet',
	#superclass : 'MethodSet',
	#instVars : [
		'finder',
		'selectedIndex',
		'multimethod'
	],
	#category : 'Tools-Refactoring',
	#package : 'Tools',
	#tag : 'Refactoring'
}

{ #category : 'instance creation' }
RepeatedCodeMessageSet class >> finder: aFinder multimethod: aBoolean [
	
	^(self messageList: aFinder methodsToReplace) initializeFinder: aFinder multimethod: aBoolean
]

{ #category : 'message list' }
RepeatedCodeMessageSet >> doNotRefreshSelection [
	
	selectedIndex := 0
]

{ #category : 'initialization' }
RepeatedCodeMessageSet >> initialize [

	selectedIndex := 0.
	super initialize 
]

{ #category : 'initialization' }
RepeatedCodeMessageSet >> initializeFinder: aFinder multimethod: aBoolean [
	
	finder := aFinder.
	multimethod := aBoolean 
]

{ #category : 'message list' }
RepeatedCodeMessageSet >> isMultimethod [

	^multimethod 
]

{ #category : 'message list' }
RepeatedCodeMessageSet >> messageListIndex [

	^selectedIndex 
]

{ #category : 'message list' }
RepeatedCodeMessageSet >> messageListIndex: anIndex [

	selectedIndex := anIndex.
	super messageListIndex: anIndex.
]

{ #category : 'source code ranges' }
RepeatedCodeMessageSet >> messageSendsRangesOf: aSelector [

	| replacement |
	
	replacement := finder replacementsAt: self messageListIndex ifAbsent: [ ^#()  ].
	
	^Array with: replacement asSourceCodeInterval
]

{ #category : 'message list' }
RepeatedCodeMessageSet >> removeMessageFromBrowserKeepingLabel [

	| newIndex |

	selectedMessage ifNil: [ ^nil ].
	messageList removeIndex: selectedIndex.
	finder removeReplacementAt: selectedIndex.
	self changed: #messageList.
	
	newIndex := selectedIndex > messageList size 
		ifTrue: [ selectedIndex - 1 ]
		ifFalse: [ selectedIndex ].
	self messageListIndex: newIndex.
]
