Extension { #name : 'Array2D' }

{ #category : '*JSON' }
Array2D >> jsonWriteOn: aStream [
	"By default, use array braces "
	aStream nextPut: $[.
	1 to: height
		do: [ :i |
			aStream nextPut: $[.
				1 to: width
					do: [ :j | elements jsonWriteElement: (self i: i j: j) on: aStream ]
					separatedBy: [aStream nextPut: $, ; space].
			aStream nextPut: $] ]
		separatedBy: [aStream nextPut: $, ; newLine ].
	aStream nextPut: $]
]
