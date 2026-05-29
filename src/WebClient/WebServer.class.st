"
WebServer provides a simple yet complete HTTP server implementation.

Example:
(WebServer new listenOn: 8080) addService: '/hello' action: [ :req | req send200Response: 'Hello World!']
"
Class {
	#name : 'WebServer',
	#superclass : 'Object',
	#instVars : [
		'listenerSocket',
		'listenerProcess',
		'interface',
		'port',
		'mutex',
		'connections',
		'entryPoints',
		'vault',
		'logAction',
		'nonceCache',
		'sessions',
		'serverString',
		'errorHandler',
		'accessLog',
		'certName',
		'siteUrl'
	],
	#classVars : [
		'Default',
		'Registry'
	],
	#category : 'WebClient-Core',
	#package : 'WebClient',
	#tag : 'Core'
}

{ #category : 'benchmarks' }
WebServer class >> benchmark [
	"Runs a WebClient/WebServer streaming benchmark to measure throughput"

	"
		WebServer benchmark
		MessageTally spyOn:[WebServer benchmark]
	"

	| amount time resp port |
	port := 8888.
	amount := 128 * 1024 * 1024.
	WebServer reset default listenOn: port.
	WebServer default addService: '/streaming' action:[:req|
		req stream200Response: DummyStream new size: amount.
	].
	time := [
		resp := WebClient httpGet: 'http://localhost:', port, '/streaming'.
		resp isSuccess ifFalse:[self error: resp status].
		resp streamTo: DummyStream new size: resp contentLength progress: nil.
		resp close.
	] timeToRun.
	WebServer reset.
	^(amount  * 1000 // time) printStringWithCommas, ' bytes/sec'

]

{ #category : 'examples' }
WebServer class >> browseDir: directory request: request [
	"Responds with a directory listing back to the original request"

	| entries listing url |
	url := request url.
	(url endsWith: '/') ifTrue:[url := url allButLast].

	entries := directory children sort:[:e1 :e2|
		e1 isDirectoryEntry = e2 isDirectoryEntry 
			ifTrue:[e1 name <= e2 name]
			ifFalse:[e2 isDirectoryEntry]].

	listing := String streamContents:[:s|
		s nextPutAll:'<html><head><title>Index of ', request url,'</title></head><body>'.
		s nextPutAll:'<h1>Index of ', request url,'</h1>'.
		s nextPutAll:'<pre>      Name                      Last modified      Size  Description<hr>'.
		s nextPutAll: '[up]  <a href="', (url copyUpToLast: $/),'">parent</a>'; cr; lf.
		entries do:[:e|
			s nextPutAll:(e isDirectoryEntry ifTrue:['[dir] '] ifFalse:['      ']).
			s nextPutAll: '<a href="', url, '/', e name, '">'.
			s nextPutAll: (e name truncateTo: 30).
			s nextPutAll: '</a>'.
			e name size < 30 ifTrue:[s nextPutAll: (String new: 30 - e name size withAll: $ )].
			s nextPutAll: (e modificationTime asString padded: #right to: 20 with: $ ).
			s nextPutAll: (e isDirectoryEntry ifTrue: [String new: 20] ifFalse: [e fileSize asString padded: #right to: 20 with: $ ]).
			s cr; lf.
		].
 	].

	request
		send200Response: listing asUtf8Bytes
		contentType: 'text/html; charset=utf-8'.


]

{ #category : 'examples' }
WebServer class >> browseFile: file request: request [
	"Responds with a file back to the original request"

	| fileSize mimeTypes resp |
	file binary.
	fileSize := file size.
"	mimeTypes := file mimeTypes ifNil:[#('application/octet-stream')]."
	mimeTypes := nil ifNil:[#('application/octet-stream')].
	resp := request newResponse protocol: 'HTTP/1.1' code: 200.
	resp headerAt: 'Content-Type' put: mimeTypes first.
	request sendResponse: resp contentStream: file size: fileSize.
]

{ #category : 'examples' }
WebServer class >> browseRequest: request [
	"Handle an HTTP request for browsing some resource"

	| path fd file directoryEntry fileEntry |

	"Extract the file path from the request"
	path := request url findTokens: '/'.
	path ifEmpty: [ ^self browseDir: DirectoryEntry currentDirectory request: request ].

	"Find the directory entry for the resource"
	fd := path allButLast inject: DirectoryEntry currentDirectory into: [ :dir :part | dir / part ].
	
	directoryEntry _ fd / path last.
	directoryEntry exists ifTrue: [
		"Send file listing. We handle this synchronously for simplicity."
		self browseDir: directoryEntry request: request.
		^ self].
	fileEntry _ fd // path last.
	fileEntry exists
	ifFalse: [^request send404Response ]
	ifTrue: [
		"Send file content. Since files can be large, we fork this off.
		However, since we forked it, we need to handle two different
		possible conditions:
			- closing the file in case of error
			- handling errors when sending it
		This makes the code below a bit ugly"
		[[
			file := fileEntry readStream.
			[ self browseFile: file request: request ]
				ensure: [ file close ] 	"close file even in case of error"
		] on: Error do: []				"ignore errors altogether"
		] fork. 							"fork it"
	]
]

{ #category : 'accessing' }
WebServer class >> default [
	"A default WebServer instance. Mostly for the examples."

	^Default ifNil:[Default := self new].
]

{ #category : 'examples' }
WebServer class >> doItFrom: req [

	| data result |
	
	req isPostRequest 
		ifTrue:[
			"We fetch all of the data instead of streaming it"
			data := req content. ]
		ifFalse: [ req isGetRequest 
			ifTrue: [ data := req rawUrl unescapePercents allButFirst ]
			ifFalse: [ ^req send404Response ]].
		
	"Compute the result"
	result := [Compiler evaluate: data] on: Error do:[:ex| ex return: ex asString].
	req send200Response: result asString 
	
]

{ #category : 'examples' }
WebServer class >> exampleAuth		"WebServer exampleAuth" [
	"Simple example requiring basic auth"

	| server port realm |
	port := 9999.
	server := WebServer reset default.
	
	"The realm to use for the server"
	realm := 'Example Realm'.

	"Add a sample user (note: password is hashed, not stored verbatim)"
	server passwordAt: 'squeak' realm: realm put: 'squeak'.

	server listenOn: port.
	server addService: '/' action:[:req| 
		server 
			authenticate: req 
			realm: realm
			methods: #(digest basic) 
			do:[self browseRequest: req]].

]

{ #category : 'examples' }
WebServer class >> exampleBrowse	"WebServer exampleBrowse" [
	"This example implements a simple http server allowing to view 
	and download files (like browsing ftp sites etc)."

	| server port |
	port := 9999.
	server := WebServer reset default.
	server listenOn: port.
	server addService: '/' action:[:req| self browseRequest: req].

]

{ #category : 'examples' }
WebServer class >> exampleDoIt		"WebServer exampleDoIt" [
	"This example executes doIts from a POST request.
	It's the simplest possible RPC interface to Squeak."

	| server port |

	port := 9999.
	server := WebServer reset default.
	server listenOn: port.
	server addService: '/' action:[:req| self doItFrom: req ].
		

]

{ #category : 'examples' }
WebServer class >> exampleSSL: certName [

	"This example implements a simple https server allowing to view 
	and download files (like browsing ftp sites etc):

		WebServer exampleSSL: 'Internet Widgits Pty'.
		WebServer exampleSSL: '/home/andreas/certs/testcert.pem'.

	"

	| server port |
	port := 8443.
	server := WebServer reset default.
	server accessLog: Transcript.
	server certName: certName.
	server listenOn: port.
	server addService: '/' action:[:req| self browseRequest: req].

]

{ #category : 'examples' }
WebServer class >> exampleSession		"WebServer exampleSession" [
	"This example uses a simple session cookie to avoid 
	authentication for every request."

	| server port realm |
	realm := 'Example Realm'.	"authentication realm"
	port := 9999.
	server := WebServer reset default.
	server listenOn: port.

	"Add a sample user (note: password is hashed, not stored verbatim)"
	server passwordAt: 'squeak' realm: realm put: 'squeak'.

	"Register the login service (sets cookie when successful)"
	server addService: '/login' action:[:req| 
		server  authenticate: req  realm: realm methods: #(digest)  do:[ | id |
			"Set the cookie and redirect back to /"
			server sessionAt: (id := UUID new hex) put: ''.
			req send302Response: (req fields at: 'url' ifAbsent:['/'])
				do:[:resp| resp setCookie: 'session' value: id path: '/']]].

	"Register the normal browse service"
	server addService: '/' action:[:req|
		"Check if we have a valid session cookie. If not redirect to login."
		(server sessionAt: (req cookieAt: 'session')) notNil
			ifTrue:[self browseRequest: req]
			ifFalse:[req send302Response: '/login?url=', req url percentEscapeUrlField]].

]

{ #category : 'registry' }
WebServer class >> forUrl: urlString [
	"Answer the WebServer registered for a given URL string."

	^self forUrl: urlString ifAbsent:[self newForUrl: urlString]
]

{ #category : 'registry' }
WebServer class >> forUrl: urlString ifAbsent: aBlock [
	"Answer the WebServer registered for a given URL string.
	If no WebServer is registered, evaluate aBlock."

	^self registry at: urlString ifAbsent: aBlock
]

{ #category : 'registry' }
WebServer class >> newForUrl: urlString [
	"Create a new WebServer instance registered for a given URL string."

	| server |
	"Out with the old ...."
	server := self removeUrl: urlString.
	server ifNotNil:[server destroy].

	"... and in with the new."
	server := self new.
	server siteUrl: urlString.
	self registry at: urlString put: server.
	^server

]

{ #category : 'registry' }
WebServer class >> registry [
	"Answer the WebServer site registry"

	^Registry ifNil:[Registry := Dictionary new]
]

{ #category : 'registry' }
WebServer class >> removeUrl: urlString [
	"Remove and answer the WebServer registered for a given URL string.
	If no WebServer was registered, return nil."

	^self removeUrl: urlString ifAbsent:[nil]
]

{ #category : 'registry' }
WebServer class >> removeUrl: urlString ifAbsent: aBlock [
	"Remove and answer the WebServer registered for a given URL string."

	^self registry removeKey: urlString ifAbsent: aBlock
]

{ #category : 'benchmarks' }
WebServer class >> requestBenchmark: persistent [
	"Runs a WebClient/WebServer benchmark to measure request handling speed.
	Uses a persistent connection if requested."

	"
		WebServer requestBenchmark: false.
		WebServer requestBenchmark: true.
		MessageTally spyOn:[WebServer requestBenchmark: true]
	"

	| port |
	port := 8888.
	WebServer reset default listenOn: port.
	WebServer default addService: '/benchmark' action:[:req|
		req send200Response: ''.
	].
	^[WebClient 
		requestBenchmark: 'http://localhost:', port, '/benchmark'
		persistent: persistent] ensure:[WebServer reset].

]

{ #category : 'accessing' }
WebServer class >> reset		"WebServer reset" [
	"Reset the default WebServer instance."

	Default ifNotNil:[
		Default destroy.
		Default := nil.
	].
]

{ #category : 'accessing' }
WebServer class >> serverDate [
	"Returns the date string to be used in responses"
	
	"FIXME: check http spec for time format"

	| date |
	^String streamContents:[:s|
		date := DateAndTime now asUTC.
		s nextPutAll: date dayOfWeekAbbreviation, ', '.
		date printOn: s.
		s nextPutAll: ' GMT'.
	].
]

{ #category : 'accessing' }
WebServer class >> serverString [
	"Returns the server string to be used in responses"

	^ 'WebServer/1.5 (',
		SystemVersion current versionString,'; ',
		WebUtils platformName,')'.
]

{ #category : 'logging' }
WebServer >> accessLog [
	"The standard access log. Can be either a stream or a string; if the access log
	is a string then the string is assumed to be a file name and the file will be opened 
	and closed for each request."

	^accessLog
]

{ #category : 'logging' }
WebServer >> accessLog: aStreamOrFilename [
	"The standard access log. Can be either a stream or a string; if the access log
	is a string then the string is assumed to be a file name and the file will be opened 
	and closed for each request."

	accessLog := aStreamOrFilename
]

{ #category : 'services' }
WebServer >> addService: entryPoint action: aBlockOrMessage [
	"Add a service to the web server. The service is specified by an entryPoint, 
	denoting the url under which the service can be requested 
	(such as /my/great/service) and an action which is a message 
	send taking a single argument, the WebRequest."

	^self addService: entryPoint 
		action: aBlockOrMessage 
		methods: self defaultHttpMethods.
]

{ #category : 'services' }
WebServer >> addService: entryPoint action: aBlockOrMessage methods: methods [
	"Add a service to the web server. The service is specified by an entryPoint, 
	denoting the url under which the service can be requested 
	(such as /my/great/service) and an action which is a message 
	send taking a single argument, the WebRequest.

	The list of methods describes what HTTP methods the given url supports."

	mutex critical: [
		entryPoints at: entryPoint percentEscapeUrl asLowercase put: {methods. aBlockOrMessage}.
	].
]

{ #category : 'handling' }
WebServer >> asyncHandleConnectionFrom: aSocket [
	"Handle an incoming connection asynchronously to avoid blocking the listener."

	| handlerProcess |
	handlerProcess := [
		[ [ self handleConnectionFrom: aSocket ] 
			on: Error do: [ :ex | aSocket destroy ] ]
			ensure: [
				aSocket destroy.
				mutex critical: [ 
					"If we get here, then handlerProcess is initialized, so it's safe to use that variable. Using Processor activeProcess is not possible, because this block may be evaluated by another process. Doing this outside the #ensure: block is not safe."
					connections remove: handlerProcess ifAbsent: [ ] ] ] ] newProcess.

	mutex critical:[connections add: handlerProcess].

	handlerProcess resume.

]

{ #category : 'authentication' }
WebServer >> authAccept: method request: request realm: realm header: authHeader [
	"Performs the requested authentication method. 
	Returns true if successfully authenticated.
	Subclasses can extend this method to support more auth methods."

	^method asLowercase caseOf: {
		['basic'] 	-> [self basicAuth: request realm: realm header: authHeader].
		['digest'] 	-> [self digestAuth: request realm: realm header: authHeader].
	} otherwise:[false].

]

{ #category : 'authentication' }
WebServer >> authHeader: method request: request realm: realm [
	"Answer the authentication header for the given method.
	Subclasses can extend this method to support more auth methods."

	^method asLowercase caseOf: {
		['basic'] 	-> ['Basic realm="', realm,'"'].
		['digest'] 	-> ['Digest realm="', realm,'", nonce="', self newNonce,'", qop="auth"'].
	} otherwise:[nil].
	
	
]

{ #category : 'authentication' }
WebServer >> authenticate: request realm: realm methods: accepted do: aBlock [
	"Authenticates an incoming request using one of the accepted methods.

	Evaluates aBlock upon successful authentication. Responds with a 401
	(Unauthorized) if the authentication fails."

	| method resp |
	request headersAt: 'Authorization' do:[:authHeader|
		method := authHeader copyUpTo: Character space.
		(accepted anySatisfy:[:auth| auth sameAs: method]) ifTrue:[
			(self authAccept: method request: request realm: realm header: authHeader)
				ifTrue:[^aBlock value].
		].
	].

	"Send a 401 (unauthorized) response"
	resp := request newResponse protocol: 'HTTP/1.1' code: 401.
	resp headerAt: 'Content-Type' put: 'text/html; charset=utf-8'.
	accepted do:[:auth| | hdr |
		hdr := self authHeader: auth request: request realm: realm.
		hdr ifNotNil:[resp addHeader: 'WWW-Authenticate' value: hdr].
	].
	request sendResponse: resp content: '<html><head><title>401 Unauthorized</title></head><body><h1>401 Unauthorized</h1><p>You are not authorized to access the requested URL</p></body></html>'.

]

{ #category : 'authentication' }
WebServer >> basicAuth: request realm: realm header: authHeader [
	"Perform Basic auth for the given request"

	| data user pass hash |
	data := String fromUtf8Bytes: (authHeader copyAfter: $ ) base64Decoded.
	user := data copyUpTo: $:.
	pass := data copyAfter: $:.
	data atAllPut: $*. data := nil.

	hash := self hashUser: user password: pass realm: realm.
	pass atAllPut: $*. pass := nil.

	^(self passwordHashAt: user, ':', realm) = hash

]

{ #category : 'initialize' }
WebServer >> builtinHttpMethods [
	"Returns the list of HTTP methods that the server handles built-in,
	i.e., without passing them to the registered service."

	^#('HEAD' 'TRACE' 'OPTIONS')
]

{ #category : 'accessing' }
WebServer >> certName [
	"The cert name to use for a secure (SSL/TLS) web server."

	^certName
]

{ #category : 'accessing' }
WebServer >> certName: aString [
	"The cert name to use for a secure (SSL/TLS) web server."

	certName := aString.
]

{ #category : 'accessing' }
WebServer >> connections [
	"The active connection processes. Can only be examined after aquiring
	the WebServer's mutex."

	^connections
]

{ #category : 'initialize' }
WebServer >> critical: aBlock [
	"Evaluate aBlock protected byt the server's mutex.
	Necessary if code needs to manipulate internal server state."

	^mutex critical: aBlock

]

{ #category : 'errors' }
WebServer >> debugErrorHandler [

	^[:anException :aRequest | 
		[nil handleSignal: anException ] 
			on: UnhandledError 
			do: [ :unhandledError | nil handleSignal: unhandledError ]]
]

{ #category : 'initialize' }
WebServer >> defaultHttpMethods [
	"Answer the list of HTTP methods that should be be supported by default.
	The methods must be implemented by the request handler."

	^#('GET' 'POST')
]

{ #category : 'initialize' }
WebServer >> destroy [
	"Destroys the receiver"

	self stopListener.
	self destroyConnections.
	listenerSocket ifNotNil:[listenerSocket destroy].

	"De-register the WebServer"
	(self class forUrl: self siteUrl ifAbsent:[self]) == self 
		ifTrue:[self class removeUrl: siteUrl]

]

{ #category : 'initialize' }
WebServer >> destroyConnections [
	"Destroy all current connections."

	| copy |
	copy := mutex critical: [ connections copy ].
	" #terminate will trigger the #ensure: block in #asyncHandleConnectionFrom:, which will block if we don't release the mutex "
	copy do: [ :p | p terminate ].
	" make sure all of them were really removed "
	mutex critical: [ connections removeAll ]

]

{ #category : 'authentication' }
WebServer >> digestAuth: request realm: realm header: authHeader [
	"Authenticates an incoming request using Digest auth."

	| user nonce uri response ha1 ha2 md5 qop nc cnonce 
	  nonceData nonceCounter nonceTimeout params |

	params := WebUtils parseAuthParams: authHeader.

	"Flush the nonce cache randomly about every 100 auth attempts"
	100 atRandom = 42 ifTrue:[self flushNonceCache].

	user := params at: 'username' ifAbsent:[''].
	nonce := params at: 'nonce' ifAbsent:[''].
	uri := params at: 'uri' ifAbsent:[request url].
	response := params at: 'response' ifAbsent:[''].
	
	qop := params at: 'qop' ifAbsent:[''].
	qop = 'auth' ifFalse:[^false]. "we require qop=auth"

	nc := params at: 'nc' ifAbsent:[''].
	cnonce := params at: 'cnonce' ifAbsent:[''].
	
	"Verify that this is a nonce that we have handed out, that it isn't expired
	and that the nc counter has increased from the last use."
	mutex critical:[
		nonceData := nonceCache at: nonce ifAbsent:[^false].
	].
	nonceCounter := nonceData first.		"last used nc"
	nonceTimeout := nonceData second.	"timeout for nonce"
	nc <= nonceCounter ifTrue:[^false]. 	"nc must increase"
	Time localSecondClock > nonceTimeout ifTrue:[^false]. "nonce expired"
	nonceData at: 1 put: nc.

	ha1 := self passwordHashAt: user, ':', realm.
	ha2 := WebUtils md5Digest: request method, ':', uri.
	md5 := WebUtils md5Digest: ha1, ':', nonce, ':', nc, ':', cnonce, ':', qop, ':', ha2.
	^md5 = response

]

{ #category : 'handling' }
WebServer >> dispatchRequest: request [
	"Look up the handler for a given request and dispatch to it"

	^self dispatchRequest: request url: request url
]

{ #category : 'handling' }
WebServer >> dispatchRequest: request url: dispatchUrl [
	"Look up the handler for a given url and dispatch to it"

	| entryUrl action |

	"Handle TRACE requests right away"
	request method = 'TRACE' ifTrue: [
		^request send200Response: request asString contentType: 'message/http'.
	].

	"Look up the entry point for the request"
	action := nil.
	entryUrl := dispatchUrl percentEscapeUrl asLowercase.
	(entryUrl beginsWith: '/') ifFalse:[entryUrl := '/', entryUrl].
	mutex critical: [
		[entryUrl notEmpty and:[action == nil]] whileTrue: [
			action := entryPoints at: entryUrl ifAbsent:[nil].
			entryUrl := entryUrl copyUpToLast: $/.
		].
		action ifNil:[action := entryPoints at: '/' ifAbsent:[nil]].
	].

	"Handle OPTIONS requests"
	request method = 'OPTIONS' ifTrue: [
		"HEAD, TRACE, and OPTIONS are always supported"
		request sendOptionsResponse: self builtinHttpMethods,
			(action ifNil:[self defaultHttpMethods] ifNotNil:[action first])
	].

	"Handle 404 not found"
	action ifNil: [^request send404Response].

	"Handle 405 method not allowed"
	(request method = 'HEAD' "builtin" 
		or: [(action at: 1) includes: request method]) ifFalse:[
			^request send405Response: self builtinHttpMethods, action first.
		].

	^[self invokeAction: (action at: 2) request: request] 
		on: Error 
		do: [ :ex|
			errorHandler 
				ifNil:[self handleError: ex request: request]
				ifNotNil:[errorHandler value: ex value: request]].
]

{ #category : 'accessing' }
WebServer >> errorHandler [
	"The user-supplied error handler. If present the handler takes two arguments:
		* The error being caught by WebServer
		* The request the error occurred in.
	The user-supplied error handler can do whatever it wants, including calling
	WebServer's #handleError:request: method which is the default."

	^errorHandler
]

{ #category : 'accessing' }
WebServer >> errorHandler: aBlock [
	"The user-supplied error handler. If present the handler takes two arguments:
		* The error being caught by WebServer
		* The request the error occurred in.
	The user-supplied error handler can do whatever it wants, including calling
	WebServer's #handleError:request: method which is the default."

	errorHandler := aBlock.
]

{ #category : 'errors' }
WebServer >> errorReportFor: anError [
	"Provide a report for an error that's been caught during processing"

	^[
		String streamContents:[:s| 
			self errorReportFor: anError 
				stack: ([anError signalerContext stackOfSize: 2000] 
							on: Error do:[:ex| ex return: #()])
				on: s
		].
	] on: Error do: [:ex| ex pass. 'error reporting failed'].
]

{ #category : 'errors' }
WebServer >> errorReportFor: anError stack: preStack on: strm [
	"Provide a report for an error that's been caught during processing"

	self errorStackFor: anError stack: preStack on: strm.
	strm newLine; nextPutAll: '-----------------------------------------------------------------'; newLine; newLine.
	self systemInfoOn: strm.

]

{ #category : 'errors' }
WebServer >> errorStackFor: anError stack: preStack on: strm [
	"Provide a report for an error that's been caught during processing"

	| cnt |
	cnt := 0.
	(preStack copyFrom: 1 to: (5 min: preStack size)) do:[:ctx|
		ctx printDetails: strm.	"variable values"
		strm newLine.
	].

	strm newLine; nextPutAll: '--- The full stack ---'; newLine.
	cnt := 0.

	preStack do:[:ctx|
		cnt := cnt + 1.
		cnt = 5 ifTrue: [
			strm nextPutAll: ' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -'; newLine].
		strm print: ctx; newLine.  "just class>>selector"
	].

]

{ #category : 'authentication' }
WebServer >> flushNonceCache [
	"Flushes expired nonces from the cache"

	| deadline |
	deadline := Time localSecondClock.
	mutex critical:[
		nonceCache := nonceCache reject:[:nonceData| deadline > nonceData second]
	].

]

{ #category : 'handling' }
WebServer >> handleConnectionFrom: aSocket [
	"Synchronously handle an incoming socket connection."

	| stream request |

	"Give the process a pretty name"
	Processor activeProcess name: (String streamContents:[:s|
		aSocket remoteAddress do:[:b| s print: b] separatedBy:[s nextPut: $.].
		s nextPut: $:; print: aSocket remotePort.
		s nextPutAll: ' - ', self class name, ' request handler'.
	]).

	"Read the request from the socket, and dispatch it.
	Since we've been forked already it's okay to block."
	[
		certName ifNil:["Regular request"
			stream := SocketStream on: aSocket.
		] ifNotNil:["SSL/TLS"
			| ssl |
			ssl := Smalltalk at: #SqueakSSL ifAbsent:[self error: 'SqueakSSL not installed'].
			stream := ssl secureSocketStream on: aSocket.
			[stream sslAccept: certName] on: Error do:[^stream destroy].
		].

		[aSocket isConnected] whileTrue:[

			"Read the next request from the connection. If the connection is closed,
			or if a network error occurs, or the read times out, just close the connection
			without further ado (rather than logging an error). Any other error resulting
			from parsing the input is treated as a 400 bad request."

			stream peek ifNil:[^aSocket destroy].
			request := self newRequest.
			[request readFrom: stream] on: Error do:[:ex| 
				(ex isKindOf: NetworkError) ifFalse:[
					[request send400Response] on: Error do:[:ignore].
				].
				^aSocket destroy].

			self dispatchRequest: request.
		].
	] on: Error do:[:ex|
		(ex isKindOf: NetworkError) ifFalse:[
			self log: 'Error in request handling: ', ex description.
			self log: (self errorReportFor: ex).
		].
	].
]

{ #category : 'errors' }
WebServer >> handleError: ex request: aRequest [
	"The default error handling during processing. Sends a 500 response."

	| errLabel errReport |
	errLabel := [ex description] on: Error do:[:ex2| 
		ex2 return: ex class name
	].
	errReport := [self errorReportFor: ex] on: Error do:[:ex2|
		ex2 return: '<error report failed>'.
	].
	[self log: errLabel] on: Error do:[:ex2| ex return].
	[self log: String newLineString, errReport] on: Error do:[:ex2| ex return].
	aRequest send500Response: errReport. 
]

{ #category : 'authentication' }
WebServer >> hashUser: user password: pass realm: realm [
	"Creates a hash for the given username password pair.
	This method is the ha1 part of digest auth and can be used for both digest
	as well as basic auth."

	^WebUtils md5Digest: user, ':', realm, ':', pass
]

{ #category : 'initialize' }
WebServer >> initialize [
	"Initialize the receiver"

	mutex := Mutex new.
	entryPoints := Dictionary new.
	connections := IdentitySet new.
	vault := Dictionary new.
	nonceCache := Dictionary new.
	sessions := Dictionary new.
	self logAction: [ :aString |
		aString isString
			ifTrue: [ Transcript log: aString ]
			ifFalse: [ Transcript log: aString printString ]].

]

{ #category : 'handling' }
WebServer >> invokeAction: action request: request [
	"Invokes the given action. Subclasses can override this method to serialize
	actions if necessary. At this point, the request header has been read from
	the network, but not its content."

	^action valueWithArguments: {request}

]

{ #category : 'testing' }
WebServer >> isRunning [
	"Is the server still running?"

	^self isStopped not
]

{ #category : 'testing' }
WebServer >> isStopped [
	"Is the server still running?"

	^listenerProcess == nil or:[listenerProcess isTerminated]
]

{ #category : 'listening' }
WebServer >> listenOn: aPort [
	"Starts the server listening on the given port"

	^self listenOn: aPort interface: nil
]

{ #category : 'listening' }
WebServer >> listenOn: aPort interface: anInterface [
	"Starts the server listening on the given port / network interface"

	^self listenOn: aPort interface: anInterface backlogSize: 8
]

{ #category : 'listening' }
WebServer >> listenOn: aPort interface: anInterface backlogSize: backlog [
	"Starts the server listening on the given port / network interface"
	
	| ipString |
	interface := anInterface.
	port := aPort.
	ipString := interface ifNil:['*'] ifNotNil:[
		String streamContents:[:s| interface do:[:b| s print: b] separatedBy:[s nextPut:$.]]].
	self log: 'listener starting (interface: ', ipString, ' port: ', port asString, ')'.
	listenerSocket := Socket newTCP.
	interface 
		ifNil:[listenerSocket listenOn: port backlogSize: backlog]
		ifNotNil:[listenerSocket listenOn: port backlogSize: backlog interface: interface].
	listenerSocket isWaitingForConnection ifFalse:[
		self error: 'Failed to listen(interface: ', interface printString, ' port: ', aPort printString,' )'.
	].
	self startListener.
]

{ #category : 'accessing' }
WebServer >> listenerInterface [
	"Returns the listener interface for the server"

	^interface
]

{ #category : 'accessing' }
WebServer >> listenerPort [
	"Returns the listener port for the server"

	^port
]

{ #category : 'accessing' }
WebServer >> listenerProcess [
	"Returns the socket listener process for the server."

	^listenerProcess
]

{ #category : 'listening' }
WebServer >> listenerProcessPriority [
	"The priority at which the listener process should run"

	^Processor lowIOPriority
]

{ #category : 'accessing' }
WebServer >> listenerSocket [
	"Returns the listener socket for the server."

	^listenerSocket
]

{ #category : 'initialize' }
WebServer >> log: aString [
	"Log the given information."

	logAction ifNotNil:[logAction valueWithArguments: {aString}].

]

{ #category : 'accessing' }
WebServer >> logAction [
	"The current log action (a block or message)"

	^logAction
]

{ #category : 'accessing' }
WebServer >> logAction: aBlockOrMessage [
	"The current log action (a block or message).
	Example:
		WebServer new logAction: [:aString| Transcript show: aString].
		WebServer new logAction: (MessageSend receiver: Transcript selector: #show).
	"

	logAction := aBlockOrMessage
]

{ #category : 'logging' }
WebServer >> logRequest: request response: response [
	"Log a request after it has been successfully processed"

	accessLog ifNil:[^self].

	"Do not use the standard exception handler for errors logging; 
	it would possibly send a 500 response. Really this should be handled
	by a different process with its own error handler."

	[WebUtils logRequest: request response: response on: accessLog]
		on: Error do:[:ex| self log: 'Error in logging: ', ex description].

]

{ #category : 'authentication' }
WebServer >> newNonce [
	"Create a new nonce to be used for a client authentication session"

	| nonce |
	nonce := UUID new hex.
	mutex critical:[
		nonceCache at: nonce put: {''. Time localSecondClock + self nonceDeadline}.
	].
	^nonce
]

{ #category : 'handling' }
WebServer >> newRequest [
	"Answer a new request.
	Subclasses should override this method to use a different request class."

	^(WebRequest new)
		server: self;
		yourself
]

{ #category : 'authentication' }
WebServer >> nonceDeadline [
	"Answer the number of seconds a nonce is considered valid for digest auth
	by the server. After this period, the client will have to reauthenticate.
	The default is 30 minutes."

	^30*60 
]

{ #category : 'authentication' }
WebServer >> passwordAt: username realm: realm put: password [
	"Store the password hash for the key."

	| hash |
	hash := self hashUser: username password: password realm: realm.
	self passwordHashAt: (username,':',realm) put: hash
]

{ #category : 'authentication' }
WebServer >> passwordHashAt: key [
	"Answer the password hash for the given key"

	^vault at: key ifAbsent:['']
]

{ #category : 'authentication' }
WebServer >> passwordHashAt: key put: hash [
	"Store the password hash for the key."

	^vault at: key put: hash
]

{ #category : 'services' }
WebServer >> removeService: entryPoint  [
	"Remove a service from the HTTP service provider.  See #addService:action:"

	mutex critical: [
		entryPoints removeKey: entryPoint percentEscapeUrl asLowercase ifAbsent: [].
	].
]

{ #category : 'listening' }
WebServer >> runListener [
	"Runs the server's listener loop. 
	Accepts incoming connections and handles them asynchronously"

	| connectionSocket |
	[[[listenerSocket notNil and:[listenerSocket isValid]] whileTrue:[
		"Waiting for five seconds means that WebServer will be
		back up after roughly five seconds when the system restarts."
		connectionSocket := listenerSocket waitForAcceptFor: 5.
		"Fork this off since or else errors in acceptClient: kill the listener"
		connectionSocket ifNotNil:[self asyncHandleConnectionFrom: connectionSocket].
	]] ensure:[
		"Logging here is only for the purpose of catching sockets going randomly bad"
		self log: 'listener terminating, socket: ', (listenerSocket ifNotNil:[:s| s statusString]).

		"Try to restart the listener"
		(listenerSocket notNil and:[listenerSocket isValid not]) ifTrue:[
			listenerSocket destroy.
			listenerProcess := nil.
			"Wait a little before retrying"
			(Delay forSeconds: 2) wait.
			^self listenOn: port interface: interface
		].
	]] on: Error do:[:ex| self log: ex].

]

{ #category : 'accessing' }
WebServer >> serverDate [
	"Returns the date string to be used in responses"

	^self class serverDate
]

{ #category : 'accessing' }
WebServer >> serverString [
	"Returns the server string to be used in responses.
	The response is cached for efficiency."

	^serverString ifNil:[serverString := self class serverString].
]

{ #category : 'accessing' }
WebServer >> serverString: aString [
	"Set the server string to be used in responses"

	^serverString := aString
]

{ #category : 'sessions' }
WebServer >> sessionAt: key [
	"Answer the session associated with the given key"

	^mutex critical:[sessions at: key ifAbsent:[nil]].
]

{ #category : 'sessions' }
WebServer >> sessionAt: key ifAbsentPut: session [
	"Answer the session associated with the given key"

	^mutex critical:[sessions at: key ifAbsentPut:[session]].
]

{ #category : 'sessions' }
WebServer >> sessionAt: key put: session [
	"Store the session associated with the given key"

	^mutex critical:[sessions at: key put: session].
]

{ #category : 'sessions' }
WebServer >> sessions [
	"The sessions associated with the WebServer. These are not used by the server
	directly but rather provided so that client code has a convenient place to store
	session data."
	
	^sessions
]

{ #category : 'sessions' }
WebServer >> sessions: aDictionary [
	"The sessions associated with the WebServer. These are not used by the server
	directly but rather provided so that client code has a convenient place to store
	session data."
	
	sessions := aDictionary
]

{ #category : 'accessing' }
WebServer >> siteUrl [
	"The site URL for WebServer, i.e., http://www.mysite.com or http://www.mysite.com/server (when used in a proxied environment) or https://www.mysite.com (when using SSL). Used to allow a client to derive the 'correct' full URL for a running server instance."

	^siteUrl
]

{ #category : 'accessing' }
WebServer >> siteUrl: aString [
	"The site URL for WebServer, i.e., http://www.mysite.com or http://www.mysite.com/server (when used in a proxied environment) or https://www.mysite.com (when using SSL). Used to allow a client to derive the 'correct' full URL for a running server instance."

	siteUrl := aString
]

{ #category : 'listening' }
WebServer >> startListener [
	"Starts the server's listener process"

	self stopListener.
	listenerProcess := [self runListener] newProcess.
	listenerProcess priority: self listenerProcessPriority.
	listenerProcess name: self class name, '''s listener process'.
	listenerProcess resume.

]

{ #category : 'listening' }
WebServer >> stopListener [
	"Stops the server's listener process"

	listenerProcess ifNotNil:[listenerProcess terminate].
	listenerProcess := nil.
]

{ #category : 'errors' }
WebServer >> systemInfoOn: strm [
	"Provides system information for a server error report"
	| info |
	strm nextPutAll: 'VM: ';
		nextPutAll:  WebUtils platformName;
		nextPutAll: ' - ';
		nextPutAll: WebUtils vmVersion;
		newLine.

	strm nextPutAll: 'Image: ';
		nextPutAll:  SystemVersion current versionString;
		nextPutAll: ' [';
		nextPutAll: Smalltalk lastUpdateString asString;
		nextPutAll: ']';
		newLine.

	strm newLine.

	"SecurityManager default printStateOn: strm."

	"Additional info available from the windows VM"
	WebUtils platformName = 'Win32' ifTrue:[
		10001 to: 10003 do: [ :i |
			info := (Smalltalk getSystemAttribute: i) ifNil:[''].
			info isEmpty ifFalse:[strm newLine; nextPutAll: info]]]
]

{ #category : 'errors' }
WebServer >> useDebugErrorHandler [

	self errorHandler: self debugErrorHandler 
]

{ #category : 'accessing' }
WebServer >> vault [
	"The vault used for storing password hashes."

	^vault
]

{ #category : 'accessing' }
WebServer >> vault: anObject [
	"The vault used for storing password hashes.

	Clients can provide their own storage mechanism. 
	Subclasses can also override the lookup and authentication mechanism."

	vault := anObject
]
