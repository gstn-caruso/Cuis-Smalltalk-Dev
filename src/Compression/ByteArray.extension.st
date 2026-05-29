Extension { #name : 'ByteArray' }

{ #category : '*Compression' }
ByteArray >> unzipped [
	|  magic1 magic2 |
	magic1 := self at: 1.
	magic2 := self at: 2.
	magic2 * 256 + magic1 = GZipConstants gzipMagic
		ifFalse: [ ^self ].
	^ (GZipReadStream on: self) upToEnd
]
