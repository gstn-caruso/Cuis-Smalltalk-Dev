'From Cuis 5.0 [latest update: #3826] on 5 August 2019 at 7:53:12 pm'!

!TestResult methodsFor: 'running' stamp: 'GC 8/5/2019 18:54:41'!
print: aString
	| out |
	
	out _ StdIOWriteStream stdout.

	out nextPutAll: aString; newLine! !

!TestResult methodsFor: 'running' stamp: 'GC 8/5/2019 18:54:41'!
printInGreen: aString
	self print: ('{1}33[32;1m{2}{1}[33m' format: { (Character asciiValue: 0) asString . aString })! !

!TestResult methodsFor: 'running' stamp: 'GC 8/5/2019 18:53:28'!
printInRed: aString
	self print: ('{1}33[31;1m{2}{1}[33m' format: { (Character asciiValue: 0) asString . aString })! !

!TestResult methodsFor: 'running' stamp: 'GC 8/5/2019 18:55:16'!
reportError: aTestCase because: anExceptionSignal
	| exception |
	
	exception _ anExceptionSignal exception.
	
	self printInRed: ('{1} has errored because: {2}' format: {aTestCase asString . exception asString })! !

!TestResult methodsFor: 'running' stamp: 'GC 8/5/2019 18:55:56'!
reportFailed: aTestCase because: anException
	
	self printInRed: ('{1} has failed because: {2}' format: {aTestCase asString . anException asString })! !

!TestResult methodsFor: 'running' stamp: 'GC 8/5/2019 19:52:50'!
printReport
	| failuresCount |
	
	self print: self asString.
	
	failuresCount _ (self errors, self failures) size.
	failuresCount isZero ifTrue: [
		self printInGreen: '--------'.
		self printInGreen: 'SUCCESS'.
		self printInGreen: '--------'.
	] ifFalse: [
		self printInRed: '--------'.
		self printInRed: failuresCount asString, ' FAILURE(S)'.
		self printInRed: '--------'.
		self errors do: [:aTestCase |
			self printInRed: ('{1} has errored because: {2}' format: {aTestCase asString . aTestCase raisedError exception asString })
		].
		self failures do: [:aTestCase |
			self printInRed: ('{1} has failed because: {2}' format: {aTestCase asString . aTestCase failureString })
		]
	]! !

!TestResult methodsFor: 'running' stamp: 'GC 8/2/2019 18:22:57'!
reportPassed: aTestCase

	"Transcript show: 'finished.'; newLine."
	
	| out inGreen |
	inGreen _ [:aString |
		'{1}[92m{2}{1}[39m' format: { (Character asciiValue: 27) asString . aString }
	].
	out _ StdIOWriteStream stdout.
	
	out nextPutAll: (inGreen value: ('{1} has passed' format: {aTestCase asString})); newLine! !


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

