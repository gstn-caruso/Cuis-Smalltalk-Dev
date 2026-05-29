"
This is a first cut at a simple MIDI output port.

"
Class {
	#name : 'SimpleMIDIPort',
	#superclass : 'Object',
	#instVars : [
		'portNumber',
		'accessSema',
		'lastCommandByteOut'
	],
	#classVars : [
		'DefaultPortNumber',
		'InterfaceClockRate'
	],
	#category : 'Sound-Scores',
	#package : 'Sound',
	#tag : 'Scores'
}

{ #category : 'utilities' }
SimpleMIDIPort class >> closeAllPorts [
	"Close all MIDI ports."
	"SimpleMIDIPort closeAllPorts"

	| lastPortNum |
	lastPortNum _ self primPortCount - 1.
	0 to: lastPortNum do: [:portNum | self basicNew primMIDIClosePort: portNum].

]

{ #category : 'class initialization' }
SimpleMIDIPort class >> initialize [
	"SimpleMIDIPort initialize"

	InterfaceClockRate _ 1000000.
	DefaultPortNumber _ 0.

]

{ #category : 'utilities' }
SimpleMIDIPort class >> inputPortNumFromUser [
	"Prompt the user for a MIDI input port. Answer a port number, or nil if the user does not select a port or if MIDI is not supported on this platform."
	"
	SimpleMIDIPort inputPortNumFromUser
	"

	| portCount aMenu dir |
	portCount _ self primPortCount.
	portCount = 0 ifTrue: [^ nil].
	aMenu _ PopUpMenu new label: 'MIDI port for input:'.
	0 to: portCount - 1 do:[:i |
		dir _ self primPortDirectionalityOf: i.
		(dir = 1) | (dir = 3) ifTrue:[
			aMenu add: (self portDescription: i) action: i]].
	 ^ aMenu startUpMenu
]

{ #category : 'utilities' }
SimpleMIDIPort class >> midiIsSupported [
	"Answer true if this platform supports MIDI."

	^ self primPortCount > 0

]

{ #category : 'instance creation' }
SimpleMIDIPort class >> openDefault [
	"Answer a new instance of me opened on the default MIDI port."

	^ self openOnPortNumber: DefaultPortNumber

]

{ #category : 'instance creation' }
SimpleMIDIPort class >> openOnPortNumber: portNum [
	"Answer a new instance of me for the given MIDI port number."
	"Details: All clients of a particular MIDI port should share the same instance of me. This allows accesses to the port to be serialized and shared port-related state state to be maintained."

	SimpleMIDIPort allSubInstancesDo: [:p |
		p portNumber = portNum ifTrue: [
			"share the existing port object for this port number"
			^ p]].

	^ super new openOnPortNumber: portNum

]

{ #category : 'utilities' }
SimpleMIDIPort class >> outputPortNumFromUser [
	"Prompt the user for a MIDI output port. Answer a port number, or nil if the user does not select a port or if MIDI is not supported on this platform."
	"
	SimpleMIDIPort outputPortNumFromUser
	"

	| portCount aMenu dir |
	portCount _ self primPortCount.
	portCount = 0 ifTrue: [^ nil].
	aMenu _ PopUpMenu new label: 'MIDI port for output:'.
	0 to: portCount - 1 do:[:i |
		dir _ self primPortDirectionalityOf: i.
		(dir = 2) | (dir = 3) ifTrue:[
			aMenu add: (self portDescription: i) action: i]].
	 ^ aMenu startUpMenu
]

{ #category : 'utilities' }
SimpleMIDIPort class >> portDescription: portNum [
	"Answer a string indicating the directionality of the given MIDI port."
	"(0 to: SimpleMIDIPort primPortCount - 1) collect:
		[:i | SimpleMIDIPort portDescription: i]"

	| portName dir |
	portName _ self primPortNameOf: portNum.
	dir _ self primPortDirectionalityOf: portNum.
	dir = 1 ifTrue: [^ portName, ' (in)'].
	dir = 2 ifTrue: [^ portName, ' (out)'].
	dir = 3 ifTrue: [^ portName, ' (in/out)'].
	^ self error: 'unknown MIDI port directionality'

]

{ #category : 'primitives' }
SimpleMIDIPort class >> primPortCount [
	"Answer the number of MIDI ports supported by this platform, or zero if this primitive is not implemented."

	<primitive: 'primitiveMIDIGetPortCount' module: 'MIDIPlugin'>
	^ 0

]

{ #category : 'primitives' }
SimpleMIDIPort class >> primPortDirectionalityOf: portNum [
	"Answer the platform-specific name for the given MIDI port."

	<primitive: 'primitiveMIDIGetPortDirectionality' module: 'MIDIPlugin'>
	self primitiveFailed.

]

{ #category : 'primitives' }
SimpleMIDIPort class >> primPortNameOf: portNum [
	"Answer the platform-specific name for the given MIDI port."

	<primitive: 'primitiveMIDIGetPortName' module: 'MIDIPlugin'>
	self primitiveFailed.

]

{ #category : 'input' }
SimpleMIDIPort >> bufferTimeStampFrom: aByteArray [
	"Return the timestamp from the given MIDI input buffer. Assume the given buffer is at least 4 bytes long."

	^ ((aByteArray at: 1) bitShift: 24) +
	  ((aByteArray at: 2) bitShift: 16) +
	  ((aByteArray at: 3) bitShift: 8) +
	   (aByteArray at: 4)

]

{ #category : 'open/close' }
SimpleMIDIPort >> close [
	"Close this MIDI port."

	portNumber ifNotNil: [self primMIDIClosePort: portNumber].
	accessSema _ nil.
	lastCommandByteOut _ nil.

]

{ #category : 'open/close' }
SimpleMIDIPort >> ensureOpen [
	"Make sure this MIDI port is open. It is good to call this before starting to use a port in case an intervening image save/restore has caused the underlying hardware port to get closed."

	portNumber ifNil: [^ self error: 'Use "openOn:" to open a MIDI port initially'].
	self primMIDIClosePort: portNumber.
	self primMIDIOpenPort: portNumber readSemaIndex: 0 interfaceClockRate: InterfaceClockRate.
	accessSema _ Semaphore forMutualExclusion.
	lastCommandByteOut _ Array new: 16 withAll: 0.  "clear running status"

]

{ #category : 'input' }
SimpleMIDIPort >> flushInput [
	"Read any lingering MIDI data from this port's input buffer."

	| buf |
	buf _ ByteArray new: 1000.
	[(self readInto: buf) > 0] whileTrue.

]

{ #category : 'output' }
SimpleMIDIPort >> midiCmd: cmd channel: channel byte: dataByte [
	"Immediately output the given MIDI command with the given channel and argument byte to this MIDI port. Assume that the port is open."

	accessSema critical: [
		self primMIDIWritePort: portNumber
			from: (ByteArray
					with: (cmd bitOr: channel)
					with: dataByte)
			at: 0].

]

{ #category : 'output' }
SimpleMIDIPort >> midiCmd: cmd channel: channel byte: dataByte1 byte: dataByte2 [
	"Immediately output the given MIDI command with the given channel and argument bytes to this MIDI port. Assume that the port is open."

	accessSema critical: [
		self primMIDIWritePort: portNumber
			from: (ByteArray
					with: (cmd bitOr: channel)
					with: dataByte1
					with: dataByte2)
			at: 0].

]

{ #category : 'output' }
SimpleMIDIPort >> midiOutput: aByteArray [
	"Output the given bytes to this MIDI port immediately. Assume that the port is open."

	accessSema critical: [
		self primMIDIWritePort: portNumber from: aByteArray at: 0].

]

{ #category : 'open/close' }
SimpleMIDIPort >> openOnPortNumber: portNum [
	"Open this MIDI port on the given port number."

	self close.
	portNumber _ portNum.
	accessSema _ Semaphore forMutualExclusion.
	self ensureOpen.

]

{ #category : 'open/close' }
SimpleMIDIPort >> portNumber [
	"Answer my port number."

	^ portNumber

]

{ #category : 'primitives' }
SimpleMIDIPort >> primMIDIClosePort: portNum [
	"Close the given MIDI port. Don't fail if port is already closed."

	<primitive: 'primitiveMIDIClosePort' module: 'MIDIPlugin'>

]

{ #category : 'primitives' }
SimpleMIDIPort >> primMIDIOpenPort: portNum readSemaIndex: readSemaIndex interfaceClockRate: interfaceClockRate [
	"Open the given MIDI port. If non-zero, readSemaIndex specifies the index in the external objects array of a semaphore to be signalled when incoming MIDI data is available. Not all platforms support signalling the read semaphore. InterfaceClockRate specifies the clock rate of the external MIDI interface adaptor on Macintosh computers; it is ignored on other platforms."

	<primitive: 'primitiveMIDIOpenPort' module: 'MIDIPlugin'>
	self primitiveFailed.

]

{ #category : 'primitives' }
SimpleMIDIPort >> primMIDIReadPort: portNum into: byteArray [
	"Read any available MIDI data into the given buffer (up to the size of the buffer) and answer the number of bytes read."

	<primitive: 'primitiveMIDIRead' module: 'MIDIPlugin'>
	self primitiveFailed.

]

{ #category : 'primitives' }
SimpleMIDIPort >> primMIDIWritePort: portNum from: byteArray at: midiClockValue [
	"Queue the given data to be sent through the given MIDI port at the given time. If midiClockValue is zero, send the data immediately."

	<primitive: 'primitiveMIDIWrite' module: 'MIDIPlugin'>
	self primitiveFailed.

]

{ #category : 'input' }
SimpleMIDIPort >> readInto: aByteArray [
	"Read any data from this port into the given buffer."

	^ self primMIDIReadPort: portNumber into: aByteArray

]
