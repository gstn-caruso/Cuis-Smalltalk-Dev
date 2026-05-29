Class {
	#name : 'SocketStreamTest',
	#superclass : 'TestCase',
	#instVars : [
		'clientStream',
		'serverStream'
	],
	#category : 'Tests-Network-Kernel',
	#package : 'Tests',
	#tag : 'Network-Kernel'
}

{ #category : 'running' }
SocketStreamTest >> setUp [
	| listener clientSocket serverSocket |
	listener := Socket newTCP.
	[listener listenOn: 0 backlogSize: 4.

	clientSocket := Socket newTCP.
	clientSocket connectTo: #[127 0 0 1] port: listener localPort.
	clientSocket waitForConnectionFor: 1.
	self assert: clientSocket isConnected.

	serverSocket := listener waitForAcceptFor: 1.
	self assert: serverSocket isConnected.
	] ensure:[listener destroy].

	clientStream := SocketStream on: clientSocket.
	serverStream := SocketStream on: serverSocket.

]

{ #category : 'running' }
SocketStreamTest >> tearDown [
	clientStream ifNotNil:[clientStream destroy].
	serverStream ifNotNil:[serverStream destroy].
]

{ #category : 'tests - stream protocol' }
SocketStreamTest >> testNextIntoClose [
	"Ensure that #next:into: will function properly when the connection is closed"

	clientStream nextPutAll:'A line of text'; flush.
	[(Delay forMilliseconds: 100) wait.
	clientStream close] fork.
	self assert: (serverStream next: 100 into: (String new: 100) startingAt: 1) 
		equals: 'A line of text'.

]

{ #category : 'tests - stream protocol' }
SocketStreamTest >> testNextIntoCloseNonSignaling [
	"Ensure that #next:into: will function properly when the connection is closed"

	serverStream shouldSignal: false.
	clientStream nextPutAll:'A line of text'; flush.
	[(Delay forMilliseconds: 100) wait.
	clientStream close] fork.
	self assert: (serverStream next: 100 into: (String new: 100) startingAt: 1)
		equals: 'A line of text'.

]

{ #category : 'tests - stream protocol' }
SocketStreamTest >> testUpTo [
	"Tests correct behavior of #upTo:"

	clientStream nextPutAll:'A line of text', String cr, 'with more text'; flush.
	self assert: (serverStream upTo: Character cr) = 'A line of text'.
	[(Delay forSeconds: 1) wait.
	clientStream nextPutAll: String cr; flush] fork.
	self assert: (serverStream upTo: Character cr) = 'with more text'.

]

{ #category : 'tests - stream protocol' }
SocketStreamTest >> testUpToAfterCloseNonSignaling [
	"Tests correct behavior of #upToAll"

	| resp |
	clientStream nextPutAll: 'A line of text'.
	clientStream close.
	serverStream shouldSignal: false.
	self shouldnt: [resp := serverStream upTo: Character cr] raise: ConnectionClosed.
	self assert: resp = 'A line of text'.
]

{ #category : 'tests - stream protocol' }
SocketStreamTest >> testUpToAfterCloseSignaling [
	"Tests correct behavior of #upToAll"

	clientStream nextPutAll:'A line of text'.
	clientStream close.
	self should: [serverStream upTo: Character cr] raise: ConnectionClosed.

]

{ #category : 'tests - stream protocol' }
SocketStreamTest >> testUpToAll [
	"Tests correct behavior of #upToAll"

	clientStream nextPutAll:'A line of text', String crlf, 'with more text'; flush.
	self assert: (serverStream upToAll: String crlf) = 'A line of text'.
	[(Delay forSeconds: 1) wait.
	clientStream nextPutAll: String crlf; flush] fork.
	self assert: (serverStream upToAll: String crlf) = 'with more text'.

]

{ #category : 'tests - stream protocol' }
SocketStreamTest >> testUpToAllAfterCloseNonSignaling [
	"Tests correct behavior of #upToAll"

	| resp |
	clientStream nextPutAll: 'A line of text'.
	clientStream close.
	serverStream shouldSignal: false.
	self shouldnt: [resp := serverStream upToAll: String crlf] raise: ConnectionClosed.
	self assert: resp = 'A line of text'.
]

{ #category : 'tests - stream protocol' }
SocketStreamTest >> testUpToAllAfterCloseSignaling [
	"Tests correct behavior of #upToAll"

	clientStream nextPutAll:'A line of text'.
	clientStream close.
	self should: [serverStream upToAll: String crlf] raise: ConnectionClosed.

]

{ #category : 'tests - stream protocol' }
SocketStreamTest >> testUpToAllAsciiVsBinary [
	"Tests correct behavior of #upToAll"

	serverStream ascii.
	clientStream nextPutAll:'A line of text', String crlf, 'with more text'; flush.
	self assert: (serverStream upToAll: #[13 10]) = 'A line of text'.

	serverStream binary.
	clientStream nextPutAll: String crlf; flush.
	self assert: (serverStream upToAll: String crlf) asString = 'with more text'.

]

{ #category : 'tests - stream protocol' }
SocketStreamTest >> testUpToAllCrlfAscii [
	"Tests correct behavior of #upToAll with a two-byte delimiter in ascii mode"
	self testUpToAllDelimiter: String crlf
		input: 'A header', String crlf, 'and a body'
		expected: {'A header'. 'and a body'}
		binary: false.

]

{ #category : 'tests - stream protocol' }
SocketStreamTest >> testUpToAllCrlfBinary [
	"Tests correct behavior of #upToAll with a two-byte delimiter in binary mode"
	self testUpToAllDelimiter: String crlf
		input: 'A header', String crlf, 'and a body'
		expected: {'A header'. 'and a body'}
		binary: true.

]

{ #category : 'tests - stream protocol' }
SocketStreamTest >> testUpToAllCrlfCrlfAscii [
	"Tests correct behavior of #upToAll with a four-byte delimiter in ascii mode"
	self testUpToAllDelimiter: String crlfcrlf
		input: 'A header', String crlfcrlf, 'and a body'
		expected: {'A header'. 'and a body'}
		binary: false.

]

{ #category : 'tests - stream protocol' }
SocketStreamTest >> testUpToAllCrlfCrlfBinary [
	"Tests correct behavior of #upToAll with a four-byte delimiter in binary mode"
	self testUpToAllDelimiter: String crlfcrlf
		input: 'A header', String crlfcrlf, 'and a body'
		expected: {'A header'. 'and a body'}
		binary: true.

]

{ #category : 'tests - stream protocol' }
SocketStreamTest >> testUpToAllDelimiter: delimiter input: input expected: aCollection binary: useBinary [
	"General test of #upToAll."
	clientStream nextPutAll: input; close.
	serverStream shouldSignal: false.
	useBinary ifTrue: [serverStream binary] ifFalse: [serverStream ascii].
	aCollection do: [:expected | | actual |
		actual := (serverStream upToAll: delimiter) asString.
		self assert: actual = expected].

]

{ #category : 'tests - stream protocol' }
SocketStreamTest >> testUpToAllEmptyPatternAscii [
	"Tests correct behavior of #upToAll with an empty delimiter string, in ascii mode"
	self testUpToAllDelimiter: ''
		input: 'xaxbxc'
		expected: {'xaxbxc'}
		binary: false.

]

{ #category : 'tests - stream protocol' }
SocketStreamTest >> testUpToAllEmptyPatternBinary [
	"Tests correct behavior of #upToAll with an empty delimiter string, in binary mode"
	self testUpToAllDelimiter: ''
		input: 'xaxbxc'
		expected: {'xaxbxc'}
		binary: true.

]

{ #category : 'tests - stream protocol' }
SocketStreamTest >> testUpToAllLimit [
	"Tests correct behavior of #upToAll:limit:"

	clientStream nextPutAll:'A line of text'; flush.
	self assert: (serverStream upToAll: String crlf limit: 5) = 'A line of text'.
]

{ #category : 'tests - stream protocol' }
SocketStreamTest >> testUpToAllLongPatternAscii [
	"Tests correct behavior of #upToAll with a long delimiter string, in ascii mode"
	self testUpToAllDelimiter: 'xxxxx'
		input: 'xxxxxaxxxxbxxxxxc'
		expected: {''. 'axxxxb'. 'c'}
		binary: false.

]

{ #category : 'tests - stream protocol' }
SocketStreamTest >> testUpToAllLongPatternBinary [
	"Tests correct behavior of #upToAll with a long delimiter string, in binary mode"
	self testUpToAllDelimiter: 'xxxxx'
		input: 'xxxxxaxxxxbxxxxxc'
		expected: {''. 'axxxxb'. 'c'}
		binary: true.

]

{ #category : 'tests - stream protocol' }
SocketStreamTest >> testUpToAllMediumPatternAscii [
	"Tests correct behavior of #upToAll with a two-character delimiter string, in ascii mode"
	self testUpToAllDelimiter: 'xx'
		input: 'xxaxbxxc'
		expected: {''. 'axb'. 'c'}
		binary: false.

]

{ #category : 'tests - stream protocol' }
SocketStreamTest >> testUpToAllMediumPatternBinary [
	"Tests correct behavior of #upToAll with a two-character delimiter string, in binary mode"
	self testUpToAllDelimiter: 'xx'
		input: 'xxaxbxxc'
		expected: {''. 'axb'. 'c'}
		binary: true.

]

{ #category : 'tests - stream protocol' }
SocketStreamTest >> testUpToAllShortPatternAscii [
	"Tests correct behavior of #upToAll with a short delimiter string, in ascii mode"
	self testUpToAllDelimiter: 'x'
		input: 'xaxbxc'
		expected: {''. 'a'. 'b'. 'c'}
		binary: false.

]

{ #category : 'tests - stream protocol' }
SocketStreamTest >> testUpToAllShortPatternAscii2 [
	"Tests correct behavior of #upToAll with a short delimiter string, in ascii mode"
	self testUpToAllDelimiter: 'x'
		input: 'axbxcx'
		expected: {'a'. 'b'. 'c'. ''}
		binary: false.

]

{ #category : 'tests - stream protocol' }
SocketStreamTest >> testUpToAllShortPatternBinary [
	"Tests correct behavior of #upToAll with a short delimiter string, in binary mode"
	self testUpToAllDelimiter: 'x'
		input: 'xaxbxc'
		expected: {''. 'a'. 'b'. 'c'}
		binary: true.

]

{ #category : 'tests - stream protocol' }
SocketStreamTest >> testUpToAllShortPatternBinary2 [
	"Tests correct behavior of #upToAll with a short delimiter string, in binary mode"
	self testUpToAllDelimiter: 'x'
		input: 'axbxcx'
		expected: {'a'. 'b'. 'c'. ''}
		binary: true.

]

{ #category : 'tests - stream protocol' }
SocketStreamTest >> testUpToAllTimeout [
	"Tests correct behavior of #upToAll"

	clientStream nextPutAll: 'A line of text'.
	serverStream timeout: 1.
	self should: [serverStream upToAll: String crlf] raise: ConnectionTimedOut.

]

{ #category : 'tests - stream protocol' }
SocketStreamTest >> testUpToAsciiVsBinary [
	"Tests correct behavior of #upTo:"

	serverStream ascii.
	clientStream nextPutAll:'A line of text', String cr, 'with more text'; flush.
	self assert: (serverStream upTo: 13) = 'A line of text'.

	serverStream binary.
	clientStream nextPutAll: String cr; flush.
	self assert: (serverStream upTo: Character cr) asString = 'with more text'.

]

{ #category : 'tests - stream protocol' }
SocketStreamTest >> testUpToEndClose [
	"Ensure that #upToEnd will function properly when the connection is closed"

	clientStream nextPutAll:'A line of text'; flush.
	[(Delay forMilliseconds: 100) wait.
	clientStream close] fork.
	self assert: (serverStream upToEnd) 
		equals: 'A line of text'.

]

{ #category : 'tests - stream protocol' }
SocketStreamTest >> testUpToEndCloseNonSignaling [
	"Ensure that #upToEnd will function properly when the connection is closed"

	serverStream shouldSignal: false.
	clientStream nextPutAll:'A line of text'; flush.
	[(Delay forMilliseconds: 100) wait.
	clientStream close] fork.
	self assert: (serverStream upToEnd)
		equals: 'A line of text'.

]

{ #category : 'tests - stream protocol' }
SocketStreamTest >> testUpToMax [
	"Tests correct behavior of #upToAll:max:"

	clientStream nextPutAll:'A line of text'; flush.
	self assert: (serverStream upTo: Character cr limit: 5) = 'A line of text'.
]

{ #category : 'tests - stream protocol' }
SocketStreamTest >> testUpToTimeout [
	"Tests correct behavior of #upToAll"

	clientStream nextPutAll: 'A line of text'.
	serverStream timeout: 1.
	self should: [serverStream upTo: Character cr] raise: ConnectionTimedOut.

]
