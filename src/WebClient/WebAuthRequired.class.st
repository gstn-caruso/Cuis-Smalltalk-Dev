"
Exception signaled when authentication is required.
"
Class {
	#name : 'WebAuthRequired',
	#superclass : 'Exception',
	#instVars : [
		'client',
		'request',
		'response',
		'authParams',
		'message'
	],
	#category : 'WebClient-Core',
	#package : 'WebClient',
	#tag : 'Core'
}

{ #category : 'instance creation' }
WebAuthRequired class >> client: aWebClient request: aWebRequest response: aWebResponse [
	"Creates a new exception"

	^(self new)
		client: aWebClient 
		request: aWebRequest 
		response: aWebResponse
]

{ #category : 'accessing' }
WebAuthRequired >> client [
	"The client causing the exception"

	^client
]

{ #category : 'initialize' }
WebAuthRequired >> client: aWebClient request: aWebRequest response: aWebResponse [
	"Initializes the exception"

	client := aWebClient.
	request := aWebRequest.
	response := aWebResponse.

]

{ #category : 'defaults' }
WebAuthRequired >> defaultAction [

	self resume: false.
]

{ #category : 'defaults' }
WebAuthRequired >> defaultResumeValue [
	"Resume with false by default"

	^false
]

{ #category : 'testing' }
WebAuthRequired >> isProxyAuth [
	"Return true if proxy authorization is required"

	^response code = 407
]

{ #category : 'testing' }
WebAuthRequired >> isUnauthorized [
	"Return true if authorization is required"

	^response code = 401
]

{ #category : 'accessing' }
WebAuthRequired >> message [
	"Answer a default message for the user to ask for input"

	self isProxyAuth ifTrue:[
		^'The proxy server at "', client proxyServerName, '" requires authentication.'.
	].

	^'The server at "', client serverName, '" requires authentication.'.
]

{ #category : 'accessing' }
WebAuthRequired >> request [
	"The request object causing the exception"

	^request
]

{ #category : 'accessing' }
WebAuthRequired >> response [
	"The response object causing the exception"

	^response
]

{ #category : 'initialize' }
WebAuthRequired >> username: username password: password [
	"Use the given username/password as credentials"

	| params retry |
	params := self isProxyAuth ifTrue:[client proxyParams] ifFalse:[client authParams].
	retry := false.
	(params at: #username ifAbsent:[nil]) = username ifFalse:[
		params at: #username put: username.
		retry := true.
	].
	(params at: #password ifAbsent:[nil]) = password ifFalse:[
		params at: #password put: password.
		retry := true.
	].
	retry ifTrue:[self resume: true].

]
