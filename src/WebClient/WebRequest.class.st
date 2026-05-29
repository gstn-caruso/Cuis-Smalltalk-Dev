"
Represents an HTTP request for WebClient/WebServer.
"
Class {
	#name : 'WebRequest',
	#superclass : 'WebMessage',
	#instVars : [
		'method',
		'request',
		'rawUrl',
		'server'
	],
	#category : 'WebClient-Core',
	#package : 'WebClient',
	#tag : 'Core'
}

{ #category : 'instance creation' }
WebRequest class >> readFrom: aStream [
	"Create a WebRequest from a given stream"

	^self new readFrom: aStream
]

{ #category : 'testing' }
WebRequest >> acceptsCookie: aCookie from: webClient [
	"Returns true if this cookie is applicable to this request"

	aCookie domain ifNotNil:[:domain|
		(webClient serverName endsWith: domain) ifFalse:[^false].
	].
	aCookie path ifNotNil:[:path|
		(self url beginsWith: path) ifFalse:[^false].
	].
	aCookie secure ifNotNil:[:secure|
		secure ifTrue:[webClient scheme = 'https' ifFalse:[^false]].
	].
	aCookie expiry ifNotNil:[:expiry|
		aCookie isExpired ifTrue:[^false].
	].
	^true
]

{ #category : 'converting' }
WebRequest >> asWebSocket [
	"Convert this request into a WebSocket"

	"Figure out the version of the protocol"
	| field version |
	version := self headerAt: 'Sec-WebSocket-Version' ifAbsent:[nil].
	version ifNil:[
		field := self headerAt: 'Sec-WebSocket-Key1' ifAbsent:[nil].
		field 
			ifNil:[^self asWebSocket68] 
			ifNotNil:[^self asWebSocket00].
	].

	"Attempt WebSocket07 conversion"
	^self asWebSocket07

]

{ #category : 'converting' }
WebRequest >> asWebSocket00 [
	"Convert this request into a WebSocket"

	| field key1 key2 bytes resp |
	resp := self newResponse protocol: 'HTTP/1.1' code: 101.
	resp status: 'HTTP/1.1 101 Web Socket Protocol Handshake'.

	"Chrome 4/5 is *VERY* sensitive to the order of the fields"
	resp headerAt: 'Upgrade' put: 'WebSocket'.
	resp headerAt: 'Connection' put: 'Upgrade'.

	field := self headerAt: 'Sec-WebSocket-Key1'.
	key1 := WebUtils extractWebSocketKey: field.
	field := self headerAt: 'Sec-WebSocket-Key2'.
	key2 := WebUtils extractWebSocketKey: field.
	bytes := WebUtils webSocketHandshake: key1 with: key2 with: (stream next: 8).

	resp headerAt: 'Sec-WebSocket-Origin' put: (self headerAt: 'Origin').
	resp headerAt: 'Sec-WebSocket-Location' put: ('ws://', (self headerAt: 'host'), self rawUrl).
	(self headerAt: 'Sec-WebSocket-Protocol' ifAbsent:[nil]) ifNotNil:[:hdr|
		resp headerAt: 'Sec-WebSocket-Protocol' put: hdr.
	].

	resp writeOn: stream.
	bytes ifNotNil:[stream nextPutAll: bytes].
	stream flush.
	^WebSocket00 on: stream.

]

{ #category : 'converting' }
WebRequest >> asWebSocket07 [
	"Convert this request into a WebSocket"

	| resp hash nonce |
	resp := self newResponse protocol: 'HTTP/1.1' code: 101.
	resp status: 'HTTP/1.1 101 Web Socket Protocol Handshake'.

	"Chrome 4/5 is *VERY* sensitive to the order of the fields"
	resp headerAt: 'Upgrade' put: 'WebSocket'.
	resp headerAt: 'Connection' put: 'Upgrade'.

	nonce := self headerAt: 'Sec-WebSocket-Key'.
	hash := WebUtils webSocketHash07: nonce.

	resp headerAt: 'Sec-WebSocket-Accept' put: hash.
	(self headerAt: 'Sec-WebSocket-Origin' ifAbsent: [self headerAt: 'Origin']) 
		ifNotNil: [ :origin | resp headerAt: 'Sec-WebSocket-Origin' put: origin ].
	resp headerAt: 'Sec-WebSocket-Location' put: ('ws://', (self headerAt: 'host'), self rawUrl).
	(self headerAt: 'Sec-WebSocket-Protocol' ifAbsent:[nil]) ifNotNil:[:hdr|
		resp headerAt: 'Sec-WebSocket-Protocol' put: hdr.
	].

	resp writeOn: stream.
	stream flush.
	^(WebSocket07 on: stream)
		masking: false;
		yourself.
	"http://tools.ietf.org/html/draft-ietf-hybi-thewebsocketprotocol-07#section-4.1 says:
   ''Frames sent from the server to the client are not masked.''
	http://tools.ietf.org/html/rfc6455#section-5.1 says: 
   ''A client MUST close a connection if it detects a masked
   frame.''
	So not using masking is compatible with the 07 protocol and is required by RFC 6455."
]

{ #category : 'converting' }
WebRequest >> asWebSocket68 [
	"Convert this request into a WebSocket"

	| resp |
	resp := self newResponse protocol: 'HTTP/1.1' code: 101.
	resp status: 'HTTP/1.1 101 Web Socket Protocol Handshake'.

	"Chrome 4/5 is *VERY* sensitive to the order of the fields"
	resp headerAt: 'Upgrade' put: 'WebSocket'.
	resp headerAt: 'Connection' put: 'Upgrade'.

	resp headerAt: 'WebSocket-Origin' put: (self headerAt: 'Origin').
	resp headerAt: 'WebSocket-Location' put: ('ws://', (self headerAt: 'host'), self rawUrl).
	(self headerAt: 'WebSocket-Protocol' ifAbsent:[nil]) ifNotNil:[:hdr|
		resp headerAt: 'WebSocket-Protocol' put: hdr.
	].
	resp writeOn: stream.
	stream flush.
	^WebSocket00 on: stream.
]

{ #category : 'sending' }
WebRequest >> closeIfTransient: resp after: aBlock [
	"Evaluate aBlock. Close the connection if it is transient.
	Inserts Connection: close header if needed."

	| close |
	close := self isPersistent not.
	close 
		ifTrue: [
			"Always be explicit and insert the Connection: close header"
			resp headerAt: 'Connection' put: 'close' ]
		ifFalse: [
			"We should tell the client that we keep this connection alive."
			resp headerAt: 'Connection' put: 'Keep-Alive' ].
	aBlock value.
	stream flush.
	close  ifTrue:[self close].

]

{ #category : 'cookies' }
WebRequest >> cookieAt: aString [
	"Answer the value for a cookie with the given name"

	^self cookieAt: aString ifAbsent:['']
]

{ #category : 'cookies' }
WebRequest >> cookieAt: aString ifAbsent: aBlock [
	"Answer the value for a cookie with the given name"

	self cookiesDo:[:name :value| name = aString ifTrue:[^value]].
	^aBlock value
]

{ #category : 'cookies' }
WebRequest >> cookies [
	"Answer all the cookies defined in the request"

	| cookies |
	cookies := Dictionary new.
	self cookiesDo:[:name :value| cookies at: name put: value].
	^cookies
]

{ #category : 'cookies' }
WebRequest >> cookiesDo: aBlock [
	"Parse the cookie headers and evaluate aBlock with name / value pairs"

	self headersAt: 'Cookie' do:[:hdr|
		(hdr findTokens: ';,') do:[:token|
			aBlock 
				value: (token copyUpTo: $=) withBlanksTrimmed 
				value: (token copyAfter: $=) withBlanksTrimmed]].
]

{ #category : 'fields' }
WebRequest >> fields [
	"Answer the fields for the given request."

	| fields |
	fields := Dictionary new.
	self getFields associationsDo:[:a| fields add: a].
	self postFields associationsDo:[:a| fields add: a].
	self multipartFields associationsDo:[:a| fields add: a].
	^fields

]

{ #category : 'fields' }
WebRequest >> getFields [
	"Decodes the fields embedded in the url ?var1=val1&var2=val2"

	| args |
	args := (rawUrl copyAfter: $?) ifEmpty:[^Dictionary new].
	^WebUtils decodeUrlEncodedForm: args multipleValues: false

]

{ #category : 'initialize' }
WebRequest >> initialize [
	"Initialize the receiver"

	super initialize.
	method := 'GET'.
	protocol := 'HTTP/1.1'.
	headers := OrderedCollection new.
]

{ #category : 'initialize' }
WebRequest >> initializeFromUrl: urlString [
	"Initialize the client from a http url or string"

	| percentEscapedUrl urlStream |
	percentEscapedUrl := urlString percentEscapeUrl.
	urlStream := percentEscapedUrl readStream.
	"Skip past scheme if present"
	urlStream upToAll: '://'.
	urlStream atEnd 
		ifTrue:[rawUrl := percentEscapedUrl]
		ifFalse:[rawUrl := urlStream upTo: $/; upToEnd].
	(rawUrl beginsWith: '/') ifFalse:[rawUrl := '/', rawUrl].

]

{ #category : 'testing' }
WebRequest >> isDeleteRequest [
	"Returns true if this is an HTTP DELETE request"

	^self method = 'DELETE'
]

{ #category : 'testing' }
WebRequest >> isGetRequest [
	"Returns true if this is an HTTP GET request"

	^self method = 'GET'
]

{ #category : 'testing' }
WebRequest >> isHeadRequest [
	"Returns true if this is an HTTP HEAD request"

	^self method = 'HEAD'
]

{ #category : 'testing' }
WebRequest >> isOptionsRequest [
	"Returns true if this is an HTTP OPTIONS request"

	^self method = 'OPTIONS'
]

{ #category : 'testing' }
WebRequest >> isPostRequest [
	"Returns true if this is an HTTP POST request"

	^self method = 'POST'
]

{ #category : 'testing' }
WebRequest >> isPutRequest [
	"Returns true if this is an HTTP PUT request"

	^self method = 'PUT'
]

{ #category : 'testing' }
WebRequest >> isTraceRequest [
	"Returns true if this is an HTTP TRACE request"

	^self method = 'TRACE'
]

{ #category : 'accessing' }
WebRequest >> method [
	"The request method (GET, POST etc)"

	^method
]

{ #category : 'accessing' }
WebRequest >> method: aString [
	"The request method (GET, POST etc)"

	method := aString
]

{ #category : 'fields' }
WebRequest >> multipartFields [
	"Answers the multipart fields of a post request"

	| fields |
	fields := Dictionary new.
	self multipartFieldsDo:[:hdrs :params :cntnt|
		params at: 'name' ifPresent:[:fieldName| fields at: fieldName put: cntnt].
	].
	^fields
]

{ #category : 'fields' }
WebRequest >> multipartFieldsDo: aBlock [
	"Evaluate aBlock with the multipart fields of a post request.
	The block is expected to take three arguments:
		* The headers from the part being processed
		* The parameters from the content-disposition header
		* The content from the part being processed
	"

	^(self isPostRequest and: [
		self contentType beginsWith: 'multipart/form-data'])
			ifTrue: [WebUtils decodeMultipartForm: self content readStream boundary: self multipartBoundary do: aBlock]
			ifFalse: [Dictionary new]
]

{ #category : 'initialize' }
WebRequest >> newResponse [
	"Create a new response entitiy.
	Subclasses can override this method to provide a different response class"

	^(WebResponse new)
		request: self;
		yourself
]

{ #category : 'initialize' }
WebRequest >> newWebSocketOn: aStream [
	"Create a new socket entitiy.
	Subclasses can override this method to provide a different response class"

	^WebSocket on: aStream
]

{ #category : 'fields' }
WebRequest >> postFields [
	"Answers the multipart fields of a post request"

	^(self isPostRequest and: [
		self contentType beginsWith: 'application/x-www-form-urlencoded'])
			ifTrue: [
				WebUtils 
					decodeUrlEncodedForm: self content 
					multipleValues: true ]
			ifFalse: [Dictionary new]
]

{ #category : 'accessing' }
WebRequest >> rawUrl [
	"The raw (unparsed) url"

	^rawUrl
]

{ #category : 'accessing' }
WebRequest >> rawUrl: aString [
	"The raw (unparsed) url"

	rawUrl := aString

]

{ #category : 'initialize' }
WebRequest >> readFrom: aStream [
	"Initialize the receiver initialized from an existing socket stream 
	This method will block until the headers have been parsed."

	| tokens |
	stream := aStream.
	stream isBinary ifTrue:[stream ascii].
	"Parse request header"
	request := stream upToAll: String crlfString.
	tokens := request findTokens: ' '.
	tokens size < 2 ifTrue:[^self error: 'Invalid HTTP request: ', request].
	method := tokens first.
	rawUrl := tokens second.
	tokens size > 2 
		ifTrue:[protocol := tokens third]
		ifFalse:[protocol := 'HTTP/1.0'].

	"Parse HTTP header"
	headers := WebUtils readHeadersFrom: stream.

]

{ #category : 'accessing' }
WebRequest >> requestLine [
	"The actual request line as sent by the client"

	^request ifNil:[self method, ' ', self rawUrl, ' ', self protocol]
]

{ #category : 'responses' }
WebRequest >> send200Response: aString [
	"Send a 200 OK response"

	^self 
		send200Response: aString asUtf8Bytes
		contentType: 'text/plain; charset=utf-8'.
]

{ #category : 'responses' }
WebRequest >> send200Response: aString contentType: contentType [
	"Send a 200 OK response"

	^self send200Response: aString contentType: contentType do:[:resp]
]

{ #category : 'responses' }
WebRequest >> send200Response: aString contentType: contentType do: aBlock [
	"Send a 200 OK response"

	| resp |
	resp := self newResponse protocol: 'HTTP/1.1' code: 200.
	resp headerAt: 'Content-Type' put: contentType.
	aBlock value: resp.
	^self sendResponse: resp content: aString.
]

{ #category : 'responses' }
WebRequest >> send301Response: location [
	"Send a 301 permanent redirect response"

	^self send301Response: location do:[:resp].
]

{ #category : 'responses' }
WebRequest >> send301Response: location do: aBlock [
	"Send a 301 permanent redirect response"

	^self send3xxResponse: location code: 301 do: aBlock
]

{ #category : 'responses' }
WebRequest >> send302Response: location [
	"Send a 302 temporary redirect response"

	^self send302Response: location do:[:resp].
]

{ #category : 'responses' }
WebRequest >> send302Response: location do: aBlock [
	"Send a 302 temporary redirect response"

	^self send3xxResponse: location code: 302 do: aBlock
]

{ #category : 'responses' }
WebRequest >> send3xxResponse: location code: statusCode [
	"Send a 3xx redirect response"

	^self send3xxResponse: location code: statusCode do:[:resp].
]

{ #category : 'responses' }
WebRequest >> send3xxResponse: location code: statusCode do: aBlock [
	"Send a 3xx redirect response"

	| resp url |
	"If the redirect is not to an absolute url, prefix it with the host if we have one"
	url := location.
	(location findString: '://') > 0 ifFalse:[
		(self headerAt: 'host') ifNotEmpty:[:host| url := 'http://', host, location]].

	resp := self newResponse protocol: 'HTTP/1.1' code: statusCode.
	resp headerAt: 'Location' put: url.
	aBlock value: resp.
	^self sendResponse: resp content: ''.

]

{ #category : 'responses' }
WebRequest >> send400Response [
	"Send a 400 bad request response"

	| message |
	message := '<html><head><title>400 Bad Request</title></head><body>',
		'<h1>Bad Request</h1>
		<p>The server encountered a request it did not understand.
		</body></html>'.
	
	self sendResponseCode: 400 
		content: message asUtf8Bytes
		type: 'text/plain; charset=utf-8'
		close: true
]

{ #category : 'responses' }
WebRequest >> send404Response [
	"Send a 404 not found response"

	^self send404Response: '<html><head><title>404 Not Found</title></head><body><h1>404 Not Found</h1><p>The requested URL ',self rawUrl,' was not found on this server.</p></body></html>'.

]

{ #category : 'responses' }
WebRequest >> send404Response: body [
	"Send a 404 not found response"

	^self 
		send404Response: body asUtf8Bytes
		do: [ :resp | resp headerAt: 'Content-Type' put: 'text/html; charset=utf-8' ]
]

{ #category : 'responses' }
WebRequest >> send404Response: body do: aBlock [
	"Send a 404 not found response"

	| resp |
	resp := self newResponse protocol: 'HTTP/1.1' code: 404.
	resp headerAt: 'Content-Type' put: 'text/html; charset=utf-8'.
	aBlock value: resp.
	^self sendResponse: resp content: body.

]

{ #category : 'responses' }
WebRequest >> send405Response: allowed [
	"Send a 405 method not allowed response"

	^self send405Response: allowed content: '<html><head><title>405 Method Not Allowed</title></head><body><h1>405 Method Not Allowed</h1><p>The requested method ',self method,' is not allowed for the URL', self rawUrl, '</p></body></html>'.
]

{ #category : 'responses' }
WebRequest >> send405Response: allowed content: body [
	"Send a 405 method not allowed response"
	| resp |
	resp := self newResponse protocol: 'HTTP/1.1' code: 405.
	resp headerAt: 'Content-Type' put: 'text/html; charset=utf-8'.
	resp headerAt: 'allow' put: (String streamContents:[:s|
		allowed do:[:m| s nextPutAll: m] separatedBy:[s nextPut: $,]
	]).
	^self sendResponse: resp content: body.
]

{ #category : 'responses' }
WebRequest >> send500Response: errReport [
	"Send a 500 internal server error response"

	| errLog |
	errLog := '<html><head><title>500 Internal Server Error</title></head><body>',
		'<h1>Internal Server Error</h1><pre>',
		(errReport  withLineEndings: String crlfString),
		'</pre></body></html>'.

	self sendResponseCode: 500
				content: errLog asUtf8Bytes
				type: 'text/html; charset=utf-8'
				close: true.

]

{ #category : 'responses' }
WebRequest >> sendOptionsResponse: allowed [
	"Send a 200 OK response for an OPTIONS request"

	^self send200Response: '' contentType: 'application/octet-stream' do:[:resp|
		resp headerAt: 'allow' put: (String streamContents:[:s|
			allowed do:[:m| s nextPutAll: m] separatedBy:[s nextPut: $,]
		]).
	].
]

{ #category : 'responses' }
WebRequest >> sendResponse: code chunked: chunkBlock [
	"Send a chunked response"

	^self sendResponse: code chunked: chunkBlock do:[:resp]
]

{ #category : 'responses' }
WebRequest >> sendResponse: code chunked: chunkBlock do: hdrBlock [
	"Send a chunked response"

	| resp |
	resp := self newResponse protocol: 'HTTP/1.1' code: code.
	resp headerAt: 'Transfer-Encoding' put: 'chunked'.
	hdrBlock value: resp.
	^self sendResponse: resp contentBlock:[:aStream|
		"Set the stream in the request and pass it in the chunk block"
		resp stream: aStream.
		chunkBlock value: resp.
		"send termination chunk"
		aStream nextPutAll: '0'; crlf; crlf; flush.
	].

]

{ #category : 'sending' }
WebRequest >> sendResponse: resp content: aString [
	"Send a WebResponse with content."

	^self sendResponse: resp contentStream: aString readStream size: aString size
]

{ #category : 'sending' }
WebRequest >> sendResponse: resp contentBlock: contentBlock [
	"Sends a WebResponse, streaming its contents from aStream.
	If a size is provided, insert a Content-Length header, otherwise
	ensure that the connection is transient."

	"Add Date and Server headers"
	resp headerAt: 'Date' put: (server ifNil:[WebServer]) serverDate.
	resp headerAt: 'Server' put: (server ifNil:[WebServer]) serverString.

	self closeIfTransient: resp after:[
		"Ignore all network errors while sending the response"
		[resp writeOn: stream.
		stream flush.
		self isHeadRequest ifFalse:[contentBlock value: stream].
		] on: NetworkError do:["ignore"].

		"Make sure we log before closing the connection"
		server ifNotNil:[server logRequest: self response: resp].
	].
]

{ #category : 'sending' }
WebRequest >> sendResponse: resp contentStream: aStream size: streamSize [
	"Sends a WebResponse, streaming its contents from aStream.
	If a size is provided, insert a Content-Length header, otherwise
	ensure that the connection is transient."

	streamSize 
		ifNil:[self headerAt: 'Connection' put: 'close'] "mark transient"
		ifNotNil:[resp headerAt: 'Content-Length' put: streamSize].

	^self sendResponse: resp contentBlock:[:sockStream|
		resp streamFrom: aStream to: sockStream size: streamSize progress: nil
	]
]

{ #category : 'responses' }
WebRequest >> sendResponseCode: code content: aString type: contentType close: aBool [
	"Send a 500 Internal server error response"

	^self sendResponseCode: code content: aString type: contentType do:[:hdr|
		aBool ifTrue:[hdr headerAt: 'Connection' put: 'close'].
	].
]

{ #category : 'responses' }
WebRequest >> sendResponseCode: code content: aString type: contentType do: aBlock [
	"Send a 500 Internal server error response"

	| resp |
	resp := self newResponse protocol: 'HTTP/1.1' code: code.
	contentType ifNotNil:[resp headerAt: 'Content-Type' put: contentType].
	aBlock value: resp.
	^self sendResponse: resp content: aString.
]

{ #category : 'responses' }
WebRequest >> sendXmlResponse: xmlString [
	"Send an a-ok 200 xml-ish response"

	^self send200Response: xmlString contentType: 'application/xml'
]

{ #category : 'accessing' }
WebRequest >> server [
	"If non-nil, the WebServer instance associated with the request."

	^server
]

{ #category : 'accessing' }
WebRequest >> server: aWebServer [
	"If non-nil, the WebServer instance associated with the request."

	server := aWebServer
]

{ #category : 'responses' }
WebRequest >> stream200Response: aStream [
	"Stream a 200 OK response"

	^self stream200Response: aStream size: aStream size
]

{ #category : 'responses' }
WebRequest >> stream200Response: aStream size: streamSize [
	"Stream a 200 OK response"

	^self stream200Response: aStream size: streamSize type: 'application/octet-stream'
]

{ #category : 'responses' }
WebRequest >> stream200Response: aStream size: streamSize type: contentType [
	"Stream a 200 OK response"

	^self stream200Response: aStream size: streamSize type: contentType do:[:resp].
]

{ #category : 'responses' }
WebRequest >> stream200Response: aStream size: streamSize type: contentType do: aBlock [
	"Stream a 200 OK response"

	| resp |
	resp := self newResponse protocol: 'HTTP/1.1' code: 200.
	resp headerAt: 'Content-Type' put: contentType.
	aBlock value: resp.
	^self sendResponse: resp contentStream: aStream size: streamSize.
]

{ #category : 'accessing' }
WebRequest >> url [
	"The url without fragment or arguments"

	^((rawUrl copyUpTo: $#) copyUpTo: $?)
]

{ #category : 'printing' }
WebRequest >> writeOn: aStream [
	"Write the request"

	self writeRequestOn: aStream.
	super writeOn: aStream
]

{ #category : 'printing' }
WebRequest >> writeRequestOn: aStream [
	"Write the request"

	aStream nextPutAll: method; space; nextPutAll: rawUrl; space; nextPutAll: protocol; nextPutAll: String crlfString.

]
