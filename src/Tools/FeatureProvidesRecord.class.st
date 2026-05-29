Class {
	#name : 'FeatureProvidesRecord',
	#superclass : 'ChangeListElement',
	#instVars : [
		'feature'
	],
	#category : 'Tools-Changes',
	#package : 'Tools',
	#tag : 'Changes'
}

{ #category : 'perform' }
FeatureProvidesRecord >> addToCodeFile: aCodeFile [
	"Part of building a CodeFile object to represent changes and show them in a CodeFileBrowser."

	aCodeFile provides: self.
]

{ #category : 'accessing' }
FeatureProvidesRecord >> feature [
	^feature
]

{ #category : 'accessing' }
FeatureProvidesRecord >> feature: aFeature [
	feature := aFeature.
]

{ #category : 'fileIn/fileOut' }
FeatureProvidesRecord >> fileIn [
	
	"It does nothing - Hernan"
]

{ #category : 'fileIn/fileOut' }
FeatureProvidesRecord >> fileOutOn: aFileStream [

	"Nothing to file out - Hernan"
]

{ #category : 'accessing' }
FeatureProvidesRecord >> string [
	^ 'provides: ', feature printString
]
