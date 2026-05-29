Extension { #name : 'ReferenceStream' }

{ #category : '*Compression-ObjectStorage' }
ReferenceStream class >> dumpOnCompressedFile: aFileEntry object: anObject [
	"Warning: If the file given by aFileEntry exists, it will be overwritten."
		
	aFileEntry forceWriteStreamDo: [ :fileStream | | compressor |
		compressor := GZipWriteStream on: fileStream.
		compressor nextPutAll: (self streamedRepresentationOf: anObject).
		compressor close]
]

{ #category : '*Compression-ObjectStorage' }
ReferenceStream class >> restoreFromCompressedFile: aFileEntry [
    ^ aFileEntry readStreamDo: [ :fileStream | | uncompressed |
        uncompressed := (GZipReadStream on: fileStream) upToEnd.
        self unStream: uncompressed]
]
