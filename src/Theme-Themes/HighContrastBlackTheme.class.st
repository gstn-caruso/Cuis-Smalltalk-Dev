"
A very dark, high contrast theme.
"
Class {
	#name : 'HighContrastBlackTheme',
	#superclass : 'Theme',
	#category : 'Theme-Themes',
	#package : 'Theme',
	#tag : 'Themes'
}

{ #category : 'colors' }
HighContrastBlackTheme >> background [
	^ `Color black twiceLighter lighter`
]

{ #category : 'colors' }
HighContrastBlackTheme >> buttonLabel [
	^ `Color white`
]

{ #category : 'tool colors' }
HighContrastBlackTheme >> defaultWindowColor [
	^ `Color veryDarkGray`
]

{ #category : 'colors' }
HighContrastBlackTheme >> focusIndicator [
	^ `Color cyan muchDarker`
]

{ #category : 'colors' }
HighContrastBlackTheme >> listMultiHighlightFocused: aBoolean [
	^ (self listHighlightFocused: aBoolean) 
		adjustSaturation: 0.0 brightness: 0.15
]

{ #category : 'menu colors' }
HighContrastBlackTheme >> menu [
	^ `Color darkGray`
]

{ #category : 'menu colors' }
HighContrastBlackTheme >> menuText [
	^ `Color white`
]

{ #category : 'menu colors' }
HighContrastBlackTheme >> menuTitleBar [
	^ self menu darker
]

{ #category : 'colors' }
HighContrastBlackTheme >> paneBackgroundFrom: aColor [
	^ aColor alphaMixed: 0.7 with: Color black
]

{ #category : 'colors' }
HighContrastBlackTheme >> shout [
	"Color symbols as an association list."

	^ {
		#selector  						-> nil.
		#arguments 						-> #(white darker).
		#comment 						-> #(magenta darker).
		#tempBar 						-> #veryLightGray.
		#tempVars 						-> #veryLightGray.
		#instVar 						-> #(green darker).
		#pseudoVariables 						-> #(cyan darker).
		#literals 						-> #(green darker).
		#messages 						-> #(yellow darker).
		#incompleteMessages  	-> #gray.
		#blockLevelZero 						-> #black.
		#blockLevelOne 						-> #brown.
		#blockLevelTwo 						-> #magenta.
		#blockLevelThree 						-> #red.
		#blockLevelFour 						-> #(magenta).
		#blockLevelFive 						-> #(orange negated).
		#blockLevelSix 						-> #(green).
		#blockLevelSeven 						-> #blue.
		#defaults 						-> #white.
		#undefined 						-> #cyan.
		#methodTags 						-> #(magenta darker).
	}
]

{ #category : 'colors' }
HighContrastBlackTheme >> text [
	^ `Color white`
]

{ #category : 'colors' }
HighContrastBlackTheme >> textCursor [
	^ super textHighlight
]

{ #category : 'colors' }
HighContrastBlackTheme >> textHighlight [
	^ `Color red muchDarker darker`
]

{ #category : 'colors' }
HighContrastBlackTheme >> unfocusedTextHighlightFrom: aColor [
	^aColor adjustSaturation: 0.0 brightness: -0.15
]

{ #category : 'other options' }
HighContrastBlackTheme >> useUniformColors [
	^true
]

{ #category : 'colors' }
HighContrastBlackTheme >> windowLabel [
	^ `Color white`
]
