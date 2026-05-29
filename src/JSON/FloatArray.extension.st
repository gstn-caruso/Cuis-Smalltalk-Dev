Extension { #name : 'FloatArray' }

{ #category : '*JSON' }
FloatArray >> jsonWriteElement: element on: aStream [
	"FloatArray elements are answered as 64 bit Float, but are really 32 bit Float.
	When writing to JSON (or printing), print them as 32 bit Float."

	element printAsIEEE32BitPrecisionFloatOn: aStream base: 10
]
