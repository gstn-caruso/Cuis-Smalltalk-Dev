'From Cuis 5.0 of 7 November 2016 [latest update: #3795] on 5 July 2019 at 7:05:50 pm'!
!classDefinition: #JUnitTestResultReport category: #'Kernel-Objects'!
Object subclass: #JUnitTestResultReport
	instanceVariableNames: 'testResult'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Kernel-Objects'!

!JUnitTestResultReport methodsFor: 'as yet unclassified' stamp: 'asdf 7/5/2019 19:05:22'!
generateReport
	
	^ String streamContents: [:s | 
	
	 self generateTag: 'testsuite' in: s do:  [
		
		testResult passed do: [ :p | self writePassingTestCase: p in: s ].
		testResult failures do: [ :p | self writeFailingTestCase: p in: s ].
		testResult errors do: [ :p | self writeFailingTestCase: p in: s ].
		]
	
	]! !

!JUnitTestResultReport methodsFor: 'as yet unclassified' stamp: 'NPM 7/1/2019 22:09:01'!
initializeFrom: aTestResult 
	
	testResult := aTestResult.! !

!JUnitTestResultReport methodsFor: 'as yet unclassified' stamp: 'NPM 7/1/2019 22:43:25'!
writeFailingTestCase: aXxxTest in: aWriteStream 
	
	aWriteStream
		nextPutAll: '<testcase ';
		nextPutAll: 'classname="', aXxxTest class name, '" '; 
		nextPutAll: 'name="', aXxxTest selector, '">';
		cr.
		
	self writeFailure: aXxxTest in: aWriteStream. 	
		
	aWriteStream 	nextPutAll: '</testcase>'; cr. ! !

!JUnitTestResultReport methodsFor: 'as yet unclassified' stamp: 'NPM 7/1/2019 22:42:13'!
writeFailure: aXxxTest in: aWriteStream 
	
	aWriteStream
		nextPutAll: '<failure ';
		nextPutAll: 'message="oops" '; 
		nextPutAll: 'type="type is required" ';
		nextPutAll: '/>';
		cr.! !

!JUnitTestResultReport methodsFor: 'as yet unclassified' stamp: 'NPM 7/1/2019 22:42:40'!
writePassingTestCase: aMultipliedUnitTest in: aWriteStream 
	
	aWriteStream
		nextPutAll: '<testcase ';
		nextPutAll: 'classname="', aMultipliedUnitTest class name, '" '; 
		nextPutAll: 'name="', aMultipliedUnitTest selector, '" ';
		nextPutAll: '/>';
		cr. ! !

!JUnitTestResultReport methodsFor: 'as yet unclassified' stamp: 'NPM 7/1/2019 22:09:30'!
writeToFile: aFileEntry 
	
	aFileEntry textContents: self generateReport.! !


!JUnitTestResultReport methodsFor: 'binding' stamp: 'NPM 7/1/2019 22:41:31'!
generateTag: aString in: aWriteStream do: aBlockClosure 
	
	aWriteStream
		nextPutAll: '<', aString, '>'; cr.

	aBlockClosure value.
		
	aWriteStream
		nextPutAll: '</', aString, '>'; cr.! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

!classDefinition: 'JUnitTestResultReport class' category: #'Kernel-Objects'!
JUnitTestResultReport class
	instanceVariableNames: ''!

!JUnitTestResultReport class methodsFor: 'as yet unclassified' stamp: 'NPM 7/1/2019 22:08:49'!
from: aTestResult 
	
	^ self
		new
		initializeFrom: aTestResult! !
