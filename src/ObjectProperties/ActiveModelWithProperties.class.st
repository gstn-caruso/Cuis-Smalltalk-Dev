Class {
	#name : 'ActiveModelWithProperties',
	#superclass : 'ActiveModel',
	#instVars : [
		'propertyMap'
	],
	#category : 'ObjectProperties',
	#package : 'ObjectProperties'
}

{ #category : 'copying' }
ActiveModelWithProperties >> postCopy [
	super postCopy.
	propertyMap := nil
]

{ #category : 'accessing' }
ActiveModelWithProperties >> propertyMap [
	propertyMap ifNil: [
		propertyMap := IdentityDictionary new ].
	^propertyMap
]

{ #category : 'accessing' }
ActiveModelWithProperties >> propertyMapOrNil [
	^propertyMap
]

{ #category : 'accessing' }
ActiveModelWithProperties >> releasePropertyMap [
	propertyMap := nil
]
