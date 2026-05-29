Class {
	#name : 'UUIDPrimitivesTest',
	#superclass : 'TestCase',
	#classVars : [
		'Default'
	],
	#category : 'Tests-Identities-UUID',
	#package : 'Tests',
	#tag : 'Identities-UUID'
}

{ #category : 'tests' }
UUIDPrimitivesTest >> testCreation [
	| uuid |
	uuid := UUID new.
	self should: [uuid size = 16].
	self shouldnt: [uuid isNilUUID].
	self should: [uuid asString size = 36].

]

{ #category : 'tests' }
UUIDPrimitivesTest >> testCreationEquality [
	| uuid1 uuid2 |
	uuid1 := UUID new.
	uuid2 := UUID new.
	self should: [uuid1 = uuid1].
	self should: [uuid2 = uuid2].
	self shouldnt: [uuid1 = uuid2].
	self shouldnt: [uuid1 hash = uuid2 hash].

]

{ #category : 'tests' }
UUIDPrimitivesTest >> testCreationFromString [
	| uuid string |
	string := UUID nilUUID asString.
	uuid := UUID fromString: string.
	self should: [uuid size = 16].
	self should: [uuid = UUID nilUUID].
	self should: [uuid isNilUUID].
	self should: [uuid asString size = 36].
	self should: [uuid asArray asSet size = 1].
	self should: [(uuid asArray asSet asArray at: 1) = 0].

]

{ #category : 'tests' }
UUIDPrimitivesTest >> testCreationFromStringNotNil [
	| uuid string |
	string := UUID new asString.
	uuid := UUID fromString: string.
	self should: [uuid size = 16].
	self should: [uuid asString size = 36].


]

{ #category : 'tests' }
UUIDPrimitivesTest >> testCreationNil [
	| uuid |
	uuid := UUID nilUUID.
	self should: [uuid size = 16].
	self should: [uuid isNilUUID].
	self should: [uuid asString size = 36].
	self should: [uuid asArray asSet size = 1].
	self should: [(uuid asArray asSet asArray at: 1) = 0].

]

{ #category : 'tests' }
UUIDPrimitivesTest >> testCreationNodeBased [
	

	(UUID new asString last: 12) = (UUID new asString last: 12) ifFalse: [^self].
	1000 timesRepeat:
		[ | uuid |
		uuid := UUID new.
		self should: [((uuid at: 7) bitAnd: 16rF0) = 16r10].
		self should: [((uuid at: 9) bitAnd: 16rC0) = 16r80]]

]

{ #category : 'tests' }
UUIDPrimitivesTest >> testDuplicationsKinda [
	| check size |

	size := 5000.
	check := Set newWithRoomForMoreThan: size.
	size timesRepeat: 
		[ | uuid |
		uuid := UUID new.
		self shouldnt: [check includes: uuid].
		check add: uuid].
		
]

{ #category : 'tests' }
UUIDPrimitivesTest >> testOrder [
	
	100 timesRepeat:
		[ | uuid1 uuid2 |
		uuid1 := UUID new.
		uuid2 := UUID new.
		(uuid1 asString last: 12) = (uuid2 asString last: 12) ifTrue:
			[self should: [uuid1 < uuid2].
			self should: [uuid2 > uuid1].
			self shouldnt: [uuid1 = uuid2]]]

]
