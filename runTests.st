|suite result report exitCode|

ChangeSet fileIn: './JUnitTestResultReport.st' asFileEntry.

suite _ TestSuite new.
TestCase allSubclassesDo: [ :testCase | testCase addToSuiteFromSelectors: suite].
result := suite run.

report := JUnitTestResultReport from: result.
report writeToFile: (DirectoryEntry currentDirectory // 'report.xml').

exitCode := (result hasFailures or: [ result hasErrors ])
	ifTrue: [ 1 ]
	ifFalse: [ 0 ].

Smalltalk quitPrimitive: exitCode
