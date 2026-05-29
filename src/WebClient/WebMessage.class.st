"
A common base class for WebRequest and WebResponse.
"
Class {
	#name : 'WebMessage',
	#superclass : 'Object',
	#instVars : [
		'stream',
		'protocol',
		'headers',
		'content'
	],
	#classVars : [
		'StatusCodes'
	],
	#category : 'WebClient-Core',
	#package : 'WebClient',
	#tag : 'Core'
}

{ #category : 'class initialization' }
WebMessage class >> initialize [
	"self initialize"

	StatusCodes := Dictionary newFromPairs:{
		"1xx: Meta status codes"
		100. 	'Continue'.
		101. 	'Switching Protocols'.
		102.	'Processing'.
		"2xx: Success status codes"
		200.	'OK'.
		201.	'Created'.
		202.	'Accepted'.
		203. 	'Non-Authoritative Information'.
		204.	'No Content'.
		205. 	'Reset Content'.
		206.	'Partial Content'.
		207.	'Multi-Status'. 				"WebDav RFC: 2518"
		"3xx: Redirection status codes"
		300.	'Multiple Choices'.
		301.	'Moved Permanently'.
		302.	'Moved Temporarily'.
		303.	'See Other'.
		304.	'Not Modified'.
		305.	'Use Proxy'.
		307.	'Temporary Redirect'.
		"4xx: Client-Side Error status code"
		400.	'Bad Request'.
		401.	'Unauthorized'.
		402.	'Payment Required'.
		403.	'Forbidden'.
		404.	'Not Found'.
		405.	'Method Not Allowed'.
		406.	'Not Acceptable'.
		407.	'Proxy Authentication Required'.
		408.	'Request Timeout'.
		409.	'Conflict'.
		410.	'Gone'.
		411.	'Lenght Required'.
		412.	'Precondition Failed'.
		413.	'Request Entity Too Large'.
		414.	'Request-URI Too Long'.
		415.	'Unsupported Media Type'.
		416.	'Requested Range Not Satisfiable'.
		417.	'Expectation Failed'.
		422.	'Unprocessable Entity'. 		"WebDav RFC: 2518"
		423.	'Locked'. 					"WebDav RFC: 2518"
		424.	'Failed Dependency'. 		"WebDav RFC: 2518"
		"5xx: Server-Side Error status codes"
		500.	'Internal Server Error'.
		501.	'Not Implemented'.
		502.	'Bad Gateway'.
		503.	'Service Unavailable'.
		504.	'Gateway Timeout'.
		505.	'HTTP Version Not Supported'.
		507.	'Insufficient Storage'. 		"WebDav RFC: 2518"
	}.
]

{ #category : 'utilities' }
WebMessage class >> statusCodeAt: code [
	"Return the textual description of a status code"

	^StatusCodes at: code ifAbsent: [ 'Unknown error' ]
]

{ #category : 'headers' }
WebMessage >> addHeader: key value: value [
	"Adds an ADDITIONAL header for the given key"

	headers add: key -> value.
]

{ #category : 'converting' }
WebMessage >> asString [
	"Prints the receiver"

	^String streamContents:[:s| self writeOn: s].
]

{ #category : 'streaming' }
WebMessage >> chunkFrom: srcStream to: dstStream progress: progressBlock [
	"Stream the content of srcStream to dstStream.
	Use chunked transfer-encoding."

	| chunkSize firstLine buffer totalRead |
	totalRead := 0.
	buffer := (srcStream isBinary ifTrue:[ByteArray] ifFalse:[String]) new.
	[firstLine := srcStream nextLine asString.
	chunkSize := ('16r',firstLine asUppercase) asNumber.
	chunkSize = 0] whileFalse:[
		progressBlock ifNotNil:[progressBlock value: nil value: totalRead].
		buffer size = chunkSize ifFalse:[buffer := buffer class new: chunkSize].
		buffer := srcStream next: chunkSize into: buffer startingAt: 1.
		dstStream nextPutAll: buffer.
		srcStream skip: 2. "CRLF"
		totalRead := totalRead + chunkSize.
	].
	srcStream skip: 2. "CRLF"
	dstStream flush.
	progressBlock ifNotNil:[progressBlock value: nil value: totalRead].
]

{ #category : 'initialize' }
WebMessage >> close [
	"Always closes regardless of connection header"

	stream ifNotNil:[stream close].
]

{ #category : 'initialize' }
WebMessage >> closeIfTransient [
	"Close the underlying connection if it's not persistent"

	self isPersistent ifFalse:[self close].

]

{ #category : 'accessing' }
WebMessage >> content [
	"Reads and caches available content and returns it."

	^content ifNil:[content := self getContent].

]

{ #category : 'accessing' }
WebMessage >> content: aString [
	"Sets content for a response"

	content := aString.
]

{ #category : 'accessing' }
WebMessage >> contentLength [
	"Answers the numeric value of the Content-Length header, or nil if no header exist"

	^(self headerAt: 'Content-Length' ifAbsent:[^nil]) asNumber
]

{ #category : 'accessing' }
WebMessage >> contentLength: aNumber [
	"Sets the numeric value of the Content-Length header"

	^self headerAt: 'Content-Length' put: aNumber
]

{ #category : 'accessing' }
WebMessage >> contentStream [
	"Answers a stream for the conent."

	^stream
]

{ #category : 'accessing' }
WebMessage >> contentType [
	"Answer the content type for the receiver"

	^self headerAt: 'Content-Type' ifAbsent:['application/octet-stream']

]

{ #category : 'accessing' }
WebMessage >> contentType: aString [
	"Sets the content type for the receiver"

	^self headerAt: 'Content-Type' put: aString
]

{ #category : 'accessing' }
WebMessage >> contentWithProgress: progressBlock [
	"Reads and caches available content and returns it."

	^content ifNil: [ content := self getContentWithProgress: progressBlock ]
]

{ #category : 'initialize' }
WebMessage >> destroy [
	"Destroys the underlying stream"

	stream ifNotNil:[stream destroy].
]

{ #category : 'private' }
WebMessage >> getContent [
	"Reads available content and returns it."

	^self getContentWithProgress: nil
]

{ #category : 'private' }
WebMessage >> getContentWithProgress: progressBlockOrNil [
	"Reads available content and returns it."

	| length result |
	length := self contentLength.
	result := (stream isBinary ifTrue: [ ByteArray ] ifFalse: [ String ])
		streamContents: [ :outputStream | 
			self 
				streamFrom: stream
				to: outputStream
				size: length
				progress: progressBlockOrNil ]
		estimatedSize: (length ifNil: [ 1000 ]).
	(self headerAt: 'content-encoding') = 'gzip' ifFalse: [ ^result ].
	^UnicodeString fromBytesStream: (GZipReadStream on: result asByteArray)
]

{ #category : 'headers' }
WebMessage >> headerAt: key [
	"Answers a single value for the given http header. 
	Do not use for headers that may appear multiple times, such at www-authenticate."

	^self headerAt: key ifAbsent:[''].
]

{ #category : 'headers' }
WebMessage >> headerAt: key ifAbsent: aBlock [
	"Answers a single value for the given http header. 
	Do not use for headers that may appear multiple times, such at www-authenticate."

	self headersAt: key do:[:value| ^value].
	^aBlock value
]

{ #category : 'headers' }
WebMessage >> headerAt: key put: value [
	"Sets the value of a header, adding if necessary"

	headers do:[:assoc|
		(assoc key sameAs: key) ifTrue:[
			assoc value: value.
			^self
		].
	].
	self addHeader: key value: value.
]

{ #category : 'headers' }
WebMessage >> headersAt: key [
	"Answers a collection of values for the given http header. 
	Use for headers that may appear multiple times, such at www-authenticate."

	^self headersAt: key ifAbsent:[#()].
]

{ #category : 'headers' }
WebMessage >> headersAt: aKey do: aBlock [
	"Evaluate aBlock with all the headers matching aKey"

	self headersDo:[:key :value|
		(aKey sameAs: key) ifTrue:[ aBlock value: value].
	].
]

{ #category : 'headers' }
WebMessage >> headersAt: key ifAbsent: aBlock [
	"Answers a collection of values for the given http header. 
	Use for headers that may appear multiple times, such at www-authenticate."

	| hdrs |
	hdrs := OrderedCollection new.
	self headersAt: key do:[:value| hdrs add: value].
	^hdrs asArray ifEmpty:[aBlock value]

]

{ #category : 'headers' }
WebMessage >> headersDo: aBlock [
	"Evaluate aBlock with all of the headers key-value pairs"

	headers do:[:assoc|
		aBlock value: assoc key value: assoc value.
	].
]

{ #category : 'testing' }
WebMessage >> isPersistent [
	"Return true if this is a persistent connection"

	"Check for explicit connection headers"
	((self headerAt:'Connection') sameAs: 'close') ifTrue:[^false].
	((self headerAt:'Connection') sameAs: 'keep-alive') ifTrue:[^true].

	"Defaults for various versions"
	(self protocol = 'HTTP/1.0') ifTrue:[^false].
	(self protocol = 'HTTP/1.1') ifTrue:[^true].

	"Assume that later HTTP versions are compatible with 1.1"
	^true
]

{ #category : 'accessing' }
WebMessage >> multipartBoundary [
	"Answer the boundary of a multipart/form-data message"

	| header |
	header := self headerAt: 'Content-Type' ifAbsent:[^nil].
	(header beginsWith: 'multipart/form-data') ifFalse:[^nil].
	^(header copyFrom: (header findString: 'boundary=') + 9 to: header size)
]

{ #category : 'streaming' }
WebMessage >> nextChunk [
	"Answer the next chunk from a message using chunked transfer encoding."

	| chunkSize chunk |
	chunkSize := Integer readFrom: (stream upToAll: String crlfString) readStream base: 16.
	chunkSize = 0 ifFalse:[chunk := stream next: chunkSize].
	stream skip: 2. "CrLf"
	^chunk
]

{ #category : 'streaming' }
WebMessage >> nextChunkPut: chunk [
	"Send the next chunk of a message using chunked transfer encoding.

	Note: This method does not allow to send empty chunks to avoid accidentally
	terminating the chunked transfer. Ending the transfer is part of the chunked
	request/response protocol (see #httpPostChunked:encoded:content:type:do:
	as well as #sendResponse:chunked:do:)"

	chunk ifNotEmpty:[
		stream nextPutAll: (chunk size printStringBase: 16); crlf.
		stream nextPutAll: chunk; crlf; flush.
	].
]

{ #category : 'printing' }
WebMessage >> printOn: aStream [
	"Prints the receiver"

	aStream nextPutAll: self class name.
	aStream nextPut: $(.
	self writeOn: aStream.
	aStream nextPut: $).
]

{ #category : 'accessing' }
WebMessage >> protocol [
	"Returns the requested protocol"

	^protocol
]

{ #category : 'accessing' }
WebMessage >> protocol: aString [
	"Returns the requested protocol"

	protocol := aString
]

{ #category : 'accessing' }
WebMessage >> remoteHost [
	"Return the name of the remote host"

	| remote |
	(stream isKindOf: SocketStream) ifFalse:[^nil]. "don't have it"
	remote := stream socket remoteAddress.
	^ NetNameResolver stringFromAddress: remote.

]

{ #category : 'headers' }
WebMessage >> removeHeader: key [
	"Removes ALL headers with the given key"

	headers := headers reject:[:assoc| assoc key sameAs: key].

]

{ #category : 'accessing' }
WebMessage >> stream [
	"Answers the underlying TCP stream"

	^stream
]

{ #category : 'accessing' }
WebMessage >> stream: aStream [
	"Sets the underlying TCP stream"

	stream := aStream
]

{ #category : 'streaming' }
WebMessage >> streamFrom: srcStream size: size progress: aBlock [
	"Stream the given source stream to the message's socket stream.
	Outbound. Can be used on both request/response depending on
	whether it is utilized by WebClient or WebServer."

	^self streamFrom: srcStream to: stream size: size progress: aBlock
]

{ #category : 'streaming' }
WebMessage >> streamFrom: srcStream to: dstStream size: sizeOrNil progress: progressBlock [
	"Stream the content of srcStream to dstStream.
	If a size is given, stream that many elements, otherwise stream up to the end."

	| buffer totalRead remaining size |
	(self headerAt: 'transfer-encoding') ifNotEmpty:[:encoding|
		encoding = 'chunked' 
			ifTrue:[^self chunkFrom: srcStream to: dstStream progress: progressBlock]
			ifFalse:[self error: 'Unknown transfer-encoding: ', encoding]].

	sizeOrNil = 0 ifTrue:[^self].

	buffer := (srcStream isBinary ifTrue:[ByteArray] ifFalse:[String]) new: 4096.
	totalRead := 0.
	size := sizeOrNil ifNil:[0].
	[(sizeOrNil == nil and:[stream atEnd not]) or:[totalRead < size]] whileTrue:[
		progressBlock ifNotNil:[progressBlock value: sizeOrNil value: totalRead].
		remaining := sizeOrNil ifNil:[99999] ifNotNil:[sizeOrNil - totalRead].
		remaining > buffer size ifTrue:[remaining := buffer size].
		buffer := srcStream next: remaining into: buffer startingAt: 1.
		dstStream nextPutAll: (remaining < buffer size  
			ifTrue:[(buffer copyFrom: 1 to: remaining)]
			ifFalse:[buffer]).
		totalRead := totalRead + buffer size.
	].
	dstStream flush.
	progressBlock ifNotNil:[progressBlock value: sizeOrNil value: totalRead].
]

{ #category : 'streaming' }
WebMessage >> streamTo: dstStream size: size progress: aBlock [
	"Stream from the receiver's socket stream to the given destination stream.
	Inbound. Can be used on both request/response depending on
	whether it is utilized by WebClient or WebServer."
	content ifNil:[
		self streamFrom: stream to: dstStream size: size progress: aBlock
	] ifNotNil:[
		self streamFrom: content readStream to: dstStream size: size progress: aBlock
	].
]

{ #category : 'printing' }
WebMessage >> writeHeadersOn: aStream [
	"Write the request"

	self headersDo:[:key :value| aStream nextPutAll: key, ': ', value asString; nextPutAll: String crlfString].

]

{ #category : 'printing' }
WebMessage >> writeOn: aStream [
	"Write the request"

	self writeHeadersOn: aStream.
	aStream nextPutAll: String crlfString.

]
