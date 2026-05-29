"
I represent a collection of individual notes at different pitches, volumes, and articulations. On request, I can select the best note to use for a given pitch, duration, and volume. I currently only support two volumes, loud and soft, and two articulations, normal and staccato, but I can easily be extended to include more. The main barrier to keeping more variations is simply the memory space (assuming my component notes are sampled sounds).

"
Class {
	#name : 'SampledInstrument',
	#superclass : 'Object',
	#instVars : [
		'sustainedSoft',
		'sustainedLoud',
		'staccatoSoft',
		'staccatoLoud',
		'sustainedThreshold',
		'loudThreshold'
	],
	#category : 'Sound-Synthesis',
	#package : 'Sound',
	#tag : 'Synthesis'
}

{ #category : 'instance creation' }
SampledInstrument class >> buildSmallOrchestra [
	"Example of how to build a skeleton orchestra that uses less memory (about 14 MBytes)."
	"SampledInstrument buildSmallOrchestra"

	| dir |
	AbstractSound unloadSampledTimbres.
	dir _ 'Tosh:Not Backed Up:Sample Library:Orchestra'.
	#(clarinet oboe bassoon trombone tympani) do: [:instName |
		SampledInstrument
			readSimpleInstrument: instName
			fromDirectory: dir.
		(AbstractSound soundNamed: instName, '-f') pruneToNotesPerOctave: 1].
	#(flute bass) do: [:instName |
		SampledInstrument
			readSimpleInstrument: instName
			fromDirectory: dir.
		(AbstractSound soundNamed: instName, '-f') pruneToNotesPerOctave: 2].

	(AbstractSound soundNamed: 'bass-f') allNotes do: [:n |
		n firstSample: (n findStartPointForThreshold: 2500)].

	(AbstractSound soundNamed: 'bassoon-f') allNotes do: [:n |
		n beUnlooped.
		n firstSample: (n findStartPointForThreshold: 0)].

	(AbstractSound soundNamed: 'trombone-f') allNotes do: [:n |
		n firstSample: (n findStartPointForThreshold: 1800)].

	AbstractSound soundNamed: 'trumpet-f' put: (AbstractSound soundNamed: 'trombone-f').
	AbstractSound soundNamed: 'horn-f' put: (AbstractSound soundNamed: 'trombone-f').
	AbstractSound soundNamed: 'violin-f' put: (AbstractSound soundNamed: 'bass-f').
	AbstractSound soundNamed: 'viola-f' put: (AbstractSound soundNamed: 'bass-f').
	AbstractSound soundNamed: 'cello-f' put: (AbstractSound soundNamed: 'bass-f').

	(AbstractSound soundNamed: 'bassoon-f') allNotes do: [:n | n beUnlooped].


]

