"
This class implements TCP/IP style network name lookup and translation facilities.

Attempt to keep track of whether there is a network available.
HaveNetwork	true if last attempt to contact the network was successful.
LastContact		Time of that contact (totalSeconds).
haveNetwork	returns true, false, or #expired.  True means there was contact in the last 30 minutes.  False means contact failed or was false last time we asked.  Get out of false state by making contact with a server in some way (FileList or updates).
"
Class {
	#name : 'NetNameResolver',
	#superclass : 'Object',
	#classVars : [
		'DefaultHostName',
		'EnableIPv6',
		'HaveNetwork',
		'ResolverBusy',
		'ResolverError',
		'ResolverMutex',
		'ResolverReady',
		'ResolverSemaphore',
		'ResolverUninitialized',
		'UseOldNetwork'
	],
	#category : 'Network-Kernel',
	#package : 'Network',
	#tag : 'Kernel'
}

{ #category : 'lookups' }
NetNameResolver class >> addressForName: hostName [
	"NetNameResolver addressForName: 'impara.de' "
	"NetNameResolver addressForName: 'localhost' "
	"NetNameResolver addressForName: '127.0.0.1' "
	| addresses |
	self useOldNetwork
		ifTrue: [^self oldAddressForName: hostName].
	addresses := self addressesForName: hostName.
	^addresses
		ifEmpty: [nil]
		ifNotEmpty: [addresses first socketAddress]
]

{ #category : 'lookups' }
NetNameResolver class >> addressForName: hostName family: addressFamily [
	"NetNameResolver addressForName: 'squeak.org' family: SocketAddressInformation addressFamilyINET4"
	"NetNameResolver addressForName: 'localhost' family: SocketAddressInformation addressFamilyINET6"
	"NetNameResolver addressForName: '127.0.0.1' family: SocketAddressInformation addressFamilyINET6"
	| addresses |
	self useOldNetwork ifTrue:
		[^self oldAddressForName: hostName].
	addresses := self addressesForName: hostName family: addressFamily.
	^addresses
		ifEmpty: [nil]
		ifNotEmpty: [addresses first socketAddress]
]

{ #category : 'lookups' }
NetNameResolver class >> addressForName: hostName timeout: secs [
	"Look up the given host name and return its address. Return nil if the address is not found in the given number of seconds."
	"NetNameResolver addressForName: 'create.ucsb.edu' timeout: 30"
	"NetNameResolver addressForName: '100000jobs.de' timeout: 30"
	"NetNameResolver addressForName: '1.7.6.4' timeout: 30"
	"NetNameResolver addressForName: '' timeout: 30 (This seems to return nil?)"

	| deadline |
	self initializeNetwork.
	self useOldNetwork
		ifFalse: [^self addressForName: hostName].
	"check if this is a valid numeric host address (e.g. 1.2.3.4)"
	(self addressFromString: hostName) ifNotNil: [ :numericHostAddress |
		^numericHostAddress ].

	"Look up a host name, including ones that start with a digit (e.g. 100000jobs.de or squeak.org)"
	deadline := Time utcMicrosecondClock + (secs * 1000000).
	"Protect the execution of this block, as the ResolverSemaphore is used for both parts of the transaction."
	^(self resolverMutex critical: [
		(self waitForResolverReadyUntil: deadline) ifTrue: [
			self primStartLookupOfName: hostName.
			(self waitForCompletionUntil: deadline) ifTrue: [
				self primNameLookupResult. ] ] ])
		ifNil: [ (NameLookupFailure hostName: hostName) signal: 'Could not resolve the server named: ', hostName ]		
]

{ #category : 'address string utils' }
NetNameResolver class >> addressFromString: addressString [
	"Return the internet address represented by the given string. The string should contain four positive decimal integers delimited by periods, commas, or spaces, where each integer represents one address byte. Return nil if the string is not a host address in an acceptable format."
	"NetNameResolver addressFromString: '1.2.3.4'"
	"NetNameResolver addressFromString: '1,2,3,4'"
	"NetNameResolver addressFromString: '1 2 3 4'"

	| newAddr s byte delimiter |
	newAddr := ByteArray new: 4.
	s := ReadStream on: addressString.
	s skipSeparators.
	1 to: 4 do: [:i |
		byte := self readDecimalByteFrom: s.
		byte = nil ifTrue: [^ nil].
		newAddr at: i put: byte.
		i < 4 ifTrue: [
			delimiter := s next.
			((delimiter = $.) or: [(delimiter = $,) or: [delimiter = $ ]])
				ifFalse: [^ nil]]].
	^ newAddr

]

{ #category : 'lookup' }
NetNameResolver class >> addressesForName: hostName [
	"NetNameResolver addressesForName: 'impara.de' "
	
	^SocketAddressInformation
		forHost: hostName
		service: ''
		flags: 0
		addressFamily: 0
		socketType: SocketAddressInformation socketTypeStream
		protocol: SocketAddressInformation protocolTCP
]

{ #category : 'lookup' }
NetNameResolver class >> addressesForName: hostName family: addressFamily [
	"NetNameResolver
		addressesForName: 'squeak.org'
		family: SocketAddressInformation addressFamilyINET4"
	"NetNameResolver
		addressesForName: 'impara.de'
		family: SocketAddressInformation addressFamilyINET6"
	
	^SocketAddressInformation
		forHost: hostName
		service: ''
		flags: 0
		addressFamily: addressFamily
		socketType: SocketAddressInformation socketTypeStream
		protocol: SocketAddressInformation protocolTCP
]

{ #category : 'system startup' }
NetNameResolver class >> enableIPv6 [
	<preference: 'Enable IPv6 and new network support'
		category: 'general'
		description: 'If true allow IPv6 support. If false, NetNameResolver useOldNetwork is set.'
		type: #Boolean>
	^EnableIPv6 ifNil: [true]
]

{ #category : 'system startup' }
NetNameResolver class >> enableIPv6: aBool [
	"Set a preference to control whether IPv6 primitives and new network support
	should be used if available, and reinitialize the UseOldNetwork flag to recognize
	the setting. If true, the new networking support will be used if the VM provides
	the required primitives. If false, IPv6 and new network support will not be used.
	The new network support may be unreliable on some platforms, so this preference
	allows it to be explicitly disabled."

	EnableIPv6 := aBool.
	self initializeOldNetworkFlag

]

{ #category : 'system startup' }
NetNameResolver class >> hasIpv6PrimSupport [
	"True if the VM includes the ipv6 primitives"
	^[NetNameResolver primHostNameSize. true]
		on: Error
		do: [false]

]

{ #category : 'class initialization' }
NetNameResolver class >> initialize [
	"NetNameResolver initialize"
	"Note: On the Mac, the name resolver is asynchronous (i.e., Squeak can do other things while it is working), but can only handle one request at a time. On other platforms, such as Unix, the resolver is synchronous; a call to, say, the name lookup primitive will block all Squeak processes until it returns."

	"Resolver Status Values"
	ResolverUninitialized := 0.	"network is not initialized"
	ResolverReady := 1.			"resolver idle, last request succeeded"
	ResolverBusy := 2.			"lookup in progress"
	ResolverError := 3.			"resolver idle, last request failed"

	DefaultHostName := ''.

	self enableIPv6: false. "Initialize preference to permit use of new networking"
	Smalltalk addToStartUpList: self.


]

{ #category : 'network initialization' }
NetNameResolver class >> initializeNetwork [
	"Initialize the network drivers and record the semaphore to be used by the resolver. Do nothing if the network is already initialized. Signal NoNetworkError if network initialization fails."
	"NetNameResolver initializeNetwork" 

	self resolverStatus = ResolverUninitialized
		ifFalse: [^HaveNetwork := true].  "network is already initialized"

	HaveNetwork := false.	"in case abort"
	Smalltalk newExternalSemaphoreDo: [ :semaphore :index |
		ResolverSemaphore := semaphore.
		"result is nil if network initialization failed, self if it succeeds"
		(self primInitializeNetwork: index)
			ifNil: [
				Smalltalk unregisterExternalObject: ResolverSemaphore.
				ResolverSemaphore := nil.
				NoNetworkError signal: 'failed network initialization']
			ifNotNil: [ HaveNetwork := true ] ].

	self initializeOldNetworkFlag
]

{ #category : 'system startup' }
NetNameResolver class >> initializeOldNetworkFlag [
	"If the VM does not provide support for IPv6 primitives, or if the enable IPv6
	preference is not selected, then set a flag to force use of traditional IPv4
	network support. This limits network support to IPv4 and uses a four-element
	ByteArray rather than SocketAddress to represent network addresses."

	UseOldNetwork := self hasIpv6PrimSupport not or: [self enableIPv6 ~= true]
]

{ #category : 'tests' }
NetNameResolver class >> isConnected [
	"Dirty, but avoids fixing the plugin bug"

	[ NetNameResolver addressForName: 'www.google.com' ]
		on: NameLookupFailure
		do: [ :exception | ^ false ].
	^ true
]

{ #category : 'lookups' }
NetNameResolver class >> localAddressString [
	"Return a string representing the local host address as four decimal bytes delimited with decimal points."
	"NetNameResolver localAddressString"

	self useOldNetwork
		ifTrue: [^self stringFromAddress: self primLocalAddress].
	^self localHostAddress hostNumber
]

{ #category : 'lookups' }
NetNameResolver class >> localHostAddress [
	"Return the local address of this host."
	"NetNameResolver localHostAddress"

	self useOldNetwork ifTrue: [
		self initializeNetwork.
		^self primLocalAddress ].
	^NetNameResolver addressForName: self localHostName
]

{ #category : 'lookups' }
NetNameResolver class >> localHostName [
	"Return the local name of this host."
	"NetNameResolver localHostName"

	| host |
	self useOldNetwork ifTrue: [
		| hostName |
		hostName := self
			nameForAddress: self localHostAddress
			timeout: 5.
		^hostName ifNil: [ self localAddressString ] ].
	host := String new: NetNameResolver primHostNameSize.
	NetNameResolver primHostNameResult: host.
	^host
]

{ #category : 'lookups' }
NetNameResolver class >> loopBackName [
	^'localhost'
]

{ #category : 'lookups' }
NetNameResolver class >> nameForAddress: hostAddress [

	^self nameForAddress: hostAddress timeout: 60
]

{ #category : 'lookups' }
NetNameResolver class >> nameForAddress: hostAddress timeout: secs [
	"Look up the given host address and return its name. Return nil if the lookup fails or is not completed in the given number of seconds. Depends on the given host address being known to the gateway, which may not be the case for dynamically allocated addresses."
	"NetNameResolver
		nameForAddress: (NetNameResolver addressFromString: '128.111.92.2')
		timeout: 30"

	| deadline |
	self initializeNetwork.
	deadline := Time utcMicrosecondClock + (secs * 1000000).
	"Protect the execution of this block, as the ResolverSemaphore is used for both parts of the transaction."
	^self resolverMutex critical: [
		(self waitForResolverReadyUntil: deadline) ifTrue: [
			self primStartLookupOfAddress: hostAddress.
			(self waitForCompletionUntil: deadline) ifTrue: [
				self primAddressLookupResult ] ] ]
]

{ #category : 'private' }
NetNameResolver class >> nextSocketAddressInformation [

	| addrSize addr info |
	addrSize := self primGetAddressInfoSize.
	addrSize < 0 ifTrue: [^nil].
	addr := SocketAddress new: addrSize.
	self primGetAddressInfoResult: addr.
	info := SocketAddressInformation
		withSocketAddress: addr
		family: self primGetAddressInfoFamily
		type: self primGetAddressInfoType
		protocol: self primGetAddressInfoProtocol.
	self primGetAddressInfoNext.
	^info
]

{ #category : 'lookups-old' }
NetNameResolver class >> oldAddressForName: aString [
	"NetNameResolver oldAddressForName: 'vpri.org' "
	^self addressForName: aString timeout: 60
]

{ #category : 'primitives' }
NetNameResolver class >> primAbortLookup [
	"Abort the current lookup operation, freeing the name resolver for the next query."

	<primitive: 'primitiveResolverAbortLookup' module: 'SocketPlugin'>
	self primitiveFailed

]

{ #category : 'primitives' }
NetNameResolver class >> primAddressLookupResult [
	"Return the host name found by the last host address lookup. Returns nil if the last lookup was unsuccessful."

	<primitive: 'primitiveResolverAddressLookupResult' module: 'SocketPlugin'>
	self primitiveFailed

]

{ #category : 'primitives-ipv6' }
NetNameResolver class >> primGetAddressInfoFamily [

	<primitive: 'primitiveResolverGetAddressInfoFamily' module: 'SocketPlugin'>
	self primitiveFailed

]

{ #category : 'primitives-ipv6' }
NetNameResolver class >> primGetAddressInfoHost: hostName service: servName flags: flags family: family type: type protocol: protocol [

	<primitive: 'primitiveResolverGetAddressInfo' module: 'SocketPlugin'>
	self primitiveFailed

]

{ #category : 'primitives-ipv6' }
NetNameResolver class >> primGetAddressInfoNext [

	<primitive: 'primitiveResolverGetAddressInfoNext' module: 'SocketPlugin'>
	self primitiveFailed

]

{ #category : 'primitives-ipv6' }
NetNameResolver class >> primGetAddressInfoProtocol [

	<primitive: 'primitiveResolverGetAddressInfoProtocol' module: 'SocketPlugin'>
	self primitiveFailed

]

{ #category : 'primitives-ipv6' }
NetNameResolver class >> primGetAddressInfoResult: socketAddress [

	<primitive: 'primitiveResolverGetAddressInfoResult' module: 'SocketPlugin'>
	self primitiveFailed

]

{ #category : 'primitives-ipv6' }
NetNameResolver class >> primGetAddressInfoSize [

	<primitive: 'primitiveResolverGetAddressInfoSize' module: 'SocketPlugin'>
	self primitiveFailed

]

{ #category : 'primitives-ipv6' }
NetNameResolver class >> primGetAddressInfoType [

	<primitive: 'primitiveResolverGetAddressInfoType' module: 'SocketPlugin'>
	self primitiveFailed

]

{ #category : 'primitives-ipv6' }
NetNameResolver class >> primGetNameInfo: socketAddress flags: flags [

	<primitive: 'primitiveResolverGetNameInfo' module: 'SocketPlugin'>
	flags == 0 ifTrue: [^self primGetNameInfo: socketAddress
						flags: SocketAddressInformation numericFlag].
	self primitiveFailed
]

{ #category : 'primitives-ipv6' }
NetNameResolver class >> primGetNameInfoHostResult: aString [

	<primitive: 'primitiveResolverGetNameInfoHostResult' module: 'SocketPlugin'>
	self primitiveFailed

]

{ #category : 'primitives-ipv6' }
NetNameResolver class >> primGetNameInfoHostSize [

	<primitive: 'primitiveResolverGetNameInfoHostSize' module: 'SocketPlugin'>
	self primitiveFailed

]

{ #category : 'primitives-ipv6' }
NetNameResolver class >> primGetNameInfoServiceResult: aString [

	<primitive: 'primitiveResolverGetNameInfoServiceResult' module: 'SocketPlugin'>
	self primitiveFailed

]

{ #category : 'primitives-ipv6' }
NetNameResolver class >> primGetNameInfoServiceSize [

	<primitive: 'primitiveResolverGetNameInfoServiceSize' module: 'SocketPlugin'>
	self primitiveFailed

]

{ #category : 'primitives-ipv6' }
NetNameResolver class >> primHostNameResult: aString [

	<primitive: 'primitiveResolverHostNameResult' module: 'SocketPlugin'>
	self primitiveFailed

]

{ #category : 'primitives-ipv6' }
NetNameResolver class >> primHostNameSize [

	<primitive: 'primitiveResolverHostNameSize' module: 'SocketPlugin'>
	self primitiveFailed

]

{ #category : 'network initialization' }
NetNameResolver class >> primInitializeNetwork: resolverSemaIndex [
	"Initialize the network drivers on platforms that need it, such as the Macintosh, and return nil if network initialization failed or the reciever if it succeeds. Since mobile computers may not always be connected to a network, this method should NOT be called automatically at startup time; rather, it should be called when first starting a networking application. It is a noop if the network driver has already been initialized. If non-zero, resolverSemaIndex is the index of a VM semaphore to be associated with the network name resolver. This semaphore will be signalled when the resolver status changes, such as when a name lookup query is completed."
	"Note: some platforms (e.g., Mac) only allow only one name lookup query at a time, so a manager process should be used to serialize resolver lookup requests."

	<primitive: 'primitiveInitializeNetwork' module: 'SocketPlugin'>
	^ nil  "return nil if primitive fails"

]

{ #category : 'primitives' }
NetNameResolver class >> primLocalAddress [
	"Return the local address of this host."

	<primitive: 'primitiveResolverLocalAddress' module: 'SocketPlugin'>
	self primitiveFailed

]

{ #category : 'primitives' }
NetNameResolver class >> primNameLookupResult [
	"Return the host address found by the last host name lookup. Returns nil if the last lookup was unsuccessful."

	<primitive: 'primitiveResolverNameLookupResult' module: 'SocketPlugin'>
	self primitiveFailed

]

{ #category : 'primitives' }
NetNameResolver class >> primNameResolverError [
	"Return an integer reflecting the error status of the last network name resolver request. Zero means no error."

	<primitive: 'primitiveResolverError' module: 'SocketPlugin'>
	self primitiveFailed

]

{ #category : 'primitives' }
NetNameResolver class >> primNameResolverStatus [
	"Return an integer reflecting the status of the network name resolver. For a list of possible values, see the comment in the 'initialize' method of this class."

	<primitive: 'primitiveResolverStatus' module: 'SocketPlugin'>
	self primitiveFailed

]

{ #category : 'primitives' }
NetNameResolver class >> primStartLookupOfAddress: hostAddr [
	"Look up the given host address in the Domain Name Server to find its name. This call is asynchronous. To get the results, wait for it to complete or time out and then use primAddressLookupResult."

	<primitive: 'primitiveResolverStartAddressLookup' module: 'SocketPlugin'>
	self primitiveFailed

]

{ #category : 'primitives' }
NetNameResolver class >> primStartLookupOfName: hostName [
	"Look up the given host name in the Domain Name Server to find its address. This call is asynchronous. To get the results, wait for it to complete or time out and then use primNameLookupResult."

	<primitive: 'primitiveResolverStartNameLookup' module: 'SocketPlugin'>
	self primitiveFailed

]

{ #category : 'lookups' }
NetNameResolver class >> promptUserForHostAddress [
	"Ask the user for a host name and return its address."
	"NetNameResolver promptUserForHostAddress"

	^ NetNameResolver promptUserForHostAddressDefault: ''

]

{ #category : 'lookups' }
NetNameResolver class >> promptUserForHostAddressDefault: defaultName [
	"Ask the user for a host name and return its address. If the default name is the empty string, use the last host name as the default."
	"NetNameResolver promptUserForHostAddressDefault: ''"

	| default hostName serverAddr |
	defaultName isEmpty
		ifTrue: [default := DefaultHostName]
		ifFalse: [default := defaultName].
	hostName := StringRequestMorph
		request: 'Host name or address?'
		initialAnswer: default.
	hostName isEmpty ifTrue: [^ 0].
	serverAddr := NetNameResolver addressForName: hostName timeout: 15.
	hostName size > 0 ifTrue: [DefaultHostName := hostName].
	^ serverAddr
]

{ #category : 'private' }
NetNameResolver class >> readDecimalByteFrom: aStream [
	"Read a positive, decimal integer from the given stream. Stop when a non-digit or end-of-stream is encountered. Return nil if stream is not positioned at a decimal digit or if the integer value read exceeds 255.
JMM - 000503 fixed didn't work correctly"

	| digitSeen value digit |
	digitSeen := false.
	value := 0.
	[aStream atEnd] whileFalse: 
		[digit := aStream next digitValue.
		(digit < 0 or: [digit > 9]) ifTrue: [
			aStream skip: -1.
			(digitSeen not or: [value > 255]) ifTrue: [^ nil].
			^ value].
		digitSeen := true.
		value := (value * 10) + digit].
	(digitSeen not or: [value > 255]) ifTrue: [^ nil].
	^ value

]

{ #category : 'lookups' }
NetNameResolver class >> resolverError [
	^self primNameResolverError

]

{ #category : 'private' }
NetNameResolver class >> resolverMutex [
	ResolverMutex ifNil: [ResolverMutex := Semaphore forMutualExclusion].
	^ResolverMutex
]

{ #category : 'lookups' }
NetNameResolver class >> resolverStatus [
	^self primNameResolverStatus

]

{ #category : 'system startup' }
NetNameResolver class >> startUp: resuming [
	"Set the UseOldNetwork flag if ipv6 primitives are not present or if the EnableIPv6 preference is not set."

	resuming ifTrue: [self initializeOldNetworkFlag]
]

{ #category : 'address string utils' }
NetNameResolver class >> stringFromAddress: addr [
	"Return a string representing the given host address as four decimal bytes delimited with decimal points."
	"NetNameResolver stringFromAddress: NetNameResolver localHostAddress"

	| s |	
	(addr isKindOf: SocketAddress) ifTrue: [^addr printString copyUpTo: $( ].
	s := WriteStream on: ''.
	1 to: 3 do: [ :i | (addr at: i) printOn: s. s nextPut: $.].
	(addr at: 4) printOn: s.
	^ s contents

]

{ #category : 'tests' }
NetNameResolver class >> testIPv6 [
	"NetNameResolver testIPv6"
	| infos addr sock size host serverSocket listeningSocket clientSocket |
	Transcript clear.
	"Transcript show: Smalltalk listLoadedModules; cr."
	self initializeNetwork.
	Transcript show: '---- host name ----'; cr.
	size := NetNameResolver primHostNameSize.
	host := String new: size.
	NetNameResolver primHostNameResult: host.
	Transcript show: host; cr.
	Transcript show: '---- address information ----'; cr.
	Transcript show: (infos := SocketAddressInformation
						forHost: 'localhost' service: 'echo' flags: 0
						addressFamily: 0 socketType: SocketAddressInformation socketTypeStream protocol: SocketAddressInformation protocolTCP) printString; cr.
	Transcript show: '---- port manipulation ----'; cr.
	addr := infos first socketAddress.
	Transcript show: addr port printString; cr.
	addr port: 1234.
	Transcript show: addr port printString; cr.
	Transcript show: addr printString; cr.
	Transcript show: '---- client socket ----'; cr.
	Transcript show: (infos := SocketAddressInformation
						forHost: 'localhost' service: 'echo' flags: 0
						addressFamily: 0
						socketType: SocketAddressInformation socketTypeStream
						protocol: SocketAddressInformation protocolTCP) printString; cr.
	infos do: [:info |
		Transcript show: 'Trying ', info printString, '... '.
		(sock := info connect) notNil
			ifTrue:
				[sock sendData: 'hello' count: 5.
				 Transcript show: sock receiveData printString.
				 sock close; destroy].
		Transcript cr].
	Transcript show: '---- localhost defaults: loopback and wildcard addresses ----'; cr.
	Transcript show: (SocketAddress loopbacks) printString; cr.
	Transcript show: (SocketAddress wildcards) printString; cr.
	Transcript show: (SocketAddress loopback4) printString; cr.
	Transcript show: (SocketAddress wildcard4) printString; cr.
	Transcript show: '---- impossible constraints ----'; cr.
	Transcript show: (SocketAddressInformation
						forHost: 'localhost' service: 'echo' flags: 0
						addressFamily:	0
						socketType:		SocketAddressInformation socketTypeDGram
						protocol:		SocketAddressInformation protocolTCP) printString; cr.
	Transcript show: '---- INET4 client-server ----'; cr.
	Transcript show: (infos := SocketAddressInformation
						forHost: '' service: '4242'
						flags:			SocketAddressInformation passiveFlag
						addressFamily:	SocketAddressInformation addressFamilyINET4
						socketType:		SocketAddressInformation socketTypeStream
						protocol:		SocketAddressInformation protocolTCP) printString; cr.
	listeningSocket := infos first listenWithBacklog: 5.
	Transcript show: (infos := SocketAddressInformation
						forHost: 'localhost' service: '4242'
						flags:			0
						addressFamily:	SocketAddressInformation addressFamilyINET4
						socketType:		SocketAddressInformation socketTypeStream
						protocol:		SocketAddressInformation protocolTCP) printString; cr.
	clientSocket := infos first connect.
	(Delay forSeconds: 2) wait.
	serverSocket := listeningSocket accept.
	(Delay forSeconds: 2) wait.
	serverSocket sendData: 'Hi there!' count: 9.
	Transcript show: clientSocket receiveData; cr.
	Transcript nextPutAll: 'client side local/remote: ';
		print: clientSocket localSocketAddress; space;
		print: clientSocket remoteSocketAddress; cr.
	Transcript nextPutAll: 'server side local/remote: ';
		print: serverSocket localSocketAddress; space;
		print: serverSocket remoteSocketAddress; cr;
		endEntry.
	clientSocket close; destroy.
	serverSocket close; destroy.
	listeningSocket close; destroy.
	Transcript show: '---- INET6 client-server ----'; cr.
	Transcript show: (infos := SocketAddressInformation
						forHost: '' service: '4242'
						flags:			SocketAddressInformation passiveFlag
						addressFamily:	SocketAddressInformation addressFamilyINET6
						socketType:		SocketAddressInformation socketTypeStream
						protocol:		SocketAddressInformation protocolTCP) printString; cr.
	infos isEmpty
		ifTrue: [Transcript show: 'FAIL -- CANNOT CREATE INET6 SERVER'; cr]
		ifFalse:
			[listeningSocket := infos first listenWithBacklog: 5.
			Transcript show: (infos := SocketAddressInformation
								forHost: 'localhost' service: '4242'
								flags:			0
								addressFamily:	SocketAddressInformation addressFamilyINET6
								socketType:		SocketAddressInformation socketTypeStream
								protocol:		SocketAddressInformation protocolTCP) printString; cr.
			clientSocket := infos first connect.
			(Delay forSeconds: 2) wait.
			serverSocket := listeningSocket accept.
			(Delay forSeconds: 2) wait.
			serverSocket sendData: 'Hi there!' count: 9.
			Transcript show: clientSocket receiveData; cr.
			Transcript nextPutAll: 'client side local/remote: ';
				print: clientSocket localSocketAddress; space;
				print: clientSocket remoteSocketAddress; cr.
			Transcript nextPutAll: 'server side local/remote: ';
				print: serverSocket localSocketAddress; space;
				print: serverSocket remoteSocketAddress; cr;
				endEntry.
			clientSocket close; destroy.
			serverSocket close; destroy.
			listeningSocket close; destroy].
	Transcript show: '---- trivial tests done ---'; cr.
]

{ #category : 'tests' }
NetNameResolver class >> testPort80 [
	"NetNameResolver testPort80"
	| infos |
	Transcript show: (infos := SocketAddressInformation
						forHost: 'localhost' service: '80' flags: 0
						addressFamily: 0 socketType: 0 protocol: 0) printString; cr.
	Transcript show: (infos := SocketAddressInformation
						forHost: '::1' service: '80' flags: 0
						addressFamily: 0 socketType: 0 protocol: 0) printString; cr.

]

{ #category : 'private' }
NetNameResolver class >> useOldNetwork [
	^UseOldNetwork ~~ false
]

{ #category : 'private' }
NetNameResolver class >> useOldNetwork: flag [
	"Unit test support, not intended for public access"
	^UseOldNetwork := flag
]

{ #category : 'private' }
NetNameResolver class >> waitForCompletionUntil: deadline [
	"Wait until deadline for the resolver to be ready to accept a new request.
	 Return true if the resolver is ready, false if the network is not initialized or
	 the resolver has not become free within the given time period."

	| status millisecondsLeft |
	status := self resolverStatus.
	[ status = ResolverBusy
	  and: [millisecondsLeft := (deadline - Time utcMicrosecondClock) // 1000.
		   millisecondsLeft > 0 ] ]
		whileTrue: "wait for resolver to be available"
			[ ResolverSemaphore waitTimeoutMSecs: millisecondsLeft.
			status := self resolverStatus ].
	status = ResolverReady ifTrue: [ ^true ].
	status = ResolverBusy ifTrue: [ self primAbortLookup ].
	^false
]

{ #category : 'private' }
NetNameResolver class >> waitForResolverReadyUntil: deadline [
	"Wait until deadline for the resolver to be ready to accept a new request. Return true if the resolver is not busy, false if the network is not initialized or the resolver has not become free within the given time period."

	| status millisecondsLeft |
	(status := self resolverStatus) = ResolverUninitialized ifTrue: [ ^false ].
	[ status = ResolverBusy
	  and: [millisecondsLeft := (deadline - Time utcMicrosecondClock) // 1000.
		   millisecondsLeft > 0 ] ]
		whileTrue: "wait for resolver to be available"
			[ ResolverSemaphore waitTimeoutMSecs: millisecondsLeft.
			  status := self resolverStatus ].
	^status ~= ResolverBusy
]
