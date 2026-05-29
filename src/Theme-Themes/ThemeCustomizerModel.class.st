Class {
	#name : 'ThemeCustomizerModel',
	#superclass : 'ActiveModel',
	#category : 'Theme-Themes',
	#package : 'Theme',
	#tag : 'Themes'
}

{ #category : 'change colors' }
ThemeCustomizerModel >> changeBackground: arguments [
	
	| backgroundColor row |
	backgroundColor := arguments first.
	row := arguments second.
	PersonalizedTheme changeBackgroundColorTo: backgroundColor.
	PersonalizedTheme beCurrent.
	row color: backgroundColor.
]

{ #category : 'change colors' }
ThemeCustomizerModel >> changeLabels: arguments [

	| labelsColor row |
	labelsColor := arguments first.
	row := arguments second.
	PersonalizedTheme changeLabelsColorTo: labelsColor.
	PersonalizedTheme beCurrent.
	row color: labelsColor.
]

{ #category : 'change colors' }
ThemeCustomizerModel >> changePrimary: arguments [

	| primaryColor row |
	primaryColor := arguments first.
	row := arguments second.
	PersonalizedTheme changePrimaryColorTo: primaryColor.
	PersonalizedTheme beCurrent.
	row color: primaryColor.
]

{ #category : 'change colors' }
ThemeCustomizerModel >> changeSecondary: arguments [

	| secondaryColor row |
	secondaryColor := arguments first.
	row := arguments second.
	PersonalizedTheme changeSecondaryColorTo: secondaryColor.
	PersonalizedTheme beCurrent.
	row color: secondaryColor.
]

{ #category : 'change colors' }
ThemeCustomizerModel >> changeText: arguments [

	| textColor row |
	textColor := arguments first.
	row := arguments second.
	PersonalizedTheme changeTextColorTo: textColor.
	PersonalizedTheme beCurrent.
	row color: textColor.
]
