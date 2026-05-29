"
An envelope models a three-stage progression for a musical note: attack, sustain, decay. Envelopes can either return the envelope value at a given time or can update some target object using a client-specified message selector.

The points instance variable holds an array of (time, value) points, where the times are in milliseconds. The points array must contain at least two points. The time coordinate of the first point must be zero and the time coordinates of subsequent points must be in ascending order, although the spacing between them is arbitrary. Envelope values between points are computed by linear interpolation.

The scale slot is initially set so that the peak of envelope matches some note attribute, such as its loudness. When entering the decay phase, the scale is adjusted so that the decay begins from the envelope's current value. This avoids a potential sharp transient when entering the decay phase.

The loopStartIndex and loopEndIndex slots contain the indices of points in the points array; if they are equal, then the envelope holds a constant value for the sustain phase of the note. Otherwise, envelope values are computed by repeatedly looping between these two points.

The loopEndMSecs slot can be set in advance (as when playing a score) or dynamically (as when responding to interactive inputs from a MIDI keyboard). In the latter case, the value of scale is adjusted to start the decay phase with the current envelope value. Thus, if a note ends before its attack is complete, the decay phase is started immediately (i.e., the attack phase is never completed).

For best results, amplitude envelopes should start and end with zero values. Otherwise, the sharp transient at the beginning or end of the note may cause audible clicks or static. For envelopes on other parameters, this may not be necessary.

"
Class {
	#name : 'Envelope',
	#superclass : 'Object',
	#instVars : [
		'points',
		'loopStartIndex',
		'loopEndIndex',
		'loopStartMSecs',
		'loopMSecs',
		'target',
		'updateSelector',
		'loopEndMSecs',
		'endMSecs',
		'scale',
		'decayScale',
		'lastValue',
		'currValue',
		'valueIncr',
		'nextRecomputeTime',
		'noChangesDuringLoop'
	],
	#category : 'Sound-Synthesis',
	#package : 'Sound',
	#tag : 'Synthesis'
}

