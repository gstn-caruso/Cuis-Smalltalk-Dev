"
I represent a SelectionMenu which operates like a modal dialog to select a files ro directory, somewhat similar to the StandardFile dialogs in MacOS and Java Swing.

Try for example, the following:

 - To pick a file entry:

	(StandardFileMenu oldFileFrom: DirectoryEntry smalltalkImageDirectory) inspect

	((StandardFileMenu new 
		newFileFrom: DirectoryEntry smalltalkImageDirectory withPattern: '*.st') startUpWithCaption: 'Pick-up a file Dave') inspect

	(StandardFileMenu new 
		oldFileFrom: DirectoryEntry smalltalkImageDirectory withPattern: '*.st' excludePattern: '.*';
		startUpWithCaption: 'Pick up a Smalltalk file') inspect

 - To pick a directory entry:

	(StandardFileMenu oldDirectoryFrom: DirectoryEntry smalltalkImageDirectory) inspect
	
	(StandardFileMenu new newDirectoryFrom: DirectoryEntry smalltalkImageDirectory;
		startUpWithCaption: 'Pick-up a directory to back-up your data') inspect

	(StandardFileMenu new
		oldDirectoryFrom: DirectoryEntry smalltalkImageDirectory;
		startUpWithCaption: 'Pick-up a directory Dave, to save your soul') inspect
		

"
Class {
	#name : 'StandardFileMenu',
	#superclass : 'SelectionMenu',
	#instVars : [
		'operationMode',
		'pattern',
		'excludePattern'
	],
	#category : 'Goodies-Tools-FileList',
	#package : 'Goodies',
	#tag : 'Tools-FileList'
}

