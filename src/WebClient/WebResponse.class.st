"
Represents an HTTP response for WebClient/WebServer.
"
Class {
	#name : 'WebResponse',
	#superclass : 'WebMessage',
	#instVars : [
		'request',
		'status',
		'code',
		'url'
	],
	#category : 'WebClient-Core',
	#package : 'WebClient',
	#tag : 'Core'
}

{ #category : 'instance creation' }
WebResponse class >> protocol: protocol code: code [
	"Create a response using the given protocol / code"

	^self new protocol: protocol code: code
]

{ #category : 'accessing' }
WebResponse >> code [
	"The HTTP response code"

	^code
]

{ #category : 'accessing' }
WebResponse >> content [
	"Reimplemented to close the socket if the request is transient"

	content ifNil:[
		content := self getContent.
		self closeIfTransient.
	].
	^content
]

{ #category : 'accessing' }
WebResponse >> contentStream [
	"Answers a stream for the conent."

	(self headerAt: 'transfer-encoding') = 'chunked' ifTrue:[
		^WebChunkedStream on: stream.
	].
	^super contentStream
]

{ #category : 'private' }
WebResponse >> getContent [
	"Do not read any content if this was a HEAD request or code is 204 (no content)"
	(request method = 'HEAD' or: [code = 204]) ifTrue:[^''].
	^super getContent
]

{ #category : 'testing' }
WebResponse >> isInformational [
	"Is this a 1xx response?"

	^self code between: 100 and: 199

]

{ #category : 'testing' }
WebResponse >> isRedirect [
	"Is this a redirect response?"

	^self code between: 300 and: 399

]

{ #category : 'testing' }
WebResponse >> isSuccess [
	"Is this a successful response?"

	^self code between: 200 and: 299

]

{ #category : 'initialize' }
WebResponse >> protocol: respProtocol code: respCode [
	"Initialize a response from protocol and code"

	code := respCode.
	protocol := respProtocol.
	status := protocol, ' ', code asString, ' ', (self class statusCodeAt: code).
	headers := OrderedCollection new.
]

{ #category : 'initialize' }
WebResponse >> readFrom: aStream [
	"Parse an HTTP response from the given stream"

	| tokens |
	stream := aStream.
	status := stream upToAll: String crlfString.
	tokens := status findTokens: ' '.
	tokens size < 2 ifTrue:[^self error:'Invalid response: ', status].
	protocol := tokens first.
	code := tokens second asNumber.
	headers := WebUtils readHeadersFrom: stream.

]

{ #category : 'accessing' }
WebResponse >> request [
	"The original request for this response"

	^request
]

{ #category : 'accessing' }
WebResponse >> request: aRequest [
	"The original request for this response"

	request := aRequest
]

{ #category : 'cookies' }
WebResponse >> setCookie: aCookie [
	"Adds a Set-Cookie header"

	^self addHeader: 'Set-Cookie' value: aCookie asString
]

{ #category : 'cookies' }
WebResponse >> setCookie: name value: value path: path  [
	"Adds a Set-Cookie header"

	^self setCookie: ((WebCookie new)
			name: name;
			value: value;
			path: path;
		yourself)
]

{ #category : 'cookies' }
WebResponse >> setCookie: name value: value path: path expires: date domain: domain secure: aBool [
	"Adds a Set-Cookie header"

	^self setCookie: ((WebCookie new)
			name: name;
			value: value;
			path: path;
			expiry: date;
			domain: domain;
			secure: aBool;
		yourself)
]

{ #category : 'cookies' }
WebResponse >> setCookieAt: key [
	"Evaluate aBlock with all the cookies deined in the request"

	self setCookiesDo:[:cookie|
		cookie name = key ifTrue:[^cookie].
	].
	^nil
]

{ #category : 'cookies' }
WebResponse >> setCookiesDo: aBlock [
	"Evaluate aBlock with all the cookies deined in the request"

	self headersAt: 'Set-Cookie' do:[:hdr|
		aBlock value: (WebCookie new readFrom: hdr readStream)
	].

]

{ #category : 'accessing' }
WebResponse >> status [
	"The status line from the response"

	^status
]

{ #category : 'accessing' }
WebResponse >> status: aString [
	"The status line from the response"

	status := aString
]

{ #category : 'accessing' }
WebResponse >> url [
	"The url of the resource at which a request was terminated after a series
	of redirects. Without redirects, this will be the same as the request url."

	^url
]

{ #category : 'accessing' }
WebResponse >> url: urlString [
	"The url of the resource at which a request was terminated after a series
	of redirects. Without redirects, this will be the same as the request url."

	url := urlString
]

{ #category : 'printing' }
WebResponse >> writeOn: aStream [
	"Store this response on aStream"

	self writeStatusOn: aStream.
	super writeOn: aStream.

]

{ #category : 'printing' }
WebResponse >> writeStatusOn: aStream [
	"Store this response on aStream"

	aStream nextPutAll: status; nextPutAll: String crlfString.

]
