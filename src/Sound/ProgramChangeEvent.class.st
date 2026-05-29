Class {
	#name : 'ProgramChangeEvent',
	#superclass : 'AbstractScoreEvent',
	#instVars : [
		'program',
		'channel'
	],
	#category : 'Sound-Scores',
	#package : 'Sound',
	#tag : 'Scores'
}

{ #category : 'accessing' }
ProgramChangeEvent >> channel [

	^ channel

]

{ #category : 'accessing' }
ProgramChangeEvent >> channel: midiChannel [

	channel _ midiChannel.

]

{ #category : 'classification' }
ProgramChangeEvent >> isProgramChange [

	^ true

]

{ #category : 'midi' }
ProgramChangeEvent >> outputOnMidiPort: aMidiPort [
	"Output this event to the given MIDI port."

	aMidiPort
		midiCmd: 16rC0
		channel: channel
		byte: program.

]

{ #category : 'printing' }
ProgramChangeEvent >> printOn: aStream [

	aStream nextPut: $(.
	time printOn: aStream.
	aStream nextPutAll: ': prog '.
	program printOn: aStream.
	aStream nextPut: $).

]

{ #category : 'accessing' }
ProgramChangeEvent >> program [

	^ program

]

{ #category : 'accessing' }
ProgramChangeEvent >> program: midiProgramChange [

	program _ midiProgramChange.

]

{ #category : 'accessing' }
ProgramChangeEvent >> program: midiProgramChange channel: midiChannel [

	program _ midiProgramChange.
	channel _ midiChannel.

]
