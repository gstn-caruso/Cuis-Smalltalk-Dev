Extension { #name : 'CodeFileBrowser' }

{ #category : '*Compression' }
CodeFileBrowser class >> browseMCZCode: aFileEntry [
	"Browse the selected file."

	| codeFile unzipped |
	aFileEntry readStreamDo: [ :stream |
		unzipped := (stream unzippedStringLFContentsOf: 'snapshot/source.st') readStream.
		codeFile := (CodeFile new fullName: aFileEntry pathName; buildFrom: unzipped) ].
	CodeFileBrowser browseCodeSource: codeFile.
]

{ #category : '*Compression' }
CodeFileBrowser class >> serviceBrowseMCZCode [
	"Answer a service for opening a changelist browser on a file"

	^ (SimpleServiceEntry 
		provider: self 
		label: 'browse code'
		selector: #browseMCZCode:
		description: 'open a "file-contents browser" on this file, allowing you to view and selectively load its code'
		buttonLabel: 'code'
		icon: #editFindReplaceIcon)
			argumentGetter: [ :fileList |
				fileList selectedFileEntry ]
]
