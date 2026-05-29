Extension { #name : 'String' }

{ #category : '*WebClient' }
String >> percentEscapeUrl [
	"Answer an instance of String where all characters are ASCII.
	If we contain any ASCII character that is invalid in an URL, parentEscape it
	If we contain any non-ASCII character, percentEscape its UTF-8 bytes.
	See https://en.wikipedia.org/wiki/URL_encoding"

	| badChars |
	badChars := `CharacterSequence invalidAsciiInUrls`.
	(self isAscii and: [(self indexOfAnyIn: badChars startingAt: 1 ifAbsent: 0) = 0]) ifTrue: [
		^self ].
	^String percentEscapingNonAsciiAndThoseIn: badChars bytes: self asUtf8Bytes
]

{ #category : '*WebClient' }
String >> percentEscapeUrlField [
	"Answer an instance of String where all characters are ASCII.
	If we contain any ASCII character that is invalid in an URL field, parentEscape it
	If we contain any non-ASCII character, percentEscape its UTF-8 bytes.
	See https://en.wikipedia.org/wiki/URL_encoding"

	| badChars |
	badChars := `String invalidAsciiInUrlFields`.
	(self isAscii and: [(self indexOfAnyIn: badChars startingAt: 1 ifAbsent: 0) = 0]) ifTrue: [
		^self ].
	^String percentEscapingNonAsciiAndThoseIn: badChars bytes: self asUtf8Bytes
]

{ #category : '*WebClient' }
String >> unescapePercents [
	"change each %XY substring to the character with ASCII value XY in hex.
	This is the opposite of #percentEscapingNonAscii: and #percentEscapingNonAsciiAndThoseIn:bytes:
	(String percentEscapingNonAscii: '⊙' bytes) unescapePercents
	'%E2%8A%99' unescapePercents
	"

	| myBytes answerClass answerBytes c decodedByte pos oldPos specialCharsByteSet |
	myBytes := self asByteArray.
	specialCharsByteSet := `ByteArray new: 256 :: at: $+ asciiValue + 1 put: 1; at: $% asciiValue + 1 put: 1; yourself`.
	answerClass := String.
	answerBytes := ByteArray streamContents: [ :byteStream |
		oldPos := 1.

		[pos := myBytes indexOfAnyIn: specialCharsByteSet startingAt: oldPos ifAbsent: [ 0 ]. pos > 0 ]
		whileTrue: [
			byteStream nextPutAll: (myBytes copyFrom: oldPos to: pos - 1).
			c := self at: pos.
			c = $+ ifTrue: [byteStream nextPut: `$  asciiValue` ] ifFalse: [
				(c = $% and: [pos + 2 <= self size]) ifTrue: [
					decodedByte := (self at: pos+1) asUppercase digitValue * 16 +
						(self at: pos+2) asUppercase digitValue.
					pos := pos + 2.
					decodedByte > 255 ifTrue: [^self].	"not really an escaped string"
					decodedByte > 127 ifTrue: [ answerClass := UnicodeString ].
					byteStream nextPut: decodedByte ]
				ifFalse: [byteStream nextPut: c codePoint ]].
			oldPos := pos+1].
		byteStream nextPutAll: (myBytes copyFrom: oldPos to: self size).
	].
	^ answerClass fromUtf8Bytes: answerBytes
]
