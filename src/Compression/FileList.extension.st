Extension { #name : 'FileList' }

{ #category : '*Compression' }
FileList >> compressFile [
	"Compress the currently selected file"

	self fullName asFileEntry readStream compressFile.
	self updateFileList
]

{ #category : '*Compression' }
FileList >> serviceCompressFile [
	"Answer a service for compressing a file"

	^ SimpleServiceEntry
		provider: self
		label: 'compress'
		selector: #compressFile
		description: 'compress file'
		buttonLabel: 'compress'
		icon: #goBottomIcon
]
