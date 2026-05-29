"
A MIDIScore is a container for a number of MIDI tracks as well as an ambient track for such things as sounds, book page triggers and other related events.
"
Class {
	#name : 'MIDIScore',
	#superclass : 'Object',
	#instVars : [
		'tracks',
		'trackInfo',
		'tempoMap',
		'ticksPerQuarterNote'
	],
	#category : 'Sound-Scores',
	#package : 'Sound',
	#tag : 'Scores'
}

{ #category : 'editing' }
MIDIScore >> appendEvent: noteEvent fullDuration: fullDuration at: selection [
	"It is assumed that the noteEvent already has the proper time"

	| track noteLoc |
	track _ tracks at: selection first.
	noteLoc _ selection third + 1.
	noteEvent midiKey = -1
		ifTrue: [noteLoc _ noteLoc - 1]
		ifFalse: ["If not a rest..."
				track _ track copyReplaceFrom: noteLoc to: noteLoc - 1
								with: (Array with: noteEvent)].
	track size >= (noteLoc + 1) ifTrue:
		["Adjust times of following events"
		noteLoc + 1 to: track size do:
			[:i | (track at: i) adjustTimeBy: fullDuration]].
	tracks at: selection first put: track
]

{ #category : 'editing' }
MIDIScore >> cutSelection: selection [

	| track selStartTime delta |
	track _ tracks at: selection first.
	selStartTime _ (track at: selection second) time.
	track _ track copyReplaceFrom: selection second to: selection third with: Array new.
	track size >=  selection second ifTrue:
		["Adjust times of following events"
		delta _ selStartTime - (track at: selection second) time.
		selection second to: track size do:
			[:i | (track at: i) adjustTimeBy: delta]].
	tracks at: selection first put: track
]

{ #category : 'nil' }
MIDIScore >> durationInTicks [
	
	| t |
	t _ 0.
	tracks do: [ :track |
		track do:
			[:n | (n isNoteEvent)
				ifTrue: [t _ t max: n endTime]
				ifFalse: [t _ t max: n time]]].
	^ t

]

{ #category : 'editing' }
MIDIScore >> eventForTrack: trackIndex after: eventIndex ticks: scoreTick [

	| track evt |
	track _ tracks at: trackIndex.
	eventIndex > track size ifTrue: [^ nil].
	evt _ track at: eventIndex.
	evt time > scoreTick ifTrue: [^ nil].
	^ evt

]

{ #category : 'editing' }
MIDIScore >> gridToNextQuarterNote: tickTime [

	^ self gridToQuarterNote: tickTime + ticksPerQuarterNote
]

{ #category : 'editing' }
MIDIScore >> gridToQuarterNote: tickTime [

	^ tickTime truncateTo: ticksPerQuarterNote
]

{ #category : 'editing' }
MIDIScore >> gridTrack: trackIndex toQuarter: quarterDelta at: indexInTrack [

	| track selStartTime delta |
	track _ tracks at: trackIndex.
	selStartTime _ (track at: indexInTrack) time.
	delta _ (self gridToQuarterNote: selStartTime + (quarterDelta*ticksPerQuarterNote))
				- selStartTime.
	indexInTrack to: track size do:
		[:i | (track at: i) adjustTimeBy: delta].

]

{ #category : 'initialization' }
MIDIScore >> initialize [

	tracks _ #().
	tempoMap _ #().
	ticksPerQuarterNote _ 100.

]

{ #category : 'editing' }
MIDIScore >> insertEvents: events at: selection [

	| track selStartTime delta |
	track _ tracks at: selection first.
	selection second = 0
		ifTrue: [selStartTime _ 0.
				selection at: 2 put: 1]
		ifFalse: [selStartTime _ (track at: selection second) time].
	track _ track copyReplaceFrom: selection second to: selection second - 1
				with: (events collect: [:e | e copy]).
	track size >=  (selection second + events size) ifTrue:
		["Adjust times of following events"
		delta _ selStartTime - (track at: selection second) time.
		selection second to: selection second + events size - 1 do:
			[:i | (track at: i) adjustTimeBy: delta].
		delta _ (self gridToNextQuarterNote: (track at: selection second + events size - 1) endTime)
					- (track at: selection second + events size) time.
		selection second + events size to: track size do:
			[:i | (track at: i) adjustTimeBy: delta].
		].
	tracks at: selection first put: track
]

{ #category : 'editing' }
MIDIScore >> jitterStartAndEndTimesBy: mSecs [

	| r range halfRange oldEnd newEnd newStart |
	r _ Random new.
	range _ 2.0 * mSecs.
	halfRange _ mSecs.
	tracks do: [:t |
		t do: [:e |
			e isNoteEvent ifTrue: [
				oldEnd _ e time + e duration.
				newEnd _ oldEnd + ((r next * range) asInteger - halfRange).
				newStart _ e time + ((r next * range) asInteger - halfRange).
				e time: newStart.
				e duration: (newEnd - newStart)]]].

				
]

{ #category : 'accessing' }
MIDIScore >> tempoMap [

	^ tempoMap

]

{ #category : 'accessing' }
MIDIScore >> tempoMap: tempoEventList [

	tempoEventList ifNil: [
		tempoMap _ #().
		^ self].
	tempoMap _ tempoEventList asArray.

]

{ #category : 'accessing' }
MIDIScore >> ticksPerQuarterNote [

	^ ticksPerQuarterNote

]

{ #category : 'accessing' }
MIDIScore >> ticksPerQuarterNote: anInteger [

	ticksPerQuarterNote _ anInteger.

]

{ #category : 'accessing' }
MIDIScore >> trackInfo [

	^ trackInfo ifNil: [tracks collect: [:i | String new]]

]

{ #category : 'accessing' }
MIDIScore >> trackInfo: trackInfoList [

	trackInfo _ trackInfoList asArray.

]

{ #category : 'accessing' }
MIDIScore >> tracks [

	^ tracks

]

{ #category : 'accessing' }
MIDIScore >> tracks: trackList [

	tracks _ trackList asArray collect: [:trackEvents | trackEvents asArray]
]
