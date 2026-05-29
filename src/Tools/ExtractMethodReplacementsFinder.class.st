Class {
	#name : 'ExtractMethodReplacementsFinder',
	#superclass : 'ReplacementsFinder',
	#instVars : [
		'newMessage'
	],
	#category : 'Tools-Refactoring',
	#package : 'Tools',
	#tag : 'Refactoring'
}

{ #category : 'instance creation' }
ExtractMethodReplacementsFinder class >> ofCodeIn: anIntervalToExtract at: aMethod to: aNewMessage [
	
	^self new initializeOfCodeIn: anIntervalToExtract at: aMethod to: aNewMessage 
]

{ #category : 'private-replacement finding' }
ExtractMethodReplacementsFinder >> createReplacementAt: foundIntervalToExtract in: aMethod [
	
	^ExtractMethodReplacement 
		fromInterval: foundIntervalToExtract asSourceCodeInterval 
		of: aMethod asMethodReference 
		to: newMessage
		
]

{ #category : 'private-replacement finding' }
ExtractMethodReplacementsFinder >> find [

	sourceMethod methodClass withAllSubclassesDo: [ :aClass | self findReplacementsAt: aClass]
]

{ #category : 'private-replacement finding' }
ExtractMethodReplacementsFinder >> findReplacementsAt: aClass [

	"I live this implementationt instead of 
	
	aClass methodsDo: findingStrategy
	
	for debugging porpouses. We can do Through with this one - Hernan"
	aClass methodsDo: [ :aMethod | findingStrategy value: aMethod ]
	
]

{ #category : 'initialization' }
ExtractMethodReplacementsFinder >> initializeOfCodeIn: anIntervalToExtract at: aMethod to: aNewMessage [
	
	intervalToExtract := anIntervalToExtract.
	sourceMethod := aMethod.
	newMessage := aNewMessage 
]

{ #category : 'replacements' }
ExtractMethodReplacementsFinder >> methodsToReplace [
	
	^replacements collect: [ :aReplacement | aReplacement methodToExtractFrom ]
]

{ #category : 'replacements' }
ExtractMethodReplacementsFinder >> originalSelectionReplacement [
	
	^ExtractMethodReplacement fromInterval: intervalToExtract of: sourceMethod to: newMessage 
]
