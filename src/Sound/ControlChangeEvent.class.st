Class {
	#name : 'ControlChangeEvent',
	#superclass : 'AbstractScoreEvent',
	#instVars : [
		'control',
		'value',
		'channel'
	],
	#category : 'Sound-Scores',
	#package : 'Sound',
	#tag : 'Scores'
}

{ #category : 'accessing' }
ControlChangeEvent >> channel [

	^ channel

]

{ #category : 'accessing' }
ControlChangeEvent >> channel: midiChannel [

	channel _ midiChannel.

]

{ #category : 'accessing' }
ControlChangeEvent >> control [

	^ control

]

{ #category : 'accessing' }
ControlChangeEvent >> control: midiControl [

	control _ midiControl.

]

{ #category : 'accessing' }
ControlChangeEvent >> control: midiControl value: midiControlValue channel: midiChannel [

	control _ midiControl.
	value _ midiControlValue.
	channel _ midiChannel.

]

{ #category : 'classification' }
ControlChangeEvent >> isControlChange [

	^ true

]

{ #category : 'midi' }
ControlChangeEvent >> outputOnMidiPort: aMidiPort [
	"Output this event to the given MIDI port."

	aMidiPort
		midiCmd: 16rB0
		channel: channel
		byte: control
		byte: value.

]

{ #category : 'printing' }
ControlChangeEvent >> printOn: aStream [
	aStream
		nextPut: $(;
		print: time;
		nextPutAll: ': ctrl[';
		print: control;
		nextPutAll: ']=';
		print: value;
		nextPut: $)
]

{ #category : 'accessing' }
ControlChangeEvent >> value [

	^ value

]

{ #category : 'accessing' }
ControlChangeEvent >> value: midiControlValue [

	value _ midiControlValue.

]
