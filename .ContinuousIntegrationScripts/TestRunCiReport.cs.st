'From Cuis 5.0 [latest update: #3826] on 15 September 2019 at 3:56:31 am'!
!classDefinition: #TestResultConsolePrinter category: #'System-Support'!
Object subclass: #TestResultConsolePrinter
	instanceVariableNames: 'outputStream'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'System-Support'!
!classDefinition: 'TestResultConsolePrinter class' category: #'System-Support'!
TestResultConsolePrinter class
	instanceVariableNames: 'stdOutCommandLine'!

!StdIOWriteStream methodsFor: 'character writing' stamp: 'FJG 9/15/2019 02:53:23'!
printUtf8CodePoint: utf8CodePoint
	"Example: printing a checkmark on the console
		 'StdIOWriteStream stdout printUtf8CodePoint: 16r2713; flush.'
	"
	
	| characterBytes |

	characterBytes _ Character utf8BytesOfUnicodeCodePoint: utf8CodePoint.
	
	self primWrite: fileID from: characterBytes startingAt: 1 count: characterBytes size
! !


!TestResultConsolePrinter methodsFor: 'initialization' stamp: 'FJG 9/15/2019 03:44:31'!
initializeWith: aWriteStream

	outputStream _ aWriteStream
	! !

!TestResultConsolePrinter methodsFor: 'printing' stamp: 'FJG 9/15/2019 03:50:49'!
inGreen: aBlock

	outputStream nextPutAll: Character escape asString, '[32m'.
	aBlock value.	
	outputStream nextPutAll: Character escape asString, '[0m'.
	outputStream flush.! !

!TestResultConsolePrinter methodsFor: 'printing' stamp: 'FJG 9/15/2019 03:50:45'!
inRed: aBlock

	outputStream nextPutAll: Character escape asString, '[31m'.
	aBlock value.	
	outputStream nextPutAll: Character escape asString, '[0m'.
	outputStream flush.! !

!TestResultConsolePrinter methodsFor: 'printing' stamp: 'FJG 9/15/2019 03:48:28'!
print: aString

	outputStream nextPutAll: aString; newLine! !

!TestResultConsolePrinter methodsFor: 'printing' stamp: 'FJG 9/15/2019 03:43:39'!
printError: aTestCase because: anExceptionSignal
	| exception |
	
	exception _ anExceptionSignal exception.
	
	self inRed: [
		outputStream printUtf8CodePoint: 16r274C.
		self print: (' {1} has errored because: {2}' format: {aTestCase asString . exception asString })
	]! !

!TestResultConsolePrinter methodsFor: 'printing' stamp: 'FJG 9/15/2019 03:56:07'!
printFailed: aTestCase because: aCause

	self inRed: [
		outputStream printUtf8CodePoint: 16r274C.
		self print: (' {1} has failed because: {2}' format: {aTestCase asString . aCause asString })
	]! !

!TestResultConsolePrinter methodsFor: 'printing' stamp: 'FJG 9/15/2019 03:41:56'!
printInGreen: aString

	self inGreen: [ self print: aString ]! !

!TestResultConsolePrinter methodsFor: 'printing' stamp: 'FJG 9/15/2019 03:42:07'!
printInRed: aString

	self inRed: [ self print: aString ]! !

!TestResultConsolePrinter methodsFor: 'printing' stamp: 'FJG 9/15/2019 03:39:50'!
printPassed: aTestCase

	self inGreen: [
		outputStream printUtf8CodePoint: 16r2713.
		self print: (' {1} has passed' format: {aTestCase asString})
	]! !

!TestResultConsolePrinter methodsFor: 'printing' stamp: 'FJG 9/15/2019 03:55:43'!
printReport: aTestResult
	| failuresCount |
	
	self print: aTestResult asString.
	
	failuresCount _ (aTestResult errors, aTestResult failures) size.
	failuresCount isZero ifTrue: [
		self
			printInGreen: '--------';
		      printInGreen: 'SUCCESS';
			printInGreen: '--------'.
	] ifFalse: [
		self printInRed: '--------';
			printInRed: failuresCount asString, ' FAILURE(S)';
			printInRed: '--------'.
		aTestResult errors do: [:aTestCase |
			self printError: aTestCase because: aTestCase raisedError
		].
		aTestResult failures do: [:aTestCase |
			self printFailed: aTestCase because: aTestCase failureString
		]
	]! !


!TestResultConsolePrinter class methodsFor: 'instance creation' stamp: 'FJG 9/15/2019 01:41:17'!
stdOutCommandLine

	^ stdOutCommandLine ifNil: [
		stdOutCommandLine _ self new initializeWith: StdIOWriteStream stdout; yourself
	]! !

!TestResultConsolePrinter class methodsFor: 'stdout printing' stamp: 'FJG 9/15/2019 03:24:22'!
printError: aTestCase because: anExceptionSignal

	self stdOutCommandLine printError: aTestCase because: anExceptionSignal! !

!TestResultConsolePrinter class methodsFor: 'stdout printing' stamp: 'FJG 9/15/2019 03:24:42'!
printFailed: aTestCase because: anException

	self stdOutCommandLine printFailed: aTestCase because: anException! !

!TestResultConsolePrinter class methodsFor: 'stdout printing' stamp: 'FJG 9/15/2019 03:23:05'!
printPassed: aTestCase

	self stdOutCommandLine printPassed: aTestCase! !

!TestResultConsolePrinter class methodsFor: 'stdout printing' stamp: 'FJG 9/15/2019 03:22:14'!
printReport: aTestResult

	self stdOutCommandLine printReport: aTestResult! !


!TestResult methodsFor: 'running' stamp: 'FJG 9/15/2019 03:22:19'!
printReport

	TestResultConsolePrinter printReport: self! !

!TestResult methodsFor: 'running' stamp: 'FJG 9/15/2019 03:26:17'!
reportError: aTestCase because: anExceptionSignal
	
	TestResultConsolePrinter printError: aTestCase because: anExceptionSignal! !

!TestResult methodsFor: 'running' stamp: 'FJG 9/15/2019 03:25:11'!
reportFailed: aTestCase because: anException
	
	TestResultConsolePrinter printFailed: aTestCase because: anException! !

!TestResult methodsFor: 'running' stamp: 'FJG 9/15/2019 03:23:35'!
reportPassed: aTestCase
	
	TestResultConsolePrinter printPassed: aTestCase! !


!TestResult methodsFor: 'running' stamp: 'GC 8/2/2019 17:48:48'!
runCase: aTestCase

	| testCasePassed |

	testCasePassed _
		[
			[
				Transcript show: 'Will run: '; print: aTestCase; newLine.
				aTestCase runCase.
				self reportPassed: aTestCase.
				true]
					on: self class failure
					do: [ :signal |
						self reportFailed: aTestCase because: signal.
						(self failures isEmpty or: [ (failures last == aTestCase) not ])
							ifTrue: [ failures add: aTestCase ].
						signal sunitExitWith: false ]]
							on: self class error
							do: [ :signal |
								self reportError: aTestCase because: signal.
								aTestCase errored: signal.
								self errors add: aTestCase.
								signal sunitExitWith: false ].

	testCasePassed
		ifTrue: [ self passed add: aTestCase ]! !


!TestResult reorganize!
('accessing' correctCount defects errorCount errors failureCount failures passed passedCount removeFromDefectsAndAddToPassed: runCount tests)
('testing' hasErrors hasFailures hasPassed isError: isFailure: isPassed:)
('printing' printOn:)
('running' printReport reportError:because: reportFailed:because: reportPassed: runCase:)
!

