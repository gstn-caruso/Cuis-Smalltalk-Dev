"
Bright white theme: good for subclassing.
"
Class {
	#name : 'HighContrastWhiteTheme',
	#superclass : 'Theme',
	#category : 'Theme-Themes',
	#package : 'Theme',
	#tag : 'Themes'
}

{ #category : 'colors' }
HighContrastWhiteTheme >> background [
	^ `Color veryVeryLightGray`
]

{ #category : 'colors' }
HighContrastWhiteTheme >> buttonLabel [
	^ `Color black`
]

{ #category : 'tool colors' }
HighContrastWhiteTheme >> defaultWindowColor [
	^ `Color white duller`
]

{ #category : 'menu colors' }
HighContrastWhiteTheme >> menu [
	^ `Color veryVeryLightGray`
]

{ #category : 'colors' }
HighContrastWhiteTheme >> textCursor [
	^ super textHighlight muchDarker
]

{ #category : 'colors' }
HighContrastWhiteTheme >> textHighlight [
	^ `Color veryVeryLightGray`
]

{ #category : 'other options' }
HighContrastWhiteTheme >> useUniformColors [
	^true
]

{ #category : 'colors' }
HighContrastWhiteTheme >> windowLabel [
	^ `Color black`
]
