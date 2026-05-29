"
A reader for Standard 1.0 format MIDI files.
MIDI File Types:
	type 0 -- one multi-channel track
	type 1 -- one or more simultaneous tracks
	type 2 -- a number on independent single-track patterns

Instance variables:
	stream			source of MIDI data
	fileType			MIDI file type
	trackCount		number of tracks in file
	ticksPerQuarter	number of ticks per quarter note for all tracks in this file
	tracks			collects track data for non-empty tracks
	strings			collects all strings in the MIDI file
	tempoMap		nil or a MIDITrack consisting only of tempo change events
	trackStream		stream on buffer containing track chunk
	track			track being read
	activeEvents 	notes that have been turned on but not off

"
Class {
	#name : 'MIDIFileReader',
	#superclass : 'Object',
	#instVars : [
		'stream',
		'fileType',
		'trackCount',
		'ticksPerQuarter',
		'tracks',
		'trackInfo',
		'tempoMap',
		'strings',
		'track',
		'trackStream',
		'activeEvents',
		'maxNoteTicks'
	],
	#category : 'Sound-Scores',
	#package : 'Sound',
	#tag : 'Scores'
}

{ #category : 'as yet unclassified' }
MIDIFileReader class >> playFileNamed: fileName  [
"
	ScorePlayerMorph openOn: (self scoreFromFileNamed: fileName)
		title: (FileDirectory localNameFor: fileName)"
]

{ #category : 'as yet unclassified' }
MIDIFileReader class >> playStream: binaryStream  [
"
	ScorePlayerMorph openOn: (self scoreFromStream: binaryStream)
		title: 'a MIDI stream'"
]

{ #category : 'as yet unclassified' }
MIDIFileReader class >> playURLNamed: urlString  [
"
	| titleString |
	titleString := urlString copyFrom: (urlString findLast: [:c | c = $/]) + 1
				to: urlString size.
	ScorePlayerMorph openOn: (self scoreFromURL: urlString)
		title: titleString"
]

{ #category : 'as yet unclassified' }
MIDIFileReader class >> scoreFromFileNamed: fileName [

	| f score |
	f _ (fileName asFileEntry readStream) binary.
	score _ (self new readMIDIFrom: f) asScore.
	f close.
	^ score

]

{ #category : 'as yet unclassified' }
MIDIFileReader class >> scoreFromStream: binaryStream [

	|  score |
	score _ (self new readMIDIFrom: binaryStream) asScore.
	^ score

]

{ #category : 'as yet unclassified' }
MIDIFileReader class >> standardMIDIInstrumentNames [
	"Answer an array of Standard MIDI instrument names."

	^ #(
		'Grand Piano'
		'Bright Piano'
		'Electric Grand Piano'
		'Honky-tonk Piano'
		'Electric Piano 1'
		'Electric Piano 2'
		'Harpsichord'
		'Clavichord'
		'Celesta'
		'Glockenspiel'
		'Music Box'
		'Vibraphone'
		'Marimba'
		'Xylophone'
		'Tubular Bells'
		'Duclimer'
		'Drawbar Organ'
		'Percussive Organ'
		'Rock Organ'
		'Church Organ'
		'Reed Organ'
		'Accordion'
		'Harmonica'
		'Tango Accordion'
		'Nylon Guitar'
		'Steel Guitar'
		'Electric Guitar 1'
		'Electric Guitar 2'
		'Electric Guitar 3'
		'Overdrive Guitar'
		'Distorted Guitar'
		'Guitar Harmonics'
		'Acoustic Bass'
		'Electric Bass 1'
		'Electric Bass 2'
		'Fretless Bass'
		'Slap Bass 1'
		'Slap Bass 2'
		'Synth Bass 1'
		'Synth Bass 2'
		'Violin'
		'Viola'
		'Cello'
		'Contrabass'
		'Tremolo Strings'
		'Pizzicato Strings'
		'Orchestral Harp'
		'Timpani'
		'String Ensemble 1'
		'String Ensemble 2'
		'Synth Strings 1'
		'Synth Strings 2'
		'Choir Ahhs'
		'Choir Oohs'
		'Synth Voice'
		'Orchestra Hit'
		'Trumpet'
		'Trombone'
		'Tuba'
		'Muted Trumpet'
		'French Horn'
		'Brass Section'
		'Synth Brass 1'
		'Synth Brass 2'
		'Soprano Sax'
		'Alto Sax'
		'Tenor Sax'
		'Baritone Sax'
		'Oboe'
		'English Horn'
		'Bassoon'
		'Clarinet'
		'Piccolo'
		'Flute'
		'Recorder'
		'Pan Flute'
		'Blown Bottle'
		'Shakuhachi'
		'Whistle'
		'Ocarina'
		'Lead 1 (square)'
		'Lead 2 (sawtooth)'
		'Lead 3 (calliope)'
		'Lead 4 (chiff)'
		'Lead 5 (charang)'
		'Lead 6 (voice)'
		'Lead 7 (fifths)'
		'Lead 8 (bass+lead)'
		'Pad 1 (new age)'
		'Pad 2 (warm)'
		'Pad 3 (polysynth)'
		'Pad 4 (choir)'
		'Pad 5 (bowed)'
		'Pad 6 (metallic)'
		'Pad 7 (halo)'
		'Pad 8 (sweep)'
		'FX 1 (rain)'
		'FX 2 (soundtrack)'
		'FX 3 (crystals)'
		'FX 4 (atmosphere)'
		'FX 5 (brightness)'
		'FX 6 (goblins)'
		'FX 7 (echoes)'
		'FX 8 (sci-fi)'
		'Sitar'
		'Banjo'
		'Shamisen'
		'Koto'
		'Kalimba'
		'Bagpipe'
		'Fiddle'
		'Shanai'
		'Tinkle Bell'
		'Agogo'
		'Steel Drum'
		'Woodblock'
		'Taiko Drum'
		'Melodic Tom'
		'Synth Drum'
		'Reverse Cymbal'
		'Guitar Fret Noise'
		'Breath Noise'
		'Seashore'
		'Bird Tweet'
		'Telephone Ring'
		'Helicopter'
		'Applause'
		'Gunshot')

]

{ #category : 'chunk reading' }
MIDIFileReader >> asScore [

	^ MIDIScore new
		tracks: tracks;
		trackInfo: trackInfo;
		tempoMap: tempoMap;
		ticksPerQuarterNote: ticksPerQuarter

]

{ #category : 'track reading' }
MIDIFileReader >> endAllNotesAt: endTicks [
	"End of score; end any notes still sounding."
	"Details: Some MIDI files have missing note-off events, resulting in very long notes. Truncate any such notes encountered."

	| dur |
	activeEvents do: [:e |
		dur _ endTicks - e time.
		dur > maxNoteTicks ifTrue: [dur _ ticksPerQuarter].  "truncate long note"
		e duration: dur].
	activeEvents _ activeEvents species new.

]

{ #category : 'track reading' }
MIDIFileReader >> endNote: midiKey chan: channel at: endTicks [

	| evt |
	evt _ activeEvents
		detect: [:e | (e midiKey = midiKey) and: [e channel = channel]]
		ifNone: [^ self].
	evt duration: (endTicks - evt time).
	activeEvents remove: evt ifAbsent: nil
]

{ #category : 'private' }
MIDIFileReader >> guessMissingInstrumentNames [
	"Attempt to guess missing instrument names from the first program change in that track."

	| progChange instrIndex instrName |
	1 to: tracks size do: [:i |
		(trackInfo at: i) isEmpty ifTrue: [
			progChange _ (tracks at: i) detect: [:e | e isProgramChange] ifNone: nil.
			progChange ifNotNil: [
				instrIndex _ progChange program + 1.
				instrName _ self class standardMIDIInstrumentNames at: instrIndex.
				trackInfo at: i put: instrName]]].

]

{ #category : 'track reading' }
MIDIFileReader >> isTempoTrack: anEventList [
	"Return true if the given event list is non-empty and contains only tempo change events."

	anEventList isEmpty ifTrue: [^ false].
	anEventList do: [:evt | evt isTempoEvent ifFalse: [^ false]].
	^ true

]

{ #category : 'track reading' }
MIDIFileReader >> metaEventAt: ticks [
	"Read a meta event. Event types appear roughly in order of expected frequency."

	| type length tempo |
	type _ trackStream next.
	length _ self readVarLengthIntFrom: trackStream.

	type = 16r51 ifTrue: [  "tempo"
		tempo _ 0.
		length timesRepeat: [tempo _ (tempo bitShift: 8) + trackStream next].
		track add: (TempoEvent new tempo: tempo; time: ticks).
		^ self].

	type = 16r2F ifTrue: [  "end of track"
		length = 0 ifFalse: [self error: 'length of end-of-track chunk should be zero'].
		self endAllNotesAt: ticks.
		trackStream skip: length.
		^ self].

	type = 16r58 ifTrue: [  "time signature"
		length = 4 ifFalse: [self error: 'length of time signature chunk should be four'].
		trackStream skip: length.
		^ self].

	type = 16r59 ifTrue: [  "key signature"
		length = 2 ifFalse: [self error: 'length of key signature chunk should be two'].
		trackStream skip: length.
		^ self].

	((type >= 1) and: [type <= 7]) ifTrue: [  "string"
		strings add: (trackStream next: length) asString.
		^ self].

	(  type = 16r21 or:   "mystery; found in MIDI files but not in MIDI File 1.0 Spec"
	 [(type = 16r7F) or:  "sequencer specific meta event"
	 [(type = 16r00) or:  "sequence number"
	 [(type = 16r20)]]])  "MIDI channel prefix"
		ifTrue: [
			trackStream skip: length.
			^ self].

	type = 16r54 ifTrue: [
		"SMPTE offset"
		self report: 'Ignoring SMPTE offset'.
		trackStream skip: length.
		^ self].

	"skip unrecognized meta event"
	self report:
		'skipping unrecognized meta event: ', (type printStringBase: 16),
		' (', length printString, ' bytes)'.
	trackStream skip: length.

]

{ #category : 'private' }
MIDIFileReader >> next16BitWord [
	"Read a 16-bit positive integer from the input stream, most significant byte first."
	"Assume: Stream has at least two bytes left."

	| n |
	n _ stream next.
	^ (n bitShift: 8) + stream next

]

{ #category : 'private' }
MIDIFileReader >> next32BitWord: msbFirst [
	"Read a 32-bit positive integer from the input stream."
	"Assume: Stream has at least four bytes left."

	| n |
	n _ stream next: 4.
	^msbFirst
		ifTrue:[((n at: 1) bitShift: 24) + ((n at: 2) bitShift: 16) + ((n at: 3) bitShift: 8) + (n at: 4)]
		ifFalse:[((n at: 4) bitShift: 24) + ((n at: 3) bitShift: 16) + ((n at: 2) bitShift: 8) + (n at: 1)]

]

{ #category : 'private' }
MIDIFileReader >> readChunkSize [
	"Read a 32-bit positive integer from the next 4 bytes, most significant byte first."
	"Assume: Stream has at least four bytes left."

	| n |
	n _ 0.
	1 to: 4 do: [:ignore | n _ (n bitShift: 8) + stream next].
	^ n

]

{ #category : 'private' }
MIDIFileReader >> readChunkType [
	"Read a chunk ID string from the next 4 bytes."
	"Assume: Stream has at least four bytes left."

	| s |
	s := String new: 4.
	1 to: 4 do: [:i | s at: i put: (Character codePoint: stream next) ].
	^ s

]

{ #category : 'chunk reading' }
MIDIFileReader >> readHeaderChunk [

	| chunkType chunkSize division |
	chunkType _ self readChunkType.
	chunkType = 'RIFF' ifTrue:[chunkType _ self riffSkipToMidiChunk].
	chunkType = 'MThd' ifFalse: [self scanForMIDIHeader].
	chunkSize _ self readChunkSize.
	fileType _ self next16BitWord.
	trackCount _ self next16BitWord.
	division _ self next16BitWord.
	(division anyMask: 16r8000)
		ifTrue: [self error: 'SMPTE time formats are not yet supported']
		ifFalse: [ticksPerQuarter _ division].
	maxNoteTicks _ 12 * 4 * ticksPerQuarter.
		"longest acceptable note; used to detect stuck notes"

	"sanity checks"
	((chunkSize < 6) or: [chunkSize > 100])
		ifTrue: [self error: 'unexpected MIDI header size ', chunkSize printString].
	(#(0 1 2) includes: fileType)
		ifFalse: [self error: 'unknown MIDI file type ', fileType printString].

	Transcript
		show: 'Reading Type ', fileType printString, ' MIDI File (';
		show: trackCount printString, ' tracks, ';
		show: ticksPerQuarter printString, ' ticks per quarter note)';
		newLine.

]

{ #category : 'chunk reading' }
MIDIFileReader >> readMIDIFrom: aBinaryStream [
	"Read one or more MIDI tracks from the given binary stream."

	stream _ aBinaryStream.
	tracks _ OrderedCollection new.
	trackInfo _ OrderedCollection new.
	self readHeaderChunk.
	trackCount timesRepeat: [self readTrackChunk].
	stream atEnd ifFalse: [self report: 'data beyond final track'].
	fileType = 0 ifTrue: [self splitIntoTracks].
	self guessMissingInstrumentNames.

]

{ #category : 'chunk reading' }
MIDIFileReader >> readTrackChunk [

	| chunkType chunkSize |
	chunkType _ self readChunkType.
	[chunkType = 'MTrk'] whileFalse: [
		self report: 'skipping unexpected chunk type "', chunkType, '"'.
		stream skip: (self readChunkSize).  "skip it"
		chunkType _ (stream next: 4) asString].
	chunkSize _ self readChunkSize.
	chunkSize < 10000000 ifFalse: [
		self error: 'suspiciously large track chunk; this may not be MIDI file'].

	self readTrackContents: chunkSize.

]

{ #category : 'track reading' }
MIDIFileReader >> readTrackContents: byteCount [

	| info |
	strings _ OrderedCollection new.
	track _ OrderedCollection new.
	trackStream _ ReadStream on: (stream next: byteCount).
	activeEvents _ OrderedCollection new.
	self readTrackEvents.
	(tracks isEmpty and: [self isTempoTrack: track])
		ifTrue: [tempoMap _ track asArray]
		ifFalse: [
			"Note: Tracks without note events are currently not saved to
			 eliminate clutter in the score player. In control applications,
			 this can be easily changed by modifying the following test."
			(self trackContainsNotes: track) ifTrue: [
				tracks add: track asArray.
				info _ WriteStream on: (String new: 100).
				strings do: [:s | info nextPutAll: s; newLine].
				trackInfo add: info contents]].
	strings _ track _ trackStream _ activeEvents _ nil.

]

{ #category : 'track reading' }
MIDIFileReader >> readTrackEvents [
	"Read the events of the current track."

	| cmd chan key vel ticks byte length evt |
	cmd _ #unknown.
	chan _ key _ vel _ 0.
	ticks _ 0.
	[trackStream atEnd] whileFalse: [
		ticks _ ticks + (self readVarLengthIntFrom: trackStream).
		byte _ trackStream next.
		byte >= 16rF0
			ifTrue: [  "meta or system exclusive event"
				byte = 16rFF ifTrue: [self metaEventAt: ticks].
				((byte = 16rF0) or: [byte = 16rF7]) ifTrue: [  "system exclusive data"
					length _ self readVarLengthIntFrom: trackStream.
					trackStream skip: length].
				cmd _ #unknown]
			ifFalse: [  "channel message event"
				byte >= 16r80
					ifTrue: [  "new command"
						cmd _ byte bitAnd: 16rF0.
						chan _ byte bitAnd: 16r0F.
						key _ trackStream next]
					ifFalse: [  "use running status"
						cmd == #unknown
							ifTrue: [self error: 'undefined running status; bad MIDI file?'].
						key _ byte].

				((cmd = 16rC0) or: [cmd = 16rD0]) ifFalse: [
					"all but program change and channel pressure have two data bytes"
					vel _ trackStream next].

				cmd = 16r80 ifTrue: [  "note off"
					self endNote: key chan: chan at: ticks].

				cmd = 16r90 ifTrue: [  "note on"
					vel = 0
						ifTrue: [self endNote: key chan: chan at: ticks]
						ifFalse: [self startNote: key vel: vel chan: chan at: ticks]].

				"cmd = 16A0 -- polyphonic key pressure; skip"

				cmd = 16rB0 ifTrue: [
					evt _ ControlChangeEvent new control: key value: vel channel: chan.
					evt time: ticks.
					track add: evt].

				cmd = 16rC0 ifTrue: [
					evt _ ProgramChangeEvent new program: key channel: chan.
					evt time: ticks.
					track add: evt].

				"cmd = 16D0 -- channel aftertouch pressure; skip"

				cmd = 16rE0 ifTrue: [
					evt _ PitchBendEvent new bend: key + (vel bitShift: 7) channel: chan.
					evt time: ticks.
					track add: evt]
	]].

]

{ #category : 'private' }
MIDIFileReader >> readVarLengthIntFrom: aBinaryStream [
	"Read a one to four byte positive integer from the given stream, most significant byte first. Use only the lowest seven bits of each byte. The highest bit of a byte is set for all bytes except the last."

	| n byte |
	n _ 0.
	1 to: 4 do: [:ignore |
		byte _ aBinaryStream next.
		byte < 128 ifTrue: [
			n = 0
				ifTrue: [^ byte]  "optimization for one-byte lengths"
				ifFalse: [^ (n bitShift: 7) + byte]].
		n _ (n bitShift: 7) + (byte bitAnd: 16r7F)].

	self error: 'variable length quantity must not exceed four bytes'.

]

{ #category : 'private' }
MIDIFileReader >> report: aString [

	Transcript show: aString; newLine
]

{ #category : 'private' }
MIDIFileReader >> riffSkipToMidiChunk [
	"This file is a RIFF file which may (or may not) contain a MIDI chunk. Thanks to Andreas Raab for this code."

	| dwLength fourcc |
	"Read length of all data"
	dwLength := self next32BitWord: false.
	"Get RIFF contents type "
	fourcc := self readChunkType.
	fourcc = 'RMID' ifFalse:[^fourcc]. "We can only read RMID files here"
	"Search for data"
	[[fourcc := self readChunkType.
	dwLength := self next32BitWord: false.
	fourcc = 'data'] whileFalse:[
		"Skip chunk - rounded to word boundary"
		stream skip: (dwLength + 1 bitAnd: 16rFFFFFFFE).
		stream atEnd ifTrue:[^'']].
	"Data chunk is raw - look into if it contains MIDI data and skip if not"
	fourcc := self readChunkType.
	fourcc = 'MThd'] whileFalse:[
		"Skip data (chunk - 4bytes) rounded to word boundary"
		stream skip: (dwLength - 3 bitAnd: 16rFFFFFFFE)].
	^fourcc
]

{ #category : 'private' }
MIDIFileReader >> scanForMIDIHeader [
	"Scan the first part of this file in search of the MIDI header string 'MThd'. Report an error if it is not found. Otherwise, leave the input stream positioned to the first byte after this string."

	| asciiM p lastSearchPosition byte restOfHeader |
	asciiM _ $M asciiValue.
	stream skip: -3.
	p _ stream position.
	lastSearchPosition _ p + 10000.  "search only the first 10000 bytes of the file"
	[p < lastSearchPosition and: [stream atEnd not]] whileTrue: [
		[(byte _ stream next) ~= asciiM and: [byte notNil]] whileTrue.  "find the next 'M' or file end"
		restOfHeader _ (stream next: 3) asString.
		restOfHeader = 'Thd'
			ifTrue: [^ self]
			ifFalse: [restOfHeader size = 3 ifTrue: [stream skip: -3]].
		p _ stream position].

	self error: 'MIDI header chunk not found'.

]

{ #category : 'private' }
MIDIFileReader >> splitIntoTracks [
	"Split a type zero MIDI file into separate tracks by channel number."

	| newTempoMap newTracks |
	tracks size = 1 ifFalse: [self error: 'expected exactly one track in type 0 file'].
	tempoMap ifNotNil: [self error: 'did not expect a tempo map in type 0 file'].
	newTempoMap _ OrderedCollection new.
	newTracks _ (1 to: 16) collect: [:i | OrderedCollection new].
	tracks first do: [:e |
		e isTempoEvent
			ifTrue: [newTempoMap addLast: e]
			ifFalse: [(newTracks at: e channel + 1) addLast: e]].
	newTempoMap size > 0 ifTrue: [tempoMap _ newTempoMap asArray].
	newTracks _ newTracks select: [:t | self trackContainsNotes: t].
	tracks _ newTracks collect: [:t | t asArray].
	trackInfo _ trackInfo, ((2 to: tracks size) collect: [:i | '']).

]

{ #category : 'track reading' }
MIDIFileReader >> startNote: midiKey vel: vel chan: chan at: startTicks [
	"Record the beginning of a note."
	"Details: Some MIDI scores have missing note-off events, causing a note-on to be received for a (key, channel) that is already sounding. If the previous note is suspiciously long, truncate it."

	| newActiveEvents dur noteOnEvent |
	newActiveEvents _ nil.
	activeEvents do: [:e |
		((e midiKey = midiKey) and: [e channel = chan]) ifTrue: [
			"turn off key already sounding"
			dur _ startTicks - e time.
			dur > maxNoteTicks ifTrue: [dur _ ticksPerQuarter].  "truncate"
			e duration: dur.
			newActiveEvents ifNil: [newActiveEvents _ activeEvents copy].
			newActiveEvents remove: e ifAbsent: nil]].
	newActiveEvents ifNotNil: [activeEvents _ newActiveEvents].

	noteOnEvent _ NoteEvent new key: midiKey velocity: vel channel: chan.
	noteOnEvent time: startTicks.
	track add: noteOnEvent.
	activeEvents add: noteOnEvent
]

{ #category : 'track reading' }
MIDIFileReader >> trackContainsNotes: eventList [
	"Answer true if the given track contains at least one note event."

	eventList do: [:e | e isNoteEvent ifTrue: [^ true]].
	^ false

]
