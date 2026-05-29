"
A light gray theme. Easy on those who are used to using gray operating systems and such.
"
Class {
	#name : 'LightGrayTheme',
	#superclass : 'Theme',
	#category : 'Theme-Themes',
	#package : 'Theme',
	#tag : 'Themes'
}

{ #category : 'tool colors' }
LightGrayTheme >> defaultWindowColor [
	^ `Color gray: 0.85`
]

{ #category : 'other options' }
LightGrayTheme >> roundedButtonRadius [
	"Only effective if #roundButtons answers true.
	Provide a reasonable default for subclasses."
	^ 5
]

{ #category : 'other options' }
LightGrayTheme >> roundedWindowRadius [
	"Only effective if #roundWindowCorners answers true.
	Provide a reasonable default for subclasses."
	^ 5
]

{ #category : 'other options' }
LightGrayTheme >> useUniformColors [
	^true
]
