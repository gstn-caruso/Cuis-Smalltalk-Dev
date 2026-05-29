"
A nice deep blue theme.
"
Class {
	#name : 'DarkBlueTheme',
	#superclass : 'Theme',
	#category : 'Theme-Themes',
	#package : 'Theme',
	#tag : 'Themes'
}

{ #category : 'colors' }
DarkBlueTheme >> buttonLabel [
	^ `Color hue: 212 chroma: 0.3 luminance: 0.8`
]

{ #category : 'tool colors' }
DarkBlueTheme >> defaultWindowColor [
	^ `Color hue: 212 chroma: 0.6 luminance: 0.24`
]

{ #category : 'menu colors' }
DarkBlueTheme >> menu [
	^ `Color hue: 212 chroma: 0.6 luminance: 0.3`
]

{ #category : 'menu colors' }
DarkBlueTheme >> menuText [
	^ `Color hue: 212 chroma: 0.3 luminance: 0.8`
]

{ #category : 'menu colors' }
DarkBlueTheme >> menuTitleBar [
	^ `(Color hue: 212 chroma: 0.6 luminance: 0.3) twiceDarker`
]

{ #category : 'colors' }
DarkBlueTheme >> paneBackgroundFrom: aColor [
	^ `(Color hue: 212 chroma: 0.8 luminance: 0.4) muchDarker`
]

{ #category : 'colors' }
DarkBlueTheme >> shout [
	"Color symbols as an association list."

	^ {
		#selector  						-> nil.
		#arguments 						-> #white.
		#comment 						-> #(green lighter).
		#tempBar 						-> #(gray quiteWhiter).
		#tempVars 						-> #(gray quiteWhiter).
		#instVar 						-> #(magenta quiteWhiter).
		#pseudoVariables 						-> #(red veryMuchLighter).
		#literals 						-> #(green veryMuchLighter).
		#messages 						-> #(cyan).
		#incompleteMessages 						-> #(gray veryMuchDarker).
		#blockLevelZero 						-> #black.
		#blockLevelOne 						-> #brown.
		#blockLevelTwo 						-> #magenta.
		#blockLevelThree 						-> #red.
		#blockLevelFour 						-> #(green darker).
		#blockLevelFive 						-> #(red darker).
		#blockLevelSix 						-> #(magenta darker).
		#blockLevelSeven 						-> #blue.
		#defaults 						-> #white.
		#undefined 						-> #(orange lighter).
		#methodTags 						-> #(green lighter).
	}
]

{ #category : 'colors' }
DarkBlueTheme >> text [
	^ `Color hue: 212 chroma: 0.3 luminance: 0.8`
]

{ #category : 'colors' }
DarkBlueTheme >> textHighlight [
	^ `Color hue: 212 chroma: 0.4 luminance: 0.3`
]

{ #category : 'colors' }
DarkBlueTheme >> unfocusedTextHighlightFrom: aColor [
	^aColor adjustSaturation: 0.0 brightness: 0.08
]

{ #category : 'other options' }
DarkBlueTheme >> useUniformColors [
	^true
]

{ #category : 'colors' }
DarkBlueTheme >> windowLabel [
	^ `Color hue: 212 chroma: 0.4 luminance: 0.6`
]
