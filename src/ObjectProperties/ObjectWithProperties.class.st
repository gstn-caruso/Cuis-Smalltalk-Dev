Class {
	#name : 'ObjectWithProperties',
	#superclass : 'Object',
	#instVars : [
		'propertyMap'
	],
	#classVars : [
		'PropertyMaps'
	],
	#category : 'ObjectProperties',
	#package : 'ObjectProperties'
}

{ #category : 'accessing' }
ObjectWithProperties class >> propertyMapFor: anObject [

	^self propertyMaps
		at: anObject
		ifAbsentOrNilPut: [ IdentityDictionary new ]
]

{ #category : 'accessing' }
ObjectWithProperties class >> propertyMapOrNilFor: anObject [

	^self propertyMaps
		at: anObject
		ifAbsent: nil
]

{ #category : 'accessing' }
ObjectWithProperties class >> propertyMaps [

	PropertyMaps ifNil: [
		PropertyMaps := EphemeronIdentityDictionary new.
		].
	^PropertyMaps
]

{ #category : 'releasing' }
ObjectWithProperties class >> releasePropertyMapFor: anObject [

	self propertyMaps
		at: anObject
		put: nil
]

{ #category : 'copying' }
ObjectWithProperties >> postCopy [
	propertyMap := nil
]

{ #category : 'accessing' }
ObjectWithProperties >> propertyMap [
	propertyMap ifNil: [
		propertyMap := IdentityDictionary new ].
	^propertyMap
]

{ #category : 'accessing' }
ObjectWithProperties >> propertyMapOrNil [
	^propertyMap
]

{ #category : 'accessing' }
ObjectWithProperties >> releasePropertyMap [
	propertyMap := nil
]
