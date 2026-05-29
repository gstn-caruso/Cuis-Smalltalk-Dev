Extension { #name : 'Object' }

{ #category : '*ObjectProperties-querying / testing' }
Object >> hasProperty: aSymbol [

	^self propertyMapOrNil
		ifNil: false
		ifNotNil: [ :map | map includesKey: aSymbol ]
]

{ #category : '*ObjectProperties-querying / testing' }
Object >> propertyAt: aSymbol [

	^self propertyMapOrNil ifNotNil: [ :map |
		map at: aSymbol ifAbsent: nil ]
]

{ #category : '*ObjectProperties-querying / testing' }
Object >> propertyAt: aSymbol ifAbsent: absentBlock [

	^self propertyMapOrNil
		ifNil: absentBlock
		ifNotNil: [ :map |
			map at: aSymbol ifAbsent: absentBlock ]
]

{ #category : '*ObjectProperties-adding / removing' }
Object >> propertyAt: aSymbol ifAbsentPut: aBlock [
	^self propertyMap at: aSymbol ifAbsentPut: aBlock
]

{ #category : '*ObjectProperties-querying / testing' }
Object >> propertyAt: aSymbol ifPresentDo: presentBlock [

	^self propertyMapOrNil
		ifNotNil: [ :map |
			map at: aSymbol ifPresent: presentBlock ]
]

{ #category : '*ObjectProperties-adding / removing' }
Object >> propertyAt: aSymbol put: propertyValue [
	^self propertyMap at: aSymbol put: propertyValue
]

{ #category : '*ObjectProperties-private' }
Object >> propertyMap [
	^ObjectWithProperties propertyMapFor: self
]

{ #category : '*ObjectProperties-private' }
Object >> propertyMapOrNil [
	^ObjectWithProperties propertyMapOrNilFor: self
]

{ #category : '*ObjectProperties-enumerating' }
Object >> propertyNamesAndValuesDo: aBlock [

	^self propertyMapOrNil
		ifNotNil: [ :map | map keysAndValuesDo: aBlock ]
]

{ #category : '*ObjectProperties-enumerating' }
Object >> propertyNamesDo: aBlock [

	^self propertyMapOrNil
		ifNotNil: [ :map | map keysDo: aBlock ]
]

{ #category : '*ObjectProperties-private' }
Object >> releasePropertyMap [
	ObjectWithProperties releasePropertyMapFor: self
]

{ #category : '*ObjectProperties-adding / removing' }
Object >> removeProperty: aSymbol [
	"removes the property named aSymbol if it exists"

	| map |
	map := self propertyMapOrNil.
	map ifNil: [ ^self ].
	map removeKey: aSymbol ifAbsent: nil.
	map isEmpty ifTrue: [
		self releasePropertyMap ].
]
