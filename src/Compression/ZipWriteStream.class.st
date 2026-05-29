Class {
	#name : 'ZipWriteStream',
	#superclass : 'DeflateStream',
	#instVars : [
		'literals',
		'distances',
		'literalFreq',
		'distanceFreq',
		'litCount',
		'matchCount',
		'encoder',
		'crc',
		'crcPosition',
		'bytesWritten'
	],
	#classVars : [
		'CrcTable',
		'VerboseLevel'
	],
	#pools : [
		'ZipConstants'
	],
	#category : 'Compression-System',
	#package : 'Compression',
	#tag : 'System'
}

{ #category : 'accessing' }
ZipWriteStream class >> baseDistance [
	^BaseDistance
]

{ #category : 'accessing' }
ZipWriteStream class >> baseLength [
	^BaseLength
]

{ #category : 'regression test' }
ZipWriteStream class >> compressAndDecompress: aFile using: tempName stats: stats [
	| fileSize tempFile result |
	aFile
		ifNil: [^ nil].
	fileSize _ aFile size.
	(fileSize < 1"00000" "or:[fileSize > 1000000]") ifTrue:[aFile close. ^nil].
	Transcript newLine; show:'Testing ', aFile name,' ... '.
	tempFile _ UniFileStream new open: tempName forWrite: true.
	'Compressing ', aFile name,'...' displayProgressAt: Sensor mousePoint
		from: 1 to: aFile size during:[:barBlock|
			result _ self regressionCompress: aFile into: tempFile notifiying: barBlock stats: stats].
	result ifTrue:[
		'Validating ', aFile name,'...' displayProgressAt: Sensor mousePoint
			from: 0 to: aFile size during:[:barBlock|
				result _ self regressionDecompress: aFile from: tempFile notifying: barBlock stats: stats]].
	aFile close.
	tempFile close.
	(DirectoryEntry smalltalkImageDirectory // tempName) delete.
	result ~~ false ifTrue:[
		Transcript show:' ok (', (result * 100 truncateTo: 0.01) printString,')'].
	^result
]

{ #category : 'accessing' }
ZipWriteStream class >> crcTable [
	^CrcTable
]

{ #category : 'accessing' }
ZipWriteStream class >> distanceCodes [
	^DistanceCodes
]

{ #category : 'accessing' }
ZipWriteStream class >> extraDistanceBits [
	^ExtraDistanceBits
]

{ #category : 'accessing' }
ZipWriteStream class >> extraLengthBits [
	^ExtraLengthBits
]

{ #category : 'class initialization' }
ZipWriteStream class >> initialize [
	"ZipWriteStream initialize"
	VerboseLevel := 0.
	self initializeCrcTable.
]

{ #category : 'class initialization' }
ZipWriteStream class >> initializeCrcTable [
	"ZipWriteStream initialize"
	CrcTable _ #(16r00000000 16r77073096 16rEE0E612C 16r990951BA 16r076DC419
  16r706AF48F 16rE963A535 16r9E6495A3 16r0EDB8832 16r79DCB8A4
  16rE0D5E91E 16r97D2D988 16r09B64C2B 16r7EB17CBD 16rE7B82D07
  16r90BF1D91 16r1DB71064 16r6AB020F2 16rF3B97148 16r84BE41DE
  16r1ADAD47D 16r6DDDE4EB 16rF4D4B551 16r83D385C7 16r136C9856
  16r646BA8C0 16rFD62F97A 16r8A65C9EC 16r14015C4F 16r63066CD9
  16rFA0F3D63 16r8D080DF5 16r3B6E20C8 16r4C69105E 16rD56041E4
  16rA2677172 16r3C03E4D1 16r4B04D447 16rD20D85FD 16rA50AB56B
  16r35B5A8FA 16r42B2986C 16rDBBBC9D6 16rACBCF940 16r32D86CE3
  16r45DF5C75 16rDCD60DCF 16rABD13D59 16r26D930AC 16r51DE003A
  16rC8D75180 16rBFD06116 16r21B4F4B5 16r56B3C423 16rCFBA9599
  16rB8BDA50F 16r2802B89E 16r5F058808 16rC60CD9B2 16rB10BE924
  16r2F6F7C87 16r58684C11 16rC1611DAB 16rB6662D3D 16r76DC4190
  16r01DB7106 16r98D220BC 16rEFD5102A 16r71B18589 16r06B6B51F
  16r9FBFE4A5 16rE8B8D433 16r7807C9A2 16r0F00F934 16r9609A88E
  16rE10E9818 16r7F6A0DBB 16r086D3D2D 16r91646C97 16rE6635C01
  16r6B6B51F4 16r1C6C6162 16r856530D8 16rF262004E 16r6C0695ED
  16r1B01A57B 16r8208F4C1 16rF50FC457 16r65B0D9C6 16r12B7E950
  16r8BBEB8EA 16rFCB9887C 16r62DD1DDF 16r15DA2D49 16r8CD37CF3
  16rFBD44C65 16r4DB26158 16r3AB551CE 16rA3BC0074 16rD4BB30E2
  16r4ADFA541 16r3DD895D7 16rA4D1C46D 16rD3D6F4FB 16r4369E96A
  16r346ED9FC 16rAD678846 16rDA60B8D0 16r44042D73 16r33031DE5
  16rAA0A4C5F 16rDD0D7CC9 16r5005713C 16r270241AA 16rBE0B1010
  16rC90C2086 16r5768B525 16r206F85B3 16rB966D409 16rCE61E49F
  16r5EDEF90E 16r29D9C998 16rB0D09822 16rC7D7A8B4 16r59B33D17
  16r2EB40D81 16rB7BD5C3B 16rC0BA6CAD 16rEDB88320 16r9ABFB3B6
  16r03B6E20C 16r74B1D29A 16rEAD54739 16r9DD277AF 16r04DB2615
  16r73DC1683 16rE3630B12 16r94643B84 16r0D6D6A3E 16r7A6A5AA8
  16rE40ECF0B 16r9309FF9D 16r0A00AE27 16r7D079EB1 16rF00F9344
  16r8708A3D2 16r1E01F268 16r6906C2FE 16rF762575D 16r806567CB
  16r196C3671 16r6E6B06E7 16rFED41B76 16r89D32BE0 16r10DA7A5A
  16r67DD4ACC 16rF9B9DF6F 16r8EBEEFF9 16r17B7BE43 16r60B08ED5
  16rD6D6A3E8 16rA1D1937E 16r38D8C2C4 16r4FDFF252 16rD1BB67F1
  16rA6BC5767 16r3FB506DD 16r48B2364B 16rD80D2BDA 16rAF0A1B4C
  16r36034AF6 16r41047A60 16rDF60EFC3 16rA867DF55 16r316E8EEF
  16r4669BE79 16rCB61B38C 16rBC66831A 16r256FD2A0 16r5268E236
  16rCC0C7795 16rBB0B4703 16r220216B9 16r5505262F 16rC5BA3BBE
  16rB2BD0B28 16r2BB45A92 16r5CB36A04 16rC2D7FFA7 16rB5D0CF31
  16r2CD99E8B 16r5BDEAE1D 16r9B64C2B0 16rEC63F226 16r756AA39C
  16r026D930A 16r9C0906A9 16rEB0E363F 16r72076785 16r05005713
  16r95BF4A82 16rE2B87A14 16r7BB12BAE 16r0CB61B38 16r92D28E9B
  16rE5D5BE0D 16r7CDCEFB7 16r0BDBDF21 16r86D3D2D4 16rF1D4E242
  16r68DDB3F8 16r1FDA836E 16r81BE16CD 16rF6B9265B 16r6FB077E1
  16r18B74777 16r88085AE6 16rFF0F6A70 16r66063BCA 16r11010B5C
  16r8F659EFF 16rF862AE69 16r616BFFD3 16r166CCF45 16rA00AE278
  16rD70DD2EE 16r4E048354 16r3903B3C2 16rA7672661 16rD06016F7
  16r4969474D 16r3E6E77DB 16rAED16A4A 16rD9D65ADC 16r40DF0B66
  16r37D83BF0 16rA9BCAE53 16rDEBB9EC5 16r47B2CF7F 16r30B5FFE9
  16rBDBDF21C 16rCABAC28A 16r53B39330 16r24B4A3A6 16rBAD03605
  16rCDD70693 16r54DE5729 16r23D967BF 16rB3667A2E 16rC4614AB8
  16r5D681B02 16r2A6F2B94 16rB40BBE37 16rC30C8EA1 16r5A05DF1B
  16r2D02EF8D
).
]

{ #category : 'regression test' }
ZipWriteStream class >> logProblem: reason for: aFile [

	'problems.log' asFileEntry appendStreamDo: [ :errFile |
		errFile
			newLine;
			nextPutAll: aFile name;
			newLine;
			nextPutAll: reason ].
	Transcript show:' failed (', reason,')'.
	aFile close.
	^false
]

{ #category : 'accessing' }
ZipWriteStream class >> matchLengthCodes [
	^MatchLengthCodes
]

{ #category : 'accessing' }
ZipWriteStream class >> maxDistanceCodes [
	^MaxDistCodes
]

{ #category : 'accessing' }
ZipWriteStream class >> maxLiteralCodes [
	^MaxLiteralCodes
]

{ #category : 'regression test' }
ZipWriteStream class >> printRegressionStats: stats from: fd [
	| raw compressed numFiles |
	raw _ stats at: #rawSize ifAbsent:[0].
	raw = 0 ifTrue:[^self].
	compressed _ stats at: #compressedSize ifAbsent:[0].
	numFiles _ stats at: #numFiles ifAbsent:[0].
	Transcript newLine; nextPutAll: fd pathName.
	Transcript newLine; tab; nextPutAll:'Files compressed: ', numFiles printStringWithCommas.
	Transcript newLine; tab; nextPutAll:'Bytes compressed: ', raw printStringWithCommas.
	Transcript newLine; tab; nextPutAll:'Avg. compression ratio: ';
		print: ((compressed / raw asFloat * 100.0) truncateTo: 0.01).
	Transcript endEntry.
]

{ #category : 'regression test' }
ZipWriteStream class >> regressionCompress: aFile into: tempFile notifiying: progressBarBlock stats: stats [
	"Compress aFile into tempFile"
	| zip encoded buffer |
	aFile binary.
	aFile position: 0.
	tempFile binary.
	buffer _ ByteArray new: 4096.
	zip _ self on: (ByteArray new: 10000).
	encoded _ zip encodedStream.
	[aFile atEnd] whileFalse:[
		progressBarBlock value: aFile position.
		zip nextPutAll: (aFile nextInto: buffer).
		encoded position > 0 ifTrue:[
			tempFile nextPutAll: encoded contents.
			encoded position: 0]].
	zip close.
	tempFile nextPutAll: encoded contents.
	^true
]

{ #category : 'regression test' }
ZipWriteStream class >> regressionDecompress: aFile from: tempFile notifying: progressBarBlock stats: stats [
	"Validate aFile as decompressed from tempFile"
	| unzip rawSize compressedSize buffer1 buffer2 |
	rawSize _ aFile size.
	compressedSize _ tempFile size.
	aFile binary.
	aFile position: 0.
	tempFile binary.
	tempFile position: 0.
	buffer1 _ ByteArray new: 4096.
	buffer2 _ buffer1 copy.
	unzip _ FastInflateStream on: tempFile.
	[aFile atEnd] whileFalse:[
		progressBarBlock value: aFile position.
		buffer1 _ aFile nextInto: buffer1.
		buffer2 _ unzip nextInto: buffer2.
		buffer1 = buffer2
			ifFalse:[^self logProblem: 'contents ' for: aFile].
	].
	unzip next ifNotNil: [ ^self logProblem: 'EOF' for: aFile].
	stats at: #rawSize put:
		(stats at: #rawSize ifAbsent:[0]) + rawSize.
	stats at: #compressedSize put:
		(stats at: #compressedSize ifAbsent:[0]) + compressedSize.
	^compressedSize asFloat / rawSize asFloat.
]

{ #category : 'regression test' }
ZipWriteStream class >> regressionTest  [
	"
	ZipWriteStream regressionTest
	"
	"Compress and decompress everything we can 
	find to validate that compression works as expected."
	self regressionTestFrom: DirectoryEntry smalltalkImageDirectory
]

{ #category : 'regression test' }
ZipWriteStream class >> regressionTestFrom: fd [
	"ZipWriteStream regressionTestFrom: FileDirectory currentDirectory"
	"ZipWriteStream regressionTestFrom: (FileDirectory on:'')"
	"ZipWriteStream regressionTestFrom: (FileDirectory on:'C:')"
	| stats entry |
	Transcript clear.
	stats _ Dictionary new.
	entry _ (DirectoryEntry smalltalkImageDirectory // '$$sqcompress$$').
	entry exists ifTrue: [ entry delete ].
	self regressionTestFrom: fd using: entry pathName stats: stats.
]

{ #category : 'regression test' }
ZipWriteStream class >> regressionTestFrom: fd using: tempName stats: stats [
	| files file fullName |
	files _ fd fileNames asArray sort.
	files do: [ :fName |
		file _ nil.
		fullName _ (fd // fName) pathName.
		fullName = tempName ifFalse: [
			file _ UniFileStream new
				open: fullName
				forWrite: false ].
		self
			compressAndDecompress: file
			using: tempName
			stats: stats ].
	stats
		at: #numFiles
		put:
			(stats
				at: #numFiles
				ifAbsent: [ 0 ]) + files size.
	files _ nil.
	self
		printRegressionStats: stats
		from: fd.
	fd directoryNames asArray sort do: [ :dName |
		self
			regressionTestFrom: fd / dName
			using: tempName
			stats: stats ].
]

{ #category : 'crc' }
ZipWriteStream class >> updateCrc: oldCrc from: start to: stop in: aCollection [
	| newCrc |
	<primitive: 'primitiveUpdateGZipCrc32' module: 'ZipPlugin'>
	newCrc _ oldCrc.
	start to: stop do:[:i|
		newCrc _ (CrcTable at: ((newCrc bitXor: (aCollection at: i)) 
				bitAnd: 255) + 1) bitXor: (newCrc bitShift: -8).
	].
	^newCrc
]

{ #category : 'initialization' }
ZipWriteStream >> close [
	self deflateBlock.
	self flushBlock: true.
	encoder close.
]

{ #category : 'accessing' }
ZipWriteStream >> crc [
	^crc
]

{ #category : 'deflating' }
ZipWriteStream >> deflateBlock: lastIndex chainLength: chainLength goodMatch: goodMatch [
	"^DeflatePlugin doPrimitive:#primitiveDeflateBlock"
	<primitive: 'primitiveDeflateBlock' module: 'ZipPlugin'>
	^super deflateBlock: lastIndex chainLength: chainLength goodMatch: goodMatch
]

{ #category : 'dynamic blocks' }
ZipWriteStream >> dynamicBlockSizeFor: lTree and: dTree using: blTree and: blFreq [
	"Compute the length for the current block using dynamic huffman trees"
	| bits index extra treeBits freq |
	bits _ 3 "block type" + 5 "literal codes length" + 5 "distance codes length".

	"Compute the # of bits for sending the bit length tree"
	treeBits _ 4. "Max index for bit length tree"
	index _ MaxBitLengthCodes.
	[index >= 4] whileTrue:[
		(index = 4 or:[(blFreq at: (BitLengthOrder at: index)+1) > 0])
			ifTrue:[treeBits _ treeBits + (index * 3).
					index _ -1]
			ifFalse:[index _ index - 1]].

	"Compute the # of bits for sending the literal/distance tree.
	Note: The frequency are already stored in the blTree"
	0 to: 15 do:[:i| "First, the non-repeating values"
		freq _ blFreq at: i+1.
		freq > 0 ifTrue:[treeBits _ treeBits + (freq * (blTree bitLengthAt: i))]].
	"Now the repeating values"
	(Repeat3To6 to: Repeat11To138) with: #(2 3 7) do:[:i :addl|
		freq _ blFreq at: i+1.
		freq > 0 ifTrue:[
			treeBits _ treeBits + (freq * ((blTree bitLengthAt: i) + addl "addl bits"))]].
	VerboseLevel > 1 ifTrue:[
		Transcript show:'['; print: treeBits; show:' bits for dynamic tree]'].
	bits _ bits + treeBits.

	"Compute the size of the compressed block"
	0 to: NumLiterals do:[:i| "encoding of literals"
		freq _ literalFreq at: i+1.
		freq > 0 ifTrue:[bits _ bits + (freq * (lTree bitLengthAt: i))]].
	NumLiterals+1 to: lTree maxCode do:[:i| "encoding of match lengths"
		freq _ literalFreq at: i+1.
		extra _ ExtraLengthBits at: i-NumLiterals.
		freq > 0 ifTrue:[bits _ bits + (freq * ((lTree bitLengthAt: i) + extra))]].
	0 to: dTree maxCode do:[:i| "encoding of distances"
		freq _ distanceFreq at: i+1.
		extra _ ExtraDistanceBits at: i+1.
		freq > 0 ifTrue:[bits _ bits + (freq * ((dTree bitLengthAt: i) + extra))]].

	^bits
]

{ #category : 'encoding' }
ZipWriteStream >> encodeLiteral: lit [
	"Encode the given literal"
	litCount _ litCount + 1.
	literals at: litCount put: lit.
	distances at: litCount put: 0.
	literalFreq at: lit+1 put: (literalFreq at: lit+1) + 1.
	^self shouldFlush
]

{ #category : 'encoding' }
ZipWriteStream >> encodeMatch: length distance: dist [
	"Encode the given match of length length starting at dist bytes ahead"
	| literal distance |
	dist > 0 
		ifFalse:[^self error:'Distance must be positive'].
	length < MinMatch 
		ifTrue:[^self error:'Match length must be at least ', MinMatch printString].
	litCount _ litCount + 1.
	matchCount _ matchCount + 1.
	literals at: litCount put: length - MinMatch.
	distances at: litCount put: dist.
	literal _ (MatchLengthCodes at: length - MinMatch + 1).
	literalFreq at: literal+1 put: (literalFreq at: literal+1) + 1.
	dist < 257
		ifTrue:[distance _ DistanceCodes at: dist]
		ifFalse:[distance _ DistanceCodes at: 257 + (dist - 1 bitShift: -7)].
	distanceFreq at: distance+1 put: (distanceFreq at: distance+1) + 1.
	^self shouldFlush
]

{ #category : 'accessing' }
ZipWriteStream >> encodedStream [
	^encoder encodedStream
]

{ #category : 'initialization' }
ZipWriteStream >> finish [
	"Finish pending operation. Do not close output stream."
	self deflateBlock.
	self flushBlock: true.
	encoder flush.
]

{ #category : 'fixed blocks' }
ZipWriteStream >> fixedBlockSizeFor: lTree and: dTree [
	"Compute the length for the current block using fixed huffman trees"
	| bits extra |
	bits _ 3 "block type".
	"Compute the size of the compressed block"
	0 to: NumLiterals do:[:i| "encoding of literals"
		bits _ bits + ((literalFreq at: i+1) * (FixedLiteralTree bitLengthAt: i))].
	NumLiterals+1 to: lTree maxCode+1 do:[:i| "Encoding of match lengths"
		extra _ ExtraLengthBits at: i-NumLiterals.
		bits _ bits + ((literalFreq at: i+1) * ((FixedLiteralTree bitLengthAt: i) + extra))].
	0 to: dTree maxCode do:[:i| "encoding of distances"
		extra _ ExtraDistanceBits at: i+1.
		bits _ bits + ((distanceFreq at: i+1) * ((FixedDistanceTree bitLengthAt: i) + extra))].

	^bits
]

{ #category : 'encoding' }
ZipWriteStream >> flushBlock [
	^self flushBlock: false
]

{ #category : 'encoding' }
ZipWriteStream >> flushBlock: lastBlock [
	"Send the current block"
	| lastFlag bitsRequired method bitsSent
	storedLength fixedLength dynamicLength 
	blTree lTree dTree blBits blFreq |

	lastFlag _ lastBlock ifTrue:[1] ifFalse:[0].

	"Compute the literal/length and distance tree"
	lTree _ ZipEncoderTree buildTreeFrom: literalFreq maxDepth: MaxBits.
	dTree _ ZipEncoderTree buildTreeFrom: distanceFreq maxDepth: MaxBits.

	"Compute the bit length tree"
	blBits _ lTree bitLengths, dTree bitLengths.
	blFreq _ WordArray new: MaxBitLengthCodes.
	self scanBitLengths: blBits into: blFreq.
	blTree _ ZipEncoderTree buildTreeFrom: blFreq maxDepth: MaxBitLengthBits.

	"Compute the bit length for the current block.
	Note: Most of this could be computed on the fly but it's getting
	really ugly in this case so we do it afterwards."
	storedLength _ self storedBlockSize.
	fixedLength _ self fixedBlockSizeFor: lTree and: dTree.
	dynamicLength _ self dynamicBlockSizeFor: lTree and: dTree 
							using: blTree and: blFreq.
	VerboseLevel > 1 ifTrue:[
		Transcript newLine; show:'Block sizes (S/F/D):';
			space; print: storedLength // 8; 
			nextPut:$/; print: fixedLength // 8; 
			nextPut:$/; print: dynamicLength // 8; space; endEntry].

	"Check which method to use"
	method _ self forcedMethod.
	method ifNil: [ 
		method _ (storedLength < fixedLength and:[storedLength < dynamicLength]) 
			ifTrue:[#stored]
			ifFalse:[fixedLength < dynamicLength ifTrue:[#fixed] ifFalse:[#dynamic]]].
	(method == #stored and:[blockStart < 0]) ifTrue:[
		"Cannot use #stored if the block is not available"
		method _ fixedLength < dynamicLength ifTrue:[#fixed] ifFalse:[#dynamic]].

	bitsSent _ encoder bitPosition. "# of bits sent before this block"
	bitsRequired _ nil.

	(method == #stored) ifTrue:[
		VerboseLevel > 0 ifTrue:[Transcript show:'S'].
		bitsRequired _ storedLength.
		encoder nextBits: 3 put: StoredBlock << 1 + lastFlag.
		self sendStoredBlock].

	(method == #fixed) ifTrue:[
		VerboseLevel > 0 ifTrue:[Transcript show:'F'].
		bitsRequired _ fixedLength.
		encoder nextBits: 3 put: FixedBlock << 1 + lastFlag.
		self sendFixedBlock].

	(method == #dynamic) ifTrue:[
		VerboseLevel > 0 ifTrue:[Transcript show:'D'].
		bitsRequired _ dynamicLength.
		encoder nextBits: 3 put: DynamicBlock << 1 + lastFlag.
		self sendDynamicBlock: blTree 
			literalTree: lTree 
			distanceTree: dTree 
			bitLengths: blBits].

	bitsRequired = (encoder bitPosition - bitsSent)
		ifFalse:[self error:'Bits size mismatch'].

	lastBlock 
		ifTrue:[self release]
		ifFalse:[self initializeNewBlock].
]

{ #category : 'accessing' }
ZipWriteStream >> forcedMethod [
	"Return a symbol describing an enforced method or nil if the method should
	be chosen adaptively. Valid symbols are
		#stored	- store blocks (do not compress)
		#fixed	- use fixed huffman trees
		#dynamic	- use dynamic huffman trees."
	^nil
]

{ #category : 'initialization' }
ZipWriteStream >> initialize [
	super initialize.
	literals _ ByteArray new: WindowSize.
	distances _ WordArray new: WindowSize.
	literalFreq _ WordArray new: MaxLiteralCodes.
	distanceFreq _ WordArray new: MaxDistCodes.
	self initializeNewBlock.

]

{ #category : 'initialization' }
ZipWriteStream >> initializeNewBlock [
	"Initialize the encoder for a new block of data"
	literalFreq atAllPut: 0.
	distanceFreq atAllPut: 0.
	literalFreq at: EndBlock+1 put: 1.
	litCount _ 0.
	matchCount _ 0.
]

{ #category : 'private' }
ZipWriteStream >> moveContentsToFront [
	"Need to update crc here"
	self updateCrc.
	super moveContentsToFront.
	crcPosition _ position + 1.
]

{ #category : 'initialization' }
ZipWriteStream >> on: aCollectionOrStream [
	crc _ 16rFFFFFFFF.
	crcPosition _ 1.
	bytesWritten _ 0.
	encoder _ ZipEncoder on: aCollectionOrStream.
	super on: ByteArray new.
	self writeHeader.

]

{ #category : 'initialization' }
ZipWriteStream >> release [
	"We're done with compression. Do some cleanup."
	literals _ distances _ literalFreq _ distanceFreq _ nil.
	self updateCrc.
	encoder flushBits.
	self writeFooter.
]

{ #category : 'dynamic blocks' }
ZipWriteStream >> scanBitLength: bitLength repeatCount: repeatCount into: anArray [
	"Update the frequency for the aTree based on the given values"
	| count |
	count _ repeatCount.
	bitLength = 0 ifTrue:[
		[count >= 11] whileTrue:[
			anArray at: Repeat11To138+1 put: (anArray at: Repeat11To138+1) + 1.
			count _ (count - 138) max: 0].
		[count >= 3] whileTrue:[
			anArray at: Repeat3To10+1 put: (anArray at: Repeat3To10+1) + 1.
			count _ (count - 10) max: 0].
		count > 0 ifTrue:[anArray at: bitLength+1 put: (anArray at: bitLength+1) + count].
	] ifFalse:[
		anArray at: bitLength+1 put: (anArray at: bitLength+1) + 1.
		count _ count - 1.
		[count >= 3] whileTrue:[
			anArray at: Repeat3To6+1 put: (anArray at: Repeat3To6+1) + 1.
			count _ (count - 6) max: 0].
		count > 0 ifTrue:[anArray at: bitLength+1 put: (anArray at: bitLength+1) + count].
	].
]

{ #category : 'dynamic blocks' }
ZipWriteStream >> scanBitLengths: bits into: anArray [
	"Scan the trees and determine the frequency of the bit lengths.
	For repeating codes, emit a repeat count."
	| lastValue lastCount value |
	bits size = 0 ifTrue:[^self].
	lastValue _ bits at: 1.
	lastCount _ 1.
	2 to: bits size do:[:i|
		value _ bits at: i.
		value = lastValue 
			ifTrue:[lastCount _ lastCount + 1]
			ifFalse:[self scanBitLength: lastValue repeatCount: lastCount into: anArray.
					lastValue _ value.
					lastCount _ 1]].
	self scanBitLength: lastValue repeatCount: lastCount into: anArray.
]

{ #category : 'dynamic blocks' }
ZipWriteStream >> sendBitLength: bitLength repeatCount: repeatCount tree: aTree [
	"Send the given bitLength, repeating repeatCount times"
	| count |
	count _ repeatCount.
	bitLength = 0 ifTrue:[
		[count >= 11] whileTrue:[
			self sendBitLength: Repeat11To138 tree: aTree.
			encoder nextBits: 7 put: (count min: 138) - 11.
			count _ (count - 138) max: 0].
		[count >= 3] whileTrue:[
			self sendBitLength: Repeat3To10 tree: aTree.
			encoder nextBits: 3 put: (count min: 10) - 3.
			count _ (count - 10) max: 0].
		count timesRepeat:[self sendBitLength: bitLength tree: aTree].
	] ifFalse:[
		self sendBitLength: bitLength tree: aTree.
		count _ count - 1.
		[count >= 3] whileTrue:[
			self sendBitLength: Repeat3To6 tree: aTree.
			encoder nextBits: 2 put: (count min: 6) - 3.
			count _ (count - 6) max: 0].
		count timesRepeat:[self sendBitLength: bitLength tree: aTree].
	].
]

{ #category : 'dynamic blocks' }
ZipWriteStream >> sendBitLength: bitLength tree: aTree [
	"Send the given bitLength"
	encoder nextBits: (aTree bitLengthAt: bitLength) 
		put: (aTree codeAt: bitLength).
]

{ #category : 'dynamic blocks' }
ZipWriteStream >> sendBitLengthTree: blTree [
	"Send the bit length tree"
	| blIndex bitLength |
	MaxBitLengthCodes to: 4 by: -1 do:[:maxIndex|
		blIndex _ BitLengthOrder at: maxIndex.
		bitLength _ blIndex <= blTree maxCode 
			ifTrue:[blTree bitLengthAt: blIndex] ifFalse:[0].
		(maxIndex = 4 or:[bitLength > 0]) ifTrue:[
			encoder nextBits: 4 put: maxIndex - 4.
			1 to: maxIndex do:[:j|
				blIndex _ BitLengthOrder at: j.
				bitLength _ blIndex <= blTree maxCode 
					ifTrue:[blTree bitLengthAt: blIndex] ifFalse:[0].
				encoder nextBits: 3 put: bitLength].
			^self]].
]

{ #category : 'dynamic blocks' }
ZipWriteStream >> sendCompressedBlock: litTree with: distTree [
	"Send the current block using the encodings from the given literal/length and distance tree"
	| sum |
	sum _ encoder
			sendBlock: (ReadStream on: literals from: 1 to: litCount)
			with: (ReadStream on: distances from: 1 to: litCount)
			with: litTree
			with: distTree.
	sum = (blockPosition - blockStart) ifFalse:[self error:'Wrong number of bytes'].
]

{ #category : 'dynamic blocks' }
ZipWriteStream >> sendDynamicBlock: blTree literalTree: lTree distanceTree: dTree bitLengths: bits [
	"Send a block using dynamic huffman trees"
	self sendLiteralTree: lTree distanceTree: dTree using: blTree bitLengths: bits.
	self sendCompressedBlock: lTree with: dTree.
]

{ #category : 'fixed blocks' }
ZipWriteStream >> sendFixedBlock [
	"Send a block using fixed huffman trees"
	self sendCompressedBlock: FixedLiteralTree with: FixedDistanceTree.
]

{ #category : 'dynamic blocks' }
ZipWriteStream >> sendLiteralTree: lTree distanceTree: dTree using: blTree bitLengths: bits [
	"Send all the trees needed for dynamic huffman tree encoding"
	| lastValue lastCount value |
	encoder nextBits: 5 put: (lTree maxCode - 256).
	encoder nextBits: 5 put: (dTree maxCode).
	self sendBitLengthTree: blTree.
	bits size = 0 ifTrue:[^self].
	lastValue _ bits at: 1.
	lastCount _ 1.
	2 to: bits size do:[:i|
		value _ bits at: i.
		value = lastValue 
			ifTrue:[lastCount _ lastCount + 1]
			ifFalse:[self sendBitLength: lastValue repeatCount: lastCount tree: blTree.
					lastValue _ value.
					lastCount _ 1]].
	self sendBitLength: lastValue repeatCount: lastCount tree: blTree.
]

{ #category : 'stored blocks' }
ZipWriteStream >> sendStoredBlock [
	"Send an uncompressed block"
	| inBytes |
	inBytes _ blockPosition - blockStart.
	encoder flushBits. "Skip to byte boundary"
	encoder nextBits: 16 put: inBytes.
	encoder nextBits: 16 put: (inBytes bitXor: 16rFFFF).
	encoder flushBits.
	1 to: inBytes do:[:i|
		encoder nextBytePut: (collection at: blockStart+i)].
]

{ #category : 'encoding' }
ZipWriteStream >> shouldFlush [
	"Check if we should flush the current block.
	Flushing can be useful if the input characteristics change."
	| nLits |
	litCount = literals size ifTrue:[^true]. "We *must* flush"
	(litCount bitAnd: 16rFFF) = 0 ifFalse:[^false]. "Only check every N kbytes"
	matchCount * 10 <= litCount ifTrue:[
		"This is basically random data. 
		There is no need to flush early since the overhead
		for encoding the trees will add to the overall size"
		^false].
	"Try to adapt to the input data.
	We flush if the ratio between matches and literals
	changes beyound a certain threshold"
	nLits _ litCount - matchCount.
	nLits <= matchCount ifTrue:[^false]. "whow! so many matches"
	^nLits * 4 <= matchCount
]

{ #category : 'stored blocks' }
ZipWriteStream >> storedBlockSize [
	"Compute the length for the current block when stored as is"
	^3 "block type bits" 
		+ (8 - (encoder bitPosition + 3 bitAnd: 7) bitAnd: 7)"skipped bits to byte boundary"
			+ 32 "byte length + chksum" 
				+ (blockPosition - blockStart * 8) "actual data bits".
]

{ #category : 'private' }
ZipWriteStream >> updateCrc [
	crcPosition <= position ifTrue:[
		bytesWritten _ bytesWritten + position - crcPosition + 1.
		crc _ self updateCrc: crc from: crcPosition to: position in: collection.
		crcPosition _ position + 1].
]

{ #category : 'private' }
ZipWriteStream >> updateCrc: oldCrc from: start to: stop in: aCollection [
	^self class updateCrc: oldCrc from: start to: stop in: aCollection
]

{ #category : 'initialization' }
ZipWriteStream >> writeFooter [
	"Write footer information if necessary"
	crc _ crc bitXor: 16rFFFFFFFF.
]

{ #category : 'initialization' }
ZipWriteStream >> writeHeader [
	"Write header information if necessary"
]