{ #category : 'standard file operations' }
StandardFileMenu class >> oldDirectoryFrom: aDirectory [
	(aDirectory isKindOf: DirectoryEntry)
		ifFalse: [ self error: 'I require a DirectoryEntry'].
	^(self new oldDirectoryFrom: aDirectory)
		startUpWithCaption: 'Select a directory'
]

{ #category : 'standard file operations' }
StandardFileMenu class >> oldFileFrom: aDirectory [
	(aDirectory isKindOf: DirectoryEntry)
		ifFalse: [ self error: 'I require a DirectoryEntry'].
	^(self new oldFileFrom: aDirectory)
		startUpWithCaption: 'Select a file'
]

{ #category : 'private' }
StandardFileMenu >> advance: anInteger containingDirectoriesFrom: aDirectory [

	| theDirectory |
	theDirectory _ aDirectory.
	1 to: anInteger do: [:i | theDirectory _ theDirectory parent].
	^theDirectory
]

{ #category : 'testing' }
StandardFileMenu >> canTypeDirectoryName [
	^ operationMode = #pickupOrNewDirectory
]

{ #category : 'testing' }
StandardFileMenu >> canTypeEntry [
	^ self canTypeFileName or: [self canTypeDirectoryName]
]

{ #category : 'testing' }
StandardFileMenu >> canTypeFileName [
	^ operationMode = #pickupOrNewFile
]

{ #category : 'basic control sequences' }
StandardFileMenu >> confirmExistingFiles: aResult [

	|choice|
	(aResult directory includesKey: aResult name) ifFalse: [^aResult].
	
	choice := (PopUpMenu
		labels:
'overwrite that file
choose another name
cancel')
		startUpWithCaption: aResult name, '
already exists.'.

	choice = 1 ifTrue: [
		aResult directory 
			removeKey: aResult name
			ifAbsent: 
				[^self startUpWithCaption: 
'Can''t delete ', aResult name, '
Select another file'].
		^aResult].
	choice = 2 ifTrue: [^self startUpWithCaption: 'Select another file'].
	^nil
 
]

{ #category : 'menu building' }
StandardFileMenu >> directoryNamesString: aDirectory [
"Answer a string concatenating the directory name strings in aDirectory, each string followed by a '[...]' indicator, and followed by a newLine."
	^ String streamContents: [:s | 
		(self matchingDirectories: aDirectory) do: [:subDirectory |	 
			s nextPutAll: subDirectory name withBlanksTrimmed , ' [...]'; newLine]]


]

{ #category : 'pattern' }
StandardFileMenu >> excludePattern: patString [
" See method pattern: "

	excludePattern := patString ifNotNil: [ patString substrings ]
]

{ #category : 'pattern' }
StandardFileMenu >> excludePatternMatches: aString [
	^excludePattern anySatisfy: [ :pat | pat match: aString ]
]

{ #category : 'menu building' }
StandardFileMenu >> fileNamesString: aDirectory [
"Answer a string concatenating the file name strings in aDirectory, each string followed by a newLine."

	^String streamContents: [:s | 
		(self matchingFiles: aDirectory) do: [:file |
			s nextPutAll: file name withBlanksTrimmed; newLine]]
]

{ #category : 'basic control sequences' }
StandardFileMenu >> getEntryName: aResult [
	| name message |		
	message := self isSelectFile 
		ifTrue: ['Enter a new file name'] 
		ifFalse: ['Enter a new directory name'].
	name := StringRequestMorph 
		request: message
		initialAnswer: ''.
	name = '' ifTrue: [
		message := self isSelectFile 
			ifTrue:[ 'Select a file'] 
			ifFalse: ['Select a directory'].
		self startUpWithCaption: message].
	^ StandardFileMenuResult	directory: aResult directory name: name
]

{ #category : 'testing' }
StandardFileMenu >> isSelectDirectory [
	^ operationMode = #pickupOrNewDirectory or: [operationMode = #pickupDirectory]
]

{ #category : 'testing' }
StandardFileMenu >> isSelectFile [
	^ operationMode = #pickupOrNewFile or: [operationMode = #pickupFile]
]

{ #category : 'menu building' }
StandardFileMenu >> makeFileMenuFor: aDirectory [
"Initialize an instance of me to operate on aDirectory"

	| theMenu |
	pattern ifNil: [ self pattern: '*'].
	excludePattern ifNil: [self excludePattern: ''].
	self 
		labels: 	(self menuLabelsString: aDirectory)
		lines: 	(self menuLinesArray: aDirectory).
	theMenu := self selections: (self menuSelectionsArray: aDirectory).
	^theMenu
]

{ #category : 'pattern' }
StandardFileMenu >> matchingDirectories: parentDirectory [
	^ (parentDirectory directories reject: [: aDirectory |
		self excludePatternMatches: aDirectory name]) sort: [:d1 :d2 | 
			d1 name asLowercase < d2 name asLowercase ]
	
]

{ #category : 'pattern' }
StandardFileMenu >> matchingFiles: parentDirectory [
	^ (parentDirectory files select: [: aFile |
		(self excludePatternMatches: aFile name) not 
		and: [self patternMatches: aFile name]]) sort: [:f1 :f2 | 
			f1 name asLowercase < f2 name asLowercase ]
	
]

{ #category : 'menu building' }
StandardFileMenu >> menuLabelsString: aDirectory [
"Answer a menu labels object corresponding to aDirectory"

	^ String streamContents: 
		[:s | 
			self canTypeFileName ifTrue: [s nextPutAll: 'Enter new file name...'; newLine].
			self canTypeDirectoryName ifTrue: [s nextPutAll: 'Enter new directory name...'; newLine].
			s nextPutAll: (self pathPartsString: aDirectory).
			s nextPutAll: (self directoryNamesString: aDirectory).
			self isSelectFile ifTrue: [s nextPutAll: (self fileNamesString: aDirectory)].
			self isSelectDirectory ifTrue: [s nextPutAll: (aDirectory name  ifNil: ['[]']); newLine].
			s skip: -1]
]

{ #category : 'menu building' }
StandardFileMenu >> menuLinesArray: aDirectory [
"Answer a menu lines object corresponding to aDirectory"

	| typeCount nameCnt dirDepth|
	typeCount := self canTypeEntry ifTrue: [1] ifFalse: [0].
	nameCnt := (self matchingDirectories: aDirectory) size.
	dirDepth := aDirectory pathComponents size.
	^ Array streamContents: [:s |
		self canTypeEntry ifTrue: [s nextPut: 1].
		s nextPut: dirDepth + typeCount + 1.
		s nextPut: dirDepth + nameCnt + typeCount + 1
	]
]

{ #category : 'menu building' }
StandardFileMenu >> menuSelectionsArray: aDirectory [
"Answer a menu selections object corresponding to aDirectory.  The object is an array corresponding to each item, each element itself constituting a two-element array, the first element of which contains a selector to operate on and the second element of which contains the parameters for that selector."

	|dirSize|
	dirSize := aDirectory pathComponents size.
	^Array streamContents: [:s |
		self canTypeEntry ifTrue:
			[s nextPut: (StandardFileMenuResult
				directory: aDirectory
				name: nil)].
		s nextPut: (StandardFileMenuResult
			directory: (DirectoryEntry roots first)
			name: '').
		aDirectory pathComponents withIndexDo: 
			[:d :i | s nextPut: (StandardFileMenuResult
				directory: (self 
					advance: dirSize - i
					containingDirectoriesFrom: aDirectory)
				name: '')].
		(self matchingDirectories: aDirectory)		 do: 
			[:dir | s nextPut: (StandardFileMenuResult
					directory: dir
					name: '')].
		self isSelectFile ifTrue: [(self matchingFiles: aDirectory) do: 
				[:file | s nextPut: (StandardFileMenuResult
					directory: aDirectory
					name: file name)	] ].
		self isSelectDirectory ifTrue: [ s nextPut: (StandardFileMenuResult 
			directory: aDirectory name: (aDirectory name  ifNil: ['[]']))]
		]
]

{ #category : 'private' }
StandardFileMenu >> newDirectoryFrom: aDirectory [

	operationMode := #pickupOrNewDirectory.
	^self makeFileMenuFor: aDirectory
]

{ #category : 'private' }
StandardFileMenu >> newFileFrom: aDirectory withPattern: aPattern [

	self newFileFrom: aDirectory withPattern: aPattern excludePattern: nil
]

{ #category : 'private' }
StandardFileMenu >> newFileFrom: aDirectory withPattern: aPattern excludePattern: anotherPattern [

	operationMode := #pickupOrNewFile.
	self pattern: aPattern.
	self excludePattern: anotherPattern.
	^self makeFileMenuFor: aDirectory
]

{ #category : 'private' }
StandardFileMenu >> oldDirectoryFrom: aDirectory [

	operationMode := #pickupDirectory.
	^self makeFileMenuFor: aDirectory
]

{ #category : 'private' }
StandardFileMenu >> oldFileFrom: aDirectory [

	operationMode := #pickupFile.
	^self makeFileMenuFor: aDirectory
]

{ #category : 'private' }
StandardFileMenu >> oldFileFrom: aDirectory withPattern: aPattern [
	self oldFileFrom: aDirectory withPattern: aPattern excludePattern: nil
]

{ #category : 'private' }
StandardFileMenu >> oldFileFrom: aDirectory withPattern: aPattern excludePattern: anotherPattern [

	operationMode := #pickupFile.
	self pattern: aPattern.
	self excludePattern: anotherPattern.
	^self makeFileMenuFor: aDirectory
]

{ #category : 'menu building' }
StandardFileMenu >> pathPartsString: aDirectory [
"Answer a string concatenating the path parts strings in aDirectory, each string followed by a newLine."

	^String streamContents:
		[:s | 
			s nextPutAll: '[]'; newLine.
			aDirectory pathComponents asArray withIndexDo: 
				[:part :i |
					s next: i put: $ .
					s nextPutAll: part withBlanksTrimmed; newLine]]
]

{ #category : 'pattern' }
StandardFileMenu >> pattern: patString [
	" * for all files, or '*.cs' for changeSets, etc.  Just like fileLists
	jmv- Added support for multiple patterns, separated by spaces.
	For example '*.cs *.st' will show both changesets and fileouts."

	pattern _ patString substrings
]

{ #category : 'pattern' }
StandardFileMenu >> patternMatches: aString [

	^pattern anySatisfy: [ :pat | pat match: aString ]
]

{ #category : 'basic control sequences' }
StandardFileMenu >> startUpWithCaption: aString at: location allowKeyboard: aBoolean [

	|result|
	result := super startUpWithCaption: aString at: location allowKeyboard: aBoolean.
	result ifNil: [^nil].
	result isDirectory ifTrue:
		[self makeFileMenuFor: result directory.
		 ^self startUpWithCaption: aString at: location allowKeyboard: aBoolean].
	result isCommand ifTrue: 
		[result := self getEntryName: result.
		result ifNil: [^nil]].
	self canTypeFileName ifTrue: [^self confirmExistingFiles: result].
	^result
	
]
