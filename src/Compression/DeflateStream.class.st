Class {
	#name : 'DeflateStream',
	#superclass : 'WriteStream',
	#instVars : [
		'hashHead',
		'hashTail',
		'hashValue',
		'blockPosition',
		'blockStart'
	],
	#pools : [
		'ZipConstants'
	],
	#category : 'Compression-System',
	#package : 'Compression',
	#tag : 'System'
}

{ #category : 'deflating' }
DeflateStream >> compare: here with: matchPos min: minLength [
	"Compare the two strings and return the length of matching characters.
	minLength is a lower bound for match lengths that will be accepted.
	Note: here and matchPos are zero based."
	| length |
	"First test if we can actually get longer than minLength"
	(collection at: here+minLength+1) = (collection at: matchPos+minLength+1)
		ifFalse:[^0].
	(collection at: here+minLength) = (collection at: matchPos+minLength)
		ifFalse:[^0].
	"Then test if we have an initial match at all"
	(collection at: here+1) = (collection at: matchPos+1)
		ifFalse:[^0].
	(collection at: here+2) = (collection at: matchPos+2)
		ifFalse:[^1].
	"Finally do the real comparison"
	length _ 3.
	[length <= MaxMatch and:[
		(collection at: here+length) = (collection at: matchPos+length)]]
			whileTrue:[length _ length + 1].
	^length - 1
]

{ #category : 'deflating' }
DeflateStream >> deflateBlock [
	"Deflate the current contents of the stream"
	| flushNeeded lastIndex |
	blockStart ifNil: [
		"One time initialization for the first block"
		1 to: MinMatch-1 do:[:i| self updateHashAt: i].
		blockStart _ 0].

	[blockPosition < position] whileTrue:[
		(position + MaxMatch > writeLimit)
			ifTrue:[lastIndex _ writeLimit - MaxMatch]
			ifFalse:[lastIndex _ position].
		flushNeeded _ self deflateBlock: lastIndex-1
							chainLength: self hashChainLength
							goodMatch: self goodMatchLength.
		flushNeeded ifTrue:[
			self flushBlock.
			blockStart _ blockPosition].
		"Make room for more data"
		self moveContentsToFront].

]

{ #category : 'deflating' }
DeflateStream >> deflateBlock: lastIndex chainLength: chainLength goodMatch: goodMatch [
	"Continue deflating the receiver's collection from blockPosition to lastIndex.
	Note that lastIndex must be at least MaxMatch away from the end of collection"
	| here matchResult flushNeeded hereMatch hereLength newMatch newLength hasMatch |
	blockPosition > lastIndex ifTrue:[^false]. "Nothing to deflate"
	hasMatch _ false.
	here _ blockPosition.
	[here <= lastIndex] whileTrue:[
		hasMatch ifFalse:[
			"Find the first match"
			matchResult _ self findMatch: here
								lastLength: MinMatch-1
								lastMatch: here
								chainLength: chainLength
								goodMatch: goodMatch.
			self insertStringAt: here. "update hash table"
			hereMatch _ matchResult bitAnd: 16rFFFF.
			hereLength _ matchResult bitShift: -16].

		"Look ahead if there is a better match at the next position"
		matchResult _ self findMatch: here+1
							lastLength: hereLength
							lastMatch: hereMatch
							chainLength: chainLength
							goodMatch: goodMatch.
		newMatch _ matchResult bitAnd: 16rFFFF.
		newLength _ matchResult bitShift: -16.

		"Now check if the next match is better than the current one.
		If not, output the current match (provided that the current match
		is at least MinMatch long)"
		(hereLength >= newLength and:[hereLength >= MinMatch]) ifTrue:[
			self assert:[self validateMatchAt: here
							from: hereMatch to: hereMatch + hereLength - 1].
			"Encode the current match"
			flushNeeded _ self
				encodeMatch: hereLength
				distance: here - hereMatch.
			"Insert all strings up to the end of the current match.
			Note: The first string has already been inserted."
			1 to: hereLength-1 do:[:i| self insertStringAt: (here _ here + 1)].
			hasMatch _ false.
			here _ here + 1.
		] ifFalse:[
			"Either the next match is better than the current one or we didn't
			have a good match after all (e.g., current match length < MinMatch).
			Output a single literal."
			flushNeeded _ self encodeLiteral: (collection at: (here + 1)).
			here _ here + 1.
			(here <= lastIndex and:[flushNeeded not]) ifTrue:[
				"Cache the results for the next round"
				self insertStringAt: here.
				hasMatch _ true.
				hereMatch _ newMatch.
				hereLength _ newLength].
		].
		flushNeeded ifTrue:[blockPosition _ here. ^true].
	].
	blockPosition _ here.
	^false
]

{ #category : 'encoding' }
DeflateStream >> encodeLiteral: literal [
	"Encode the given literal.
	Return true if the current block needs to be flushed."
	^false
]

{ #category : 'encoding' }
DeflateStream >> encodeMatch: matchLength distance: matchDistance [
	"Encode a match of the given length and distance.
	Return true if the current block should be flushed."
	^false
]

{ #category : 'deflating' }
DeflateStream >> findMatch: here lastLength: lastLength lastMatch: lastMatch chainLength: maxChainLength goodMatch: goodMatch [
	"Find the longest match for the string starting at here.
	If there is no match longer than lastLength return lastMatch/lastLength.
	Traverse at most maxChainLength entries in the hash table.
	Stop if a match of at least goodMatch size has been found."
	| matchResult matchPos distance chainLength limit bestLength length |
	"Compute the default match result"
	matchResult _ (lastLength bitShift: 16) bitOr: lastMatch.

	"There is no way to find a better match than MaxMatch"
	lastLength >= MaxMatch ifTrue:[^matchResult].

	"Start position for searches"
	matchPos _ hashHead at: (self updateHashAt: here + MinMatch) + 1.

	"Compute the distance to the (possible) match"
	distance _ here - matchPos.

	"Note: It is required that 0 < distance < MaxDistance"
	(distance > 0 and:[distance < MaxDistance]) ifFalse:[^matchResult].

	chainLength _ maxChainLength.	"Max. nr of match chain to search"
	here > MaxDistance	"Limit for matches that are too old"
		ifTrue:[limit _ here - MaxDistance]
		ifFalse:[limit _ 0].

	"Best match length so far (current match must be larger to take effect)"
	bestLength _ lastLength.

	["Compare the current string with the string at match position"
	length _ self compare: here with: matchPos min: bestLength.
	"Truncate accidental matches beyound stream position"
	(here + length > position) ifTrue:[length _ position - here].
	"Ignore very small matches if they are too far away"
	(length = MinMatch and:[(here - matchPos) > (MaxDistance // 4)])
		ifTrue:[length _ MinMatch - 1].
	length > bestLength ifTrue:["We have a new (better) match than before"
		"Compute the new match result"
		matchResult _ (length bitShift: 16) bitOr: matchPos.
		bestLength _ length.
		"There is no way to find a better match than MaxMatch"
		bestLength >= MaxMatch ifTrue:[^matchResult].
		"But we may have a good, fast match"
		bestLength > goodMatch ifTrue:[^matchResult].
	].
	(chainLength _ chainLength - 1) > 0] whileTrue:[
		"Compare with previous entry in hash chain"
		matchPos _ hashTail at: (matchPos bitAnd: WindowMask) + 1.
		matchPos <= limit ifTrue:[^matchResult]. "Match position is too old"
	].
	^matchResult
]

{ #category : 'initialization' }
DeflateStream >> flush [
	"Force compression"
	self deflateBlock.
]

{ #category : 'deflating' }
DeflateStream >> flushBlock [
	"Flush a deflated block"
]

{ #category : 'accessing' }
DeflateStream >> goodMatchLength [
	"Return the length that is considered to be a 'good' match.
	Higher values will result in better compression but take more time."
	^MaxMatch "Best compression"
]

{ #category : 'accessing' }
DeflateStream >> hashChainLength [
	"Return the max. number of hash chains to traverse.
	Higher values will result in better compression but take more time."
	^4096 "Best compression"
]

{ #category : 'initialization' }
DeflateStream >> initialize [
	blockStart _ nil.
	blockPosition _ 0.
	hashValue _ 0.
	self initializeHashTables.
]

{ #category : 'initialization' }
DeflateStream >> initializeHashTables [
	hashHead _ WordArray new: 1 << HashBits.
	hashTail _ WordArray new: WindowSize.

]

{ #category : 'deflating' }
DeflateStream >> insertStringAt: here [
	"Insert the string at the given start position into the hash table.
	Note: The hash value is updated starting at MinMatch-1 since
	all strings before have already been inserted into the hash table
	(and the hash value is updated as well)."
	| prevEntry |
	hashValue _ self updateHashAt: (here + MinMatch).
	prevEntry _ hashHead at: hashValue+1.
	hashHead at: hashValue+1 put: here.
	hashTail at: (here bitAnd: WindowMask)+1 put: prevEntry.
]

{ #category : 'private' }
DeflateStream >> moveContentsToFront [
	"Move the contents of the receiver to the front"
	| delta |
	delta _ (blockPosition - WindowSize).
	delta <= 0 ifTrue:[^self].
	"Move collection"
	collection 
		replaceFrom: 1 
		to: collection size - delta 
		with: collection 
		startingAt: delta+1.
	position _ position - delta.
	"Move hash table entries"
	blockPosition _ blockPosition - delta.
	blockStart _ blockStart - delta.
	self updateHashTable: hashHead delta: delta.
	self updateHashTable: hashTail delta: delta.
]

{ #category : 'accessing' }
DeflateStream >> next: bytes putAll: aCollection startingAt: startPos [
	(startPos = 1 and:[bytes = aCollection size]) 
		ifTrue:[^self nextPutAll: aCollection].
	^self nextPutAll: (aCollection copyFrom: startPos to: startPos + bytes - 1)
]

{ #category : 'accessing' }
DeflateStream >> nextPut: aByteOrCharacter [
	"To add Characters, we take the UTF-8 bytes"
	aByteOrCharacter isCharacter ifTrue: [
		^self nextPutAll: aByteOrCharacter asString ].
	^super nextPut: aByteOrCharacter
]

{ #category : 'accessing' }
DeflateStream >> nextPutAll: bytesOrString [
	"To add Strings, we take the UTF-8 bytes"
	| bytes start count max |
	bytes _ bytesOrString isString
		ifTrue: [ bytesOrString asUtf8Bytes ]
		ifFalse: [ bytesOrString asByteArray ].
	start _ 1.
	count _ bytes size.
	[count = 0] whileFalse:[
		position = writeLimit ifTrue:[self deflateBlock].
		max _ writeLimit - position.
		max > count ifTrue:[max _ count].
		collection replaceFrom: position+1
			to: position+max
			with: bytes
			startingAt: start.
		start _ start + max.
		count _ count - max.
		position _ position + max].
	^bytes
]

{ #category : 'initialization' }
DeflateStream >> on: aCollection [
	self initialize.
	super on: (aCollection species new: WindowSize * 2).
]

{ #category : 'initialization' }
DeflateStream >> on: aCollection from: firstIndex to: lastIndex [
	"Not for DeflateStreams please"
	^self shouldNotImplement
]

{ #category : 'accessing' }
DeflateStream >> pastEndPut: anObject [
	self deflateBlock.
	^self nextPut: anObject
]

{ #category : 'deflating' }
DeflateStream >> updateHash: nextValue [
	"Update the running hash value based on the next input byte.
	Return the new updated hash value."
	^((hashValue bitShift: HashShift) bitXor: nextValue) bitAnd: HashMask.
]

{ #category : 'deflating' }
DeflateStream >> updateHashAt: here [
	"Update the hash value at position here (one based)"
	^self updateHash: (collection at: here)
]

{ #category : 'private' }
DeflateStream >> updateHashTable: table delta: delta [
	| pos |
	<primitive: 'primitiveDeflateUpdateHashTable' module: 'ZipPlugin'>
	1 to: table size do:[:i|
		"Discard entries that are out of range"
		(pos _ table at: i) >= delta
			ifTrue:[table at: i put: pos - delta]
			ifFalse:[table at: i put: 0]].
]

{ #category : 'deflating' }
DeflateStream >> validateMatchAt: pos from: startPos to: endPos [
	| here |
	here _ pos.
	startPos+1 to: endPos+1 do:[:i|
		(collection at: i) = (collection at: (here _ here + 1))
			ifFalse:[^self error:'Not a match']].
	^true
]
