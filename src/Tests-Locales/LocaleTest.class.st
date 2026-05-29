"
A unit test class for class Locale
"
Class {
	#name : 'LocaleTest',
	#superclass : 'TestCase',
	#category : 'Tests-Locales',
	#package : 'Tests',
	#tag : 'Locales'
}

{ #category : 'tests' }
LocaleTest >> testCurrent [

	self assert: Locale current notNil
	
]
