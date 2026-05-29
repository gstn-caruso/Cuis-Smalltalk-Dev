Extension { #name : 'FileEntry' }

{ #category : '*json' }
FileEntry >> jsonContents [
	"
	'noesta.json' asFileEntry jsonContents
	"
	^self readStreamDo: [ :stream |
		Json readFrom: stream ]
]
