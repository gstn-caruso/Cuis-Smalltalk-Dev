"
I represent a socket (network) address consisting of a host internet address and a port number.  My contents are opaque and cannot be interpreted directly.  See the accessing protocol for methods that retrieve the information I contain.
"
Class {
	#name : 'SocketAddress',
	#superclass : 'ByteArray',
	#category : 'Network-Kernel',
	#package : 'Network',
	#tag : 'Kernel'
}

{ #category : 'instance creation' }
SocketAddress class >> fromOldByteAddress: byteArray [
	"Use the resolver to find a socket address corresponding to byteArray"

	| rs addrString addressInfos addressInfo |
	rs := ReadStream on: byteArray.
	addrString := String streamContents: [:strm | 
		[rs atEnd] whileFalse: [
			strm nextPutAll: rs next asString.
			rs atEnd ifFalse: [strm nextPut: $. ]]].
	addressInfos := NetNameResolver addressesForName: addrString.
	addressInfos isEmpty ifTrue: [self error: 'invalid address ', addrString].
	addressInfo := addressInfos
		detect: [:e | e addressFamilyName = #inet4]
		ifNone: [self error: 'no inet4 address for ', addrString].
	^addressInfo socketAddress "first available inet4 interface"

]

{ #category : 'accessing' }
SocketAddress class >> loopback4 [

	^self loopbacks4 first
]

{ #category : 'accessing' }
SocketAddress class >> loopback6 [

	^self loopbacks6 first
]

{ #category : 'accessing' }
SocketAddress class >> loopbacks [

	^SocketAddressInformation forHost: '' service: '0'
		flags:			0
		addressFamily:	0
		socketType:SocketAddressInformation socketTypeStream
		protocol:		 SocketAddressInformation protocolTCP
]

{ #category : 'accessing' }
SocketAddress class >> loopbacks4 [

	^SocketAddressInformation forHost: 'localhost' service: ''
		flags:			0
		addressFamily:	SocketAddressInformation addressFamilyINET4
		socketType: SocketAddressInformation socketTypeStream 
		protocol: SocketAddressInformation protocolTCP
]

{ #category : 'accessing' }
SocketAddress class >> loopbacks6 [

	^SocketAddressInformation forHost: '' service: '0'
		flags:			0
		addressFamily:	SocketAddressInformation addressFamilyINET6
		socketType:		0
		protocol:		0
]

{ #category : 'accessing' }
SocketAddress class >> wildcard4 [

	^self wildcards4 first
]

{ #category : 'accessing' }
SocketAddress class >> wildcard6 [

	^self wildcards6 first
]

{ #category : 'accessing' }
SocketAddress class >> wildcards [

	^SocketAddressInformation forHost: '' service: '0'
		flags:			SocketAddressInformation passiveFlag
		addressFamily:	0
		socketType: SocketAddressInformation socketTypeStream
		protocol: SocketAddressInformation protocolTCP
]

{ #category : 'accessing' }
SocketAddress class >> wildcards4 [

	^SocketAddressInformation forHost: '' service: '0'
		flags:			SocketAddressInformation passiveFlag
		addressFamily:	SocketAddressInformation addressFamilyINET4
		socketType:		 SocketAddressInformation socketTypeStream
		protocol:		 SocketAddressInformation protocolTCP
]

{ #category : 'accessing' }
SocketAddress class >> wildcards6 [

	^SocketAddressInformation forHost: '' service: '0'
		flags:			SocketAddressInformation passiveFlag
		addressFamily:	SocketAddressInformation addressFamilyINET6
		socketType:		0
		protocol:		0
]

{ #category : 'converting' }
SocketAddress >> asByteArray [
	"Assuming IPV4, answer a byte array representation of the host number"
	^ ((self hostNumber findTokens: '.')
		collect: [:e | e asInteger]) asByteArray
]

{ #category : 'converting' }
SocketAddress >> asSocketAddress [

]

{ #category : 'accessing' }
SocketAddress >> hostName [

	| size name |
	NetNameResolver primGetNameInfo: self flags: 0.
	size := NetNameResolver primGetNameInfoHostSize.
	name := String new: size.
	NetNameResolver primGetNameInfoHostResult: name.
	^name
]

{ #category : 'accessing' }
SocketAddress >> hostNumber [

	| size name |
	NetNameResolver primGetNameInfo: self flags: 1.
	size := NetNameResolver primGetNameInfoHostSize.
	name := String new: size.
	NetNameResolver primGetNameInfoHostResult: name.
	^name
]

{ #category : 'primitives' }
SocketAddress >> port [

	<primitive: 'primitiveSocketAddressGetPort' module: 'SocketPlugin'>
	self primitiveFailed

]

{ #category : 'primitives' }
SocketAddress >> port: anInteger [

	<primitive: 'primitiveSocketAddressSetPort' module: 'SocketPlugin'>
	self primitiveFailed

]

{ #category : 'printing' }
SocketAddress >> printOn: aStream [

	[aStream
			nextPutAll: self hostNumber;
			nextPut: $(; nextPutAll: self hostName; nextPut: $);
			nextPut: $,;
			nextPutAll: self serviceNumber;
			nextPut: $(; nextPutAll: self serviceName; nextPut: $)]
		on: Error "e.g. inspector on address from a previous session"
		do: [aStream nextPutAll: 'an invalid ';
				nextPutAll: self class name;
				nextPut: Character space.
			^super printOn: aStream]
]

{ #category : 'accessing' }
SocketAddress >> serviceName [

	| size name |
	NetNameResolver primGetNameInfo: self flags: 0.
	size := NetNameResolver primGetNameInfoServiceSize.
	name := String new: size.
	NetNameResolver primGetNameInfoServiceResult: name.
	^name
]

{ #category : 'accessing' }
SocketAddress >> serviceNumber [

	| size name |
	NetNameResolver primGetNameInfo: self flags: 1.
	size := NetNameResolver primGetNameInfoServiceSize.
	name := String new: size.
	NetNameResolver primGetNameInfoServiceResult: name.
	^name
]
