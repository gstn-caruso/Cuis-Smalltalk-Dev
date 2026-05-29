Extension { #name : 'UniFileStream' }

{ #category : '*Compression' }
UniFileStream >> compressFile [
	"Write a new file that has the data in me compressed in GZip format."
	|  zipped buffer |

	self readOnly; binary.
	zipped _ (self name, '.gz') asFileEntry writeStream.
	zipped binary.
	zipped _ GZipWriteStream on: zipped.
	buffer _ ByteArray new: 50000.
	'Compressing ', self fullName displayProgressAt: Sensor mousePoint
		from: 0 to: self size
		during: [ :barBlock |
			[self atEnd] whileFalse: [
				barBlock value: self position.
				zipped nextPutAll: (self nextInto: buffer)].
			zipped close.
			self close ].
	 ^zipped
]

{ #category : '*Compression' }
UniFileStream >> viewGZipContents [
	"View the contents of a gzipped file"

	|  stringContents |
	self binary.
	stringContents := self contentsOfEntireFile.
	stringContents := (GZipReadStream on: stringContents) upToEnd.
	stringContents := (UnicodeString fromUtf8Bytes: stringContents) withCuisLineEndings.

	Workspace new
		contents: stringContents;
		openLabel: 'Decompressed contents of: ', self localName
]
