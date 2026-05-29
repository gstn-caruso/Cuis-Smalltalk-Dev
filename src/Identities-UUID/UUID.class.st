"
A class to generate UUID
by John M McIntosh johnmci@smalltalkconsulting.com

See http://www.webdav.org/specs/draft-leach-uuids-guids-01.txt

If a plugin does not exist then we generate a UUID version 4 type GUUID
"
Class {
	#name : 'UUID',
	#superclass : 'ByteArray',
	#category : 'Identities-UUID',
	#package : 'Identities',
	#tag : 'UUID'
}

{ #category : 'instance creation' }
UUID class >> fromString: aString [
	| object |
	aString size ~= 36 ifTrue: [Error signal].
	object := self nilUUID. 
	object asUUID: aString.
	^object
]

{ #category : 'instance creation' }
UUID class >> nilUUID [
	"Must call basicNew: here because I have a non-trivial initialize method."

	^self basicNew: 16
]

{ #category : 'instance creation' }
UUID class >> numElements [
	^16
]

{ #category : 'comparing' }
UUID >> < aMagnitude  [
	"Answer whether the receiver is less than the argument."

	| x y |
	1 to: self size do: [ :i |
		(x := self at: i) = (y := aMagnitude at: i) ifFalse: [ ^x < y ] ].
	^false.
]

{ #category : 'comparing' }
UUID >> <= aMagnitude  [
	"Answer whether the receiver is less than or equal to the argument."

	^(self > aMagnitude) not
]

{ #category : 'comparing' }
UUID >> > aMagnitude  [
	"Answer whether the receiver is greater than the argument."

	^aMagnitude < self
]

{ #category : 'comparing' }
UUID >> >= aMagnitude  [
	"Answer whether the receiver is greater than or equal to the argument."

	^(self < aMagnitude) not
]

{ #category : 'converting' }
UUID >> asString [
	^String streamContents: [ :result |
		1 to: 4 do:[:i| self printHexAt: i to: result].
		result nextPut: $-.
		5 to: 6 do:[:i| self printHexAt: i to: result].
		result nextPut: $-.
		7 to: 8 do:[:i| self printHexAt: i to: result].
		result nextPut: $-.
		9 to: 10 do:[:i| self printHexAt: i to: result].
		result nextPut: $-.
		11 to: 16 do:[:i| self printHexAt: i to: result]].
]

{ #category : 'converting' }
UUID >> asUUID: aString [
	| stream token byte |
	stream := ReadStream on: (aString copyReplaceAll: '-' with: '') asUppercase.
	1 to: stream size/2 do: [:i | 
		token := stream next: 2.
		byte := Integer readFrom: (ReadStream on: token ) base: 16.
		self at: i put: byte].
	^self

]

{ #category : 'initalize-release' }
UUID >> initialize [
	self primMakeUUID.
]

{ #category : 'testing' }
UUID >> isNilUUID [
	1 to: self size do: [:i | (self at: i) ~= 0 ifTrue: [^false]].
	^true.
]

{ #category : 'system primitives' }
UUID >> primMakeUUID [
	<primitive: 'primitiveMakeUUID' module: 'UUIDPlugin'>
	UUIDGenerator default generateBytes: self forVersion: 4.
]

{ #category : 'converting' }
UUID >> printHexAt: index to: aStream [
	| map v |
	map := '0123456789abcdef'.
	v := self at: index.
	aStream nextPut: (map at: (v bitShift: -4) + 1). 
	aStream nextPut: (map at: (v bitAnd: 15) + 1).

]

{ #category : 'printing' }
UUID >> printOn: aStream [
	aStream nextPutAll: 'an UUID('.
	self asString printOn: aStream.
	aStream nextPutAll: ')'
]

{ #category : 'printing' }
UUID >> printString [
	^self asString
]
