Extension { #name : 'String' }

{ #category : '*Immutability' }
String >> at: index put: aCharacter  [
	"Primitive. Store the Character in the field of the receiver indicated by
	the index. Fail if the index is not an Integer or is out of bounds, or if
	the argument is not a Character. Essential. See Object documentation
	whatIsAPrimitive."

	<primitive: 64>

	self isImmutable
		ifTrue: [ ^ self modificationForbiddenFor: #at:put: index: index value: aCharacter ].

	aCharacter isCharacter
		ifTrue: [	
			aCharacter codePoint > 255 ifTrue: [
				self error: 'String only store Latin-1 Characters'].
			index isInteger
				ifTrue: [self errorSubscriptBounds: index]
				ifFalse: [self errorNonIntegerIndex]]
		ifFalse: [self error: 'Strings only store Characters']
]
