Extension { #name : 'Time' }

{ #category : '*Network-Kernel' }
Time class >> milliseconds: currentTime since: lastTime [
	"Answer the elapsed time since last recorded in milliseconds (i.e. of millisecondClockValue).
	 Since the time basis is now a 61-bit or greater UTC microsecond clock, rollover is no longer an issue."

	^currentTime - lastTime
]

{ #category : '*Network-Kernel' }
Time class >> millisecondsSince: lastTime [
	"Answer the elapsed time since last recorded in milliseconds.
	Compensate for rollover."

	^self milliseconds: self millisecondClockValue since: lastTime

]

{ #category : '*Network-Kernel' }
Time class >> utcMicrosecondClock [
	"Answer the UTC microseconds since the Smalltalk epoch (January 1st 1901, the start of the 20th century).
	 The value is derived from the Posix epoch with a constant offset corresponding to elapsed microseconds
	 between the two epochs according to RFC 868."
	<primitive: 240>
	^0
]
