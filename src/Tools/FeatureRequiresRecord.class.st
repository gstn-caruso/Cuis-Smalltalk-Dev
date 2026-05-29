Class {
	#name : 'FeatureRequiresRecord',
	#superclass : 'ChangeListElement',
	#instVars : [
		'feature'
	],
	#category : 'Tools-Changes',
	#package : 'Tools',
	#tag : 'Changes'
}

{ #category : 'perform' }
FeatureRequiresRecord >> addToCodeFile: aCodeFile [
	"Part of building a CodeFile object to represent changes and show them in a CodeFileBrowser."

	aCodeFile requires: self.
]

{ #category : 'accessing' }
FeatureRequiresRecord >> feature [
	^feature
]

{ #category : 'accessing' }
FeatureRequiresRecord >> feature: aFeature [
	feature := aFeature.
]

{ #category : 'fileIn/fileOut' }
FeatureRequiresRecord >> fileIn [
	
	"It does nothing - Hernan"
]

{ #category : 'fileIn/fileOut' }
FeatureRequiresRecord >> fileOutOn: aFileStream [

	"Nothing to file out - Hernan"
]

{ #category : 'accessing' }
FeatureRequiresRecord >> string [
	^ 'requires: ', feature printString
]
