Class {
	#name : 'ZLibWriteStream',
	#superclass : 'ZipWriteStream',
	#category : 'Compression-System',
	#package : 'Compression',
	#tag : 'System'
}

{ #category : 'crc' }
ZLibWriteStream class >> updateAdler32: adler from: start to: stop in: aCollection [
	"Update crc using the Adler32 checksum technique from RFC1950"
"
        unsigned long s1 = adler & 0xffff;
        unsigned long s2 = (adler >> 16) & 0xffff;
        int n;

        for (n = 0; n < len; n++) {
          s1 = (s1 + buf[n]) % BASE;
          s2 = (s2 + s1)     % BASE;
        }
        return (s2 << 16) + s1;
"
	| s1 s2 |
	<primitive: 'primitiveUpdateAdler32' module: 'ZipPlugin'>
	s1 := adler bitAnd: 16rFFFF.
	s2 := (adler bitShift: -16) bitAnd: 16rFFFF.
	start to: stop do: [ :n | | b |
		b := aCollection at: n.
		s1 := (s1 + b) \\ 65521.
		s2 := (s2 + s1) \\ 65521. ].
	^(s2 bitShift: 16) + s1
]

{ #category : 'initialization' }
ZLibWriteStream >> on: aCollectionOrStream [
	super on: aCollectionOrStream.
	crc _ 1.
]

{ #category : 'initialization' }
ZLibWriteStream >> updateCrc: adler from: start to: stop in: aCollection [
	"Update crc using the Adler32 checksum technique from RFC1950"
	^self class updateAdler32: adler from:  start to:  stop in: aCollection
]

{ #category : 'initialization' }
ZLibWriteStream >> writeFooter [
	"Store the Adler32 checksum as the last 4 bytes."
	3 to: 0 by: -1 do:[:i| encoder nextBytePut: (crc >> (i*8) bitAnd: 255)].
]

{ #category : 'initialization' }
ZLibWriteStream >> writeHeader [
	"Write header information"
	encoder nextBits: 8 put: 120. "deflate method with 15bit window size"
	encoder nextBits: 8 put: 94. "checksum; no preset; fast (flevel=1) compression"
]
