Class {
	#name : 'ColorTest',
	#superclass : 'TestCase',
	#category : 'Tests-Color-Extras',
	#package : 'Tests',
	#tag : 'Color-Extras'
}

{ #category : 'tests' }
ColorTest >> testIsGrey [

	self assert: Color black isGrey.
	self assert: Color grey isGrey.
	self assert: Color white isGrey.
	self deny: Color red isGrey.
	self deny: Color green isGrey.
	self deny: Color blue isGrey
]