{ #category : 'instance creation' }
Envelope class >> example [
	"Envelope example showOnDisplay"

	| p |
	p _ Array with: 0@0 with: 100@1.0 with: 250@0.7 with: 400@1.0 with: 500@0.
	^ (self points: p loopStart: 2 loopEnd: 4) sustainEnd: 1200.

]

{ #category : 'instance creation' }
Envelope class >> exponentialDecay: multiplier [
	"(Envelope exponentialDecay: 0.95) showOnDisplay"

	| mSecsPerStep pList t v last |
	mSecsPerStep _ 10.
	((multiplier > 0.0) and: [multiplier < 1.0])
		ifFalse: [self error: 'multiplier must be greater than 0.0 and less than 1.0'].
	pList _ OrderedCollection new.
	pList add: 0@0.0.
	last _ 0.0.
	v _ 1.0.
	t _ 10.
	[v > 0.01] whileTrue: [
		(v - last) abs > 0.02 ifTrue: [
			"only record substatial changes"
			pList add: t@v.
			last _ v].
		t _ t + mSecsPerStep.
		v _ v * multiplier].
	pList add: (t + mSecsPerStep)@0.0.

	^ self points: pList asArray
		loopStart: pList size 
		loopEnd: pList size

]

{ #category : 'instance creation' }
Envelope class >> points: pList loopStart: loopStart loopEnd: loopEnd [

	^ self new setPoints: pList asArray
		loopStart: loopStart
		loopEnd: loopEnd

]

{ #category : 'accessing' }
Envelope >> attackTime [
	"Return the time taken by the attack phase."

	^ (points at: loopStartIndex) x

]

{ #category : 'accessing' }
Envelope >> centerPitch: aNumber [
	"Set the center pitch of a pitch-controlling envelope. This default implementation does nothing."

]

{ #category : 'private' }
Envelope >> checkParameters [
	"Verify that the point array, loopStartIndex, and loopStopIndex obey the rules."

	| lastT t |
	points size > 1
		ifFalse: [^ self error: 'the point list must contain at least two points'].
	points first x = 0
		ifFalse: [^ self error: 'the time of the first point must be zero'].
	lastT _ points first x.
	2 to: points size do: [:i |
		t _ (points at: i) x.
		t >= lastT
			ifFalse: [^ self error: 'the points must be in ascending time order']].

	(loopStartIndex isInteger and:
	 [(loopStartIndex > 0) and: [loopStartIndex <= points size]])
		ifFalse: [^ self error: 'loopStartIndex is not a valid point index'].
	(loopEndIndex isInteger and:
	 [(loopEndIndex > 0) and: [loopEndIndex <= points size]])
		ifFalse: [^ self error: 'loopEndIndex is not a valid point index'].
	 loopStartIndex <= loopEndIndex
		ifFalse: [^ self error: 'loopEndIndex must not precede loopStartIndex'].

]

{ #category : 'private' }
Envelope >> computeIncrementAt: mSecs between: p1 and: p2 scale: combinedScale [
	"Compute the current and increment values for the given time between the given inflection points."
	"Assume: p1 x <= mSecs <= p2 x"

	| valueRange timeRange |
	valueRange _ (p2 y - p1 y) asFloat.
	timeRange _ (p2 x - p1 x) asFloat.
	currValue _ (p1 y + (((mSecs - p1 x) asFloat / timeRange) * valueRange)) * combinedScale.
	valueIncr _ (((p2 y * combinedScale) - currValue) / (p2 x - mSecs)) * 10.0.
	^ currValue

]

{ #category : 'applying' }
Envelope >> computeValueAtMSecs: mSecs [
	"Return the value of this envelope at the given number of milliseconds from its onset. Return zero for times outside the time range of this envelope."
	"Note: Unlike the private method incrementalComputeValueAtMSecs:, this method does is not increment. Thus it is slower, but it doesn't depend on being called sequentially at fixed time intervals."

	| t i |
	mSecs < 0 ifTrue: [^ 0.0].

	(loopEndMSecs notNil and: [mSecs >= loopEndMSecs]) ifTrue: [  "decay phase"
		t _ (points at: loopEndIndex) x + (mSecs - loopEndMSecs).
		i _ self indexOfPointAfterMSecs: t startingAt: loopEndIndex.
		i ifNil: [^ 0.0].  "past end"
		^ (self interpolate: t between: (points at: i - 1) and: (points at: i)) * decayScale].

	mSecs < loopStartMSecs ifTrue: [  "attack phase"
		i _ self indexOfPointAfterMSecs: mSecs startingAt: 1.
		i = 1 ifTrue: [^ (points at: 1) y * scale].
		^ self interpolate: mSecs between: (points at: i - 1) and: (points at: i)].

	"sustain phase"
	loopMSecs = 0 ifTrue: [^ (points at: loopEndIndex) y * scale].  "looping on a single point"
	t _ loopStartMSecs + ((mSecs - loopStartMSecs) \\ loopMSecs).
	i _ self indexOfPointAfterMSecs: t startingAt: loopStartIndex.

	^ self interpolate: t between: (points at: i - 1) and: (points at: i)

]

{ #category : 'accessing' }
Envelope >> decayEndIndex [

	^ points size

]

{ #category : 'accessing' }
Envelope >> decayTime [
	"Return the time taken by the decay phase."

	^ points last x - (points at: loopEndIndex) x

]

{ #category : 'accessing' }
Envelope >> duration [
	"Return the time of the final point."

	loopEndMSecs
		ifNil: [^ points last x].
	^ loopEndMSecs + self decayTime

]

{ #category : 'accessing' }
Envelope >> duration: seconds [
	"Set the note duration to the given number of seconds."
	"Details: The duration is reduced by 19 mSec to ensure proper cutoffs even when the sound starts playing between doControl epochs."
	"Note: This is a hack. With a little additional work on the envelope logic, it should be possible to reduce or eliminate this fudge factor. In particular, an envelope should use the time remaining, rather than time-since-start to determine when to enter its decay phase. In addition, an envelope must be able to cut off in minimum time (~5-10 msec) if there isn't enough time to do their normal decay. All of this is to allow instruments with leisurely decays to play very short notes if necessary (say, when fast-forwarding through a score)." 

	| attack decay endTime |
	endMSecs _ (seconds * 1000.0) asInteger - 19.
	attack _ self attackTime.
	decay _ self decayTime.
	endMSecs > (attack + decay)
		ifTrue: [endTime _ endMSecs - decay]
		ifFalse: [
			endMSecs >= attack
				ifTrue: [endTime _ attack]
				ifFalse: [endTime _ endMSecs]].

	self sustainEnd: (endTime max: 0).

]

{ #category : 'private' }
Envelope >> incrementalComputeValueAtMSecs: mSecs [
	"Compute the current value, per-step increment, and the time of the next inflection point."
	"Note: This method is part of faster, but less general, way of computing envelope values. It depends on a known, fixed control updating rate."

	| t i |
	(loopEndMSecs notNil and: [mSecs >= loopEndMSecs]) ifTrue: [  "decay phase"
		t _ (points at: loopEndIndex) x + (mSecs - loopEndMSecs).
		i _ self indexOfPointAfterMSecs: t startingAt: loopEndIndex.
		i ifNil: [  "past end"
			currValue _ points last y * scale * decayScale.
			valueIncr _ 0.0.
			nextRecomputeTime _ mSecs + 1000000.
			^ currValue].
		nextRecomputeTime _ mSecs + ((points at: i) x - t).
		^ self computeIncrementAt: t
			between: (points at: i - 1)
			and: (points at: i)
			scale: scale * decayScale].

	mSecs < loopStartMSecs
		ifTrue: [  "attack phase"
			t _ mSecs.
			i _ self indexOfPointAfterMSecs: t startingAt: 1.
			nextRecomputeTime _ mSecs + ((points at: i) x - t)]
		ifFalse: [  "sustain (looping) phase"
			noChangesDuringLoop ifTrue: [
				currValue _ (points at: loopEndIndex) y * scale.
				valueIncr _ 0.0.
					loopEndMSecs
						ifNil: [nextRecomputeTime _ mSecs + 10]	 "unknown end time"
						ifNotNil: [nextRecomputeTime _ loopEndMSecs].
				^ currValue].
			t _ loopStartMSecs + ((mSecs - loopStartMSecs) \\ loopMSecs).
			i _ self indexOfPointAfterMSecs: t startingAt: loopStartIndex.
			nextRecomputeTime _ (mSecs + ((points at: i) x - t)) min: loopEndMSecs].

	^ self computeIncrementAt: t
		between: (points at: i - 1)
		and: (points at: i)
		scale: scale.

]

{ #category : 'private' }
Envelope >> indexOfPointAfterMSecs: mSecs startingAt: startIndex [
	"Return the index of the first point whose time is greater that mSecs, starting with the given index. Return nil if mSecs is after the last point's time."

	startIndex to: points size do:
		[:i | (points at: i) x > mSecs ifTrue: [^ i]].
	^ nil

]

{ #category : 'private' }
Envelope >> interpolate: mSecs between: p1 and: p2 [
	"Return the scaled, interpolated value for the given time between the given time points."
	"Assume: p1 x <= mSecs <= p2 x"

	| valueRange timeRange |
	valueRange _ (p2 y - p1 y) asFloat.
	valueRange = 0.0 ifTrue: [^ p1 y * scale].
	timeRange _ (p2 x - p1 x) asFloat.
	^ (p1 y + (((mSecs - p1 x) asFloat / timeRange) * valueRange)) * scale.

]

{ #category : 'accessing' }
Envelope >> loopEndIndex [

	^ loopEndIndex

]

{ #category : 'accessing' }
Envelope >> loopStartIndex [

	^ loopStartIndex

]

{ #category : 'accessing' }
Envelope >> name [

	^ self updateSelector allButLast

]

{ #category : 'accessing' }
Envelope >> points [

	^ points

]

{ #category : 'applying' }
Envelope >> reset [
	"Reset the state for this envelope."

	lastValue _ -100000.0.  "impossible value"
	nextRecomputeTime _ 0.
	self updateTargetAt: 0.

]

{ #category : 'accessing' }
Envelope >> scale: aNumber [

	scale _ aNumber asFloat.

]

{ #category : 'private' }
Envelope >> setPoints: pointList loopStart: startIndex loopEnd: endIndex [

	| lastVal |
	points _ pointList asArray collect: [:p | p x asInteger @ p y asFloat].
	loopStartIndex _ startIndex.
	loopEndIndex _ endIndex.
	self checkParameters.
	loopStartMSecs _ (points at: loopStartIndex) x.
	loopMSecs _ (points at: loopEndIndex) x - (points at: loopStartIndex) x.
	loopEndMSecs _ nil.  "unknown end time; sustain until end time is known"
	scale ifNil: [scale _ 1.0].
	decayScale ifNil: [decayScale _ 1.0].

	"note if there are no changes during the loop phase"
	noChangesDuringLoop _ true.
	lastVal _ (points at: loopStartIndex) y.
	loopStartIndex to: loopEndIndex do: [:i | 
		(points at: i) y ~= lastVal ifTrue: [
			noChangesDuringLoop _ false.
			^ self]].

]

{ #category : 'applying' }
Envelope >> showOnDisplay [
	"Envelope example showOnDisplay"

	| xOrigin yOrigin minVal maxVal yScale step x v y |
	xOrigin _ 30.
	yOrigin _ 130.
	minVal _ 1e100.
	maxVal _ -1e100.
	points do: [:p |
		p y < minVal ifTrue: [minVal _ p y].
		p y > maxVal ifTrue: [maxVal _ p y]].

	yScale _ 100.0 / ((maxVal - minVal) * scale).
	step _ (self duration // 150) max: 1.

	Display fillBlack: ((xOrigin + ((points at: loopStartIndex) x // step))@(yOrigin - 100) extent: 1@100).
	Display fillBlack: ((xOrigin + ((points at: loopEndIndex) x // step))@(yOrigin - 100) extent: 1@100).
	Display fillBlack: (xOrigin@(yOrigin - 100) extent: 1@100).
	x _ xOrigin.
	step negated to: self duration + step by: step do: [:mSecs |
		v _ self computeValueAtMSecs: mSecs.
		y _ yOrigin - ((v - minVal) * yScale) asInteger.
		Display fillBlack: ((x - 1)@(y - 1) extent: 2@2).
		Display fillBlack: (x@yOrigin extent: 1@1).
		x _ x + 1].

]

{ #category : 'storing' }
Envelope >> storeOn: strm [
	strm nextPutAll: '((' , self class name;
		nextPutAll: ' points: '; store: (points collect: [:p | p x @ (p y roundTo: 0.00001)]);
		nextPutAll: ' loopStart: '; print: loopStartIndex;
		nextPutAll: ' loopEnd: '; print: loopEndIndex; nextPutAll: ')';
		nextPutAll: ' updateSelector: '; store: self updateSelector; nextPutAll: ';';
		nextPutAll: ' scale: '; print: scale; nextPutAll: ')'.

]

{ #category : 'applying' }
Envelope >> sustainEnd: mSecs [
	"Set the ending time of the sustain phase of this envelope; the decay phase will start this point. Typically derived from a note's duration."
	"Details: to avoid a sharp transient, the decay phase is scaled so that the beginning of the decay matches the envelope's instantaneous value when the decay phase starts."

	| vIfSustaining firstVOfDecay |
	loopEndMSecs _ nil. "pretend to be sustaining"
	decayScale _ 1.0.
	nextRecomputeTime _ 0.
	vIfSustaining _ self computeValueAtMSecs: mSecs.  "get value at end of sustain phase"
	loopEndMSecs _ mSecs.
	firstVOfDecay _ (points at: loopEndIndex) y * scale.
	firstVOfDecay = 0.0
		ifTrue: [decayScale _ 1.0]
		ifFalse: [decayScale _ vIfSustaining / firstVOfDecay].

]

{ #category : 'accessing' }
Envelope >> target [

	^ target

]

{ #category : 'accessing' }
Envelope >> target: anObject [

	target _ anObject.

]

{ #category : 'accessing' }
Envelope >> updateSelector [

	^ updateSelector

]

{ #category : 'accessing' }
Envelope >> updateSelector: aSymbol [

	updateSelector _ aSymbol.

]

{ #category : 'applying' }
Envelope >> updateTargetAt: mSecs [
	"Send my updateSelector to the given target object with the value of this envelope at the given number of milliseconds from its onset. Answer true if the value changed."

	| newValue |
	newValue _ self valueAtMSecs: mSecs.
	newValue = lastValue ifTrue: [^ false].
	target
		perform: updateSelector
		with: newValue.
	lastValue _ newValue.
	^ true

]

{ #category : 'applying' }
Envelope >> valueAtMSecs: mSecs [
	"Return the value of this envelope at the given number of milliseconds from its onset. Return zero for times outside the time range of this envelope."

	mSecs < 0 ifTrue: [^ 0.0].
	mSecs < nextRecomputeTime
		ifTrue: [currValue _ currValue + valueIncr]
		ifFalse: [currValue _ self incrementalComputeValueAtMSecs: mSecs].
	^ currValue

]

{ #category : 'accessing' }
Envelope >> volume: aNumber [
	"Set the maximum volume of a volume-controlling envelope. This default implementation does nothing."

]
