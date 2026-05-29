"
WebUtils contains a number of utility methods used by WebClient/WebServer.
"
Class {
	#name : 'WebUtils',
	#superclass : 'Object',
	#classInstVars : [
		'currentProxyServer'
	],
	#category : 'WebClient-Core',
	#package : 'WebClient',
	#tag : 'Core'
}

{ #category : 'decoding' }
WebUtils class >> decodeMultipartForm: aStream boundary: boundary do: aBlock [
	"Parse the contents of a multipart/form-data submission.

	Evaluate aBlock with three parts: The headers, the (parsed) form-data
	arguments and the (undecoded) contents of the part. The sender is
	expected to take care of other issues such as content-transfer-encoding
	and similar headers."

	| skip headers content disposition index params |
	aStream upToAll: '--', boundary.
	[aStream atEnd or:[(skip := aStream next: 2) = '--']] whileFalse:[
		skip = String crlfString ifFalse:[self error: 'Error decoding multipart/form-data fields'].
		headers := Dictionary new.
		(WebUtils readHeadersFrom: aStream) do:[:hdr| headers add: hdr].
		content := aStream upToAll: String crlfString, '--', boundary.
		params := Dictionary new.
		disposition := headers at: 'content-disposition' ifAbsent:[''].
		#(name filename) do:[:arg| | len val |
			len := arg size + 2.
			index := disposition findString: arg,'='.
			index > 0 ifTrue:[
				val := disposition copyFrom: index + len to: (disposition indexOf: $" startingAt: index+len) - 1.
				params at: arg put: val.
			].
		].
		aBlock value: headers value: params value: content.
	].
]

{ #category : 'decoding' }
WebUtils class >> decodeUrlEncodedForm: aString [
	"Decodes the fields embedded in the url ?var1=val1&var2=val2"

	^self decodeUrlEncodedForm: aString multipleValues: false
]

{ #category : 'decoding' }
WebUtils class >> decodeUrlEncodedForm: aString do: aBlock [
	"Decodes the fields embedded in the url ?var1=val1&var2=val2.
	Evaluates aBlock with the key/value pairs defined in the fields."

	| args keyval index key value |
	args := aString readStream.
	[args atEnd] whileFalse:[
		keyval := args upTo: $&.
		(index := keyval indexOf: $=) = 0 ifTrue:[
			key := keyval.
			value := ''.
		] ifFalse:[
			key := keyval copyFrom: 1 to: index-1.
			value := keyval copyFrom: index +1 to: keyval size.
		].
		key := key unescapePercents.
		value := value unescapePercents.
		aBlock value: key value: value.
	].

]

{ #category : 'decoding' }
WebUtils class >> decodeUrlEncodedForm: aString multipleValues: aBool [
	"Decodes the fields embedded in the url ?var1=val1&var2=val2"

	| fields |
	fields := Dictionary new.
	self decodeUrlEncodedForm: aString do:[:key :value|
		aBool 
			ifTrue:[fields at: key put: (fields at: key ifAbsent:['']), value]
			ifFalse:[fields at: key put: value].
	].
	^fields
]

{ #category : 'proxy' }
WebUtils class >> defaultProxyServer [
	"Answer the default proxy server to use."
	^ currentProxyServer 
]

{ #category : 'proxy' }
WebUtils class >> defaultProxyServer: aString [
	"Set the default proxy server to use."
	currentProxyServer _ aString 
]

{ #category : 'decoding' }
WebUtils class >> encodeMultipartForm: fieldMap boundary: boundary [
	"Encodes the fieldMap as multipart/form-data.

	The fieldMap may contain MIMEDocument instances to indicate the presence
	of a file to upload to the server. If the MIMEDocument is present, its
	content type and file name will be used for the upload.

	The fieldMap can be EITHER an array of associations OR a Dictionary of 
	key value pairs (the former is useful for providing multiple fields and/or 
	specifying the order of fields)."

	^String streamContents:[:stream|
		(fieldMap as: Dictionary) keysAndValuesDo:[:fieldName :fieldValue | | fieldContent |
			"Write multipart boundary and common headers"
			stream nextPutAll: '--', boundary; nextPutAll: String crlfString.
			stream nextPutAll: 'Content-Disposition: form-data; name="', fieldName, '"'.
			"Figure out if this is a file upload - This code was deleted. Cuis does not currently include MIMEDocument. See Squeak."
			fieldContent := fieldValue.
			stream nextPutAll: String crlfString; nextPutAll: String crlfString.
			stream nextPutAll: fieldContent asString.
			stream nextPutAll: String crlfString.
		].
		stream nextPutAll: '--', boundary, '--', String crlfString.
	].

]

{ #category : 'decoding' }
WebUtils class >> encodeUrlEncodedForm: fieldMap [
	"Encodes the fieldsMap in the form of var1=val1&var2=val2.
	The fieldMap can be EITHER an array of associations OR a Dictionary of 
	key value pairs (the former is useful for providing multiple fields and/or 
	specifying the order of fields)."

	| associations |
	associations := (fieldMap isKindOf: Dictionary) ifTrue:[fieldMap associations] ifFalse:[fieldMap].
	^String streamContents:[:s|
		associations do:[:assoc|
			s nextPutAll: assoc key percentEscapeUrlField.
			assoc value ifNotNil:[
				s nextPutAll: '='.
				s nextPutAll: assoc value asString percentEscapeUrlField
			].
		] separatedBy:[s nextPutAll:'&'].
	].
]

{ #category : 'websockets' }
WebUtils class >> extractWebSocketKey: field [
	"Decodes a WebSocket key:

		Sec-WebSocket-Key1: 18x 6]8vM;54 *(5:  {   U1]8  z [  8
		Sec-WebSocket-Key2: 1_ tx7X d  <  nw  334J702) 7]o}` 0

		For each of these fields, the server has to take the digits from the
		 value to obtain a number (in this case 1868545188 and 1733470270
		respectively), then divide that number by the number of spaces
		characters in the value (in this case 12 and 10) to obtain a 32-bit
		number (155712099 and 173347027).  These two resulting numbers are
		then used in the server handshake, as described below.
	"

	| digits spaces |
	digits := spaces := 0.
	field do:[:ch|
		ch isDigit ifTrue:[digits := digits * 10 + ch digitValue].
		ch = $ ifTrue:[spaces := spaces + 1].
	].
	^digits // spaces.

]

{ #category : 'auth' }
WebUtils class >> handleAuth: aBlock [
	"Utility method to handle web authentication requests interactively.

	Use like here:
		| wc |
		wc := WebClient new.
		WebUtils handleAuth:[wc httpGet: 'http://some.auth.required'].
	"

	| user pass |
	^[aBlock value] on: WebAuthRequired do:[:ex|
		"Allow outer handlers to take over authentication"
		ex isNested ifFalse:[
			user := StringRequestMorph request:  ex message, 
				'\Please enter your user name:' initialAnswer:''.
			user ifNotEmpty:[
				"Just a little obfuscation to avoid completely plain passwords"
				pass := (StringRequestMorph request:
					'Please enter the password for "', user,'":') asUtf8Bytes base64Encoded.
				 ex username: user password: [String fromUtf8Bytes: pass base64Decoded]]].
		ex pass].
]

{ #category : 'oauth' }
WebUtils class >> hmacSha1: message key: signKey [
	"Compute the SHA1 HMAC for the given message"

	| blockSize key ipad opad |
	blockSize := 64. "SHA1 block size"
	key := signKey asByteArray.
	key size > blockSize ifTrue:[key := self sha1Hash: key].
	key size < blockSize ifTrue:[key := key, (ByteArray new: blockSize - key size)].
	ipad := ByteArray new: blockSize withAll: 16r36.
	opad := ByteArray new: blockSize withAll: 16r5C.
	^self sha1Hash: 
		(key with: opad collect:[:b1 :b2| b1 bitXor: b2]), 
		(self sha1Hash: (key with: ipad collect:[:b1 :b2| b1 bitXor: b2]), message)
]

{ #category : 'json-encode' }
WebUtils class >> jsonArray: anArray on: stream [
	"Encodes an array"

	stream nextPut: $[.
	anArray 
		do:[:each| self jsonObj: each on: stream]
		separatedBy:[stream nextPutAll:', '].
	stream nextPut:$].

]

{ #category : 'json-decode' }
WebUtils class >> jsonArrayFrom: stream [
	"Decodes a JSON [value, *] array from the stream"

	| ch result |
	(ch := stream next) = $[ ifFalse:[^self error: 'JSON Array expected'].
	stream skipSeparators.
	stream peek = $] ifTrue:[stream next. ^#()].
	result := WriteStream on: (Array new: 10).
	["Decode the next value"
	stream skipSeparators.
	result nextPut: (self jsonDecode: stream).
	stream skipSeparators.
	(ch := stream next) = $]] whileFalse:[
		ch = $, ifFalse:[^self error: 'Comma expected'].
	].

	^result contents
]

{ #category : 'json-encode' }
WebUtils class >> jsonChar: aCharacter on: stream [
	"Writes a single encoded character"

	| codePoint |
	codePoint _ aCharacter codePoint.

	codePoint < 32 ifTrue:["Control character"
		codePoint caseOf: {
			[13]	-> [^stream nextPutAll: '\r'].
			[12]	-> [^stream nextPutAll: '\f'].
			[10]	-> [^stream nextPutAll: '\n'].
			[9]		-> [^stream nextPutAll: '\t'].
			[8]		-> [^stream nextPutAll: '\b'].
		} otherwise:[
			^stream nextPutAll: '\u'; nextPutAll: 
				((codePoint printStringBase: 16) padded: #left to: 4 with: $0)
		].
	].

	(codePoint >= 32 and:[codePoint <=127]) ifTrue:["Ascii character"
		(codePoint = 34 or:[codePoint = 92 or:[codePoint = 47]]) ifTrue:[stream nextPut: $\].
		^stream nextPut: aCharacter
	].
"just 16 bits??????"
	"Encode other characters (control chars, accents, umlauts, unicode)"
	stream nextPutAll:  
		'\u', (((codePoint bitAnd: 16rFFFF) printStringBase: 16) padded: #left to: 4 with: $0).

]

{ #category : 'json-decode' }
WebUtils class >> jsonCharFrom: stream on: writeStream [
	"Decodes a backslash-escaped character"

	| ch decoded |
	ch _ stream next.
	decoded _ ch caseOf: {
		[$u] 	-> 	[Character codePoint: (Integer readFrom: (stream next: 4) readStream base: 16)].
		[$r] 	-> 	[Character cr].
		[$n] 	-> 	[Character lf].
		[$t] 	-> 	[Character tab].
		[$b] 	->	[Character backspace].
		[$f] 	->	[Character newPage].
	} otherwise: [ch].
	writeStream nextPut: decoded
]

{ #category : 'json-decode' }
WebUtils class >> jsonDecode: stream [
	"Decodes an arbitrary JSON encoded value from the given stream"

	stream skipSeparators.
	^stream peek caseOf: {
		[$"]		->	[self jsonStringFrom: stream].
		[$t]		->	[self jsonTrueFrom: stream].
		[$f]		->	[self jsonFalseFrom: stream].
		[$n]		->	[self jsonNullFrom: stream].
		[${]		-> 	[self jsonMapFrom: stream].
		[$[]		->	[self jsonArrayFrom: stream].
	} otherwise:[self jsonNumberFrom: stream].

]

{ #category : 'json-encode' }
WebUtils class >> jsonEncode: anObject [
	"Encode the given object as JSON"

	^String streamContents:[:s| self jsonObj: anObject on: s]
]

{ #category : 'json-decode' }
WebUtils class >> jsonFalseFrom: stream [
	"Decodes 'false' from aStream"

	((stream next: 5) = 'false' 
		and:[stream atEnd or:[stream peek isAlphaNumeric not]]) 
			ifFalse:[^self error: 'Expected ''false'''].
	^false
]

{ #category : 'json-encode' }
WebUtils class >> jsonMap: aDictionary on: stream [
	"Encodes a dictionary"

	stream nextPut: ${.
	"Sorting keys ensures deterministic order"
	aDictionary keys asArray sort do:[:key|
		self jsonString: key on: stream.
		stream nextPutAll:': '.
		self jsonObj: (aDictionary at: key) on: stream.
	] separatedBy:[stream nextPutAll: ', '].
	stream nextPut: $}.
]

{ #category : 'json-decode' }
WebUtils class >> jsonMapFrom: stream [
	"Decodes a JSON {key:value, *} object from the stream"

	| map ch key value |
	map := Dictionary new.
	(ch := stream next) = ${ ifFalse:[^self error: 'JSON Object expected'].
	stream skipSeparators.
	stream peek = $} ifTrue:[^map].

	["Decode the next key:value pair"
	stream skipSeparators.
	key := self jsonStringFrom: stream.
	stream skipSeparators.
	stream next = $: ifFalse:[^self error: 'Key-value pair expected'].
	value := self jsonDecode: stream.
	map at: key put: value.
	stream skipSeparators.
	(ch := stream next) = $}] whileFalse:[
		ch = $, ifFalse:[^self error: 'Comma expected'].
	].

	^map
]

{ #category : 'json-decode' }
WebUtils class >> jsonNullFrom: stream [
	"Decodes 'null' from aStream"

	((stream next: 4) = 'null'
		and:[stream atEnd or:[stream peek isAlphaNumeric not]]) 
			ifFalse:[^self error: 'Expected ''null'''].
	^nil
]

{ #category : 'json-encode' }
WebUtils class >> jsonNumber: aNumber on: stream [
	"Encodes a number"

	| value |
	value := aNumber.
	value isInteger ifFalse:[value := aNumber asFloat].
	stream print: aNumber.

]

{ #category : 'json-decode' }
WebUtils class >> jsonNumberFrom: stream [
	"Decodes a JSON number from the stream"

	| ascii integer fraction scale sign expSign exponent value ch |
	integer := fraction := 0. sign := scale := exponent := expSign := 1.
	ascii := stream next asciiValue.
	ascii = 45 "$- asciiValue" ifTrue:[
		sign := -1.
		ascii := stream next asciiValue.
	].
	"JSON requires at least one digit"
	(ascii >= 48 and:[ascii <= 57]) ifFalse:[^self error: 'Digit expected'].

	"Read the integer part"
	integer := ascii - 48.
	[ch := stream next ifNil:[^integer * sign].
	ascii := ch asciiValue.
	ascii >= 48 and:[ascii <= 57]] whileTrue:[
		integer := (integer * 10) + (ascii - 48).
	].

	ascii = 46 "$. asciiValue" ifTrue:[
		"Read the fraction part"
		[ch := stream next ifNil:[^(integer * scale + fraction * sign) asFloat / scale].
		ascii := ch asciiValue.
		ascii >= 48 and:[ascii <= 57]] whileTrue:[
			fraction := (fraction * 10) + (ascii - 48).
			scale := scale * 10.
		].
		value := (integer * scale + fraction * sign) asFloat / scale asFloat.
	] ifFalse:[value := integer * sign].

	(ascii =  69 "$E asciiValue" or:[ascii =  101 "$e asciiValue"]) ifTrue:[
		"Read exponent"
		ascii := stream next asciiValue.
		ascii = $- ifTrue:[
			expSign := -1.
			ascii := stream next asciiValue.
		] ifFalse:[ascii = $+ ifTrue:[ascii := stream next asciiValue]].
		exponent := ascii - 48.
		[ch := stream next ifNil:[^value * (10 raisedTo: expSign * exponent)].
		ascii := ch asciiValue.
		ascii >= 48 and:[ascii <= 57]] whileTrue:[
			exponent := (exponent * 10) + (ascii - 48).			
		].
		exponent := exponent * expSign.
	].

	"Skip back before last character since number might be part of a sequence
	like 1, 2, 3, 4, etc (which would eat the trailing comma)"
	ch isAlphaNumeric ifTrue:[^self error: 'Delimiter expected'].
	stream skip: -1.

	exponent = 1 ifFalse:[
		exponent < 0 ifTrue:[value := value asFloat].
		value := value * (10 raisedTo: exponent).
	].
	^value
]

{ #category : 'json-encode' }
WebUtils class >> jsonObj: anObject on: stream [
	"Encode a generic object"

	anObject isString ifTrue:[^self jsonString: anObject on: stream].
	anObject isNumber ifTrue:[^self jsonNumber: anObject on: stream].
	anObject == nil ifTrue:[^stream nextPutAll: 'null'].
	anObject == true ifTrue:[^stream nextPutAll: 'true'].
	anObject == false ifTrue:[^stream nextPutAll: 'false'].
	anObject isArray ifTrue:[^self jsonArray: anObject on: stream].
	(anObject is: #Dictionary) ifTrue:[^self jsonMap: anObject on: stream].

	self error: 'Cannot encode: ', anObject
]

{ #category : 'json-encode' }
WebUtils class >> jsonString: aString on: stream [
	"Encodes a string"

	stream nextPut: $".
	aString do:[:ch| self jsonChar: ch on: stream].
	stream nextPut: $".

]

{ #category : 'json-decode' }
WebUtils class >> jsonStringFrom: stream [
	"Decodes a JSON encoded string"

	| ch result |
	(ch := stream next) = $" 
		ifFalse:[^self error: 'String expected'].
	result := WriteStream on: (String new: 20).
	[(ch := stream next) == nil] whileFalse:[
		ch = $" ifTrue:[^result contents].
		ch = $\
			ifTrue: [ self jsonCharFrom: stream on: result ]
			ifFalse: [ result nextPut: ch ].
	].
	^self error: 'Unterminated string'
]

{ #category : 'json-decode' }
WebUtils class >> jsonTrueFrom: stream [
	"Decodes 'true' from aStream"

	((stream next: 4) = 'true'
		and:[stream atEnd or:[stream peek isAlphaNumeric not]]) 
			 ifFalse:[^self error: 'Expected ''true'''].
	^true
]

{ #category : 'misc' }
WebUtils class >> logEntryFor: request response: response [
	"Create a log entry in common log format from the given request / response"

	| entry logdate logsize |

	"CLF prints date as [day/month/year:hour:min:sec zone]"
	logdate := String streamContents:[:s| | date |
		date := DateAndTime fromSeconds: Time localSecondClock.
		s nextPut: $[.
			date date printOn: s format: #( 1 2 3 $/ 2 1 2).
		s nextPut: $:.
			date time print24: true on: s.
		s nextPutAll:(' ',
			(date offset hours >= 0 ifTrue:['+'] ifFalse:['-']),
			(date offset hours abs asString padded: #left to: 2 with: $0),
			(date offset minutes abs asString padded: #left to: 2 with: $0)
		).
		s nextPut: $].
	].

	"CLF prints zero length as - "
	logsize := response contentLength ifNil:[0].
	logsize = 0 ifTrue:[logsize := '-'].

	entry := String streamContents:[:s|
		s 
			nextPutAll: (request remoteHost ifNil:[
				"Substitute with the host header"
				(request headerAt: 'host') copyUpTo: $:
			]);
			nextPutAll: ' -'; 	"RFC 1413 identity of client"
			nextPutAll: ' -';	"TODO: userid of authenticated user"
			nextPutAll: ' ', logdate;
			nextPutAll: ' "', request requestLine, '"';
			nextPutAll: ' ', response code asString;
			nextPutAll: ' ', logsize asString.
	].
	^entry

]

{ #category : 'misc' }
WebUtils class >> logRequest: request response: response on: streamOrFilename [
	"Log a request in common log format on the given stream / file."

	| entry |

	"Create the log entry for the request/response pair"
	entry := self logEntryFor: request response: response.

	"If the argument is a string, it represents the file name to log to"
	streamOrFilename isString
		ifTrue: [
			streamOrFilename asFileEntry appendStreamDo: [ :stream |
				stream nextPutAll: entry; newLine ]]
		ifFalse: [
			streamOrFilename nextPutAll: entry; newLine.
			streamOrFilename flush ]
]

{ #category : 'misc' }
WebUtils class >> mcVersion [
	"Answers the Monticello version of WebServer's MC package"

	| version |
	"
	Smalltalk at: #MCWorkingCopy ifPresent:[:mc|
		mc managersForClass: self do:[:wc|
			wc ancestors ifNotEmpty:[:ancestry| version := ancestry first name]]].
	"
	^version ifNil:[''].
]

{ #category : 'md5' }
WebUtils class >> md5Digest: aStringOrByteArray [
	"This creates a little endian hex string to be used with various auth methods
	This is the same as htdigest (apache) uses for its md5 digest auth db"

	^(self md5HashStream: (ReadStream on: aStringOrByteArray asByteArray)) reversed hex
]

{ #category : 'md5' }
WebUtils class >> md5HashStream: aStream [
	"self md5HashStream: (ReadStream on: 'foo')"

	| start buffer bytes sz n words hash |
	hash := WordArray 
		with: 16r67452301 
		with: 16rEFCDAB89 
		with: 16r98BADCFE 
		with: 16r10325476.
	words := WordArray new: 16.
	buffer := ByteArray new: 64.
	start := aStream position.
	[aStream atEnd] whileFalse: [
		bytes := aStream nextInto: buffer.
		(bytes size < 64 or:[aStream atEnd]) ifTrue:[
			sz := bytes size.
			buffer replaceFrom: 1 to: sz with: bytes startingAt: 1.
			buffer from: sz+1 to: buffer size put: 0.
			sz < 56 ifTrue:[
				buffer at: sz + 1 put: 128. "trailing bit"
			] ifFalse:[
				"not enough room for the length, so just pad this one, then..."
				sz < 64 ifTrue:[buffer at: sz + 1 put: 128].
				1 to: 16 do:[:i| words at: i put: (buffer uint32At: i*4-3 bigEndian: false)].
				self md5Transform: words hash: hash.
				"process one additional block of padding ending with the length"
				buffer atAllPut: 0.
				sz = 64 ifTrue: [buffer at: 1 put: 128].
			].
			"Fill in the final 8 bytes with the 64-bit length in bits."
			n := (aStream position - start) * 8.
			7 to: 0 by: -1 do:[:i| buffer at: (buffer size - i) put: ((n bitShift: 7 - i * -8) bitAnd: 255)].
		].
		1 to: 16 do:[:i| words at: i put: (buffer uint32At: i*4-3 bigEndian: false)].
		self md5Transform: words hash: hash.
	].
	bytes := ByteArray new: 16.
	bytes uint32At: 1 put: (hash at: 4) bigEndian: true.
	bytes uint32At: 5 put: (hash at: 3) bigEndian: true.
	bytes uint32At: 9 put: (hash at: 2) bigEndian: true.
	bytes uint32At: 13 put: (hash at: 1) bigEndian: true.
	^bytes

]

{ #category : 'md5' }
WebUtils class >> md5Transform: in hash: hash [
	"This adds the incoming words to the existing hash"

	| a b c d |
	<primitive: 'primitiveMD5Transform' module: 'CroquetPlugin'>
	a := hash at: 1.
	b := hash at: 2.
	c := hash at: 3.
	d := hash at: 4.

	a := self step1: a x: b y: c z: d data: (in at:  1) add: 16rD76AA478 shift: 7.
	d := self step1: d x: a y: b z: c data: (in at:  2) add: 16rE8C7B756 shift: 12.
	c := self step1: c x: d y: a z: b data: (in at:  3) add: 16r242070DB shift: 17.
	b := self step1: b x: c y: d z: a data: (in at:  4) add: 16rC1BDCEEE shift: 22.
	a := self step1: a x: b y: c z: d data: (in at:  5) add: 16rF57C0FAF shift:  7.
	d := self step1: d x: a y: b z: c data: (in at:  6) add: 16r4787C62A shift: 12.
	c := self step1: c x: d y: a z: b data: (in at:  7) add: 16rA8304613 shift: 17.
	b := self step1: b x: c y: d z: a data: (in at:  8) add: 16rFD469501 shift: 22.
	a := self step1: a x: b y: c z: d data: (in at:  9) add: 16r698098D8 shift:  7.
	d := self step1: d x: a y: b z: c data: (in at: 10) add: 16r8B44F7AF shift: 12.
	c := self step1: c x: d y: a z: b data: (in at: 11) add: 16rFFFF5BB1 shift: 17.
	b := self step1: b x: c y: d z: a data: (in at: 12) add: 16r895CD7BE shift: 22.
	a := self step1: a x: b y: c z: d data: (in at: 13) add: 16r6B901122 shift:  7.
	d := self step1: d x: a y: b z: c data: (in at: 14) add: 16rFD987193 shift: 12.
	c := self step1: c x: d y: a z: b data: (in at: 15) add: 16rA679438E shift: 17.
	b := self step1: b x: c y: d z: a data: (in at: 16) add: 16r49B40821 shift: 22.

	a := self step2: a x: b y: c z: d data: (in at:  2) add: 16rF61E2562 shift:  5.
	d := self step2: d x: a y: b z: c data: (in at:  7) add: 16rC040B340 shift:  9.
	c := self step2: c x: d y: a z: b data: (in at: 12) add: 16r265E5A51 shift: 14.
	b := self step2: b x: c y: d z: a data: (in at:  1) add: 16rE9B6C7AA shift: 20.
	a := self step2: a x: b y: c z: d data: (in at:  6) add: 16rD62F105D shift:  5.
	d := self step2: d x: a y: b z: c data: (in at: 11) add: 16r02441453 shift:  9.
	c := self step2: c x: d y: a z: b data: (in at: 16) add: 16rD8A1E681 shift: 14.
	b := self step2: b x: c y: d z: a data: (in at:  5) add: 16rE7D3FBC8 shift: 20.
	a := self step2: a x: b y: c z: d data: (in at: 10) add: 16r21E1CDE6 shift:  5.
	d := self step2: d x: a y: b z: c data: (in at: 15) add: 16rC33707D6 shift:  9.
	c := self step2: c x: d y: a z: b data: (in at:  4) add: 16rF4D50D87 shift: 14.
	b := self step2: b x: c y: d z: a data: (in at:  9) add: 16r455A14ED shift: 20.
	a := self step2: a x: b y: c z: d data: (in at: 14) add: 16rA9E3E905 shift:  5.
	d := self step2: d x: a y: b z: c data: (in at:  3) add: 16rFCEFA3F8 shift:  9.
	c := self step2: c x: d y: a z: b data: (in at:  8) add: 16r676F02D9 shift: 14.
	b := self step2: b x: c y: d z: a data: (in at: 13) add: 16r8D2A4C8A shift: 20.

	a := self step3: a x: b y: c z: d data: (in at:  6) add: 16rFFFA3942 shift:  4.
	d := self step3: d x: a y: b z: c data: (in at:  9) add: 16r8771F681 shift: 11.
	c := self step3: c x: d y: a z: b data: (in at: 12) add: 16r6D9D6122 shift: 16.
	b := self step3: b x: c y: d z: a data: (in at: 15) add: 16rFDE5380C shift: 23.
	a := self step3: a x: b y: c z: d data: (in at:  2) add: 16rA4BEEA44 shift:  4.
	d := self step3: d x: a y: b z: c data: (in at:  5) add: 16r4BDECFA9 shift: 11.
	c := self step3: c x: d y: a z: b data: (in at:  8) add: 16rF6BB4B60 shift: 16.
	b := self step3: b x: c y: d z: a data: (in at: 11) add: 16rBEBFBC70 shift: 23.
	a := self step3: a x: b y: c z: d data: (in at: 14) add: 16r289B7EC6 shift:  4.
	d := self step3: d x: a y: b z: c data: (in at:  1) add: 16rEAA127FA shift: 11.
	c := self step3: c x: d y: a z: b data: (in at:  4) add: 16rD4EF3085 shift: 16.
	b := self step3: b x: c y: d z: a data: (in at:  7) add: 16r04881D05 shift: 23.
	a := self step3: a x: b y: c z: d data: (in at: 10) add: 16rD9D4D039 shift:  4.
	d := self step3: d x: a y: b z: c data: (in at: 13) add: 16rE6DB99E5 shift: 11.
	c := self step3: c x: d y: a z: b data: (in at: 16) add: 16r1FA27CF8 shift: 16.
	b := self step3: b x: c y: d z: a data: (in at:  3) add: 16rC4AC5665 shift: 23.

	a := self step4: a x: b y: c z: d data: (in at:  1) add: 16rF4292244 shift:  6.
	d := self step4: d x: a y: b z: c data: (in at:  8) add: 16r432AFF97 shift: 10.
	c := self step4: c x: d y: a z: b data: (in at: 15) add: 16rAB9423A7 shift: 15.
	b := self step4: b x: c y: d z: a data: (in at:  6) add: 16rFC93A039 shift: 21.
	a := self step4: a x: b y: c z: d data: (in at: 13) add: 16r655B59C3 shift:  6.
	d := self step4: d x: a y: b z: c data: (in at:  4) add: 16r8F0CCC92 shift: 10.
	c := self step4: c x: d y: a z: b data: (in at: 11) add: 16rFFEFF47D shift: 15.
	b := self step4: b x: c y: d z: a data: (in at:  2) add: 16r85845DD1 shift: 21.
	a := self step4: a x: b y: c z: d data: (in at:  9) add: 16r6FA87E4F shift:  6.
	d := self step4: d x: a y: b z: c data: (in at: 16) add: 16rFE2CE6E0 shift: 10.
	c := self step4: c x: d y: a z: b data: (in at:  7) add: 16rA3014314 shift: 15.
	b := self step4: b x: c y: d z: a data: (in at: 14) add: 16r4E0811A1 shift: 21.
	a := self step4: a x: b y: c z: d data: (in at:  5) add: 16rF7537E82 shift:  6.
	d := self step4: d x: a y: b z: c data: (in at: 12) add: 16rBD3AF235 shift: 10.
	c := self step4: c x: d y: a z: b data: (in at:  3) add: 16r2AD7D2BB shift: 15.
	b := self step4: b x: c y: d z: a data: (in at: 10) add: 16rEB86D391 shift: 21.

	a := (a + (hash at: 1)) bitAnd: 16rFFFFFFFF. hash at: 1 put: a.
	b := (b + (hash at: 2)) bitAnd: 16rFFFFFFFF. hash at: 2 put: b.
	c := (c + (hash at: 3)) bitAnd: 16rFFFFFFFF. hash at: 3 put: c.
	d := (d + (hash at: 4)) bitAnd: 16rFFFFFFFF. hash at: 4 put: d.

	^hash
]

{ #category : 'decoding' }
WebUtils class >> multipartBoundary [
	"Answer a string to be used as multpart boundary in posts"

	^'----squeak-', Date today printString,'-', Time localMillisecondClock printString, '-webclient-----'.
]

{ #category : 'oauth' }
WebUtils class >> oAuthSign: webRequest url: requestUrl extra: postFields using: params [
	"Sign the given webRequest using the set of oauth parameters provided"

	| epoch timestamp nonce normalized baseString query signature key header extraKeys baseUrl |

	"Allow providing an oauth_timestamp; HOWEVER this is only useful for
	tests etc. For actual API calls the timestamp *must* match real-time closely
	or else the request will be rejected"

	timestamp := params at: 'oauth_timestamp' ifAbsent:[
		"Timestamp is relative to Jan. 1st 1970 GMT"
		epoch := DateAndTime year: 1970 day: 1 hour: 0 minute: 0 second: 0 
			offset: (Duration seconds: 0).
		(DateAndTime now asUTC - epoch) totalSeconds.
	].

	"Same for nonces (although nonces can be reused)"
	nonce := params at: 'oauth_nonce' ifAbsent:[UUID new hex].

	"Assemble the required parameters. Start with the (POST) body fields."
	normalized := (postFields as: Dictionary) associations asOrderedCollection.

	"If present, extract any (GET) fields from the URL"
	(requestUrl copyAfter: $?) ifNotEmpty:[:fields|
		self decodeUrlEncodedForm: fields do:[:fkey :fval| normalized add: fkey -> fval]].

	"Keep the extra argument keys so we can exclude them below"
	extraKeys := Set newFrom: (normalized collect:[:assoc| assoc key]).
	normalized add:('oauth_nonce' -> nonce).
	normalized add: ('oauth_timestamp' -> timestamp asString).
	
	normalized add: (params associationAt: 'oauth_consumer_key').
	normalized add: (params associationAt: 'oauth_signature_method').
	normalized add: (params associationAt: 'oauth_version').

	(params includesKey: 'oauth_callback') ifTrue:[
		normalized add: (params associationAt: 'oauth_callback').
	].
	(params includesKey: 'oauth_token') ifTrue:[
		normalized add: (params associationAt: 'oauth_token').
	].
	(params includesKey: 'oauth_verifier') ifTrue:[
		normalized add: (params associationAt: 'oauth_verifier').
	].

	normalized := normalized sort:[:a1 :a2| 
		a1 key = a2 key 
			ifTrue:[a1 value <= a2 value]
			ifFalse:[a1 key <= a2 key]].

	query := String streamContents:[:s|
		normalized do:[:assoc|
			s nextPutAll: assoc key.
			s nextPutAll: '='.
			s nextPutAll: assoc value percentEscapeUrlField.
		] separatedBy:[s nextPutAll: '&'].
	].

	baseUrl := (requestUrl copyUpTo: $?) copyUpTo: $#.
	baseString := webRequest method, 
		'&', baseUrl percentEscapeUrlField, 
		'&',  query percentEscapeUrlField.

	key := (params at: 'oauth_consumer_secret'), 
			'&', (params at: 'oauth_token_secret' ifAbsent:['']).
	(params at: 'oauth_signature_method') caseOf: {
		['HMAC-SHA1'] -> [
			signature := (WebUtils hmacSha1: baseString key: key) base64Encoded
		].
	} otherwise:[self error: 'Unsupported signature method'].

	header := String streamContents:[:s|
		s nextPutAll: 'OAuth '.
		"Even though we need to include the extra args in the computation,
		they do NOT go into the OAuth header field."
		normalized do:[:assoc|
			(extraKeys includes: assoc key) 
				ifFalse:[ s nextPutAll: assoc key, '="', assoc value percentEscapeUrlField, '",']].
		s nextPutAll: 'oauth_signature="', signature percentEscapeUrlField, '"'.
	].

	webRequest headerAt: 'Authorization' put: header.
]

{ #category : 'oauth' }
WebUtils class >> oAuthSign: webRequest url: requestUrl using: params [
	"Sign the given webRequest using the set of oauth parameters provided"

	^self oAuthSign: webRequest url: requestUrl extra: #() using: params
]

{ #category : 'auth utils' }
WebUtils class >> parseAuthParams: authHeader [
	"Parse the auth header to find authentication parameters"

	| authParams stream key value|
	authParams := Dictionary new.
	stream := ReadStream on: authHeader.
	authParams at: 'method' put: (stream upTo: Character space) asLowercase.
	[stream skipSeparators.
	stream atEnd] whileFalse:[
		key := stream upTo: $=.
		stream skipSeparators.
		stream peek = $" 
			ifTrue:[value := stream next; upTo: $". stream upTo: $,]
			ifFalse:[value := stream upToAny: ' ,' asSet].
		authParams at: key asLowercase put: value.
	].
	^authParams
]

{ #category : 'misc' }
WebUtils class >> platformName [
	"Return the name of the platform we're running on."

	^Smalltalk getSystemAttribute: 1001
]

{ #category : 'proxy' }
WebUtils class >> proxyExceptionsDo: aBlock [
	"Evaluate aBlock with all registered proxy exceptions. 
	Uses the information from HTTPSocket."

	"HTTPSocket httpProxyExceptions do: aBlock."
]

{ #category : 'proxy' }
WebUtils class >> proxyServerFor: serverName [
	"Answer the proxy server to use for the given server:port
	Returns the proxy server:port to use or nil if no proxy is required."

	| domain |
	domain := serverName copyUpTo: $:.
	self proxyExceptionsDo:[:pattern| (pattern match: domain) ifTrue:[^nil]].
	^self defaultProxyServer
]

{ #category : 'quoting' }
WebUtils class >> quote: aString [
	"Quote the given string, escaping as necessary any embedded quotes"

	^'"', (aString copyReplaceAll: '"' with: '\"'), '"'

]

{ #category : 'headers' }
WebUtils class >> readHeadersFrom: aStream [
	"Parse http headers and answer a collection of key -> value pairs."

	| headers nextLine existing |
	headers := OrderedCollection new.
	[nextLine := aStream upToAll: String crlfString.
	nextLine isEmpty] whileFalse:[
		nextLine first isSeparator ifTrue:["Continuation as per HTTP 1.1 spec"
			existing := headers last.
			existing value: (existing value, String space, nextLine withBlanksTrimmed).
		] ifFalse:["Regular header"
			headers add: 
				(nextLine copyUpTo: $:) asLowercase ->
					(nextLine copyAfter: $:) withBlanksTrimmed.
		].
	].
	^headers
]

{ #category : 'md5' }
WebUtils class >> rotate: value by: amount [
	"Rotate value left by amount"

	| lowMask highMask |
	lowMask := (1 bitShift: 32-amount) - 1.
	highMask := 16rFFFFFFFF - lowMask.
	^((value bitAnd: lowMask) bitShift: amount) + 
		((value bitAnd: highMask) bitShift: amount-32)
]

{ #category : 'oauth' }
WebUtils class >> sha1Hash: message [
	"Compute the SHA1 hash for the given message. Slightly different from 
	SecureHashAlgorithm to produce fixed-length byte arrays."

	| sha hash |
	sha := SecureHashAlgorithm new hashMessage: message.
	hash := ByteArray new: 20.
	1 to: 20 do:[:i| hash at: i put: (sha digitAt: 21-i)].
	^hash

]

{ #category : 'md5' }
WebUtils class >> step1: w x: x y: y z: z data: data add: add shift: s [
	"Step 1 in MD5 transformation"

	| f result |
	f := z bitXor: (x bitAnd: (y bitXor: z)).
	result := w + f + data + add.
	result := self rotate: result by: s.
	^result + x bitAnd: 16rFFFFFFFF
]

{ #category : 'md5' }
WebUtils class >> step2: w x: x y: y z: z data: data add: add shift: s [
	"Step 2 in MD5 transformation"

	| f result |
	f := y bitXor: (z bitAnd: (x bitXor: y)).
	result := w + f + data + add.
	result := self rotate: result by: s.
	^result + x bitAnd: 16rFFFFFFFF
]

{ #category : 'md5' }
WebUtils class >> step3: w x: x y: y z: z data: data add: add shift: s [
	"Step 3 in MD5 transformation"

	| f result |
	f := (x bitXor: y) bitXor: z.
	result := w + f + data + add.
	result := self rotate: result by: s.
	^result + x bitAnd: 16rFFFFFFFF
]

{ #category : 'md5' }
WebUtils class >> step4: w x: x y: y z: z data: data add: add shift: s [
	"Step 4 in MD5 transformation"

	| f result |
	f := y bitXor: (x bitOr: (z  bitXor: 16rFFFFFFFF)).
	result := w + f + data + add.
	result := self rotate: result by: s.
	^result + x bitAnd: 16rFFFFFFFF
]

{ #category : 'quoting' }
WebUtils class >> unquote: aString [
	"Unquote the given string, unescaping as necessary any embedded quotes"

	(aString beginsWith: '"') ifFalse:[^aString].
	(aString endsWith: '"') ifFalse:[^aString].
	^(aString copyReplaceAll: '\"' with: '"') allButFirst allButLast
]

{ #category : 'misc' }
WebUtils class >> vmVersion	 [
	"Return a string identifying the interpreter version"

	^Smalltalk getSystemAttribute: 1004
]

{ #category : 'websockets' }
WebUtils class >> webSocketHandshake: key1 with: key2 with: data [
	"Do the actual WebSocket handshake computation"

	| bytes |
	bytes := ByteArray new: 16.
	bytes int32At: 1 put: key1 bigEndian: true.
	bytes int32At: 5 put: key2 bigEndian: true.
	bytes replaceFrom: 9 to: 16 with: data.
	^(self md5HashStream: bytes readStream) reversed
]

{ #category : 'websockets' }
WebUtils class >> webSocketHash07: key [
	"Do the actual WebSocket hash computation"

	| uid |
	uid := '258EAFA5-E914-47DA-95CA-C5AB0DC85B11'.
	^(ByteArray newFrom: (SecureHashAlgorithm new hashMessage: key, uid)) reversed base64Encoded
]
