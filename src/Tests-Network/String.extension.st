Extension { #name : 'String' }

{ #category : '*Tests-Network' }
String class >> cr [
	^ self crString
]

{ #category : '*Tests-Network' }
String class >> crlf [
	"Answer a string containing a carriage return and a linefeed."

	^ self crlfString
]

{ #category : '*Tests-Network' }
String class >> crlfcrlf [
	^self crlf , self crlf.

]
