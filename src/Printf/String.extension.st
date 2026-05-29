Extension { #name : 'String' }

{ #category : '*Printf' }
String >> asArgumentArrayForFormatString [

	^{self}
	
]

{ #category : '*Printf' }
String >> printf [
	^ (self indexOf: $%) ~= 0
		ifTrue: [ self ]
		ifFalse: [ (PrintfFormatString new setFormat: self) printf: #() ]
		
]

{ #category : '*Printf' }
String >> printf: arguments [
	"Answer the string that results from applying the receiver
	 as a printf-style format string to the arguments.  For example
		'Hello %d world!' printf: {Date today year}"
	^(PrintfFormatString new setFormat: self)
		printf: arguments;
		string
		
]
