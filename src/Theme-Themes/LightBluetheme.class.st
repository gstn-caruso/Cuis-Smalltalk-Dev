"
A nice deep blue theme.
"
Class {
	#name : 'LightBluetheme',
	#superclass : 'Theme',
	#category : 'Theme-Themes',
	#package : 'Theme',
	#tag : 'Themes'
}

{ #category : 'colors' }
LightBluetheme >> buttonLabel [
	^ Color hue: 0 chroma: 0 luminance: 0.13
]

{ #category : 'tool colors' }
LightBluetheme >> debugger [
	^ Color lightYellow
	
]

{ #category : 'tool colors' }
LightBluetheme >> defaultWindowColor [
	"^ Color hue: 0 chroma: 0 luminance: 1."
	^ Color r: 0.686 g: 0.796 b: 0.910
]

{ #category : 'menu colors' }
LightBluetheme >> menu [
	"^ Color hue: 212 chroma: 0.6 luminance: 0.3"
		^ Color r: 0.686 g: 0.796 b: 0.910
]

{ #category : 'menu colors' }
LightBluetheme >> menuText [
	"^ Color hue: 212 chroma: 0.3 luminance: 0.8"
		^ Color hue: 0 chroma: 0 luminance: 0.13
]

{ #category : 'menu colors' }
LightBluetheme >> menuTitleBar [
	^ self menu twiceDarker
]

{ #category : 'colors' }
LightBluetheme >> paneBackgroundFrom: aColor [
	^ Color hue: 0 chroma: 0 luminance: 1.
	"^ (Color hue: 212 chroma: 0.8 luminance: 0.4) muchDarker"
]

{ #category : 'colors' }
LightBluetheme >> shout [
	"Color symbols as an association list."

	^ {
		#selector  					-> nil.
		#arguments 					-> #(cyan muchDarker).
		#comment 					-> #(green muchDarker).
		#tempBar 					-> #gray.
		#tempVars 					-> #(gray muchDarker).
		#instVar 					-> #(magenta muchDarker).
		#pseudoVariables 			-> #(red muchDarker).
		#literals 					-> #(green muchDarker).
		#messages 					-> #(blue darker).
		#incompleteMessages  	-> #(gray veryMuchDarker).
		#blockLevelZero 			-> #black.
		#blockLevelOne 			-> #brown.
		#blockLevelTwo 			-> #magenta.
		#blockLevelThree 			-> #red.
		#blockLevelFour 			-> #(green darker).
		#blockLevelFive 			-> #(orange darker).
		#blockLevelSix 			-> #(magenta darker).
		#blockLevelSeven 			-> #blue.
		#defaults 					-> #black.
		#undefined 					-> #red.
		#methodTags 				-> #(green muchDarker).
	}
]

{ #category : 'colors' }
LightBluetheme >> text [
	^ Color hue: 0 chroma: 0 luminance: 0.13
]

{ #category : 'colors' }
LightBluetheme >> textHighlight [
	"^ Color hue: 0 chroma: 0.56 luminance: 0.45"
	^ Color r: 0 g: 0.584 b: 0.8.
]

{ #category : 'colors' }
LightBluetheme >> textHighlightFocused: focused [
	"A nice light blue."
	| textHighlight |
	Display depth = 1 ifTrue: [^ Color veryVeryLightGray].
	Display depth = 2 ifTrue: [^ Color gray: 0.87].
	textHighlight := self textHighlight.
	^focused
		ifTrue: [ textHighlight ]
		ifFalse: [ self unfocusedTextHighlightFrom: textHighlight ]
]

{ #category : 'colors' }
LightBluetheme >> unfocusedTextHighlightFrom: aColor [
	^aColor adjustSaturation: 0.0 brightness: 0.08
]

{ #category : 'other options' }
LightBluetheme >> useUniformColors [
	^true
]

{ #category : 'colors' }
LightBluetheme >> windowLabel [
	"^ Color hue: 0 chroma: 0.56 luminance: 0.45	"
	^ Color r: 0.2 g: 0.2 b: 0.2
]
