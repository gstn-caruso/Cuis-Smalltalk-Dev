"
Most colors are the based on ColorTheme:
	baseColor adjustSaturation: -0.1 brightness: -0.7
"
Class {
	#name : 'DarkColorTheme',
	#superclass : 'Theme',
	#category : 'Theme-Themes',
	#package : 'Theme',
	#tag : 'Themes'
}

{ #category : 'colors' }
DarkColorTheme >> background [
	^ `Color darkGray`
]

{ #category : 'tool colors' }
DarkColorTheme >> browser [
	^ `Color r: 0.255 g: 0.3 b: 0.21`
]

{ #category : 'colors' }
DarkColorTheme >> buttonLabel [
	^ `Color gray: 0.8`
]

{ #category : 'tool colors' }
DarkColorTheme >> debugger [
	^ `Color r: 0.3 g: 0.27 b: 0.27`
]

{ #category : 'tool colors' }
DarkColorTheme >> fileContentsBrowser [
	^ `Color r: 0.1 g: 0.1 b: 0.072`
]

{ #category : 'tool colors' }
DarkColorTheme >> fileList [
	^ `Color r: 0.4 g: 0.36 b: 0.4`
]

{ #category : 'menu colors' }
DarkColorTheme >> menu [
	^ `Color gray`
]

{ #category : 'menu colors' }
DarkColorTheme >> menuText [
	^ `Color gray: 0.9`
]

{ #category : 'tool colors' }
DarkColorTheme >> messageNames [
	^ `Color r: 0.213 g: 0.3 b: 0.165`
]

{ #category : 'tool colors' }
DarkColorTheme >> messageSet [
	^ `Color r: 0.27 g: 0.3 b: 0.3`
]

{ #category : 'tool colors' }
DarkColorTheme >> object [
	^ `Color r: 0.3 g: 0.298 b: 0.298`
]

{ #category : 'tool colors' }
DarkColorTheme >> packageList [
	^ `Color r: 0.2 g: 0.16 b: 0.04`
]

{ #category : 'colors' }
DarkColorTheme >> paneBackgroundFrom: aColor [
	^ (aColor adjustSaturation: -0.2 brightness: 0.3) alpha: 0.9
]

{ #category : 'tool colors' }
DarkColorTheme >> testRunner [
	^ `Color r: 0.211 g: 0.232 b: 0.276`
]

{ #category : 'tool colors' }
DarkColorTheme >> transcript [
	^ `Color r: 0.3 g: 0.25 b: 0.15`
]

{ #category : 'tool colors' }
DarkColorTheme >> versionsBrowser [
	^ `Color r: 0.277 g: 0.256 b: 0.3`
]

{ #category : 'colors' }
DarkColorTheme >> windowLabel [
	^ `Color gray: 0.6`
]

{ #category : 'tool colors' }
DarkColorTheme >> workspace [
	^ `Color r: 0.3 g: 0.3 b: 0.27`
]
