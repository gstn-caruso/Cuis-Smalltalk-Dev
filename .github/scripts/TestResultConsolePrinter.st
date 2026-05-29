'From Cuis7.7 [latest update: #7777] on 28 May 2026 at 10:00:00 pm'!
!classDefinition: #TestResultConsolePrinter category: #'System-Support'!
Object subclass: #TestResultConsolePrinter
	instanceVariableNames: 'outputStream'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'System-Support'!
!classDefinition: 'TestResultConsolePrinter class' category: #'System-Support'!
TestResultConsolePrinter class
	instanceVariableNames: ''!

!TestResultConsolePrinter methodsFor: 'initialization' stamp: 'GC 5/28/2026 22:00:00'!
initializeWith: aWriteStream

	outputStream := aWriteStream! !


!TestResultConsolePrinter methodsFor: 'printing primitives' stamp: 'GC 5/28/2026 22:00:00'!
print: aString

	outputStream nextPutAll: aString; newLine; flush! !

!TestResultConsolePrinter methodsFor: 'printing primitives' stamp: 'GC 5/28/2026 22:00:00'!
printInGreen: aString

	outputStream nextPutAll: Character escape asString, '[32m'.
	outputStream nextPutAll: aString.
	outputStream nextPutAll: Character escape asString, '[0m'; newLine; flush! !

!TestResultConsolePrinter methodsFor: 'printing primitives' stamp: 'GC 5/28/2026 22:00:00'!
printInRed: aString

	outputStream nextPutAll: Character escape asString, '[31m'.
	outputStream nextPutAll: aString.
	outputStream nextPutAll: Character escape asString, '[0m'; newLine; flush! !


!TestResultConsolePrinter methodsFor: 'report' stamp: 'GC 5/28/2026 22:00:00'!
nameOf: aTestCase

	^ aTestCase class name, '>>', aTestCase selector! !

!TestResultConsolePrinter methodsFor: 'report' stamp: 'GC 5/28/2026 22:00:00'!
reasonForFailure: aTestCase
	"A short, single-line reason for a failed test case."

	^ [aTestCase failureString] on: Error do: [:e | '(no failure description)']! !

!TestResultConsolePrinter methodsFor: 'report' stamp: 'GC 5/28/2026 22:00:00'!
reasonForError: aTestCase
	"A short, single-line reason for an errored test case: the underlying
	exception class and its message text."

	^ [ | ex |
		ex := aTestCase raisedError exception.
		ex class name, ': ', (ex messageText ifNil: [ '' ]) ]
			on: Error do: [:e | aTestCase raisedError printString ]! !

!TestResultConsolePrinter methodsFor: 'report' stamp: 'GC 5/28/2026 22:00:00'!
printClass: aTestClass of: aTestResult
	"Surefire-style one-line summary for a single test class, plus the detail
	of any failed or errored test case under it."

	| passed failed errored runCount line |
	passed := (aTestResult passed select: [:tc | tc class == aTestClass]) size.
	failed := aTestResult failures select: [:tc | tc class == aTestClass].
	errored := aTestResult errors select: [:tc | tc class == aTestClass].
	runCount := passed + failed size + errored size.

	line := aTestClass name, ': ', runCount printString, ' run, ', passed printString, ' passed'.
	failed isEmpty ifFalse: [ line := line, ', ', failed size printString, ' failed' ].
	errored isEmpty ifFalse: [ line := line, ', ', errored size printString, ' errored' ].

	(failed isEmpty and: [ errored isEmpty ])
		ifTrue: [ self printInGreen: line ]
		ifFalse: [
			self printInRed: line.
			failed do: [:tc |
				self printInRed: '    FAILED  ', (self nameOf: tc), '  --  ', (self reasonForFailure: tc) ].
			errored do: [:tc |
				self printInRed: '    ERROR   ', (self nameOf: tc), '  --  ', (self reasonForError: tc) ] ]! !

!TestResultConsolePrinter methodsFor: 'report' stamp: 'GC 5/28/2026 22:00:00'!
printReport: aTestResult
	"Print a surefire-style report: one summary line per test class (green if
	clean, red with detail if it has defects), then a global summary line."

	| classes totalRun defects |
	classes := ((aTestResult passed, aTestResult failures, aTestResult errors)
		collect: [:tc | tc class]) asSet asSortedCollection: [:a :b | a name <= b name].
	classes do: [:aTestClass | self printClass: aTestClass of: aTestResult].

	totalRun := aTestResult passed size + aTestResult failures size + aTestResult errors size.
	defects := aTestResult failures size + aTestResult errors size.
	self print: '--------'.
	defects isZero
		ifTrue: [ self printInGreen: 'SUCCESS  --  ', totalRun printString, ' run, all passed' ]
		ifFalse: [ self printInRed: defects printString, ' FAILURE(S)/ERROR(S)  --  ', totalRun printString, ' run' ].
	self print: '--------'! !


!TestResultConsolePrinter class methodsFor: 'instance creation' stamp: 'GC 5/28/2026 22:00:00'!
stdOutCommandLine

	^ self new initializeWith: StdIOWriteStream stdout; yourself! !

!TestResultConsolePrinter class methodsFor: 'stdout printing' stamp: 'GC 5/28/2026 22:00:00'!
printReport: aTestResult

	^ self stdOutCommandLine printReport: aTestResult! !


!TestResult methodsFor: 'running' stamp: 'GC 5/28/2026 22:00:00'!
printReport

	TestResultConsolePrinter printReport: self! !
