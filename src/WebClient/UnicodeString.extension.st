Extension { #name : 'UnicodeString' }

{ #category : '*WebClient' }
UnicodeString >> percentEscapeUrl [
	"Answer an instance of String where all characters are ASCII.
	If we contain any ASCII character that is invalid in an URL, parentEscape it
	If we contain any non-ASCII character, percentEscape its UTF-8 bytes.
	See https://en.wikipedia.org/wiki/URL_encoding"

	| badChars |
	badChars := `CharacterSequence invalidAsciiInUrls`.
	(self isAscii and: [(self indexOfAnyIn: badChars startingAt: 1 ifAbsent: 0) = 0]) ifTrue: [
		^self asByteString ].
	^String percentEscapingNonAsciiAndThoseIn: badChars bytes: self asUtf8Bytes
]

{ #category : '*WebClient' }
UnicodeString >> percentEscapeUrlField [
	"Answer an instance of String where all characters are ASCII.
	If we contain any ASCII character that is invalid in an URL field, parentEscape it
	If we contain any non-ASCII character, percentEscape its UTF-8 bytes.
	See https://en.wikipedia.org/wiki/URL_encoding"

	| badChars |
	badChars := `String invalidAsciiInUrlFields`.
	(self isAscii and: [(self indexOfAnyIn: badChars startingAt: 1 ifAbsent: 0) = 0]) ifTrue: [
		^self asByteString ].
	^String percentEscapingNonAsciiAndThoseIn: badChars bytes: self asUtf8Bytes
]
