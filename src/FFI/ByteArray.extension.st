Extension { #name : 'ByteArray' }

{ #category : '*FFI-Kernel' }
ByteArray >> asExternalAddress [
	"Answer an instance of ExternalAddress, with my contents, assuming they form a pointer.
	See inheritance.
	See #asByteArrayWithPointer"

	^ self pointerAt: 1.
]

{ #category : '*FFI-Kernel' }
ByteArray >> asExternalPointer [
	"Compatibility.
	Used for generated FFI code."

	^self asExternalAddress
]

{ #category : '*FFI-Kernel' }
ByteArray >> asNullTerminated [
	"Answer the receiver with a null as the last character"

	(self isNullTerminated) 
		ifTrue:[^self].
	^self copyWith: 0
]

{ #category : '*FFI-Kernel' }
ByteArray >> booleanAt: byteOffset [
	"Booleans are just integers in C word"
	"If a regular ByteArray, byteOffset is the start position in self.
	If an ExternalAddress, take us as a pointer. byteOffset is applied to the pointer. Access memory at pointer+offset."
	^(self integerAt: byteOffset size: 1 signed: false) ~= 0
]

{ #category : '*FFI-Kernel' }
ByteArray >> booleanAt: byteOffset put: value [
	"Booleans are just integers in C word"
	"If a regular ByteArray, byteOffset is the start position in self.
	If an ExternalAddress, take us as a pointer. byteOffset is applied to the pointer. Access memory at pointer+offset."
	self integerAt: byteOffset put: (value ifTrue:[1] ifFalse:[0]) size: 1 signed: false.
	^value
]

{ #category : '*FFI-Kernel' }
ByteArray >> bytesAt: byteOffset length: length [
	"Answer a ByteArray of the given length starting at the indicated byte offset."
	"If a regular ByteArray, byteOffset is the start position in self.
	If an ExternalAddress, take us as a pointer.
		byteOffset is applied to the pointer, access memory at pointer+offset."

	^self bytesAt: byteOffset maxLength: length stopAtNullByte: false
]

{ #category : '*FFI-Kernel' }
ByteArray >> bytesAt: byteOffset maxLength: lengthInBytes stopAtNullByte: aBoolean [
	"Answer a ByteArray of the given length starting at the indicated byte offset.
	Stop at the first null byte if aBoolean, and don't include it in the result."
	"If a regular ByteArray, byteOffset is the start position in self.
	If an ExternalAddress, take us as a pointer. byteOffset is applied to the pointer,
	access memory at pointer+offset."

	^ ByteArray streamContents: [ :strm | | byteIndex byteCount mayContinue byte |
		byteIndex := byteOffset.
		byteCount := 0.
		mayContinue := true.
		[ mayContinue and: [ lengthInBytes isNil or:[ byteCount < lengthInBytes ]]] whileTrue: [
			byte := self uint8At: byteIndex.
			(aBoolean and: [byte = 0])
				ifTrue: [ mayContinue := false ]
				ifFalse: [ strm nextPut: byte ].
			byteIndex := byteIndex + 1.
			byteCount := byteCount + 1 ]].
]

{ #category : '*FFI-Kernel' }
ByteArray >> bytesAt: byteOffset maxLength: lengthInBytes stopAtNullWord: aBoolean [
	"Answer a ByteArray of the given length starting at the indicated byte offset.
	lengthInBytes is assumed to be even.
	Stop at the first null 16 bit word if aBoolean, and don't include it in the result."
	"If a regular ByteArray, byteOffset is the start position in self.
	If an ExternalAddress, take us as a pointer. byteOffset is applied to the pointer,
	access memory at pointer+offset."

	^ ByteArray streamContents: [ :strm | | byteIndex mayContinue byte1 byte2 |
		byteIndex := byteOffset.
		mayContinue := true.
		[ mayContinue and: [ lengthInBytes isNil or:[ byteIndex <= lengthInBytes ]]] whileTrue: [
			byte1 := self uint8At: byteIndex.
			byteIndex := byteIndex + 1.
			byte2 := self uint8At: byteIndex.
			byteIndex := byteIndex + 1.
			(aBoolean and: [byte1 + byte2 = 0])
				ifTrue: [ mayContinue := false ]
				ifFalse: [ strm nextPut: byte1; nextPut: byte2 ]]].
]

{ #category : '*FFI-Kernel' }
ByteArray >> copyToExternalMemory [
	"Copy the receiver into external memory and answer the pointer"

	|addr|
	
	(self size = 0)
		ifTrue: [^ExternalAddress new].	
	addr := ExternalAddress gcallocate: self size.
	self withIndexDo: [:aByte :i | addr uint8At: i put: aByte].
	^addr
]

{ #category : '*FFI-Kernel' }
ByteArray >> doubleAt: byteOffset [
	"Primitive. Return a float value from the receiver.
	- FAILS IF the receiver has not enough bytes for an IEEE 754 (64 bits) floating point number.
	- NOTE that this primitive will access memory in the outer space if invoked from ExternalAddress.
	- SEE Float class >> #fromIEEE64Bit: and Float >> #asIEEE64BitWord"
	<primitive: #primitiveFFIDoubleAt module: #SqueakFFIPrims error: ec>
	^ self primitiveFailed
]

{ #category : '*FFI-Kernel' }
ByteArray >> doubleAt: byteOffset put: value [
	"Primitive. Store the given value as IEEE 754 (64 bits) floating point number.
	- FAILS IF the receiver has not enough bytes for that representation.
	- NOTE that this primitive will access memory in the outer space if invoked from ExternalAddress.
	- SEE Float class >> #fromIEEE64Bit: and Float >> #asIEEE64BitWord"
	<primitive: #primitiveFFIDoubleAtPut module: #SqueakFFIPrims error: ec>
	^ self primitiveFailed
]

{ #category : '*FFI-Kernel' }
ByteArray >> floatAt: byteOffset [
	"Primitive. Return a float value from the receiver.
	- FAILS IF the receiver has not enough bytes for an IEEE 754 (32 bits) floating point number.
	- NOTE that this primitive will access memory in the outer space if invoked from ExternalAddress.
	- SEE Float class >> #fromIEEE32Bit: and Float >> #asIEEE32BitWord"
	<primitive: #primitiveFFIFloatAt module: #SqueakFFIPrims error: ec>
	^ self primitiveFailed
]

{ #category : '*FFI-Kernel' }
ByteArray >> floatAt: byteOffset put: value [
	"Primitive. Store the given value as IEEE 754 (32 bits) floating point number.
	- FAILS IF the receiver has not enough bytes for that representation.
	- NOTE that this primitive will access memory in the outer space if invoked from ExternalAddress.
	- SEE Float class >> #fromIEEE32Bit: and Float >> #asIEEE32BitWord"
	<primitive: #primitiveFFIFloatAtPut module: #SqueakFFIPrims error: ec>
	^ self primitiveFailed
]

{ #category : '*FFI-Kernel' }
ByteArray >> int16At: byteOffset [
	"Answer the signed 16-bit integer at byte offset, in platform native order."
	<primitive: #primitiveSignedInt16At module: #SqueakFFIPrims error: ec>
	^self integerAt: byteOffset size: 2 signed: true
]

{ #category : '*FFI-Kernel' }
ByteArray >> int16At: byteOffset put: value [
	"Store the signed 16-bit integer at byte offset, in platform native order."
	<primitive: #primitiveSignedInt16AtPut module: #SqueakFFIPrims error: ec>
	^self integerAt: byteOffset put: value size: 2 signed: true
]

{ #category : '*FFI-Kernel' }
ByteArray >> int32At: byteOffset [
	"Answer the signed 32-bit integer at byte offset, in platform native order."
	<primitive: #primitiveSignedInt32At module: #SqueakFFIPrims error: ec>
	^self integerAt: byteOffset size: 4 signed: true
]

{ #category : '*FFI-Kernel' }
ByteArray >> int32At: byteOffset put: value [
	"Store the signed 32-bit integer at byte offset, in platform native order."
	<primitive: #primitiveSignedInt32AtPut module: #SqueakFFIPrims error: ec>
	^self integerAt: byteOffset put: value size: 4 signed: true
]

{ #category : '*FFI-Kernel' }
ByteArray >> int64At: byteOffset [
	"Answer the signed 64-bit integer at byte offset, in platform native order."
	<primitive: #primitiveSignedInt64At module: #SqueakFFIPrims error: ec>
	^self integerAt: byteOffset size: 8 signed: true
]

{ #category : '*FFI-Kernel' }
ByteArray >> int64At: byteOffset put: value [
	"Store the signed 64-bit integer at byte offset, in platform native order."
	<primitive: #primitiveSignedInt64AtPut module: #SqueakFFIPrims error: ec>
	^self integerAt: byteOffset put: value size: 8 signed: true
]

{ #category : '*FFI-Kernel' }
ByteArray >> int8At: byteOffset [
	"Answer the signed 8-bit integer at byte offset."
	<primitive: #primitiveSignedInt8At module: #SqueakFFIPrims error: ec>
	^self integerAt: byteOffset size: 1 signed: true
]

{ #category : '*FFI-Kernel' }
ByteArray >> int8At: byteOffset put: value [
	"Store the signed 8-bit integer at byte offset."
	<primitive: #primitiveSignedInt8AtPut module: #SqueakFFIPrims error: ec>
	^self integerAt: byteOffset put: value size: 1 signed: true
]

{ #category : '*FFI-Kernel-platform' }
ByteArray >> integerAt: byteOffset [
	"32 or 64 bits, depending on the platform"
	^Smalltalk wordSize = 8
		ifTrue: [ self int64At: byteOffset ]
		ifFalse: [ self int32At: byteOffset ]
]

{ #category : '*FFI-Kernel-platform' }
ByteArray >> integerAt: byteOffset put: value [
	"32 or 64 bits, depending on the platform"
	^Smalltalk wordSize = 8
		ifTrue: [ self int64At: byteOffset put: value ]
		ifFalse: [ self int32At: byteOffset put: value ]
]

{ #category : '*FFI-Kernel' }
ByteArray >> integerAt: byteOffset put: value size: nBytes signed: aBoolean [
	"Primitive. Store the given value as integer of nBytes size in the receiver.
	- BYTE ORDER is platform native order.
	- FAILS IF the value is out of range.
	- NOTE that this primitive will access memory in the outer space if invoked from ExternalAddress."
	<primitive: #primitiveFFIIntegerAtPut module: #SqueakFFIPrims error: ec>
	^ self primitiveFailed
]

{ #category : '*FFI-Kernel' }
ByteArray >> integerAt: byteOffset size: nBytes signed: aBoolean [
	"Primitive. Return an integer of nBytes size from the receiver.
	- BYTE ORDER is platform native order.
	- FAILS IF the receiver has not enough bytes.
	- NOTE that this primitive will access memory in the outer space if invoked from ExternalAddress."
	<primitive: #primitiveFFIIntegerAt module: #SqueakFFIPrims error: ec>
	^ self primitiveFailed
]

{ #category : '*FFI-Kernel' }
ByteArray >> isExternalAddress [
	"Return true if the receiver describes the address of an object in the outside world"
	^true
]

{ #category : '*FFI-Kernel' }
ByteArray >> isNull [
	"Answer false since only external addresses can be null"
	^false
]

{ #category : '*FFI-Kernel' }
ByteArray >> isNullTerminated [
	"Answer true if the receiver is null terminated"
	
	^(self size > 0) and:[self last = 0] 
]

{ #category : '*FFI-Kernel-oldTypeNames' }
ByteArray >> longPointerAt: byteOffset [
	"Answer an 8-byte pointer object stored at the given byte address"
	"If a regular ByteArray, byteOffset is the start position in self.
	If an ExternalAddress, take us as a pointer. byteOffset is applied to the pointer. Access memory at pointer+offset."

	^ExternalAddress fromInteger: (self uint64At: byteOffset)
]

{ #category : '*FFI-Kernel-oldTypeNames' }
ByteArray >> longPointerAt: byteOffset put: value [
	"Store an 8-byte pointer object at the given byte address"
	"If a regular ByteArray, byteOffset is the start position in self.
	If an ExternalAddress, take us as a pointer. byteOffset is applied to the pointer. Access memory at pointer+offset."

	self uint64At: byteOffset put: value asInteger.
	^value
]

{ #category : '*FFI-Kernel' }
ByteArray >> pointer32At: byteOffset [
	"Answer a 4-byte pointer object stored at the given byte address"
	"If a regular ByteArray, byteOffset is the start position in self.
	If an ExternalAddress, take us as a pointer. byteOffset is applied to the pointer. Access memory at pointer+offset."

	^ExternalAddress fromInteger: (self uint32At: byteOffset)
]

{ #category : '*FFI-Kernel' }
ByteArray >> pointer32At: byteOffset put: value [
	"Store a 4-byte pointer object at the given byte address"
	"If a regular ByteArray, byteOffset is the start position in self.
	If an ExternalAddress, take us as a pointer. byteOffset is applied to the pointer. Access memory at pointer+offset."

	self uint32At: byteOffset put: value asInteger.
	^value
]

{ #category : '*FFI-Kernel' }
ByteArray >> pointer64At: byteOffset [
	"Answer an 8-byte pointer object stored at the given byte address"
	"If a regular ByteArray, byteOffset is the start position in self.
	If an ExternalAddress, take us as a pointer. byteOffset is applied to the pointer. Access memory at pointer+offset."

	^ExternalAddress fromInteger: (self uint64At: byteOffset)
]

{ #category : '*FFI-Kernel' }
ByteArray >> pointer64At: byteOffset put: value [
	"Store an 8-byte pointer object at the given byte address"
	"If a regular ByteArray, byteOffset is the start position in self.
	If an ExternalAddress, take us as a pointer. byteOffset is applied to the pointer. Access memory at pointer+offset."

	self uint64At: byteOffset put: value asInteger.
	^value
]

{ #category : '*FFI-Kernel' }
ByteArray >> pointerAt: byteOffset [
	"Answer a pointer object stored at the given byte address"
	"If a regular ByteArray, byteOffset is the start position in self.
	If an ExternalAddress, take us as a pointer. byteOffset is applied to the pointer. Access memory at pointer+offset."
	^ExternalAddress fromInteger: (ExternalAddress wordSize = 8
										ifTrue: [self uint64At: byteOffset]
										ifFalse: [self uint32At: byteOffset])
]

{ #category : '*FFI-Kernel' }
ByteArray >> pointerAt: byteOffset length: length [
	"Answer a pointer of the given length starting at the indicated byte offset."

	^ ExternalAddress fromInteger: (self integerAt: byteOffset size: length signed: false)
]

{ #category : '*FFI-Kernel' }
ByteArray >> pointerAt: byteOffset put: value [
	"Store a pointer object at the given byte address"
	"If a regular ByteArray, byteOffset is the start position in self.
	If an ExternalAddress, take us as a pointer. byteOffset is applied to the pointer. Access memory at pointer+offset."
	(ExternalAddress wordSize = 8)
		ifTrue: [self uint64At: byteOffset put: value asInteger]
		ifFalse: [self uint32At: byteOffset put: value asInteger].
	^value
]

{ #category : '*FFI-Kernel' }
ByteArray >> pointerAt: byteOffset put: externalAddress length: length [
	"Store a pointer of the given length starting at the indicated byte offset."

	self integerAt: byteOffset put: externalAddress asInteger size: length signed: false.
	^ externalAddress
]

{ #category : '*FFI-Kernel-oldTypeNames' }
ByteArray >> shortPointerAt: byteOffset [
	"Answer a 4-byte pointer object stored at the given byte address"
	"If a regular ByteArray, byteOffset is the start position in self.
	If an ExternalAddress, take us as a pointer. byteOffset is applied to the pointer. Access memory at pointer+offset."

	^ExternalAddress fromInteger: (self uint32At: byteOffset)
]

{ #category : '*FFI-Kernel-oldTypeNames' }
ByteArray >> shortPointerAt: byteOffset put: value [
	"Store a 4-byte pointer object at the given byte address"
	"If a regular ByteArray, byteOffset is the start position in self.
	If an ExternalAddress, take us as a pointer. byteOffset is applied to the pointer. Access memory at pointer+offset."

	self uint32At: byteOffset put: value asInteger.
	^value
]

{ #category : '*FFI-Kernel-oldTypeNames' }
ByteArray >> signedByteAt: byteOffset [
	"Answer an 8bit signed integer starting at the given byte offset"
	"If a regular ByteArray, byteOffset is the start position in self.
	If an ExternalAddress, take us as a pointer. byteOffset is applied to the pointer. Access memory at pointer+offset."

	^self int8At: byteOffset
]

{ #category : '*FFI-Kernel-oldTypeNames' }
ByteArray >> signedByteAt: byteOffset put: value [
	"Store an 8bit signed integer starting at the given byte offset"
	"If a regular ByteArray, byteOffset is the start position in self.
	If an ExternalAddress, take us as a pointer. byteOffset is applied to the pointer. Access memory at pointer+offset."

	^self int8At: byteOffset put: value
]

{ #category : '*FFI-Kernel-oldTypeNames' }
ByteArray >> signedCharAt: byteOffset [
	"If a regular ByteArray, byteOffset is the start position in self.
	If an ExternalAddress, take us as a pointer. byteOffset is applied to the pointer.
	Access memory at pointer+offset.
	Note: This method should likely be removed.
		- It will answer an instance of Character, but based on a single byte it will only be in the Latin-1 range.
		- There's no concept of sign for Characters. This doesn't make any sense.
	Perhaps users should use #signedByteAt: instead?"

	^ Character codePoint: (self uint8At: byteOffset)
]

{ #category : '*FFI-Kernel-oldTypeNames' }
ByteArray >> signedCharAt: byteOffset put: aCharacter [
	"If a regular ByteArray, byteOffset is the start position in self.
	If an ExternalAddress, take us as a pointer. byteOffset is applied to the pointer.
	Access memory at pointer+offset.
	Note: This method should likely be removed.
		- It takes an instance of Character, but it must be in the Latin-1 range.
		- There's no concept of sign for Characters. This doesn't seem useful.
	Perhaps users should use #signedByteAt:put: instead?"

	^self uint8At: byteOffset put: aCharacter codePoint
]

{ #category : '*FFI-Kernel-oldTypeNames' }
ByteArray >> signedLongAt: byteOffset [
	"Answer a 32bit signed integer starting at the given byte offset"
	"If a regular ByteArray, byteOffset is the start position in self.
	If an ExternalAddress, take us as a pointer. byteOffset is applied to the pointer. Access memory at pointer+offset."

	^self int32At: byteOffset
]

{ #category : '*FFI-Kernel-oldTypeNames' }
ByteArray >> signedLongAt: byteOffset put: value [
	"Store a 32bit signed integer starting at the given byte offset"
	"If a regular ByteArray, byteOffset is the start position in self.
	If an ExternalAddress, take us as a pointer. byteOffset is applied to the pointer. Access memory at pointer+offset."

	^self int32At: byteOffset put: value
]

{ #category : '*FFI-Kernel-oldTypeNames' }
ByteArray >> signedLongLongAt: byteOffset [
	"If a regular ByteArray, byteOffset is the start position in self.
	If an ExternalAddress, take us as a pointer. byteOffset is applied to the pointer. Access memory at pointer+offset."

	^self int64At: byteOffset
]

{ #category : '*FFI-Kernel-oldTypeNames' }
ByteArray >> signedLongLongAt: byteOffset put: value [
	"If a regular ByteArray, byteOffset is the start position in self.
	If an ExternalAddress, take us as a pointer. byteOffset is applied to the pointer. Access memory at pointer+offset."

	^self int64At: byteOffset put: value
]

{ #category : '*FFI-Kernel-oldTypeNames' }
ByteArray >> signedShortAt: byteOffset [
	"Answer a 16bit signed integer starting at the given byte offset"
	"If a regular ByteArray, byteOffset is the start position in self.
	If an ExternalAddress, take us as a pointer. byteOffset is applied to the pointer. Access memory at pointer+offset."

	^self int16At: byteOffset
]

{ #category : '*FFI-Kernel-oldTypeNames' }
ByteArray >> signedShortAt: byteOffset put: value [
	"Store a 16bit signed integer starting at the given byte offset"
	"If a regular ByteArray, byteOffset is the start position in self.
	If an ExternalAddress, take us as a pointer. byteOffset is applied to the pointer. Access memory at pointer+offset."

	^self int16At: byteOffset put: value
]

{ #category : '*FFI-Kernel' }
ByteArray >> structAt: byteOffset length: length [
	"Return a structure of the given length starting at the indicated byte offset."
	"If a regular ByteArray, byteOffset is the start position in self.
	If an ExternalAddress, take us as a pointer. byteOffset is applied to the pointer. Access memory at pointer+offset."
	^self bytesAt: byteOffset length: length
]

{ #category : '*FFI-Kernel' }
ByteArray >> structAt: byteOffset put: value length: length [
	"Store a structure of the given length starting at the indicated byte offset."
	"If a regular ByteArray, byteOffset is the start position in self.
	If an ExternalAddress, take us as a pointer. byteOffset is applied to the pointer. Access memory at pointer+offset."
	| start remaining |
	start := 1.
	remaining := length.
	[remaining >= 8] whileTrue:
		[self uint64At: byteOffset + start - 1 put: (value uint64At: start).
		 start := start + 8.
		 remaining := remaining - 8].
	"remaining is now in the range 0 to 7 (assuming non-negative)"
	remaining >= 4 ifTrue:
		[self uint32At: byteOffset + start - 1 put: (value uint32At: start).
		 start := start + 4.
		 remaining := remaining - 4].
	"remaining is now in the range 0 to 3"
	remaining >= 2 ifTrue:
		[self uint16At: byteOffset + start - 1 put: (value uint16At: start).
		 start := start + 2.
		 remaining := remaining - 2].
	"remaining is now in the range 0 to 1"
	remaining = 1 ifTrue:
		[self uint8At: byteOffset + start - 1 put: (value uint8At: start)].
	^value
]

{ #category : '*FFI-Kernel' }
ByteArray >> uint16At: byteOffset [
	"Answer the signed 16-bit integer at byte offset, in platform native order."
	<primitive: #primitiveUnsignedInt16At module: #SqueakFFIPrims error: ec>
	^self integerAt: byteOffset size: 2 signed: false
]

{ #category : '*FFI-Kernel' }
ByteArray >> uint16At: byteOffset put: value [
	"Store the unsigned 16-bit integer at byte offset, in platform native order."
	<primitive: #primitiveUnsignedInt16AtPut module: #SqueakFFIPrims error: ec>
	^self integerAt: byteOffset put: value size: 2 signed: false
]

{ #category : '*FFI-Kernel' }
ByteArray >> uint32At: byteOffset [
	"Answer the signed 32-bit integer at byte offset, in platform native order."
	<primitive: #primitiveUnsignedInt32At module: #SqueakFFIPrims error: ec>
	^self integerAt: byteOffset size: 4 signed: false
]

{ #category : '*FFI-Kernel' }
ByteArray >> uint32At: byteOffset put: value [
	"Store the unsigned 32-bit integer at byte offset, in platform native order."
	<primitive: #primitiveUnsignedInt32AtPut module: #SqueakFFIPrims error: ec>
	^self integerAt: byteOffset put: value size: 4 signed: false
]

{ #category : '*FFI-Kernel' }
ByteArray >> uint64At: byteOffset [
	"Answer the signed 64-bit integer at byte offset, in platform native order."
	<primitive: #primitiveUnsignedInt64At module: #SqueakFFIPrims error: ec>
	^self integerAt: byteOffset size: 8 signed: false
]

{ #category : '*FFI-Kernel' }
ByteArray >> uint64At: byteOffset put: value [
	"Store the unsigned 64-bit integer at byte offset, in platform native order."
	<primitive: #primitiveUnsignedInt64AtPut module: #SqueakFFIPrims error: ec>
	^self integerAt: byteOffset put: value size: 8 signed: false
]

{ #category : '*FFI-Kernel' }
ByteArray >> uint8At: byteOffset [
	"Answer the unsigned 8-bit integer at byte offset. Same as #byteAt: and #at:."
	<primitive: #primitiveUnsignedInt8At module: #SqueakFFIPrims error: ec>
	^self integerAt: byteOffset size: 1 signed: false
]

{ #category : '*FFI-Kernel' }
ByteArray >> uint8At: byteOffset put: value [
	"Store the unsigned 8-bit integer at byte offset. Same as #byteAt:put: and #at:put:."
	<primitive: #primitiveUnsignedInt8AtPut module: #SqueakFFIPrims error: ec>
	^self integerAt: byteOffset put: value size: 1 signed: false
]

{ #category : '*FFI-Kernel-platform' }
ByteArray >> uintegerAt: byteOffset [
	"32 or 64 bits, depending on the platform"
	^Smalltalk wordSize = 8
		ifTrue: [ self uint64At: byteOffset ]
		ifFalse: [ self uint32At: byteOffset ]
]

{ #category : '*FFI-Kernel-platform' }
ByteArray >> uintegerAt: byteOffset put: value [
	"32 or 64 bits, depending on the platform"
	^Smalltalk wordSize = 8
		ifTrue: [ self uint64At: byteOffset put: value ]
		ifFalse: [ self uint32At: byteOffset put: value ]
]

{ #category : '*FFI-Kernel-oldTypeNames' }
ByteArray >> unsignedByteAt: byteOffset [
	"Answer an 8bit unsigned integer starting at the given byte offset"
	"If a regular ByteArray, byteOffset is the start position in self.
	If an ExternalAddress, take us as a pointer. byteOffset is applied to the pointer. Access memory at pointer+offset."

	^self uint8At: byteOffset
]

{ #category : '*FFI-Kernel-oldTypeNames' }
ByteArray >> unsignedByteAt: byteOffset put: value [
	"Store an 8bit unsigned integer starting at the given byte offset"
	"If a regular ByteArray, byteOffset is the start position in self.
	If an ExternalAddress, take us as a pointer. byteOffset is applied to the pointer. Access memory at pointer+offset."

	^self uint8At: byteOffset put: value
]

{ #category : '*FFI-Kernel-oldTypeNames' }
ByteArray >> unsignedCharAt: byteOffset [
	"If a regular ByteArray, byteOffset is the start position in self.
	If an ExternalAddress, take us as a pointer. byteOffset is applied to the pointer.
	Access memory at pointer+offset.
	Note: This method should likely be removed.
		- It will answer an instance of Character, but based on a single byte it will only be in the Latin-1 range.
	Perhaps users should use #unsignedByteAt: instead?"

	^ Character codePoint: (self uint8At: byteOffset)
]

{ #category : '*FFI-Kernel-oldTypeNames' }
ByteArray >> unsignedCharAt: byteOffset put: aCharacter [
	"If a regular ByteArray, byteOffset is the start position in self.
	If an ExternalAddress, take us as a pointer. byteOffset is applied to the pointer.
	Access memory at pointer+offset.
	Note: This method should likely be removed.
		- It takes an instance of Character, but it must be in the Latin-1 range.
	Perhaps users should use #unsignedByteAt:put: instead?"

	^self uint8At: byteOffset put: aCharacter codePoint
]

{ #category : '*FFI-Kernel-oldTypeNames' }
ByteArray >> unsignedLongAt: byteOffset [
	"Answer a 32bit unsigned integer starting at the given byte offset"
	"If a regular ByteArray, byteOffset is the start position in self.
	If an ExternalAddress, take us as a pointer. byteOffset is applied to the pointer. Access memory at pointer+offset."

	^self uint32At: byteOffset
]

{ #category : '*FFI-Kernel-oldTypeNames' }
ByteArray >> unsignedLongAt: byteOffset put: value [
	"Store a 32bit signed integer starting at the given byte offset"
	"If a regular ByteArray, byteOffset is the start position in self.
	If an ExternalAddress, take us as a pointer. byteOffset is applied to the pointer. Access memory at pointer+offset."

	^self uint32At: byteOffset put: value
]

{ #category : '*FFI-Kernel-oldTypeNames' }
ByteArray >> unsignedLongLongAt: byteOffset [
	"Answer a 64-bit integer in Smalltalk order (little-endian)."
	"If a regular ByteArray, byteOffset is the start position in self.
	If an ExternalAddress, take us as a pointer. byteOffset is applied to the pointer. Access memory at pointer+offset."

	^self uint64At: byteOffset
]

{ #category : '*FFI-Kernel-oldTypeNames' }
ByteArray >> unsignedLongLongAt: byteOffset put: value [
	"I store 64-bit integers in Smalltalk (little-endian) order."
	"If a regular ByteArray, byteOffset is the start position in self.
	If an ExternalAddress, take us as a pointer. byteOffset is applied to the pointer. Access memory at pointer+offset."

	^self uint64At: byteOffset put: value
]

{ #category : '*FFI-Kernel-oldTypeNames' }
ByteArray >> unsignedShortAt: byteOffset [
	"Answer a 16bit unsigned integer starting at the given byte offset"
	"If a regular ByteArray, byteOffset is the start position in self.
	If an ExternalAddress, take us as a pointer. byteOffset is applied to the pointer. Access memory at pointer+offset."

	^self uint16At: byteOffset
]

{ #category : '*FFI-Kernel-oldTypeNames' }
ByteArray >> unsignedShortAt: byteOffset put: value [
	"Store a 16bit unsigned integer starting at the given byte offset"
	"If a regular ByteArray, byteOffset is the start position in self.
	If an ExternalAddress, take us as a pointer. byteOffset is applied to the pointer. Access memory at pointer+offset."

	^self uint16At: byteOffset put: value
]

{ #category : '*FFI-Kernel' }
ByteArray >> utf16StringAt: byteOffset length: lengthInBytes [
	"Return a UnicodeString using the given byte length starting at the indicated byte offset.
	Assume bytes are UTF-16 encoded, and in this platform endianess."
	"If a regular ByteArray, byteOffset is the start position in self.
	If an ExternalAddress, take us as a pointer.
		byteOffset is applied to the pointer, access memory at pointer+offset."

	^ self utf16StringAt: byteOffset maxLength: lengthInBytes stopAtNull: false
]

{ #category : '*FFI-Kernel' }
ByteArray >> utf16StringAt: byteOffset maxLength: lengthInBytes stopAtNull: aBoolean [
	"Return a UnicodeString using the given byte length starting at the indicated byte offset.
	Stop at the first null 16 bit word if aBoolean, and don't include it in the result.
	Assume bytes are UTF-16 encoded, and in this platform endianess."
	"If a regular ByteArray, byteOffset is the start position in self.
	If an ExternalAddress, take us as a pointer.
		byteOffset is applied to the pointer, access memory at pointer+offset."

	| utf16Bytes utf8Bytes |
	utf16Bytes := self bytesAt: byteOffset maxLength: lengthInBytes stopAtNullWord: aBoolean.
	"We need a regular ByteArray for this call."
	utf8Bytes := UnicodeString utf8FromUtf16Bytes: utf16Bytes bigEndianHint: Smalltalk isBigEndian.
	^UnicodeString fromUtf8Bytes: utf8Bytes.
]

{ #category : '*FFI-Kernel' }
ByteArray >> utf8StringAt: byteOffset length: lengthInBytes [
	"Return a UnicodeString using the given byte length starting at the indicated byte offset.
	Assume bytes are UTF-8 encoded."
	"If a regular ByteArray, byteOffset is the start position in self.
	If an ExternalAddress, take us as a pointer.
		byteOffset is applied to the pointer, access memory at pointer+offset."

	^ self utf8StringAt: byteOffset maxLength: lengthInBytes stopAtNull: false
]

{ #category : '*FFI-Kernel' }
ByteArray >> utf8StringAt: byteOffset maxLength: lengthInBytes stopAtNull: aBoolean [
	"Return a UnicodeString using the given byte length starting at the indicated byte offset.
	Stop at the first null byte if aBoolean, and don't include it in the result.
	Assume bytes are UTF-8 encoded."
	"If a regular ByteArray, byteOffset is the start position in self.
	If an ExternalAddress, take us as a pointer. byteOffset is applied to the pointer.
	Access memory at pointer+offset."

	| bytes |
	bytes := self bytesAt: byteOffset maxLength: lengthInBytes stopAtNullByte: aBoolean.
	^UnicodeString fromUtf8Bytes: bytes.
]

{ #category : '*FFI-Kernel' }
ByteArray >> voidAt: byteOffset [
	"no accessors for void"
	^self shouldNotImplement
]

{ #category : '*FFI-Kernel' }
ByteArray >> voidAt: byteOffset put: value [
	"no accessors for void"
	^self shouldNotImplement
]
