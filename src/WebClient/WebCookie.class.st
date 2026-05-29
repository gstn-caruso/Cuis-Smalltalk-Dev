"
WebCookie represents an http cookie for use by WebClient.
"
Class {
	#name : 'WebCookie',
	#superclass : 'Object',
	#instVars : [
		'name',
		'value',
		'path',
		'domain',
		'expiry',
		'version',
		'secure',
		'httpOnly',
		'comment'
	],
	#category : 'WebClient-Core',
	#package : 'WebClient',
	#tag : 'Core'
}

{ #category : 'comparing' }
WebCookie >> = aCookie [
	"Compare the receiver with aCookie"

	^aCookie class == self class 
		and:[aCookie name = self name
		and:[aCookie domain = self domain
		and:[aCookie path = self path]]].
]

{ #category : 'converting' }
WebCookie >> asString [
	"Create the string representation for this cookie"

	^String streamContents:[:s| self printOn: s].
]

{ #category : 'accessing' }
WebCookie >> comment [
	"Cookie comment"

	^comment
]

{ #category : 'accessing' }
WebCookie >> comment: aString [
	"Cookie comment"

	comment := aString
]

{ #category : 'accessing' }
WebCookie >> domain [
	"Cookie domain"

	^domain
]

{ #category : 'accessing' }
WebCookie >> domain: aString [
	"Cookie domain"

	domain := aString.
]

{ #category : 'accessing' }
WebCookie >> expiry [
	"The expiry DateAndTime"

	^expiry
]

{ #category : 'accessing' }
WebCookie >> expiry: aDateAndTime [
	"The expiry DateAndTime"

	expiry := aDateAndTime ifNotNil:[:dt| dt asUTC].
]

{ #category : 'accessing' }
WebCookie >> expirySeconds: maxAge [
	"Compute the cookie's expiry age from the given number of seconds"

	maxAge = 0 ifTrue:[self expiry: DateAndTime new].
	self expiry: DateAndTime now + maxAge seconds.
]

{ #category : 'comparing' }
WebCookie >> hash [
	"Hash is re-implemented because #= is re-implemented"

	^name hash + domain hash + path hash.
]

{ #category : 'accessing' }
WebCookie >> httpOnly [
	"If the cookie should be httpOnly (not scriptable).
	See http://msdn2.microsoft.com/en-us/library/ms533046.aspx"

	^httpOnly
]

{ #category : 'accessing' }
WebCookie >> httpOnly: aBool [
	"If the cookie should be httpOnly (not scriptable).
	See http://msdn2.microsoft.com/en-us/library/ms533046.aspx"

	httpOnly := aBool
]

{ #category : 'initialize' }
WebCookie >> initialize [
	"Initializes the receiver"
	super initialize.
	secure := false.
	httpOnly := false.

]

{ #category : 'testing' }
WebCookie >> isExpired [
	"Return true if this cookie is expired"
	
	expiry ifNil:[^false].
	^expiry asUTC < DateAndTime now asUTC
]

{ #category : 'accessing' }
WebCookie >> name [
	"The name of the cookie"

	^name
]

{ #category : 'accessing' }
WebCookie >> name: aString [
	"The name of the cookie"

	name := aString
]

{ #category : 'accessing' }
WebCookie >> path [
	"Cookie path"

	^path
]

{ #category : 'accessing' }
WebCookie >> path: aString [
	"Cookie path"

	path := aString
]

{ #category : 'printing' }
WebCookie >> printOn: aStream [
	"Creates the string representation for this cookie"

	aStream nextPutAll: name, '=', value asString.
	expiry ifNotNil:[ 
		aStream nextPutAll:'; expires='.
		aStream nextPutAll: expiry dayOfWeekName ,  ', '.
		expiry date printOn: aStream format: #(1 2 3 $- 2 2 2 ).
		aStream nextPutAll: ' ', expiry time print24,' GMT'.
	].
	path ifNotNil:[
		aStream nextPutAll:'; path=', (WebUtils quote: path).
	].
	domain ifNotNil:[
		aStream nextPutAll:'; domain=', (WebUtils quote: domain).
	].
	version ifNotNil:[
		aStream nextPutAll:'; version=', version asString.
	].
	secure ifTrue:[
		aStream nextPutAll: '; secure'.
	].
	httpOnly ifTrue:[
		aStream nextPutAll: '; HttpOnly'.
	].

]

{ #category : 'initialize' }
WebCookie >> readExpiryFrom: aString [
	"Read a cookie expiry date from the given string.
	The expiration date is specified in the 'Wdy, DD-Mon-YYYY HH:MM:SS GMT' format."
	
	| tokens |
	^[
		tokens := aString withBlanksTrimmed.
		(tokens copyAfterLast: Character space) = 'GMT'
			ifFalse:[^DateAndTime new].
		tokens := ((tokens copyAfter: Character space) copyUpToLast: Character space), '+00:00'.
		DateAndTime readFrom: tokens readStream.
	] on: Error do:[:ex| ex return: DateAndTime new].
]

{ #category : 'initialize' }
WebCookie >> readFrom: aStream [
	"Read a cookie from the given stream"

	| keyval key val |
	aStream skipSeparators.
	name := (aStream upTo: $=) withBlanksTrimmed.
	value := (aStream upTo: $;) withBlanksTrimmed.
	[aStream atEnd] whileFalse:[
		keyval := aStream upTo: $;.
		key := (keyval copyUpTo: $=) withBlanksTrimmed.
		val := (keyval copyAfter: $=) withBlanksTrimmed.
		key asLowercase caseOf: {
			['expires'] 	-> [self expiry: (self readExpiryFrom: val)].
			['path']		-> [self path: (WebUtils unquote: val)].
			['domain'] 	-> [self domain: (WebUtils unquote: val)].
			['secure'] 	-> [self secure: true].
			['version'] 	-> [self version: val].
			['httponly'] 	-> [self httpOnly: true].
			['comment']	 ->[self comment: val].
			['max-age']	->[self expirySeconds: val asNumber].
		} otherwise:[Transcript log: 'Unknown cookie field: ', key].
	].
]

{ #category : 'accessing' }
WebCookie >> secure [
	"Secure cookie flag"

	^secure
]

{ #category : 'accessing' }
WebCookie >> secure: aBool [
	"Secure cookie flag"

	secure := aBool
]

{ #category : 'accessing' }
WebCookie >> value [
	"The value of the cookie"

	^value
]

{ #category : 'accessing' }
WebCookie >> value: aString [
	"The value of the cookie"

	value := aString
]

{ #category : 'accessing' }
WebCookie >> version [
	"Cookie version"

	^version
]

{ #category : 'accessing' }
WebCookie >> version: aString [
	"Cookie version"

	version := aString
]
