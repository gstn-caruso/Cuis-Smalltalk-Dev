Class {
	#name : 'ZipCrcTests',
	#superclass : 'TestCase',
	#category : 'Tests-Compression',
	#package : 'Tests',
	#tag : 'Compression'
}

{ #category : 'tests' }
ZipCrcTests >> testInvalidGZipCrc [
	"See that a wrong CRC raises an appropriate error"
	| reader writer bytes crcByte |
	writer := GZipWriteStream on: ByteArray new.
	writer nextPutAll: 'Hello World'.
	writer close.

	bytes := writer encodedStream contents.
	crcByte := bytes at: bytes size-5. "before the length"
	bytes at: bytes size-5 put: (crcByte + 1 bitAnd: 255).

	reader := GZipReadStream on: bytes.
	self should:[reader upToEnd] raise: CRCError.

	reader := GZipReadStream on: bytes.
	self should:[reader contents] raise: CRCError.

	reader := GZipReadStream on: bytes.
	self should:[reader next: 100] raise: CRCError.

]

{ #category : 'tests' }
ZipCrcTests >> testInvalidZLibCrc [
	"See that a wrong CRC raises an appropriate error"
	| reader writer bytes crcByte |
	writer := ZLibWriteStream on: ByteArray new.
	writer nextPutAll: 'Hello World'.
	writer close.

	bytes := writer encodedStream contents.
	crcByte := bytes at: bytes size-2.
	bytes at: bytes size-2 put: (crcByte + 1 bitAnd: 255).

	reader := ZLibReadStream on: bytes.
	self should:[reader upToEnd] raise: CRCError.

	reader := ZLibReadStream on: bytes.
	self should:[reader contents] raise: CRCError.

	reader := ZLibReadStream on: bytes.
	self should:[reader next: 100] raise: CRCError.

]

{ #category : 'tests' }
ZipCrcTests >> testInvalidZipCrc [
	"See that a wrong CRC raises an appropriate error"
	| reader writer bytes |
	writer := ZipWriteStream on: ByteArray new.
	writer nextPutAll: 'Hello World'.
	writer close.

	bytes := writer encodedStream contents.

	reader := ZipReadStream on: bytes.
	reader expectedCrc: writer crc - 1.
	self should:[reader upToEnd] raise: CRCError.

	reader := ZipReadStream on: bytes.
	reader expectedCrc: writer crc - 1.
	self should:[reader contents] raise: CRCError.

	reader := ZipReadStream on: bytes.
	reader expectedCrc: writer crc - 1.
	self should:[reader next: 100] raise: CRCError.

]

{ #category : 'tests' }
ZipCrcTests >> testMissingGZipCrc [
	"See that the lack of a CRC raises an appropriate error"
	| reader writer bytes |
	writer := GZipWriteStream on: ByteArray new.
	writer nextPutAll: 'Hello World'.
	writer close.

	bytes := writer encodedStream contents.
	bytes := bytes copyFrom: 1 to: bytes size-6.

	reader := GZipReadStream on: bytes.
	self should:[reader upToEnd] raise: CRCError.

	reader := GZipReadStream on: bytes.
	self should:[reader contents] raise: CRCError.

	reader := GZipReadStream on: bytes.
	self should:[reader next: 100] raise: CRCError.

]

{ #category : 'tests' }
ZipCrcTests >> testMissingZLibCrc [
	"See that the lack of a CRC raises an appropriate error"
	| reader writer bytes |
	writer := ZLibWriteStream on: ByteArray new.
	writer nextPutAll: 'Hello World'.
	writer close.

	bytes := writer encodedStream contents.
	bytes := bytes copyFrom: 1 to: bytes size-2.

	reader := ZLibReadStream on: bytes.
	self should:[reader upToEnd] raise: CRCError.

	reader := ZLibReadStream on: bytes.
	self should:[reader contents] raise: CRCError.

	reader := ZLibReadStream on: bytes.
	self should:[reader next: 100] raise: CRCError.

]

{ #category : 'tests' }
ZipCrcTests >> testMissingZipCrc [
	"See that the lack of a CRC does not raise an error"
	| reader writer bytes readBytes |
	writer := ZipWriteStream on: ByteArray new.
	writer nextPutAll: 'Hello World'.
	writer close.

	bytes := writer encodedStream contents.

	reader := ZipReadStream on: bytes.
	self shouldnt:[readBytes _ reader upToEnd] raise: CRCError.
	self assert: readBytes = 'Hello World' asUtf8Bytes.

	reader := ZipReadStream on: bytes.
	self shouldnt:[reader contents] raise: CRCError.

	reader := ZipReadStream on: bytes.
	self shouldnt:[reader next: 100] raise: CRCError.

]

{ #category : 'tests' }
ZipCrcTests >> testValidGZipCrc [
	| reader writer bytes |
	writer := GZipWriteStream on: ByteArray new.
	writer nextPutAll: 'Hello World'.
	writer close.

	bytes := writer encodedStream contents.
	reader := GZipReadStream on: bytes.
	self assert: reader upToEnd = 'Hello World' asUtf8Bytes.
]

{ #category : 'tests' }
ZipCrcTests >> testValidZLibCrc [
	| reader writer bytes |
	writer := ZLibWriteStream on: ByteArray new.
	writer nextPutAll: 'Hello World'.
	writer close.

	bytes := writer encodedStream contents.
	reader := ZLibReadStream on: bytes.
	self assert: reader upToEnd = 'Hello World' asUtf8Bytes.
	
	bytes := writer encodedStream contents.
	reader := ZLibReadStream on: bytes.
	self assert: (reader next: 100) = 'Hello World' asUtf8Bytes.
]

{ #category : 'tests' }
ZipCrcTests >> testValidZipCrc [
	"See that a correct CRC does not raise an error and that we can read what we wrote."
	| reader writer bytes readBytes |
	writer := ZipWriteStream on: ByteArray new.
	writer nextPutAll: 'Hello World'.
	writer close.

	bytes := writer encodedStream contents.

	reader := ZipReadStream on: bytes.
	reader expectedCrc: writer crc.
	self shouldnt:[ readBytes _ reader upToEnd] raise: CRCError.
	self assert: readBytes = 'Hello World' asUtf8Bytes.

	reader := ZipReadStream on: bytes.
	reader expectedCrc: writer crc.
	self shouldnt:[ readBytes _ reader contents] raise: CRCError.
	self assert: readBytes = 'Hello World' asUtf8Bytes.

	reader := ZipReadStream on: bytes.
	reader expectedCrc: writer crc.
	self shouldnt:[ readBytes _ reader next: 11 ] raise: CRCError.
	self assert: readBytes = 'Hello World' asUtf8Bytes.
	
	reader := ZipReadStream on: bytes.
	reader expectedCrc: writer crc.
	self shouldnt:[ readBytes _ reader next: 100 ] raise: CRCError.
	self assert: readBytes = 'Hello World' asUtf8Bytes.
]
