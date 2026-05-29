Class {
	#name : 'ExtendedClipboardTest',
	#superclass : 'TestCase',
	#category : 'Tests-ExtendedClipboard',
	#package : 'Tests',
	#tag : 'ExtendedClipboard'
}

{ #category : 'testing' }
ExtendedClipboardTest >> testStar16BitToAndFromImageClipboard [
	"
	ExtendedClipboardTest new testStar16BitToAndFromImageClipboard
	"
	| form form1 form2 |
	form _ (Display copy: (10@10 extent: 60@40)) asFormOfDepth: 16.

	"This will use a refStreamed object"
	Clipboard default storeObject: form.
	form2 _ Clipboard default retrieveObject.
	form1 _ form copy.
	form1 addDeltasFrom: form2.
	self assert: form1 primCountBits = 0 description: 'Form copyPasted from Clipboard appears to be bad.'.

	"This will also test storing and retrieving PNG data from platform Clipboard, and PNG conversion"
	ExtendedClipboardInterface current
		clearClipboard;
		addClipboardData: (PNGReadWriter bytesFor: form)  dataFormat: 'public.png'.
	form2 _ Clipboard default retrieveObject.
	form1 _ form copy.
	form1 addDeltasFrom: form2.
	self assert: form1 primCountBits = 0 description: 'Form copyPasted from Clipboard appears to be bad.'.
]

{ #category : 'testing' }
ExtendedClipboardTest >> testStar8BitToAndFromImageClipboard [
	"
	ExtendedClipboardTest new testStar8BitToAndFromImageClipboard
	"
	| form form1 form2 |
	self assert: Clipboard default extendedClipboardInterface canStore description: 'Extended Clipboard cant store'.

	form _ (Display copy: (10@10 extent: 60@40)) asFormOfDepth: 8.

	"This will use a refStreamed object"
	Clipboard default storeObject: form.
	form2 _ Clipboard default retrieveObject.
	self assert: (form2 is: #Form).
	form1 _ form copy.
	form1 addDeltasFrom: form2.
	self assert: form1 primCountBits = 0 description: 'Form copyPasted from Clipboard appears to be bad.'.

	"This will also test storing and retrieving PNG data from platform Clipboard, and PNG conversion"
	ExtendedClipboardInterface current
		clearClipboard;
		addClipboardData: (PNGReadWriter bytesFor: form)  dataFormat: 'public.png'.
	form2 _ Clipboard default retrieveObject.
	form1 _ form copy.
	form1 addDeltasFrom: form2.
	self assert: form1 primCountBits = 0 description: 'Form copyPasted from Clipboard appears to be bad.'.
]

{ #category : 'testing' }
ExtendedClipboardTest >> testStarToAndFromImageClipboard [
	"
	ExtendedClipboardTest new testStarToAndFromImageClipboard
	"
	| form form1 form2 |
	form _ Display copy: (10@10 extent: 60@40).

	"This will use a refStreamed object"
	Clipboard default storeObject: form.
	form2 _ Clipboard default retrieveObject.
	form1 _ form copy.
	form1 addDeltasFrom: form2.
	self assert: form1 primCountBits = 0 description: 'Form copyPasted from Clipboard appears to be bad.'.

	"This will also test storing and retrieving PNG data from platform Clipboard, and PNG conversion"
	ExtendedClipboardInterface current
		clearClipboard;
		addClipboardData: (PNGReadWriter bytesFor: form)  dataFormat: 'public.png'.
	form2 _ Clipboard default retrieveObject.
	form1 _ form copy.
	form1 addDeltasFrom: form2.
	self assert: form1 primCountBits = 0 description: 'Form copyPasted from Clipboard appears to be bad.'.
]
