Extension { #name : 'FileEntry' }

{ #category : '*Sound' }
FileEntry >> wavContents [
	^SampledSound fromFileEntry: self
]
