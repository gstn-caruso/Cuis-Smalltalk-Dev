"
This is the theme from Cuis 2.9.


Some of the icons in this theme were originally created with:

	Clipboard default storeObject:
	 	((PNGReadWriter bytesFor: (Form fromFileNamed: 'appearanceIcon.png')) asString base64Encoded)
"
Class {
	#name : 'ClassicTheme',
	#superclass : 'Theme',
	#category : 'Theme-Themes',
	#package : 'Theme',
	#tag : 'Themes'
}

{ #category : 'icons' }
ClassicTheme >> acceptIcon [

	^ self fetch: #( '16x16' 'smalltalk' 'accept' )

]

{ #category : 'icons' }
ClassicTheme >> appearanceIcon [

	^ self fetch: #( '16x16' 'apps' 'preferences-desktop-theme' )

]

{ #category : 'colors' }
ClassicTheme >> buttonLabel [
	^ `Color black`
]

{ #category : 'icons' }
ClassicTheme >> cancelIcon [

	^ self fetch: #( '16x16' 'smalltalk' 'cancel' )

]

{ #category : 'icons' }
ClassicTheme >> closeIcon [

	^ self fetch: #( '10x10' 'buttons' 'close' )

]

{ #category : 'icons' }
ClassicTheme >> collapseIcon [

	^ self fetch: #( '10x10' 'buttons' 'collapse' )

]

{ #category : 'icons' }
ClassicTheme >> copyIcon [

	^ self fetch: #( '16x16' 'actions' 'edit-copy' )

]

{ #category : 'icons' }
ClassicTheme >> cutIcon [

	^ self fetch: #( '16x16' 'actions' 'edit-cut' )

]

{ #category : 'icons' }
ClassicTheme >> deleteIcon [

	^ self cutIcon
]

{ #category : 'icons' }
ClassicTheme >> doItIcon [

	^ self fetch: #( '16x16' 'smalltalk' 'do-it' )

]

{ #category : 'other options' }
ClassicTheme >> embossedTitles [
	^false
]

{ #category : 'icons' }
ClassicTheme >> expandIcon [

	^ self fetch: #( '10x10' 'buttons' 'expand' )

]

{ #category : 'icons' }
ClassicTheme >> findIcon [

	^ self fetch: #( '16x16' 'actions' 'edit-find' )

]

{ #category : 'icons' }
ClassicTheme >> helpIcon [

	^ self fetch: #( '16x16' 'apps' 'help-browser' )

]

{ #category : 'icons' }
ClassicTheme >> morphsIcon [

	^ self fetch: #( '16x16' 'smalltalk' 'morphs' )

]

{ #category : 'icons' }
ClassicTheme >> newIcon [

	^ self fetch: #( '16x16' 'actions' 'document-new' )

]

{ #category : 'icons' }
ClassicTheme >> openIcon [

	^ self fetch: #( '16x16' 'actions' 'document-open' )
]

{ #category : 'icons' }
ClassicTheme >> pasteIcon [

	^ self fetch: #( '16x16' 'actions' 'edit-paste' )

]

{ #category : 'icons' }
ClassicTheme >> printIcon [

	^ self fetch: #( '16x16' 'actions' 'document-print-preview' )

]

{ #category : 'icons' }
ClassicTheme >> quitIcon [

	^ self fetch: #( '16x16' 'actions' 'system-log-out' )

]

{ #category : 'icons' }
ClassicTheme >> redoIcon [

	^ self fetch: #( '16x16' 'actions' 'edit-redo' )

]

{ #category : 'other options' }
ClassicTheme >> roundButtons [
	^false
]

{ #category : 'other options' }
ClassicTheme >> roundWindowCorners [
	^false
]

{ #category : 'icons' }
ClassicTheme >> saveAndQuitIcon [

	^ self quitIcon

]

{ #category : 'icons' }
ClassicTheme >> saveAsIcon [

	^ self fetch: #( '16x16' 'actions' 'document-save-as' )
]

{ #category : 'icons' }
ClassicTheme >> saveAsNewVersionIcon [

	^ self saveAsIcon

]

{ #category : 'icons' }
ClassicTheme >> saveIcon [

	^ self fetch: #( '16x16' 'actions' 'document-save' )

]

{ #category : 'icons' }
ClassicTheme >> undoIcon [

	^ self fetch: #( '16x16' 'actions' 'edit-undo' )

]

{ #category : 'icons' }
ClassicTheme >> windowIcon [

	^ self fetch: #( '16x16' 'apps' 'preferences-system-windows' )

]

{ #category : 'other options' }
ClassicTheme >> windowLabel [
	^ `Color black`
]

{ #category : 'icons' }
ClassicTheme >> windowMenuIcon [

	^ self fetch: #( '10x10' 'buttons' 'window-menu' )

]
