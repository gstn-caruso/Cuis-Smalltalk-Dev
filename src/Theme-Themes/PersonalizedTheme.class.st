Class {
	#name : 'PersonalizedTheme',
	#superclass : 'Theme',
	#classInstVars : [
		'writing',
		'secondary',
		'primary',
		'labels',
		'background',
		'savedThemes'
	],
	#category : 'Theme-Themes',
	#package : 'Theme',
	#tag : 'Themes'
}

{ #category : 'accessing' }
PersonalizedTheme class >> backgroundColor [
	^background.
]

{ #category : 'changes' }
PersonalizedTheme class >> changeBackgroundColorTo: color [
	background := color.
]

{ #category : 'changes' }
PersonalizedTheme class >> changeLabelsColorTo: color [
	labels := color.
]

{ #category : 'changes' }
PersonalizedTheme class >> changePrimaryColorTo: color [
	primary := color.
]

{ #category : 'changes' }
PersonalizedTheme class >> changeSecondaryColorTo: color [
	secondary := color.
]

{ #category : 'changes' }
PersonalizedTheme class >> changeTextColorTo: color [
	writing := color.
]

{ #category : 'manage themes' }
PersonalizedTheme class >> deleteThemeNamed: aName [

	self savedThemes removeKey: aName ifAbsent: [^self].
	
	Transcript show: 'Theme deleted successfully: ', aName; cr.
]

{ #category : 'initialize' }
PersonalizedTheme class >> initialize [
	"^self initializeThemeWithDefaultColors "
]

{ #category : 'initialize' }
PersonalizedTheme class >> initializeThemeWithDefaultColors [
	savedThemes ifNil: [ savedThemes := Dictionary new ].
	background := Theme current background.
	primary := Theme current browser.
	labels := Theme current buttonLabel.
	writing := Theme current text.
	secondary := Theme current workspace.
]

{ #category : 'accessing' }
PersonalizedTheme class >> labelsColor [
	^ labels.
]

{ #category : 'manage themes' }
PersonalizedTheme class >> loadThemeNamed: aThemeName [

	| themeData |
	
	themeData := self savedThemes at: aThemeName ifAbsent: [^self].
	
	self changeBackgroundColorTo: (themeData at: #background).
	self changeLabelsColorTo: (themeData at: #labels).
	self changePrimaryColorTo: (themeData at: #primary).
	self changeSecondaryColorTo: (themeData at: #secondary).
	self changeTextColorTo: (themeData at: #writing).
	
	self beCurrent.
	
	self runningWorld fullRepaintNeeded.
]

{ #category : 'accessing' }
PersonalizedTheme class >> primaryColor [
	^ primary.
]

{ #category : 'manage themes' }
PersonalizedTheme class >> saveCurrentAs: aName [

	| currentSettings |
	
	currentSettings := Dictionary new.
	currentSettings at: #background put: background.
	currentSettings at: #labels put: labels.
	currentSettings at: #primary put: primary.
	currentSettings at: #secondary put: secondary.
	currentSettings at: #writing put: writing.
	
	self savedThemes at: aName put: currentSettings.
	
	Transcript show: 'Theme saved: ', aName; cr.
]

{ #category : 'accessing' }
PersonalizedTheme class >> savedThemes [

	savedThemes ifNil: [ savedThemes := Dictionary new ].
	^ savedThemes
]

{ #category : 'accessing' }
PersonalizedTheme class >> secondaryColor [
	^secondary.
]

{ #category : 'accessing' }
PersonalizedTheme class >> writingColor [
	^writing.
]

{ #category : 'colors' }
PersonalizedTheme >> background [
	^self class backgroundColor.
]

{ #category : 'colors' }
PersonalizedTheme >> browser [
	^ self class primaryColor.
]

{ #category : 'colors' }
PersonalizedTheme >> buttonLabel [
	^ self class labelsColor.
]

{ #category : 'colors' }
PersonalizedTheme >> debugger [
	^(self class primaryColor) alphaMixed: 0.6 with: Color white.
]

{ #category : 'colors' }
PersonalizedTheme >> defaultWindowColor [
	^self class secondaryColor.
]

{ #category : 'other options' }
PersonalizedTheme >> embossedTitles [
	^true
]

{ #category : 'initialization' }
PersonalizedTheme >> initialize [

	PersonalizedTheme backgroundColor ifNil: [
		ThemeCustomizerWindow open.].
]

{ #category : 'colors' }
PersonalizedTheme >> menu [
	^(self class backgroundColor darker) alphaMixed: 0.5 with: Color white
]

{ #category : 'colors' }
PersonalizedTheme >> paneBackgroundFrom: aColor [
	^ (aColor adjustSaturation: -0.5 brightness: 0.3) alphaMixed: 0.55 with: Color white.
]

{ #category : 'other options' }
PersonalizedTheme >> roundWindowCorners [
	^true
]

{ #category : 'colors' }
PersonalizedTheme >> text [
	^ self class writingColor.
]

{ #category : 'colors' }
PersonalizedTheme >> textHighlight [
	^ (self class primaryColor adjustSaturation: 0.05 brightness: 0.2) alphaMixed: 0.6 with: Color white.
]

{ #category : 'colors' }
PersonalizedTheme >> textPane [
	^ (self class primaryColor adjustSaturation: -0.3 brightness: 0.4) alphaMixed: 0.6 with: Color white.
]

{ #category : 'other options' }
PersonalizedTheme >> useUniformColors [
	^true
]

{ #category : 'colors' }
PersonalizedTheme >> versionsBrowser [
	^(self class primaryColor) alphaMixed: 0.6 with: Color white.
]

{ #category : 'colors' }
PersonalizedTheme >> windowLabel [
	^ self class writingColor.
]

{ #category : 'colors' }
PersonalizedTheme >> workspace [
	^ self class secondaryColor.
]
