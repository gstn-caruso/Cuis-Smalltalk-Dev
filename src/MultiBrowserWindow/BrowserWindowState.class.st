Class {
	#name : 'BrowserWindowState',
	#superclass : 'Object',
	#instVars : [
		'model',
		'mainLayout',
		'codePane'
	],
	#category : 'MultiBrowserWindow',
	#package : 'MultiBrowserWindow'
}

{ #category : 'instance creation' }
BrowserWindowState class >> model: aModel mainLayout: aLayout codePane: aCodePane [
	^self new model: aModel mainLayout: aLayout codePane: aCodePane
]

{ #category : 'accessing' }
BrowserWindowState >> browserModel [
	^model
]

{ #category : 'accessing' }
BrowserWindowState >> codePane [
	^codePane
]

{ #category : 'accessing' }
BrowserWindowState >> mainLayout [
	^mainLayout
]

{ #category : 'initialization' }
BrowserWindowState >> model: aModel mainLayout: aLayout codePane: aCodePane [
	model := aModel.
	mainLayout := aLayout.
	codePane := aCodePane.
]
