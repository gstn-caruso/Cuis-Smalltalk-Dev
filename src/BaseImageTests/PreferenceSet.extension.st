Extension { #name : 'PreferenceSet' }

{ #category : '*BaseImageTests' }
PreferenceSet >> withTemporaryValue: temporaryValue of: aPreferenceName do: aBlock [
	"Allows to execute a piece of code with a temporary value of the given preference. Useful for testing purposes."
	
	| currentValue |
	currentValue := self at: aPreferenceName.
	self at: aPreferenceName put: temporaryValue.
	[ aBlock value ] ensure: [ self at: aPreferenceName put: currentValue ]
]
