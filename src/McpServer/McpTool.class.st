Class {
	#name : 'McpTool',
	#superclass : 'Object',
	#category : 'McpServer-Tools',
	#package : 'McpServer',
	#tag : 'Tools'
}

{ #category : 'accessing' }
McpTool >> asJsonDescription [
	^ {
		'name' -> self name.
		'description' -> self description.
		'inputSchema' -> self inputSchema
	}
]

{ #category : 'private' }
McpTool >> decodeArrayParam: aValue [
	aValue isString ifTrue: [ ^ Json readFrom: aValue readStream ].
	^ aValue
]

{ #category : 'accessing' }
McpTool >> description [
	^ self subclassResponsibility
]

{ #category : 'executing' }
McpTool >> execute: args [
	^ self subclassResponsibility
]

{ #category : 'private' }
McpTool >> executeBatch: items action: aBlock [
	| errorOccurred results |
	errorOccurred := false.
	results := String streamContents: [:out |
		items
			do: [:item |
				out nextPutAll:
					([aBlock value: item]
						on: Error
						do: [:e |
							errorOccurred := true.
							'ERROR: ' , e messageText])]
			separatedBy: [out lf; lf]].
	errorOccurred ifTrue: [McpError signal: results].
	^ results
]

{ #category : 'accessing' }
McpTool >> inputSchema [
	^ self subclassResponsibility
]

{ #category : 'accessing' }
McpTool >> name [
	^ self subclassResponsibility
]

{ #category : 'private' }
McpTool >> resolveClassReference: className [
	^ (Smalltalk classNamed: className) ifNil: [Error signal: 'Unknown class: ' , className]
]

{ #category : 'private' }
McpTool >> split: aString at: aSeparator otherwise: errorBlock [
	| index |
	index := aString indexOfSubCollection: aSeparator startingAt: 1 ifAbsent: [^ errorBlock value].
	^ { (aString copyFrom: 1 to: index - 1). (aString copyFrom: index + aSeparator size to: aString size) }
]

{ #category : 'validation' }
McpTool >> typeErrorFor: value against: propertySchema atKey: key [
	"Nil means value satisfies propertySchema."
	| type items |
	type := propertySchema at: 'type' ifAbsent: [^ nil].
	type = 'string' ifTrue: [
		value isString ifTrue: [^ nil].
		^ '''' , key , ''' must be a string, got ' , value class name].
	type = 'array' ifTrue: [
		"An array arg may arrive as a JSON-encoded string; decoded at execute time."
		value isString ifTrue: [^ nil].
		value isArray ifFalse: [
			^ '''' , key , ''' must be an array, got ' , value class name].
		items := propertySchema at: 'items' ifAbsent: [^ nil].
		(items at: 'type' ifAbsent: [nil]) = 'string' ifFalse: [^ nil].
		value withIndexDo: [:item :i |
			item isString ifFalse: [
				^ '''' , key , '[' , i printString , ']'' must be a string, got ' , item class name]].
		^ nil].
	^ nil
]

{ #category : 'validation' }
McpTool >> validateArguments: args [

	| schema properties required missingKeys unknownKeys typeErrors message |
	schema := self inputSchema.
	properties := schema at: 'properties' ifAbsent: [Dictionary new].
	required := schema at: 'required' ifAbsent: [#()].
	missingKeys := required select: [:key | (args includesKey: key) not].
	unknownKeys := OrderedCollection new.
	typeErrors := OrderedCollection new.
	args keysAndValuesDo: [:key :value |
		(properties includesKey: key)
			ifTrue: [
				(self typeErrorFor: value against: (properties at: key) atKey: key)
					ifNotNil: [:err | typeErrors add: err]]
			ifFalse: [unknownKeys add: key]].
	(missingKeys isEmpty and: [unknownKeys isEmpty and: [typeErrors isEmpty]]) ifTrue: [^self].
	message := String streamContents: [:s |
		s nextPutAll: 'Tool ''' , self name , ''': '.
		missingKeys isEmpty ifFalse: [
			s nextPutAll: 'missing required argument(s): ';
				nextPutAll: (', ' join: missingKeys);
				nextPutAll: '. '
		].
		unknownKeys isEmpty ifFalse: [
			s nextPutAll: 'unknown argument(s): ';
				nextPutAll: (', ' join: unknownKeys);
				nextPutAll: '; expected: ';
				nextPutAll: (', ' join: properties keys);
				nextPutAll: '. '
		].
		typeErrors isEmpty ifFalse: [
			s nextPutAll: 'type error(s): ';
				nextPutAll: ('; ' join: typeErrors);
				nextPutAll: '. '
		].
		s nextPutAll: 'Schema: ';
			nextPutAll: (Json render: schema)
	].
	McpError signal: message
]
