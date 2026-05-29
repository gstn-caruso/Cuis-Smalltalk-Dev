"
I represent a month.
"
Class {
	#name : 'Month',
	#superclass : 'Timespan',
	#category : 'Kernel-Chronology',
	#package : 'Kernel',
	#tag : 'Chronology'
}

{ #category : 'inquiries' }
Month class >> classDefinesDuration [

	^true
]

{ #category : 'inquiries' }
Month class >> daysInMonth [
	^#(31 28 31 30 31 30 31 31 30 31 30 31)
]

{ #category : 'smalltalk-80' }
Month class >> daysInMonth: indexOrName forYear: yearInteger  [

	| index |
	index := indexOrName isInteger 
				ifTrue: [indexOrName]
				ifFalse: [self indexOfMonth: indexOrName].
	^ (self daysInMonth at: index)
			+ ((index = 2
					and: [Year isLeapYear: yearInteger])
						ifTrue: [1] ifFalse: [0])
]

{ #category : 'squeak protocol' }
Month class >> includingDateAndTime: aDateAndTime [
	"Months start at day 1"
	| monthStart days |
	monthStart := DateAndTime
				year: aDateAndTime yearNumber
				month: aDateAndTime monthIndex
				day: 1.
	days := self daysInMonth: monthStart monthIndex forYear: monthStart yearNumber.
	^ self basicNew
 		start: monthStart;
		duration: (Duration days: days);
		yourself
]

{ #category : 'smalltalk-80' }
Month class >> indexOfMonth: aMonthName [


	1 to: 12 do: [ :i |  (aMonthName, '*' match: (self monthNames at: i)) ifTrue: [^i] ].
	self error: aMonthName , ' is not a recognized month name'
]

{ #category : 'squeak protocol' }
Month class >> month: month year: year [
	"Create a Month for the given <year> and <month>.
	<month> may be a number or a String with the
	name of the month. <year> should be with 4 digits."

	^ self including: (DateAndTime year: year month: month day: 1)

]

{ #category : 'inquiries' }
Month class >> monthNames [
	^#(January February March April May June July August September October November December)
]

{ #category : 'inquiries' }
Month class >> mustEncompassWholeDates [

	^true
]

{ #category : 'smalltalk-80' }
Month class >> nameOfMonth: anIndex [

	^ self monthNames at: anIndex
]

{ #category : 'instance creation' }
Month class >> readFrom: aStream [
	"Read a Date from the stream in any of the forms:
		<year>-<month>			(1982-04) (ISO8601)
		<month>-<year>			(04-1982) (Only if second argument has 3 or more characters)
		<monthName> <year>		(April, 1982; April 1982; APR-82; APR82)
		<year> <monthName>		(1982, April; 1982 April; etc)"

	| firstAsNumber firstAsNumberSign second secondLength secondStart |
	firstAsNumberSign := aStream peek == $- ifTrue: [-1] ifFalse: [1].

	[aStream peek isAlphaNumeric] whileFalse: [aStream skip].
	aStream peek isDigit ifTrue: [
		firstAsNumber := (Integer readFrom: aStream) * firstAsNumberSign ].

	[aStream peek isAlphaNumeric] whileFalse: [aStream skip].
	aStream peek isLetter
		ifTrue: [
			^self readNamedMonthFrom: aStream firstNumber: firstAsNumber ].
	
	"YY-MM, YYYY-MM, etc.  (ISO8601), MM-YYYY"
	secondStart := aStream position.
	second := Integer readFrom: aStream.
	secondLength := aStream position - secondStart.

	^secondLength > 2
		ifTrue: [
			"MM-YYYY"
			^self month: (Month nameOfMonth: firstAsNumber) year: second ]
		ifFalse: [
			"YY-MM, YYYY-MM, etc.  (ISO8601)"
			^self month: (Month nameOfMonth: second) year: firstAsNumber ]
]

{ #category : 'instance creation' }
Month class >> readNamedMonthFrom: aStream firstNumber: firstAsNumberOrNil [
	"See sender. Handle these forms:
		<monthName> <year>		(April, 1982; April 1982; APR-82; APR82)
		<year> <monthName>		(1982, April; 1982 April; etc)
		"

	| month year |

	"MonthName-YY or YY-MonthName"
	month := String streamContents: [ :strm |
		[ aStream peek isLetter ] whileTrue: [ strm nextPut: aStream next ]].
	firstAsNumberOrNil
		ifNil: [
			"MonthName YY"
			[aStream peek isAlphaNumeric] whileFalse: [aStream skip].
			year := Integer readFrom: aStream ]
		ifNotNil: [
			"YY-MonthName"
			year := firstAsNumberOrNil ].

	^ self month: month year: year
]

{ #category : 'squeak protocol' }
Month >> daysInMonth [

	^ self duration days
]

{ #category : 'public protocol' }
Month >> daysInYear [
	"Answer the number of days in the month represented by the receiver."

	^ start daysInYear
]

{ #category : 'public protocol' }
Month >> isLeapYear [

	^ start isLeapYear
]

{ #category : 'public protocol' }
Month >> monthAbbreviation [

	^ start monthAbbreviation
]

{ #category : 'public protocol' }
Month >> monthIndex [

	^ start monthIndex
]

{ #category : 'public protocol' }
Month >> monthName [

	^ start monthName
]

{ #category : 'inquiries' }
Month >> name [
	^ self monthName
]

{ #category : 'printing' }
Month >> printOn: aStream [
	aStream nextPutAll: self monthName, ' ', self yearNumber printString
]

{ #category : 'double dispatching' }
Month >> subtractFrom: aTimespan [

	^ aTimespan subtractMonth: self
]

{ #category : 'double dispatching' }
Month >> subtractMonth: aMonth [
	"Months can be subtracted even they have different length."

	^self start subtractDateAndtime: aMonth start
]

{ #category : 'public protocol' }
Month >> year [

	^start year
]

{ #category : 'public protocol' }
Month >> yearNumber [

	^ start yearNumber
]
