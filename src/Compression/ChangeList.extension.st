Extension { #name : 'ChangeList' }

{ #category : '*Compression' }
ChangeList class >> browseMCZContents: aFileEntry [
	"Browse the selected file."
	|  unzippedString unzipped changeList fullName packageFile pkName |
	
	"For Monticello packages we do as we do with our own .pck.st files: Instead of just browsing
	contents, also include what is no longer part of the package (and should therefore be removed on install)
	See #browsePackageContents:
	However, this was never tested to run!"
	self flag: #jmvVer.

	fullName := aFileEntry pathName.
	pkName := CodePackageFile monticelloPackageNameFrom: fullName.
	aFileEntry readStreamDo: [ :stream |
		unzippedString := stream unzippedStringLFContentsOf: 'snapshot/source.st'.
		unzipped := unzippedString readStream.
		changeList := self new scanFile: unzipped from: 0 to: unzippedString size.
		stream reset.
		packageFile := CodePackageFile new.
		packageFile
			buildFileStream: unzipped
			packageName: pkName
			fullName: fullName ].

	"Add deletions of methods and classes that are in the CodePackage (i.e., active in the system)
	but are no longer in the CodePackageFile being viewed."
	packageFile methodsToRemove do: [ :methodReference |
		changeList
			addItem: (MethodDeletionChange new methodReference: methodReference)
			text: 'method no longer in package: ', methodReference stringVersion ].
	packageFile classesToRemove do: [ :clsName |
		changeList
			addItem: (ClassDeletionChange new className: clsName)
			text: 'class no longer in package: ', clsName ].
	changeList clearSelections.
	ChangeListWindow open: changeList label: aFileEntry pathName.
]

{ #category : '*Compression' }
ChangeList class >> serviceMCZContents [
	"Answer a service for opening a changelist browser on a file"

	^ (SimpleServiceEntry 
		provider: self 
		label: 'see file contents'
		selector: #browseMCZContents:
		description: 'open a code file contents tool on this file'
		buttonLabel: 'contents'
		icon: #changesIcon)
			argumentGetter: [ :fileList |
				fileList selectedFileEntry ]
]