{ #category : 'instance creation' }
SampledInstrument class >> readLoudAndStaccatoInstrument: instName fromDirectory: orchestraDir [
	"SampledInstrument
		readLoudAndStaccatoInstrument: 'oboe'
		fromDirectory: 'Tosh:Sample Library:Orchestra'"

	| sampleSetDir memBefore memAfter loud short snd |
	sampleSetDir _ orchestraDir, ':', instName.
	memBefore _ Smalltalk garbageCollect.
	loud _ SampledInstrument new readSampleSetFrom: sampleSetDir, ' f'.
	short _ SampledInstrument new readSampleSetFrom: sampleSetDir, ' stacc'.
	memAfter _ Smalltalk garbageCollect.
	Transcript show:
		instName, ': ', (memBefore - memAfter) printString,
		' bytes; ', memAfter printString, ' bytes left'; newLine.
	AbstractSound soundNamed: instName, '-f&stacc' put:
		(snd _ SampledInstrument new
			allSampleSets: loud;
			staccatoLoudAndSoftSampleSet: short).
	"fix slow attacks"
	snd allNotes do: [:n | n firstSample: (n findStartPointForThreshold: 500)].

	AbstractSound soundNamed: instName, '-f' put:
		(snd _ SampledInstrument new
			allSampleSets: loud).
	"fix slow attacks"
	snd allNotes do: [:n | n firstSample: (n findStartPointForThreshold: 1000)].

]

{ #category : 'instance creation' }
SampledInstrument class >> readPizzInstrument: instName fromDirectory: orchestraDir [
	"SampledInstrument
		readPizzInstrument: 'violin'
		fromDirectory: 'Tosh:Sample Library:Orchestra'"

	| sampleSetDir memBefore memAfter sampleSet snd |
	sampleSetDir _ orchestraDir, ':', instName, ' pizz'.
	memBefore _ Smalltalk garbageCollect.
	sampleSet _ SampledInstrument new readSampleSetFrom: sampleSetDir.
	memAfter _ Smalltalk garbageCollect.
	Transcript show:
		instName, ': ', (memBefore - memAfter) printString,
		' bytes; ', memAfter printString, ' bytes left'; newLine.
	AbstractSound soundNamed: instName, '-pizz' put:
		(snd _ SampledInstrument new allSampleSets: sampleSet).

	"fix slow attacks"
	snd allNotes do: [:n |
		n firstSample: (n findStartPointForThreshold: 1000)].

	^ snd

]

{ #category : 'instance creation' }
SampledInstrument class >> readSimpleInstrument: instName fromDirectory: orchestraDir [
	"SampledInstrument
		readSimpleInstrument: 'oboe'
		fromDirectory: 'Tosh:Sample Library:Orchestra'"

	| sampleSetDir memBefore memAfter sampleSet snd |
	sampleSetDir _ orchestraDir, ':', instName, ' f'.
	memBefore _ Smalltalk garbageCollect.
	sampleSet _ SampledInstrument new readSampleSetFrom: sampleSetDir.
	memAfter _ Smalltalk garbageCollect.
	Transcript show:
		instName, ': ', (memBefore - memAfter) printString,
		' bytes; ', memAfter printString, ' bytes left'; newLine.
	AbstractSound soundNamed: instName, '-f' put:
		(snd _ SampledInstrument new allSampleSets: sampleSet).

	"fix slow attacks"
	snd allNotes do: [:n |
		n firstSample: (n findStartPointForThreshold: 1000)].

	^ snd

]

{ #category : 'other' }
SampledInstrument >> allNotes [
	"Answer a collection containing of all the unique sampled sounds used by this instrument."

	| r |
	r _ IdentitySet new.
	r addAll: sustainedLoud.
	sustainedSoft ~~ sustainedLoud ifTrue: [r addAll: sustainedSoft].
	staccatoLoud ~~ sustainedLoud ifTrue: [r addAll: staccatoLoud].
	staccatoSoft ~~ staccatoLoud ifTrue: [r addAll: staccatoSoft].
	^ r asArray sort: [:n1 :n2 | n1 pitch < n2 pitch]
]

{ #category : 'accessing' }
SampledInstrument >> allSampleSets: sortedNotes [

	| keyMap |
	keyMap _ self midiKeyMapFor: sortedNotes.
	sustainedSoft _ keyMap.
	sustainedLoud _ keyMap.
	staccatoSoft _ keyMap.
	staccatoLoud _ keyMap.

]

{ #category : 'other' }
SampledInstrument >> chooseSamplesForPitch: pitchInHz from: sortedNotes [
	"From the given collection of LoopedSampledSounds, choose the best one to be pitch-shifted to produce the given pitch."
	"Assume: the given collection is sorted in ascending pitch order."

	| i lower higher |
	i _ 1.
	[(i < sortedNotes size) and: [(sortedNotes at: i) pitch < pitchInHz]]
		whileTrue: [i _ i + 1].
	i = 1 ifTrue: [^ sortedNotes at: 1].
	lower _ sortedNotes at: i - 1.
	higher _ sortedNotes at: i.
	"note: give slight preference for down-shifting a higher-pitched sample set"
	(pitchInHz / lower pitch) < ((0.95 * higher pitch) / pitchInHz)
		ifTrue: [^ lower]
		ifFalse: [^ higher].

]

{ #category : 'accessing' }
SampledInstrument >> initialize [

	sustainedThreshold _ 0.15.
	loudThreshold _ 0.5.

]

{ #category : 'accessing' }
SampledInstrument >> loudThreshold [

	^ loudThreshold

]

{ #category : 'accessing' }
SampledInstrument >> loudThreshold: aNumber [

	loudThreshold _ aNumber asFloat.

]

{ #category : 'other' }
SampledInstrument >> memorySpace [
	"Answer the number of bytes required to store the samples for this instrument."

	| total |
	total _ 0.
	self allNotes do: [:n |
		total _ total + (n leftSamples monoSampleCount * 2).
		n isStereo ifTrue: [total _ total + (n leftSamples monoSampleCount * 2)]].
	^ total

]

{ #category : 'other' }
SampledInstrument >> midiKeyMapFor: sortedNotes [
	"Return a 128 element array that maps each MIDI key number to the sampled note from the given set with the closests pitch. A precise match isn't necessary because the selected note will be pitch shifted to play at the correct pitch."

	^ (0 to: 127) collect: [:k |
		self
			chooseSamplesForPitch: (AbstractSound pitchForMIDIKey: k)
			from: sortedNotes].

]

{ #category : 'other' }
SampledInstrument >> playChromaticRunFrom: startPitch to: endPitch [

	(AbstractSound chromaticRunFrom: startPitch to: endPitch on: self) play.

]

{ #category : 'other' }
SampledInstrument >> pruneNoteList: aNoteList notesPerOctave: notesPerOctave [
	"Return a pruned version of the given note list with only the given number of notes per octave. Assume the given notelist is in sorted order."

	| r interval lastPitch |
	r := OrderedCollection new.
	interval := (2.0 raisedTo: (1.0 / notesPerOctave)) * 0.995.
	lastPitch := 0.0.
	aNoteList do: [:n |
		n pitch > (lastPitch * interval) ifTrue: [
			r addLast: n.
			lastPitch := n pitch]].
	^ r

]

{ #category : 'other' }
SampledInstrument >> pruneToNotesPerOctave: notesPerOctave [
	"Prune all my keymaps to the given number of notes per octave."

	sustainedLoud _ self midiKeyMapFor:
		(self pruneNoteList: sustainedLoud notesPerOctave: notesPerOctave).
	sustainedSoft _ self midiKeyMapFor:
		(self pruneNoteList: sustainedSoft notesPerOctave: notesPerOctave).
	staccatoLoud _ self midiKeyMapFor:
		(self pruneNoteList: staccatoLoud notesPerOctave: notesPerOctave).
	staccatoSoft _ self midiKeyMapFor:
		(self pruneNoteList: staccatoSoft notesPerOctave: notesPerOctave).

]

{ #category : 'other' }
SampledInstrument >> pruneToSingleNote: aNote [
	"Fill all my keymaps with the given note."

	| oneNoteMap |
	oneNoteMap _ Array new: 128 withAll: aNote.
	sustainedLoud _ oneNoteMap.
	sustainedSoft _ oneNoteMap.
	staccatoLoud _ oneNoteMap.
	staccatoSoft _ oneNoteMap.

]

{ #category : 'other' }
SampledInstrument >> readSampleSetFrom: dirName [
	"Answer a collection of sounds read from AIFF files in the given directory and sorted in ascending pitch order."

	| all dir fullName snd |
	all _ SortedCollection sortBlock: [:s1 :s2 | s1 pitch < s2 pitch].
	dir _ dirName asDirectoryEntry.
	dir fileNames do: [ :n |
		fullName _ (dir / n) pathName.
		Utilities
			informUser: 'Reading AIFF file ', n
			during: [
				snd _ LoopedSampledSound new
					fromAIFFFileNamed: fullName
					mergeIfStereo: true].
		all add: snd].
	^ all asArray
]

{ #category : 'other' }
SampledInstrument >> readSampleSetInfoFrom: dirName [
	"MessageTally spyOn: [SampledInstrument new readSampleSetFrom: 'Tosh:Desktop Folder:AAA Squeak2.0 Beta:Organ Samples:Flute8'] timeToRun"

	| all dir fullName info |
	all _ OrderedCollection new.
	dir _ dirName asDirectoryEntry.
	dir fileNames do: [ :n |
		fullName _ (dir / n) pathName.
		info _ AIFFFileReader new readFromFile: fullName
			mergeIfStereo: false
			skipDataChunk: true.
		all add: n -> info].
	^ all

]

{ #category : 'playing' }
SampledInstrument >> soundForMidiKey: midiKey dur: d loudness: l [
	"Answer an initialized sound object that generates a note for the given MIDI key (in the range 0..127), duration (in seconds), and loudness (in the range 0.0 to 1.0)."

	| keymap note |
	l >= loudThreshold
		ifTrue: [
			d >= sustainedThreshold
				ifTrue: [keymap _ sustainedLoud]
				ifFalse: [keymap _ staccatoLoud]]
		ifFalse: [
			d >= sustainedThreshold
				ifTrue: [keymap _ sustainedSoft]
				ifFalse: [keymap _ staccatoSoft]].
	keymap ifNil: [keymap _ sustainedLoud].
	note _ (keymap at: midiKey) copy.
	^ note
		setPitch: (AbstractSound pitchForMIDIKey: midiKey)
		dur: d
		loudness: (l * note gain)

]

{ #category : 'playing' }
SampledInstrument >> soundForPitch: pitchNameOrNumber dur: d loudness: l [
	"Answer an initialized sound object that generates a note of the given pitch, duration, and loudness. Pitch may be a numeric pitch or a string pitch name such as 'c4'. Duration is in seconds and loudness is in the range 0.0 to 1.0."
	"Note:  Generally, SampledInstruments are expected to be played via MIDI key numbers rather than by pitches, since finding the MIDI key for a given pitch is expensive."

	^ self soundForMidiKey: (AbstractSound midiKeyForPitch: pitchNameOrNumber)
		dur: d
		loudness: l

]

{ #category : 'accessing' }
SampledInstrument >> staccatoLoudAndSoftSampleSet: sortedNotes [

	staccatoLoud _ self midiKeyMapFor: sortedNotes.
	staccatoSoft _ staccatoLoud.

]

{ #category : 'accessing' }
SampledInstrument >> staccatoLoudSampleSet: sortedNotes [

	staccatoLoud _ self midiKeyMapFor: sortedNotes.

]

{ #category : 'accessing' }
SampledInstrument >> staccatoSoftSampleSet: sortedNotes [

	staccatoSoft _ self midiKeyMapFor: sortedNotes.

]

{ #category : 'accessing' }
SampledInstrument >> sustainedLoudSampleSet: sortedNotes [

	sustainedLoud _ self midiKeyMapFor: sortedNotes.

]

{ #category : 'accessing' }
SampledInstrument >> sustainedSoftSampleSet: sortedNotes [

	sustainedSoft _ self midiKeyMapFor: sortedNotes.

]

{ #category : 'accessing' }
SampledInstrument >> sustainedThreshold [

	^ sustainedThreshold

]

{ #category : 'accessing' }
SampledInstrument >> sustainedThreshold: aNumber [

	sustainedThreshold _ aNumber asFloat.

]

{ #category : 'other' }
SampledInstrument >> testAtPitch: aPitch [
	"SampledInstrument testAtPitch: 'c4'"

	| pattern |
	pattern _ (#(
		(c4 0.64 100) 
		(c4 0.64 200) 
		(c4 0.64 400) 
		(c4 0.64 600) 
		(c4 0.64 800) 
		(c4 1.28 1000) 
		(c4 1.28 400) 
		(c4 0.32 500) 
		(c4 0.32 500) 
		(c4 0.32 500) 
		(c4 0.32 500) 
		(c4 0.16 500) 
		(c4 0.16 500) 
		(c4 0.16 500) 
		(c4 0.16 500) 
		(c4 0.16 500) 
		(c4 0.08 500) 
		(c4 0.08 500) 
		(c4 0.16 500) 
		(c4 0.08 500) 
		(c4 0.08 500) 
		(c4 0.64 500))
			collect: [:triple | triple copy at: 1 put: aPitch; yourself]).
	(AbstractSound noteSequenceOn: self from: pattern) play.

]

{ #category : 'other' }
SampledInstrument >> trimAttackOf: sampleBuffer threshold: threshold [
	"Trim 'silence' off the initial attacks of the given sound buffer."

	(sustainedSoft, sustainedLoud, staccatoSoft, staccatoLoud) do: [:snd |
		snd leftSamples: (self trimAttackOf: snd leftSamples threshold: threshold).
		snd isStereo ifTrue: [
			snd rightSamples:
				(self trimAttackOf: snd rightSamples threshold: threshold)]].

]

{ #category : 'other' }
SampledInstrument >> trimAttacks: threshold [
	"Trim 'silence' off the initial attacks all my samples."

	(sustainedSoft, sustainedLoud, staccatoSoft, staccatoLoud) do: [:snd |
		snd leftSamples: (self trimAttackOf: snd leftSamples threshold: threshold).
		snd isStereo ifTrue: [
			snd rightSamples:
				(self trimAttackOf: snd rightSamples threshold: threshold)]].

]
