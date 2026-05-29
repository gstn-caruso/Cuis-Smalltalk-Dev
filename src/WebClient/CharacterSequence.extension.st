Extension { #name : 'CharacterSequence' }

{ #category : '*WebClient' }
CharacterSequence class >> invalidAsciiInUrlFields [
	"Answer a CharacterSet ByteArray with all ASCII characters that are invalid in an URL field.
	See https://en.wikipedia.org/wiki/URL_encoding
	Do include Reserved Characters (i.e. Characters that are used to form URLs)
	This is appropriate to prepare any ASCII String to be used as a field name or value in an URL.
	See senders.	"

	| answer |
	answer := ByteArray new: 256.
	(((0 to: 127) collect: [ :i | Character codePoint: i ]) reject: [ :c | c isAlphaNumeric  | ('.-_' includes: c)]) do: [ :char |
			answer at: char codePoint + 1 put: 1 ].
	^answer
]

{ #category : '*WebClient' }
CharacterSequence class >> invalidAsciiInUrls [
	"Answer a CharacterSet ByteArray with all ASCII characters that are invalid in an URL.
	See https://en.wikipedia.org/wiki/URL_encoding
	Do not include Reserved Characters (i.e. Characters that are used to form URLs)
	This is appropriate for preparing a complete URL to be sent to network primitives.
	See senders.	"

	| answer |
	answer := ByteArray new: 256.
	((((0 to: 31) collect: [ :i | Character codePoint: i ]),
		{Character space. $". $<. $>. $\. $^. $`. ${. $|. $}. Character codePoint: 127})) do: [ :char |
			answer at: char codePoint + 1 put: 1 ].
	^answer
]
