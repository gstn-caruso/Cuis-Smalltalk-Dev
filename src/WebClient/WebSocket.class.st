"
A wrapper object for the WebSocket API.
"
Class {
	#name : 'WebSocket',
	#superclass : 'Object',
	#instVars : [
		'name',
		'process',
		'stream',
		'handlers'
	],
	#category : 'WebClient-Core',
	#package : 'WebClient',
	#tag : 'Core'
}

{ #category : 'example' }
WebSocket class >> example	"WebSocket example" [

	"This is a very simple WebSocket example implementing a basic chat system.
	Each message sent by a client connection is broadcast to everyone."

	| mutex sockets |
	mutex := Mutex new.
	sockets := OrderedCollection new.
	WebServer reset default listenOn: 8080.

	WebServer default addService: '/' action:[:req|
		"Serves the main html chat page"
		req send200Response: self examplePage contentType: 'text/html'.
	].

	WebServer default addService: '/broadcast' action:[:req| | ws |
		"Implements the WebSocket broadcaster"
		ws := req asWebSocket.
		ws timeout: 300. "5 minutes timeout"
	
		"Transcript log: 'New ', ws requestLine."
		Transcript log: 'New '.
		
		ws onMessage:[:data|
			mutex critical:[sockets do:[:s| s send: data]].
		].
		ws onClose:[
			Transcript log: 'Closing ', ws requestLine.
			mutex critical:[sockets remove: ws ifAbsent:[]].
		].
		ws onError:[:ex|
			Transcript log: ws requestLine.
			Transcript log: ex description.
			Transcript log: ex signalerContext longStack.
		].
		mutex critical:[sockets add: ws].

		"We don't need to #fork here, in fact we shouldn't since it ensures
		that shutting down WebServer shuts down any WebSockets, too."
		ws run.
	].
]

{ #category : 'example' }
WebSocket class >> examplePage [
	"The example HTML page for WebServer"

	^'<html>
<p id="status">WebSocket: Not connected</p> 
<form> 
    <input type="text" id="chat" placeholder="type and press enter to chat" /> 
</form> 
<p>To test, open two windows with Web Socket support, type a message above and press return.</p> 
<ul id="log"></ul> 

<script>

var conn = {};
var log = document.getElementById("log");
var chat = document.getElementById("chat");
var form = chat.form;
var state = document.getElementById("status"); 
 
if (window.WebSocket === undefined) {
  state.innerHTML = "(WebSockets not supported)";
} else {
    conn = new WebSocket("ws://localhost:8080/broadcast");
    conn.onopen = function () {
      state.innerHTML = "WebSocket: Connected";
    };
 
    conn.onmessage = function (event) {
      log.innerHTML = "<li>" + event.data + "</li>" + log.innerHTML;
    };
    
    conn.onclose = function (event) {
      state.innerHTML = "WebSocket: Closed";
    };

	form.addEventListener("submit", function (event) {
		event.preventDefault();
		if (conn.readyState === 1) {
			conn.send(chat.value);      
			chat.value = "";
		}
	}, false);
};
 
</script> 

</body>
</html>'
]

{ #category : 'instance creation' }
WebSocket class >> on: aStream [
	"Create a new WebSocket instance using the given SocketStream"

	^self new on: aStream
]

{ #category : 'initialize' }
WebSocket >> close [
	"Request graceful close"

	^self subclassResponsibility
]

{ #category : 'running' }
WebSocket >> fork [
	"Fork the WebSocket's input process."

	process := [self run] newProcess.
	process resume.

]

{ #category : 'private' }
WebSocket >> handle: selector arguments: argList [

	^self handle: selector arguments: argList ifAbsent:[nil]
]

{ #category : 'private' }
WebSocket >> handle: selector arguments: argList ifAbsent: aBlock [

	^(handlers at: selector ifAbsent:[^aBlock value])
		valueWithPossibleArgs: argList.
]

{ #category : 'private' }
WebSocket >> handleClose [
	"Handle a connection close"

	^self handle: 'close' arguments: (Array with: self)

]

{ #category : 'private' }
WebSocket >> handleError: exception [
	"Handle an error"

	^self handle: 'error' arguments: (Array with: exception with: self)
]

{ #category : 'private' }
WebSocket >> handleMessage: msgData type: msgType [
	"Handle an incoming message of the given type"

	self handle: 'message' arguments: (Array with: msgData with: msgType with: self)
]

{ #category : 'initialize' }
WebSocket >> initialize [
	super initialize.
	handlers := Dictionary new.
]

{ #category : 'initialize' }
WebSocket >> on: aStream [
	"Create a new WebSocket instance using the given SocketStream"

	stream := aStream.
	name := String streamContents:[:s| 
		stream socket remoteAddress 
			do:[:b| s print: b] 
			separatedBy:[s nextPut: $.]].
	name := name, ':', stream socket remotePort asString.
	
]

{ #category : 'running' }
WebSocket >> onClose: aBlock [
	"Set the handler block to invoke when the socket is closed"

	handlers at: 'close' put: aBlock.
]

{ #category : 'running' }
WebSocket >> onError: aBlock [
	"Set the handler block to invoke when an error occurs"

	handlers at: 'error' put: aBlock.
]

{ #category : 'running' }
WebSocket >> onMessage: aBlock [
	"Set the handler block to invoke when a message is received"

	handlers at: 'message' put: aBlock.

]

{ #category : 'private' }
WebSocket >> printOn: aStream [
	"Print the receiver"

	aStream nextPutAll: self class name.
	aStream nextPutAll: '(', name, ')'.
]

{ #category : 'running' }
WebSocket >> run [
	"Run the WebSocket's input process."

	^self subclassResponsibility
]

{ #category : 'read/write' }
WebSocket >> send: aString [
	"Writes one frame worth of data"

	^self subclassResponsibility
]

{ #category : 'accessing' }
WebSocket >> timeout [
	"The underlying stream timeout"

	^stream timeout
]

{ #category : 'accessing' }
WebSocket >> timeout: seconds [
	"Sets the underlying stream timeout"

	^stream timeout: seconds
]
