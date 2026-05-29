"
A very gray theme. Easy on those who are used to using gray operating systems and such.
"
Class {
	#name : 'LightTheme',
	#superclass : 'Theme',
	#category : 'Theme-Themes',
	#package : 'Theme',
	#tag : 'Themes'
}

{ #category : 'other options' }
LightTheme >> useUniformColors [
	^true
]

{ #category : 'colors' }
LightTheme >> windowLabel [
	^ `Color gray: 0.3`
]
