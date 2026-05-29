"
This is a real-time player for MIDI scores (i.e., scores read from MIDI files). Score can be played using either the internal sound synthesis or an external MIDI synthesizer on platforms that support MIDI output.

"
Class {
	#name : 'ScorePlayer',
	#superclass : 'AbstractSound',
	#instVars : [
		'score',
		'instruments',
		'overallVolume',
		'leftVols',
		'rightVols',
		'muted',
		'rate',
		'tempo',
		'secsPerTick',
		'done',
		'repeat',
		'ticksSinceStart',
		'ticksClockIncr',
		'trackEventIndex',
		'tempoMapIndex',
		'activeSounds',
		'activeMIDINotes',
		'midiPort',
		'midiPlayerProcess',
		'durationInTicks'
	],
	#category : 'Sound-Scores',
	#package : 'Sound',
	#tag : 'Scores'
}

{ #category : 'instance creation' }
ScorePlayer class >> onScore: aMIDIScore [

	^ self new onScore: aMIDIScore

]

{ #category : 'volume' }
ScorePlayer >> adjustVolumeTo: vol overMSecs: mSecs [
	| normalizedVolume incr block |
	normalizedVolume _ (vol asFloat min: 1.0) max: 0.0.
	incr _ (self overallVolume - normalizedVolume) / mSecs * 50.0.
	block _ normalizedVolume > 0.0
		ifTrue: [
			[[(normalizedVolume - self overallVolume) abs > 0.01] whileTrue: [self overallVolume: self overallVolume - incr. (Delay forMilliseconds: 50) wait]]]
		ifFalse: [
			[[self overallVolume > 0.0] whileTrue: [self overallVolume: self overallVolume - incr. (Delay forMilliseconds: 50) wait]. self pause]].
	block fork

]

{ #category : 'midi output' }
ScorePlayer >> closeMIDIPort [
	"Stop using MIDI for output. Music will be played using the built-in sound synthesis."

	self pause.
	midiPort _ nil.

]

{ #category : 'copying' }
ScorePlayer >> copySounds [
	"Private! Support for copying."

	instruments _ instruments copy.
	leftVols _ leftVols copy.
	rightVols _ rightVols copy.
	muted _ muted copy.
	self reset.

]

{ #category : 'operating' }
ScorePlayer >> disableReverb: aBoolean [

	aBoolean
		ifTrue: [SoundPlayer stopReverb]
		ifFalse: [SoundPlayer startReverb].

]

{ #category : 'sound generation' }
ScorePlayer >> doControl [

	super doControl.
	1 to: activeSounds size do: [:i | (activeSounds at: i) first doControl].
	ticksSinceStart _ ticksSinceStart + ticksClockIncr.
	self processAllAtTick: ticksSinceStart asInteger.

]

{ #category : 'accessing' }
ScorePlayer >> duration [
	"Answer the duration in seconds of my MIDI score when played at the current rate. Take tempo changes into account."

	| totalSecs currentTempo lastTempoChangeTick |
	totalSecs _ 0.0.
	currentTempo _ 120.0.  "quarter notes per minute"
	lastTempoChangeTick _ 0.
	score tempoMap ifNotNil: [
		score tempoMap do: [:tempoEvt |
			"accumulate time up to this tempo change event"
			secsPerTick _ 60.0 / (currentTempo * rate * score ticksPerQuarterNote).
			totalSecs _ totalSecs + (secsPerTick * (tempoEvt time - lastTempoChangeTick)).

			"set the new tempo"
			currentTempo _ (120.0 * (500000.0 / tempoEvt tempo)) roundTo: 0.01.
			lastTempoChangeTick _ tempoEvt time]].

	"add remaining time through end of score"
	secsPerTick _ 60.0 / (currentTempo * rate * score ticksPerQuarterNote).
	totalSecs _ totalSecs + (secsPerTick * (score durationInTicks - lastTempoChangeTick)).
	^ totalSecs

]

{ #category : 'accessing' }
ScorePlayer >> durationInTicks [

	durationInTicks ifNil: [^ 1000].
	^ durationInTicks
]

{ #category : 'accessing' }
ScorePlayer >> infoForTrack: i [
	"Return the info string for the given track."
	"Note: MIDI files follow varying conventions on their use of comment strings. Often, the first string in the track suggests the role of that track in the score, such as 'flute 1' or 'soprano'."

	^ score trackInfo at: i

]

{ #category : 'initialization' }
ScorePlayer >> initialize [

	super initialize.
	score _ MIDIScore new.
	instruments _ #().
	overallVolume _ 0.5.
	leftVols _ #().
	rightVols _ #().
	muted _ #().
	rate _ 1.0.
	repeat _ false.
	durationInTicks _ 100
]

{ #category : 'accessing' }
ScorePlayer >> instrumentForTrack: trackIndex [

	^ instruments at: trackIndex

]

{ #category : 'accessing' }
ScorePlayer >> instrumentForTrack: trackIndex put: aSoundProto [

	trackIndex > instruments size ifTrue: [^ self].
	instruments at: trackIndex put: aSoundProto.

]

{ #category : 'sound generation' }
ScorePlayer >> isDone [

	| track |
	activeSounds size > 0 ifTrue: [^ false].
	activeMIDINotes size > 0 ifTrue: [^ false].
	1 to: score tracks size do: [:i |
		track _ score tracks at: i.
		(trackEventIndex at: i) <= track size ifTrue: [^ false]].
	^ true

]

{ #category : 'accessing' }
ScorePlayer >> isStereo [

	^ true

]

{ #category : 'sound generation' }
ScorePlayer >> jumpToTick: startTick [

	| |
	self reset.
	self processTempoMapAtTick: startTick.
	self skipNoteEventsThruTick: startTick.
	ticksSinceStart _ startTick.

]

{ #category : 'midi output' }
ScorePlayer >> midiPlayLoop [

	| mSecsPerStep tStart mSecs |
	mSecsPerStep _ 5.
	[done] whileFalse: [
		tStart _ Time localMillisecondClock.
		self processAllAtTick: ticksSinceStart asInteger.
		(Delay forMilliseconds: mSecsPerStep) wait.
		mSecs _ Time localMillisecondClock - tStart.
		ticksSinceStart _ ticksSinceStart + (mSecs asFloat / (1000.0 * secsPerTick))]
]

{ #category : 'accessing' }
ScorePlayer >> midiPort [

	^ midiPort

]

{ #category : 'accessing' }
ScorePlayer >> millisecondsSinceStart [
	"Answer the approximate number of milliseconds of real time since the beginning of the score. Since this calculation uses the current tempo, which can change throughout the piece, it is safer to use ticksSinceStart for synchronization."

	^ (secsPerTick * ticksSinceStart * 1000) asInteger

]

{ #category : 'sound generation' }
ScorePlayer >> mixSampleCount: n into: aSoundBuffer startingAt: startIndex leftVol: leftVol rightVol: rightVol [
	"Play a number of sounds concurrently. The level of each sound can be set independently for the left and right channels."

	| myLeftVol myRightVol someSoundIsDone pair snd trk left right |
	myLeftVol _ (leftVol * overallVolume) asInteger.
	myRightVol _ (rightVol * overallVolume) asInteger.
	someSoundIsDone _ false.
	1 to: activeSounds size do: [:i |
		pair _ activeSounds at: i.
		snd _ pair at: 1.
		trk _ pair at: 2.
		left _ (myLeftVol * (leftVols at: trk)) // ScaleFactor.
		right _ (myRightVol * (rightVols at: trk)) // ScaleFactor.
		snd samplesRemaining > 0
			ifTrue: [
				snd mixSampleCount: n into: aSoundBuffer startingAt: startIndex leftVol: left rightVol: right]
			ifFalse: [someSoundIsDone _ true]].

	someSoundIsDone ifTrue: [
		activeSounds _ activeSounds select: [:p | p first samplesRemaining > 0]].

]

{ #category : 'accessing' }
ScorePlayer >> mutedForTrack: trackIndex [

	^ muted at: trackIndex

]

{ #category : 'accessing' }
ScorePlayer >> mutedForTrack: trackIndex put: aBoolean [

	trackIndex > muted size ifTrue: [^ self].
	muted at: trackIndex put: aBoolean.
	aBoolean ifFalse: [^ self].

	"silence any currently sounding notes for this track"
	activeSounds do: [:pair |
		pair last = trackIndex ifTrue: [activeSounds remove: pair ifAbsent: nil]].
	midiPort ifNotNil: [
		activeMIDINotes do: [:pair |
			pair last = trackIndex ifTrue: [
				pair first endNoteOnMidiPort: midiPort.
				activeMIDINotes remove: pair ifAbsent: nil]]].

]

{ #category : 'accessing' }
ScorePlayer >> mutedState [

	^ muted

]

{ #category : 'initialization' }
ScorePlayer >> onScore: aMIDIScore [

	| trackCount totalVol incr curr pan |
	score _ aMIDIScore.
	trackCount _ score tracks size.
	durationInTicks _ score durationInTicks.
	instruments _ (1 to: trackCount) collect: [:i | FMSound oboe1].
	leftVols _ Array new: trackCount.
	rightVols _ Array new: trackCount.
	muted  _ Array new: trackCount withAll: false.
	rate _ 1.0.
	repeat _ false.
	tempo _ 120.0.

	trackCount = 0 ifTrue: [^ self].
	1 to: trackCount do: [:i |
		leftVols at: i put: ScaleFactor // 4.
		rightVols at: i put: ScaleFactor // 4].

	"distribute inital panning of tracks left-to-right"
	totalVol _ 1.0.
	incr _ totalVol / (((trackCount // 2) + 1) * 2).
	curr _ 0.
	1 to: trackCount do: [:t |
		t even
			ifTrue: [pan _ curr]
			ifFalse: [
				curr _ curr + incr.
				pan _ totalVol - curr].
		self panForTrack: t put: pan].


]

{ #category : 'midi output' }
ScorePlayer >> openMIDIPort: portNum [
	"Open the given MIDI port. Music will be played as MIDI commands to the given MIDI port."

	midiPort _ SimpleMIDIPort openOnPortNumber: portNum.

]

{ #category : 'accessing' }
ScorePlayer >> overallVolume [

	^ overallVolume

]

{ #category : 'accessing' }
ScorePlayer >> overallVolume: aNumber [
	"Set the overally playback volume to a value between 0.0 (off) and 1.0 (full blast)."

	overallVolume _ (aNumber asFloat min: 1.0) max: 0.0.


]

{ #category : 'accessing' }
ScorePlayer >> panForTrack: i [

	| left right fullVol pan |
	left _ leftVols at: i.
	right _ rightVols at: i.
	left = right ifTrue: [^ 0.5].  "centered"
	fullVol _ left max: right.
	left < fullVol
		ifTrue: [pan _ left asFloat / (2.0 * fullVol)]
		ifFalse: [pan _ 1.0 - (right asFloat / (2.0 * fullVol))].
	^ pan roundTo: 0.001


]

{ #category : 'accessing' }
ScorePlayer >> panForTrack: trackIndex put: aNumber [
	"Set the left-right pan for this track to a value in the range [0.0..1.0], where 0.0 means full-left."

	| fullVol pan left right |
	trackIndex > leftVols size ifTrue: [^ self].
	fullVol _ (leftVols at: trackIndex) max: (rightVols at: trackIndex).
	pan _ (aNumber asFloat min: 1.0) max: 0.0.
	pan <= 0.5
		ifTrue: [  "attenuate right channel"
			left _ fullVol.
			right _ 2.0 * pan * fullVol]
		ifFalse: [  "attenuate left channel"
			left _ 2.0 * (1.0 - pan) * fullVol.
			right _ fullVol].
	rightVols at: trackIndex put: right asInteger.
	leftVols at: trackIndex put: left asInteger.

]

{ #category : 'operating' }
ScorePlayer >> pause [
	"Pause this sound. It can be resumed from this point, or reset and resumed to start from the beginning."

	super pause.
	activeSounds _ activeSounds species new.
	midiPort ifNotNil: [self stopMIDIPlaying].

]

{ #category : 'accessing' }
ScorePlayer >> positionInScore [

	^ self ticksSinceStart asFloat / (self durationInTicks max: 1)
]

{ #category : 'accessing' }
ScorePlayer >> positionInScore: pos [

	self isPlaying ifTrue: [^ self "ignore rude intrusion"].
	ticksSinceStart _ pos * durationInTicks.
	done _ false.


]

{ #category : 'copying' }
ScorePlayer >> postCopy [
	"Copy my component sounds."

	super postCopy.
	self copySounds

]

{ #category : 'sound generation' }
ScorePlayer >> processAllAtTick: scoreTick [

	self processTempoMapAtTick: scoreTick.
	midiPort
		ifNil: [self processNoteEventsAtTick: scoreTick]
		ifNotNil: [self processMIDIEventsAtTick: scoreTick].
	self isDone ifTrue: [
		repeat
			ifTrue: [self reset]
			ifFalse: [done _ true]].

]

{ #category : 'midi output' }
ScorePlayer >> processMIDIEventsAtTick: scoreTick [
	"Process note events through the given score tick using MIDI."

	| j evt |
	1 to: score tracks size do: [:i |
		j _ trackEventIndex at: i.
		[
			evt _ score eventForTrack: i after: j ticks: scoreTick.
			 evt notNil
		] whileTrue: [
			evt isNoteEvent
				ifTrue: [
					(muted at: i) ifFalse: [
						evt startNoteOnMidiPort: midiPort.
						activeMIDINotes add: (Array with: evt with: i)]]
				ifFalse: [evt outputOnMidiPort: midiPort].
			j _ j + 1.
			trackEventIndex at: i put: j]].
	self turnOffActiveMIDINotesAt: scoreTick.

]

{ #category : 'sound generation' }
ScorePlayer >> processNoteEventsAtTick: scoreTick [
	"Process note events through the given score tick using internal Squeak sound synthesis."

	| instr j evt snd |
	1 to: score tracks size do: [:i |
		instr _ instruments at: i.
		j _ trackEventIndex at: i.
		[
			evt _ score eventForTrack: i after: j ticks: scoreTick.
			evt notNil
		] whileTrue: [
			(evt isNoteEvent and: [(muted at: i) not]) ifTrue: [
				snd _ instr
					soundForMidiKey: evt midiKey
					dur: secsPerTick * evt duration
					loudness: evt velocity asFloat / 127.0.
				activeSounds add: (Array with: snd with: i)].
			j _ j + 1.
			trackEventIndex at: i put: j]].

]

{ #category : 'sound generation' }
ScorePlayer >> processTempoMapAtTick: scoreTick [
	"Process tempo changes through the given score tick."

	| map tempoChanged |
	map _ score tempoMap.
	map ifNil: [^ self].
	tempoChanged _ false.
	[(tempoMapIndex <= map size) and:
	 [(map at: tempoMapIndex) time <= scoreTick]] whileTrue: [
		tempoChanged _ true.
		tempoMapIndex _ tempoMapIndex + 1].

	tempoChanged ifTrue: [
		tempo _ (120.0 * (500000.0 / (map at: tempoMapIndex - 1) tempo)) roundTo: 0.01.
		self tempoOrRateChanged].


]

{ #category : 'accessing' }
ScorePlayer >> rate [

	^ rate

]

{ #category : 'accessing' }
ScorePlayer >> rate: aNumber [
	"Set the playback rate. For example, a rate of 2.0 will playback at twice normal speed."

	rate _ aNumber asFloat.
	self tempoOrRateChanged.

]

{ #category : 'accessing' }
ScorePlayer >> repeat [
	"Return true if this player will repeat when it gets to the end of the score, false otherwise."

	^ repeat

]

{ #category : 'accessing' }
ScorePlayer >> repeat: aBoolean [
	"Turn repeat mode on or off."

	repeat _ aBoolean.

]

{ #category : 'sound generation' }
ScorePlayer >> reset [

	super reset.
	tempo _ 120.0.
	self tempoOrRateChanged.
	done _ false.
	ticksSinceStart _ 0.
	"one index for each sound track, plus one for the ambient track..."
	trackEventIndex _ Array new: score tracks size+1 withAll: 1.
	tempoMapIndex _ 1.
	activeSounds _ OrderedCollection new.
	activeMIDINotes _ OrderedCollection new.
	overallVolume ifNil: [overallVolume _ 0.5].

]

{ #category : 'operating' }
ScorePlayer >> resumePlaying [
	"Resume playing. Start over if done."

	done ifTrue: [self reset].
	self jumpToTick: ticksSinceStart.  "Play up to here in case we got scrolled to new position."
	midiPort
		ifNil: [super resumePlaying]  "let the sound player drive sound generation" 
		ifNotNil: [self startMIDIPlaying].  "start a process to drive MIDI output"

]

{ #category : 'sound generation' }
ScorePlayer >> samplesRemaining [

	done
		ifTrue: [^ 0]
		ifFalse: [^ 1000000].

]

{ #category : 'accessing' }
ScorePlayer >> score [

	^ score

]

{ #category : 'accessing' }
ScorePlayer >> secsPerTick [

	^ secsPerTick
]

{ #category : 'accessing' }
ScorePlayer >> settingsString [

	| s |
	s _ WriteStream on: (String new: 1000).
	s nextPutAll: 'player'; newLine.
	s tab; nextPutAll: 'rate: ', self rate printString, ';'; newLine.
	s tab; nextPutAll: 'overallVolume: ', self overallVolume printString, ';'; newLine.
	1 to: self trackCount do: [:t |
		s tab; nextPutAll: 'instrumentForTrack: ', t printString,
			' put: (AbstractSound soundNamed: #default);'; newLine.
		s tab; nextPutAll: 'mutedForTrack: ', t printString,
			' put: ', (self mutedForTrack: t) printString, ';'; newLine.
		s tab; nextPutAll: 'volumeForTrack: ', t printString,
			' put: ', (self volumeForTrack: t) printString, ';'; newLine.
		s tab; nextPutAll: 'panForTrack: ', t printString,
			' put: ', (self panForTrack: t) printString, ';'; newLine].
	s tab; nextPutAll: 'repeat: ', self repeat printString, '.'; newLine.
	^ s contents

]

{ #category : 'sound generation' }
ScorePlayer >> skipNoteEventsThruTick: startTick [
	"Skip note events through the given score tick using internal Squeak sound synthesis."

	| j evt |
	1 to: score tracks size do: [:i |
		j _ trackEventIndex at: i.
		[evt _ score eventForTrack: i after: j ticks: startTick.
		 evt == nil] whileFalse: [
			evt isNoteEvent
				ifTrue: [
					(((evt time + evt duration) > startTick) and: [(muted at: i) not]) ifTrue: [
						self startNote: evt forStartTick: startTick trackIndex: i]]
				ifFalse: [
					midiPort ifNotNil: [evt outputOnMidiPort: midiPort]].
			j _ j + 1].
		trackEventIndex at: i put: j].

]

{ #category : 'midi output' }
ScorePlayer >> startMIDIPlaying [
	"Start up a process to play this score via MIDI."

	midiPort ensureOpen.
	midiPlayerProcess ifNotNil: [midiPlayerProcess terminate].
	midiPlayerProcess _ [self midiPlayLoop] newProcess.
	midiPlayerProcess
		priority: Processor userInterruptPriority;
		name: 'ScorePlayer';
		resume.

]

{ #category : 'sound generation' }
ScorePlayer >> startNote: noteEvent forStartTick: startTick trackIndex: trackIndex [
	"Prepare a note to begin playing at the given tick. Used to start playing at an arbitrary point in the score. Handle both MIDI and built-in synthesis cases."

	| snd |
	midiPort
		ifNil: [
			snd _ (instruments at: trackIndex)
				soundForMidiKey: noteEvent midiKey
				dur: secsPerTick * (noteEvent endTime - startTick)
				loudness: noteEvent velocity asFloat / 127.0.
			activeSounds add: (Array with: snd with: trackIndex)]
		ifNotNil: [
			noteEvent startNoteOnMidiPort: midiPort.
			activeMIDINotes add: (Array with: noteEvent with: trackIndex)].

]

{ #category : 'midi output' }
ScorePlayer >> stopMIDIPlaying [
	"Terminate the MIDI player process and turn off any active notes."

	midiPlayerProcess ifNotNil: [midiPlayerProcess terminate].
	midiPlayerProcess _ nil.
	activeMIDINotes do: [:pair | pair first endNoteOnMidiPort: midiPort].
	activeMIDINotes _ activeMIDINotes species new.

]

{ #category : 'accessing' }
ScorePlayer >> tempo [
	"Return the current tempo in beats (quarter notes) per minute. The tempo at any given moment is defined by the score and cannot be changed by the client. To change the playback speed, the client may change the rate parameter."

	^ tempo

]

{ #category : 'operating' }
ScorePlayer >> tempoOrRateChanged [
	"This method should be called after changing the tempo or rate."

	secsPerTick _ 60.0 / (tempo * rate * score ticksPerQuarterNote).
	ticksClockIncr _ (1.0 / self controlRate) / secsPerTick.

]

{ #category : 'accessing' }
ScorePlayer >> ticksForMSecs: mSecs [

	^ (mSecs asFloat / (1000.0 * secsPerTick)) rounded

]

{ #category : 'accessing' }
ScorePlayer >> ticksSinceStart [
	"Answer the number of score ticks that have elapsed since this piece started playing. The duration of a tick is determined by the MIDI score."

	^ ticksSinceStart

]

{ #category : 'accessing' }
ScorePlayer >> ticksSinceStart: newTicks [
	"Adjust ticks to folow, eg, piano roll autoscrolling"

	self isPlaying ifFalse: [ticksSinceStart _ newTicks]

]

{ #category : 'accessing' }
ScorePlayer >> trackCount [

	^ score tracks size

]

{ #category : 'midi output' }
ScorePlayer >> turnOffActiveMIDINotesAt: scoreTick [
	"Turn off any active MIDI notes that should be turned off at the given score tick."

	| evt someNoteEnded |
	midiPort ifNil: [^ self].
	someNoteEnded _ false. 
	activeMIDINotes do: [:pair |
		evt _ pair first.
		evt endTime <= scoreTick ifTrue: [
			evt endNoteOnMidiPort: midiPort.
			someNoteEnded _ true]].

	someNoteEnded ifTrue: [
		activeMIDINotes _ activeMIDINotes select: [:p | p first endTime > scoreTick]].

]

{ #category : 'initialization' }
ScorePlayer >> updateDuration [

	durationInTicks _ score durationInTicks.

]

{ #category : 'accessing' }
ScorePlayer >> volumeForTrack: i [

	| vol |
	vol _ (leftVols at: i) max: (rightVols at: i).
	^ (vol asFloat / ScaleFactor) roundTo: 0.0001

]

{ #category : 'accessing' }
ScorePlayer >> volumeForTrack: trackIndex put: aNumber [

	| newVol oldLeft oldRight oldFullVol left right |
	trackIndex > leftVols size ifTrue: [^ self].
	newVol _ ((aNumber asFloat max: 0.0) min: 1.0) * ScaleFactor.
	oldLeft _ leftVols at: trackIndex.
	oldRight _ rightVols at: trackIndex.
	oldFullVol _ oldLeft max: oldRight.
	oldFullVol = 0 ifTrue: [oldFullVol _ 1.0].
	oldLeft < oldFullVol
		ifTrue: [
			left _ newVol * oldLeft / oldFullVol.
			right _ newVol]
		ifFalse: [
			left _ newVol.
			right _ newVol * oldRight / oldFullVol].
	leftVols at: trackIndex put: left asInteger.
	rightVols at: trackIndex put: right asInteger.

]
