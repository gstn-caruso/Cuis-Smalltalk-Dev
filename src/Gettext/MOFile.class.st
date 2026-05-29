"
Wrapper for MO file of gettext.
Known limitation:  
	currently don't support prural form.
	translation strings have to be encoded in utf-8.

Implementation notes:
	Testing on XO showed emulation of hash search without plugin + on demand loading is slow.
	The test also showed conversion of utf8 string to Squeak's String is really slow (especially for non-latin language).
	so in this version, all of original/translated strings are loaded on initiaization,
	but "translated strings" is left as ByteString on loading time, to reduce loading time.
	After that the translated string is converted on demand. 

"
Class {
	#name : 'MOFile',
	#superclass : 'Object',
	#instVars : [
		'localeID',
		'isLittleEndian',
		'magic',
		'revision',
		'nStrings',
		'originalTableOffset',
		'translatedTableOffset',
		'hashTableSize',
		'hashTableOffset',
		'hashTable',
		'originalStrings',
		'translatedStrings',
		'translations'
	],
	#classVars : [
		'Cr',
		'Lf'
	],
	#category : 'Gettext',
	#package : 'Gettext'
}

{ #category : 'instance creation' }
MOFile class >> fileName: path localeID: id [
	^self new 
			load:path localeID: id
]

{ #category : 'class initialization' }
MOFile class >> initialize [
	Cr _ Character cr.
	Lf _ Character lf.

]

{ #category : 'experimental' }
MOFile >> hashPjw: aString [
	"This is the hash function used by the (unused) hashTable. Kept in case someone wants to try and make it work"
	"So called `hashpjw' function by P.J. Weinberger
   	[see Aho/Sethi/Ullman, COMPILERS: Principles, Techniques and Tools,
   	1986, 1987 Bell Telephone Laboratories, Inc.] "
	| stringSize hash g |
	stringSize _ aString size.
	hash _ 0.
	1 to: stringSize do: [:pos |
		hash _ hash bitShift: 4.
		hash _ hash + ((aString at: pos) asInteger).
		g _ hash bitAnd: 16rF0000000.
		g = 0 ifFalse: [
			hash _ hash  bitXor: (g bitShift: -24).
			hash _ hash bitXor: g.
		]
	].
	^hash.

]

{ #category : 'public' }
MOFile >> load: aFileEntry localeID: id [
"all of strings are loaded. 
translation strings are converted to internal string format on load time.
original-string/index pairs are registerd to Dictionary on load time."
	localeID := id.
	aFileEntry readStreamDo: [:strm | |originalTable translatedTable|
		self loadHeader: strm.
		originalTable := self loadStringPointers: strm offset: originalTableOffset.					
		translatedTable := self loadStringPointers: strm offset: translatedTableOffset.
		originalStrings := self loadStrings: strm pointers: originalTable.
		translatedStrings := self loadStrings: strm pointers: translatedTable.
		translations := Dictionary newWithRoomForMoreThan: nStrings.  
		1 to: nStrings do: [:index | | key |
			key := originalStrings at: index.
			translations at: key put: index].
		originalStrings := nil] 
]

{ #category : 'private' }
MOFile >> loadHeader: strm [
	strm binary.
	magic :=  strm nextUint32BigEndian: true .
	magic = 16rDE120495 
		ifTrue: [isLittleEndian := true]
		ifFalse: [
			magic = 16r950412DE 
				ifTrue: [isLittleEndian := false]
				ifFalse: [ self error: 'invalid MO'] 		].
	revision := strm nextUint32BigEndian: isLittleEndian not.
	nStrings := strm nextUint32BigEndian: isLittleEndian not.
	originalTableOffset := strm nextUint32BigEndian: isLittleEndian not.
	translatedTableOffset := strm nextUint32BigEndian: isLittleEndian not.
	hashTableSize := strm nextUint32BigEndian: isLittleEndian not.
	hashTableOffset := strm nextUint32BigEndian: isLittleEndian not
]

{ #category : 'private' }
MOFile >> loadStringPointers: strm offset: tableOffset [
"returns tupple {arrayOfOffsetToString  arrayOfLengthOfString}"
	| offsetTable lenTable len offset tupple |
	offsetTable := IntegerArray new: nStrings.
	lenTable := IntegerArray new: nStrings.
	strm binary.
	strm position: tableOffset.
	1 to: nStrings do: [:index |
		len := strm nextUint32BigEndian: isLittleEndian not.
		offset := strm nextUint32BigEndian: isLittleEndian not.
		offsetTable at: index put: offset.
		lenTable at: index put: len ].
	tupple := Array new: 2.
	tupple at: 1 put: offsetTable.
	tupple at: 2 put:  lenTable.
	^tupple
]

{ #category : 'private' }
MOFile >> loadStrings: strm pointers: table [
"We convert string encoding at load time.
Currently, we do not take care to set the leadingChar for a languageEnvironment"
	| offsetTable lenTable strings |
	strm useCharacters.
	offsetTable :=  table first.
	lenTable := table second.
	strings := Array new: nStrings.
	1 to: nStrings do: [:index | |  rawStr start byteLength endPos|
		start := offsetTable at: index.
		byteLength := lenTable at: index.
		endPos := start + byteLength.
		rawStr :=  (String new: byteLength) writeStream.
		strm position:  start.
		[strm position < endPos] whileTrue: [rawStr nextPut: strm next].
		strings at: index put: (UnicodeString fromUtf8Bytes: rawStr contents asByteArray	)].
	^strings.
]

{ #category : 'public' }
MOFile >> searchFor: aString [
	| index |
	index _ translations at: aString ifAbsent: [^nil].
	^translatedStrings at: index.
	

]

{ #category : 'public' }
MOFile >> translationFor: aString  [
	aString size = 0 ifTrue: [^ '']. "Gettext header"
	^ (self searchFor: aString) ifNil: [aString]

]
