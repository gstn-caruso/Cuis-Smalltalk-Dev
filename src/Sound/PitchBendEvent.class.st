Class {
	#name : 'PitchBendEvent',
	#superclass : 'AbstractScoreEvent',
	#instVars : [
		'bend',
		'channel'
	],
	#category : 'Sound-Scores',
	#package : 'Sound',
	#tag : 'Scores'
}

{ #category : 'accessing' }
PitchBendEvent >> bend [

	^ bend

]

{ #category : 'accessing' }
PitchBendEvent >> bend: midiPitchBend [

	bend _ midiPitchBend.

]

{ #category : 'accessing' }
PitchBendEvent >> bend: midiPitchBend channel: midiChannel [

	bend _ midiPitchBend.
	channel _ midiChannel.

]

{ #category : 'accessing' }
PitchBendEvent >> channel [

	^ channel

]

{ #category : 'accessing' }
PitchBendEvent >> channel: midiChannel [

	channel _ midiChannel.

]

{ #category : 'classification' }
PitchBendEvent >> isPitchBend [

	^ true

]

{ #category : 'midi' }
PitchBendEvent >> outputOnMidiPort: aMidiPort [
	"Output this event to the given MIDI port."

	aMidiPort
		midiCmd: 16rE0
		channel: channel
		byte: (bend bitAnd: 16r7F)
		byte: (bend bitShift: -7).

]

{ #category : 'printing' }
PitchBendEvent >> printOn: aStream [

	aStream nextPut: $(.
	time printOn: aStream.
	aStream nextPutAll: ': bend '.
	bend printOn: aStream.
	aStream nextPut: $).

]
