"
Export translations to gettext format divided into categories.

"Export gettext template files"
GetTextExporter new exportTemplate.

"Export translation files for current locale"
GetTextExporter new exportTranslator: (InternalTranslator newLocaleID: LocaleID current).

"Export all gettext template and po files."
GetTextExporter exportAll.

"To register a class category as a new domain"
TextDomainManager registerClassCategory: 'Morphic-Books' domain: 'Book'.
"Remove a class category"
TextDomainManager unregisterClassCategory: 'Morphic-Books'.
"
Class {
	#name : 'GetTextExporter',
	#superclass : 'Object',
	#instVars : [
		'stream'
	],
	#category : 'Gettext',
	#package : 'Gettext'
}

{ #category : 'accessing' }
GetTextExporter class >> defaultSelectors [
	"Answers the selectors that are sent to strings that should be translated"
	
	^ #(
		#translated 
		#translatedNoop
		)
]

{ #category : 'utilities' }
GetTextExporter class >> exportTemplate [
	"GetTextExporter exportTemplate"
	self new exportTemplate
]

{ #category : 'utilities' }
GetTextExporter class >> exportTemplateFor: someSelectors [
	"Writes files to be used as the translation template.
	It will include strings that are receivers of any of someSelectors"
	
	self new exportFor: someSelectors 
]

{ #category : 'utilities' }
GetTextExporter class >> exportTemplateIncluding: aSelector [
	"Writes files to be used as the translation template.
	It will include strings that are receivers of aSelector"
	
	self exportTemplateFor: self defaultSelectors, {aSelector} 
]

{ #category : 'utilities' }
GetTextExporter class >> keys [
	| categories |
	categories _ Dictionary new.
	GetTextExporter new appendTranslations: categories.
	^ categories values
		inject: Set new
		into: [:set :next | set addAll: next keys;
				 yourself]
]

{ #category : 'private' }
GetTextExporter >> appendStringReceivers: aSymbol into: domains [
	| literals references domainName methodReference keywords found |
	
	found _ TranslatedReceiverFinder new stringReceiversOf: aSymbol.
	found do: [ :assoc |
		methodReference _ assoc key.
		keywords _ assoc value.
		domainName _ self getTextDomainForClassCategory:			methodReference methodClass category.
		literals _ domains at: domainName ifAbsentPut: [Dictionary new].
		keywords do: [ :literal |
			references _ literals at: literal ifAbsentPut: [OrderedCollection new].
			references add: methodReference.
		].
	]. 

]

{ #category : 'exporting' }
GetTextExporter >> appendTranslations: domains  [

	self 
		appendTranslations: domains 
		for: self class defaultSelectors 
]

{ #category : 'exporting' }
GetTextExporter >> appendTranslations: domains for: someSelectors [
	"Append translations in the given domains.
	Will be done by searching for strings receiving the given selectors"

	someSelectors do:[ :selector |
		self appendStringReceivers: selector into: domains]

]

{ #category : 'private' }
GetTextExporter >> createHeaders [
	| headers |
	headers _ OrderedCollection new.
	headers add: 'Project-Id-Version' -> 'Cuis'.
	headers add: 'POT-Creation-Date' -> self currentDateAndTime.
	headers add: 'PO-Revision-Date' -> self currentDateAndTime.
	headers add: 'Last-Translator' -> ''.
	headers add: 'Language-Team' -> ''.
	headers add: 'MIME-Version' -> '1.0'.
	headers add: 'Content-Type' -> ('text/plain; charset=ascii').
	headers add: 'Content-Transfer-Encoding' -> '8bit'.
	headers add: 'X-Cuis-SystemVersion' -> (SystemVersion current asString).
	^ headers
]

{ #category : 'private' }
GetTextExporter >> currentDateAndTime [
	^ String
		streamContents: [:aStream | 
			aStream nextPutAll: Date today yyyymmdd;
				space.
			Time now
				print24: true
				showSeconds: false
				on: aStream.
			aStream nextPutAll: '-0000']
]

{ #category : 'exporting' }
GetTextExporter >> dirNameDomain: domain [
"Answer a file name for the domain."
	^ 'po' asDirectoryEntry / domain // (domain , '.pot')

]

{ #category : 'private' }
GetTextExporter >> export: literals domain: domainName  [
"Export a gettext file in a category. literals is a dictionary of keyword -> #(MethodReference...) in the textDomain."
	| fileEntry |	
	fileEntry _ self dirNameDomain: domainName.
	fileEntry ensureParent.
	[stream _ fileEntry forceWriteStream.
	self exportHeader: domainName.
	self exportBody: literals] 		
		ensure: 	[stream close]
]

{ #category : 'file out' }
GetTextExporter >> exportBody: literals [
	"Export a gettext file body. literals is a dictionary of keyword ->
	#(MethodReference...) in the textDomain."
	"Build {sortKey. comment. msgid } to optimize sorting (getting category is
	too slow).
	If there are two or more methods for a mgsid, only first method
	(alphabetical) is used for sorting."
	| sorted msgid sortedMethods category sortKey comment triplets commentUnderLined |
	triplets _ literals associations collect: [:assoc | 
		msgid _ assoc key.
		sortedMethods _ assoc value asArray sort.
		category _ sortedMethods first actualClass category asString.
		sortKey _ category , ',' , sortedMethods first printString , ',' , msgid.
		comment _ (sortedMethods
			collect: [:each | each actualClass asString , '>>' , each selector asString])
			inject: category
			into: [:result :methodName | result , ',' , methodName].
		"Replace white spaces to _ because gettext tool might replace a space to 
		a new line some times, and it makes 		difficult to take a diff."
		commentUnderLined _ comment copyReplaceAll: ' ' with: '_'.
		Array 	with: sortKey with: commentUnderLined with: msgid].
	
	"Sort and output the words"
	sorted _ triplets			sort: [:a :b | a first <= b first].
	sorted 	do: [:triplet | 
		comment _ triplet second.
		msgid _ triplet third.
		self exportRecordHeader: comment.
		self exportPhrase: msgid]
]

{ #category : 'exporting' }
GetTextExporter >> exportFor: someSelectors [
"Export translation files. the file extention is 'pot'"
	| domains |
	domains _ Dictionary new.
	self appendTranslations: domains for: someSelectors.
	domains 	keysAndValuesDo: [:domainName :value | 	
		self export: value 	domain: domainName]
]

{ #category : 'private' }
GetTextExporter >> exportHeader: domainName [
	| headers |
	self exportTag: 'msgid' msg: ''.
	self exportTag: 'msgstr' msg: ''.
	headers _ self createHeaders.
	headers add: 'X-Cuis-Domain' -> domainName.
	headers do: [:each | self exportHeaderLineKey: each key value: each value].
	stream lf
]

{ #category : 'private' }
GetTextExporter >> exportHeaderLineKey: keyString value: valueString  [
	stream nextPut: $";
		 nextPutAll: keyString;
		 nextPut: $:;
		 space;
		 nextPutAll: valueString;
		 nextPutAll: '\n';
		 nextPut: $";
		 lf.
]

{ #category : 'private' }
GetTextExporter >> exportPhrase: phraseString [
	phraseString ifEmpty: [^ self].
	self exportTag: 'msgid' msg: phraseString.
	self exportTag: 'msgstr' msg: ''.
	stream lf

]

{ #category : 'private' }
GetTextExporter >> exportRecordHeader: context [
	stream 
		nextPutAll: '#: ';
		nextPutAll: context;
		lf.
]

{ #category : 'private' }
GetTextExporter >> exportTag: tag msg: aString  [
	| pos end line |
	(aString indexOf: Character lf)	 = 0
		ifTrue: [self exportTag: tag singleLine: aString]
		ifFalse: [self exportTag: tag singleLine: ''.
			pos _ 1.
			end _ 0.
			[end < aString size]
				whileTrue: [end _ aString indexOf: Character lf startingAt: pos.
					end = 0
						ifTrue: [end _ aString size].
					line _ aString copyFrom: pos to: end.
					stream nextPut: $";
						
						nextPutAll: (self formatString: line);
						 nextPut: $";
						 lf.
					pos _ end + 1]]
]

{ #category : 'private' }
GetTextExporter >> exportTag: tag singleLine: aString  [
	stream nextPutAll: tag.
	stream space.
	stream nextPut: $".
	stream
		nextPutAll: (self formatString: aString).
	stream nextPut: $".
	stream lf
]

{ #category : 'exporting' }
GetTextExporter >> exportTemplate [
	"GetTextExporter new exportTemplate"
	self exportFor: self class defaultSelectors 
]

{ #category : 'private' }
GetTextExporter >> formatReplacements [
	| replacements |
	replacements _ OrderedCollection new.
	replacements add: '\' -> '\\'.
	replacements add: String lfString -> '\n'.
	replacements add: String tab -> '\t'.
	replacements add: '"' -> '\"'.
	^ replacements
]

{ #category : 'private' }
GetTextExporter >> formatString: aString  [
	| result |
	result _ aString.
	self formatReplacements
		do: [:each | result _ result copyReplaceAll: each key with: each value].
	^ result
]

{ #category : 'private' }
GetTextExporter >> getTextDomainForClassCategory: aClassCategory [
	^TextDomainManager domainForClassCategory:  aClassCategory
		
]

{ #category : 'accessing' }
GetTextExporter >> stream [
	^ stream
]

{ #category : 'accessing' }
GetTextExporter >> stream: aStream [
	stream _ aStream
]
