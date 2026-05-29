"
emulation of gettext runtime
Known limitation:  
     currently don't support prural form.

"
Class {
	#name : 'GetTextTranslator',
	#superclass : 'NaturalLanguageTranslator',
	#instVars : [
		'moFiles'
	],
	#classVars : [
		'LocaleDirsForDomain',
		'SystemDefaultLocaleDirs',
		'UserDefaultLocaleDirs'
	],
	#category : 'Gettext',
	#package : 'Gettext'
}

{ #category : 'translation data layout' }
GetTextTranslator class >> addSystemDefaultLocaleDir: dir [
	"new dir will be put as first"
 	self systemDefaultLocaleDirs addFirst: dir
]

{ #category : 'private' }
GetTextTranslator class >> availableLanguageLocaleIDs [
"GetTextTranslator availableLanguageLocaleIDs"
	| ids dirs localeDirForLang directoryNames |
	ids _ Set new.
	dirs _ Set new.
	dirs addAll: LocaleDirsForDomain values.
	dirs addAll: self defaultLocaleDirs.
	dirs do: [:dir |
		| localesDir |
		localesDir _ dir assureExistence. 
		directoryNames _ [localesDir directoryNames] on: FileDoesNotExistException do: [:e | #()].
		directoryNames			do: [:langDirName | | localeID  |
			localeID _ LocaleID posixName: langDirName.
			localeDirForLang _ (localesDir / localeID posixName / 'LC_MESSAGES') assureExistence.
			localeDirForLang ifNotNil: [
				(localeDirForLang fileMatching: '*.mo') ifNotNil: [ids add: localeID]
			]
		].
	].
	^ids
]

{ #category : 'private' }
GetTextTranslator class >> createAvailableTranslators [
"Load new instances of translators corresponding to the currently available translation files"
	self setupLocaleDirs.
	self availableLanguageLocaleIDs do: [ :localeID |
		NaturalLanguageTranslator translators 
			at: localeID 
			put: (self newForLocaleID: localeID).
	]
]

{ #category : 'translation data layout' }
GetTextTranslator class >> defaultLocaleDirs [
	| dirs |
	dirs _ OrderedCollection new.
	UserDefaultLocaleDirs ifNotNil: [dirs addAll: UserDefaultLocaleDirs].
	dirs addAll: self systemDefaultLocaleDirs.
	^dirs

]

{ #category : 'private' }
GetTextTranslator class >> findMOForLocaleID: id domain: aDomainName [
	| moFile |
	(self localeDirsForDomain: aDomainName) do: [:each |
		moFile _ each / id posixName / 'LC_MESSAGES' // (aDomainName, '.mo').
		[moFile exists ifTrue: [^moFile] ] 
			on: FileDoesNotExistException 
			do: [:e | ^nil]].
	^nil
]

{ #category : 'class initialization' }
GetTextTranslator class >> initialize [
	SystemDefaultLocaleDirs _ OrderedCollection new.
	UserDefaultLocaleDirs _ OrderedCollection new.
	LocaleDirsForDomain _ Dictionary new.
]

{ #category : 'translation data layout' }
GetTextTranslator class >> localeDirForDomain: aDomainName [
	"returns registered localeDirectory for the textdomain. returns nil if not registered"
	^LocaleDirsForDomain at: aDomainName ifAbsent: [nil]
]

{ #category : 'private' }
GetTextTranslator class >> localeDirsForDomain [
	^LocaleDirsForDomain ifNil: [LocaleDirsForDomain _ Dictionary new]
]

{ #category : 'translation data layout' }
GetTextTranslator class >> localeDirsForDomain: aDomainName [
	"returns collection of locale directories for text domain.  
	This includes user defined one for the domain, user defaults and system defaults" 
	| dirs dir |
	dirs _ OrderedCollection new.
	dir _ self localeDirForDomain: aDomainName.
	dir ifNotNil: [dirs add: dir].
	dirs addAll:  self defaultLocaleDirs. 
	
	^dirs
]

{ #category : 'instance creation' }
GetTextTranslator class >> newForLocaleID: id [
	^self new localeID: id
]

{ #category : 'private' }
GetTextTranslator class >> privateStartUp [

	self createAvailableTranslators
]

{ #category : 'actions' }
GetTextTranslator class >> reset [
	"Flush remembered stuff.
	Load new translators (based on the files currently found)"
	
	super reset.
	
	self createAvailableTranslators 
	 
	
]

{ #category : 'translation data layout' }
GetTextTranslator class >> setLocaleDir: path forDoamin: aDomainName [
	self localeDirsForDomain
		at: aDomainName
		put: path.
]

{ #category : 'translation data layout' }
GetTextTranslator class >> setupLocaleDirs [
	| dirs |
	SystemDefaultLocaleDirs _ nil.
	dirs _ self systemDefaultLocaleDirs.
	dirs add:  DirectoryEntry smalltalkImageDirectory / 'locale'.
	dirs add:  DirectoryEntry vmDirectory / 'locale'.
	^dirs
]

{ #category : 'translation data layout' }
GetTextTranslator class >> systemDefaultLocaleDirs [
	^SystemDefaultLocaleDirs ifNil: [SystemDefaultLocaleDirs _ OrderedCollection new]

]

{ #category : 'translation data layout' }
GetTextTranslator class >> userDefaultLocaleDirs [
	^UserDefaultLocaleDirs ifNil: [UserDefaultLocaleDirs _ OrderedCollection new]

]

{ #category : 'accessing' }
GetTextTranslator >> domainRegistered: aDomainName [
	"only current translator actually load the MO, to minimize loading time.
	 other translator will load anyway when it goes current"
	(self class current == self) 
		ifTrue: [self moFileForDomain: aDomainName].
	
]

{ #category : 'accessing' }
GetTextTranslator >> domainUnregistered: aDomainName [
	moFiles removeKey: aDomainName ifAbsent: [^self]
	
]

{ #category : 'initialize-release' }
GetTextTranslator >> initialize [
	moFiles _ Dictionary new.
]

{ #category : 'private' }
GetTextTranslator >> loadMOFileForDomain: aDomainName [
	| moName |
	moName _ self class 
		findMOForLocaleID: self localeID
		domain: aDomainName.
	moName notNil
		 ifTrue: [^MOFile new :: 
			load: moName	localeID: self localeID]
		ifFalse: [^nil]

]

{ #category : 'accessing' }
GetTextTranslator >> loadMOFiles [
	TextDomainManager allKnownDomains 
		do: [:domainName | 
			self moFileForDomain: domainName
		].
]

{ #category : 'private' }
GetTextTranslator >> moFileForDomain: domainName [
"Returns the cached MOFile for the given domainName (or nil).
If none is cached, it will try to load one (every time) and cache it on demand."
	| moFile |
	^moFiles 
		at: domainName 
		ifAbsent: [
			moFile _ self loadMOFileForDomain: domainName.
			moFile notNil ifTrue:[				moFiles at: domainName put: moFile].
			moFile]
]

{ #category : 'accessing' }
GetTextTranslator >> refresh [
	"Purge the cached translations (and load on demand)"
	
	moFiles _ Dictionary new

]

{ #category : 'language switching' }
GetTextTranslator >> setCurrent [
	"ensure actual contents of MOs is loaded on switching language"
	self loadMOFiles
]

{ #category : 'translation' }
GetTextTranslator >> translate: aString inDomain: aDomainName [
	| mo |
	mo _ self moFileForDomain: aDomainName.
	^mo isNil 
		ifTrue: [aString] 
		ifFalse: [mo translationFor: aString]

]
