Class {
	#name : 'FFIMemoryTests',
	#superclass : 'TestCase',
	#category : 'Tests-FFI',
	#package : 'Tests',
	#tag : 'FFI'
}

{ #category : 'memory tests' }
FFIMemoryTests >> testCopyToExternalMemory [
	"Test copyToExternalMemory"
	
	| sampleString sampleBytes addr bytes string |

	sampleString := 'This is a test'.
	sampleBytes := (sampleString, Character null asString) asUtf8Bytes.
	addr := sampleBytes copyToExternalMemory.
	self assert: (addr is: #ExternalAddress).
	self assert: (addr isNull not).
	
	"Don't try to read from a null address"
	(addr isNull not) 
		ifTrue:[
			bytes := addr bytesAt: 1 maxLength: sampleString size stopAtNullByte: true.
			self assert: ((sampleBytes size - 1) = (bytes size)).
			string := addr utf8StringAt: 1 maxLength: sampleString size stopAtNull: true.
			self assert: (sampleString = string)].
]

{ #category : 'memory tests' }
FFIMemoryTests >> testMoveToExternalMemoryAndBack [
	"Test moveToExternalMemory"
	
	| sample |

	"Create a sample object and show it is in Smalltalk memory"
	sample := FFITestBiggerStruct new
		x: -100;
		y: -50;
		z: -25;
		w: 0;
		r: 25;
		s: 50;
		t: 100;
		u: 5555;
		yourself.
	self assert: sample isInExternalMemory not.
	
	"Move the data to external memory and show the values still work"
	sample moveToExternalMemory.
	self assert: sample isInExternalMemory.
	self assert: (sample x = -100).
	self assert: (sample y = -50).
	self assert: (sample z = -25).
	self assert: (sample w = 0).
	self assert: (sample r = 25).
	self assert: (sample s = 50).
	self assert: (sample t = 100).
	self assert: (sample u = 5555).
	
	"Move the data back to smallalk memory and show the values still work"
	sample moveToSmalltalkMemory.
	self assert: sample isInExternalMemory not.
	self assert: (sample x = -100).
	self assert: (sample y = -50).
	self assert: (sample z = -25).
	self assert: (sample w = 0).
	self assert: (sample r = 25).
	self assert: (sample s = 50).
	self assert: (sample t = 100).
	self assert: (sample u = 5555).
]
