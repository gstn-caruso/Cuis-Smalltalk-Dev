"
Locale current
Locale current isoLanguage
Locale current isoCountry


References:
http://www.w3.org/WAI/ER/IG/ert/iso639.htm
http://www.oasis-open.org/cover/iso639a.html
http://oss.software.ibm.com/cvs/icu/~checkout~/icuhtml/design/language_code_issues.html
http://www.w3.org/Protocols/rfc2616/rfc2616-sec3.html#sec3.10
	
ISO 3166
http://mitglied.lycos.de/buran/knowhow/codes/locales/
"
Class {
	#name : 'Locale',
	#superclass : 'Object',
	#instVars : [
		'id'
	],
	#classVars : [
		'Activated',
		'Current',
		'CurrentPlatform',
		'KnownLocales',
		'LanguageSymbols',
		'LocaleChangeListeners',
		'PlatformEncodings',
		'Previous'
	],
	#category : 'Locales',
	#package : 'Locales'
}

{ #category : 'settings' }
Locale class >> activated [
	^ Activated ifNil: [Activated _ false]
]

{ #category : 'settings' }
Locale class >> activated: aBoolean [
	Activated _ aBoolean
]

{ #category : 'notification' }
Locale class >> addLocalChangedListener: anObjectOrClass [
	self localeChangedListeners add: anObjectOrClass
]

{ #category : 'accessing' }
Locale class >> current [

	^ Current ifNil: [ Current _ self determineCurrentLocale ]
]

{ #category : 'accessing' }
Locale class >> currentPlatform: locale during: aBlock  [
	"Alter current locale during a block"
	| savedLocale |
	savedLocale _ self current.
	[self switchTo: locale.
	aBlock value]
		ensure: [self switchTo: savedLocale]
]

{ #category : 'platform specific' }
Locale class >> defaultEncodingName: languageSymbol  [
	| encodings platformName osVersion |
	platformName _ Smalltalk platformName.
	osVersion _ Smalltalk osVersion.
	encodings _ self platformEncodings at: languageSymbol
				ifAbsent: [self platformEncodings at: #default].
	encodings at: platformName ifPresent: [:encoding | ^encoding].
	encodings at: platformName , ' ' , osVersion
		ifPresent: [:encoding | ^encoding].
	^encodings at: #default
]

{ #category : 'private' }
Locale class >> defaultLocales [
	
	"return IDs of default locales"
	
	^ #(de en es fr it)
]

{ #category : 'private' }
Locale class >> determineCurrentLocale [
	"For now just return the default locale.
	A smarter way would be to determine the current platforms default locale."
	"Locale determineCurrentLocale"

	^self new determineLocale
]

{ #category : 'private' }
Locale class >> initKnownLocales [
	| locales |
	locales _ Dictionary new.

	"Init the locales for which we have translations"
	self defaultLocales do: [:id |
		locales at: id put: (self new localeID: id)].
	^locales
]

{ #category : 'initialization' }
Locale class >> initialize [
	Smalltalk addToStartUpList: Locale.
	Preferences 
		name: #useLocale
		description: 'Use the system locale to set the system language, etc., at startup.  For time-zone handling, see automaticTimezone.'
		category: #system
		type: Boolean
		value: false

]

{ #category : 'initialization' }
Locale class >> initializePlatformEncodings [
	"Locale initializePlatformEncodings"

	| platform |
	PlatformEncodings ifNil: [ PlatformEncodings _ Dictionary new ].

	platform _ PlatformEncodings at: 'default' ifAbsentPut: Dictionary new.
	platform
		at: 'default' put: 'iso8859-1';
		at: 'Win32 CE' put: 'utf-8'.

	platform _ PlatformEncodings at: 'ja' ifAbsentPut: Dictionary new.
	platform
		at: 'default' put: 'shift-jis';
		at: 'unix' put: 'euc-jp';
		at: 'Win32 CE' put: 'utf-8'.
		
	platform _ PlatformEncodings at: 'ko' ifAbsentPut: Dictionary new.
	platform
		at: 'default' put: 'euc-kr';
		at: 'Win32 CE' put: 'utf-8'.

	platform _ PlatformEncodings at: 'zh' ifAbsentPut: Dictionary new.
	platform
		at: 'default' put: 'gb2312';
		at: 'unix' put: 'euc-cn';
		at: 'Win32 CE' put: 'utf-8'.

]

{ #category : 'accessing' }
Locale class >> isoLanguage: isoLanguage [
	^self isoLanguage: isoLanguage isoCountry: nil
]

{ #category : 'accessing' }
Locale class >> isoLanguage: isoLanguage isoCountry: isoCountry [
	^self localeID: (LocaleID  isoLanguage: isoLanguage isoCountry: isoCountry)
]

{ #category : 'private' }
Locale class >> knownLocales [
	"KnownLocales := nil"
	^KnownLocales ifNil: [KnownLocales := self initKnownLocales]
]

{ #category : 'accessing' }
Locale class >> languageSymbol: languageSymbol [
	"Locale languageSymbol: #Deutsch"

	^self isoLanguage: (LanguageSymbols at: languageSymbol)
]

{ #category : 'notification' }
Locale class >> localeChanged [
"	SystemNavigation default allBehaviorsDo: [:b |
		b == self ifFalse: [b localeChanged]].
"
]

{ #category : 'notification' }
Locale class >> localeChangedGently [
"	SystemNavigation default allBehaviorsDo: [:b | b == self ifFalse: [b localeChangedGently]].
"
]

{ #category : 'notification' }
Locale class >> localeChangedListeners [
	^LocaleChangeListeners ifNil: [LocaleChangeListeners := OrderedCollection new]
]

{ #category : 'accessing' }
Locale class >> localeID: id [
	^self knownLocales at: id ifAbsentPut: [Locale new localeID: id]
]

{ #category : 'class initialization' }
Locale class >> platformEncodings [
	PlatformEncodings isEmptyOrNil ifTrue: [ self initializePlatformEncodings ].
	^PlatformEncodings

]

{ #category : 'system startup' }
Locale class >> startUp: resuming [
	resuming ifFalse: [^self].
	(Preferences at: #useLocale)
		ifTrue: [
			| newID |
			newID := self current determineLocaleID.
			newID ~= LocaleID current
				ifTrue: [self switchToID: newID]]
]

{ #category : 'accessing' }
Locale class >> switchTo: locale [
	self switchTo: locale gently: false.

]

{ #category : 'accessing' }
Locale class >> switchTo: locale gently: gentlyFlag [
	"Locale switchTo: (Locale isoLanguage: 'de')"
	| nlTranslatorClass availableID |
	nlTranslatorClass := nil.
	availableID := locale localeID.
	availableID := Smalltalk at: #NaturalLanguageTranslator ifPresent: [ :c |
		nlTranslatorClass := c.
		(nlTranslatorClass availableForLocaleID: locale localeID) localeID ].
	Current localeID = availableID ifFalse: [
			Previous := Current.
			CurrentPlatform := Current := Locale localeID: availableID.
			nlTranslatorClass ifNotNil: [ nlTranslatorClass localeChanged ].
			gentlyFlag ifTrue: [self localeChangedGently] ifFalse: [self localeChanged]]
]

{ #category : 'accessing' }
Locale class >> switchToID: localeID [
	"Locale switchToID: (LocaleID isoLanguage: 'de') "

	self switchTo: (Locale localeID: localeID)
]

{ #category : 'accessing' }
Locale >> determineLocale [
	self localeID: self determineLocaleID
]

{ #category : 'accessing' }
Locale >> determineLocaleID [
	"Locale current determineLocaleID"
	| langCode isoLang countryCode isoCountry |
	langCode := self fetchISO2Language.
	isoLang := langCode
		ifNil: [^self localeID]
		ifNotNil: [langCode].
	countryCode := self primCountry copyUpTo: Character null.
	isoCountry := countryCode
		ifNil: [^LocaleID isoLanguage: isoLang]
		ifNotNil: [countryCode].
	^LocaleID isoLanguage: isoLang isoCountry: isoCountry
]

{ #category : 'private' }
Locale >> fetchISO2Language [
	"Locale current fetchISO2Language"

	| lang isoLang |
	lang := self primLanguage.
	lang ifNil: [ ^ nil ].
	lang := lang copyUpTo: Character null.
	lang size = 2 ifTrue: [ ^ lang ].
	isoLang := ISOLanguageDefinition iso3LanguageDefinition: lang.
	^ isoLang ifNotNil: [ isoLang iso2 ]
]

{ #category : 'accessing' }
Locale >> isoCountry [
	^self localeID isoCountry
]

{ #category : 'accessing' }
Locale >> isoLanguage [
	^self localeID isoLanguage
]

{ #category : 'accessing' }
Locale >> isoLocale [
	"<language>-<country>"
	^self isoCountry
		ifNil: [self isoLanguage]
		ifNotNil: [self isoLanguage , '-' , self isoCountry]
]

{ #category : 'accessing' }
Locale >> localeID [
	^id
]

{ #category : 'accessing' }
Locale >> localeID: anID [
	id := anID
]

{ #category : 'system primitives' }
Locale >> primCountry [
	"Returns string with country tag according to ISO 639"
	<primitive: 'primitiveCountry' module: 'LocalePlugin'>
	^'FR'
]

{ #category : 'system primitives' }
Locale >> primCurrencyNotation [
	"Returns boolean if symbol is pre- (true) or post-fix (false)"
	<primitive: 'primitiveCurrencyNotation' module: 'LocalePlugin'>
	^true
]

{ #category : 'system primitives' }
Locale >> primCurrencySymbol [
	"Returns string with currency symbol"
	<primitive: 'primitiveCurrencySymbol' module:'LocalePlugin'>
	^'$'
]

{ #category : 'system primitives' }
Locale >> primDST [
	"Returns boolean if DST  (daylight saving time) is active or not"
	<primitive:'primitiveDaylightSavings' module: 'LocalePlugin'>
	^false
]

{ #category : 'system primitives' }
Locale >> primDecimalSymbol [
	"Returns string with e.g. '.' or ','"
	<primitive:'primitiveDecimalSymbol' module: 'LocalePlugin'>
	^'.'
]

{ #category : 'system primitives' }
Locale >> primDigitGrouping [
	"Returns string with e.g. '.' or ',' (thousands etc)"
	<primitive:'primitiveDigitGroupingSymbol' module: 'LocalePlugin'>
	^','
]

{ #category : 'system primitives' }
Locale >> primLanguage [
	"returns string with language tag according to ISO 639"
	<primitive:'primitiveLanguage' module: 'LocalePlugin'>
	^'en'
]

{ #category : 'system primitives' }
Locale >> primLongDateFormat [
	"Returns the long date format
	d day, m month, y year,
	double symbol is null padded, single not padded (m=6, mm=06)
	dddd weekday
	mmmm month name"
	<primitive:'primitiveLongDateFormat' module: 'LocalePlugin'>
	^'dddd, mmmm d, yyyy'

]

{ #category : 'system primitives' }
Locale >> primMeasurement [
	"Returns boolean denoting metric(true) or imperial(false)."
	<primitive:'primitiveMeasurementMetric' module: 'LocalePlugin'>
	^true

]

{ #category : 'system primitives' }
Locale >> primShortDateFormat [
	"Returns the short date format
	d day, m month, y year,
	double symbol is null padded, single not padded (m=6, mm=06)
	dddd weekday
	mmmm month name"
	<primitive:'primitiveShortDateFormat' module: 'LocalePlugin'>
	^'m/d/yy'

]

{ #category : 'system primitives' }
Locale >> primTimeFormat [
	"Returns string time format
	Format is made up of 
	h hour (h 12, H 24), m minute, s seconds, x (am/pm String)
	double symbol is null padded, single not padded (h=6, hh=06)"
	<primitive:'primitiveTimeFormat' module: 'LocalePlugin'>
	^'h:mmx'

]

{ #category : 'system primitives' }
Locale >> primTimezone [
	"The offset from UTC in minutes, with positive offsets being towards the east.
	(San Francisco is in UTC -08*60 and Paris is in GMT +01*60 (daylight savings is not in effect)."
	<primitive:'primitiveTimezoneOffset' module: 'LocalePlugin'>
	^0
]

{ #category : 'system primitives' }
Locale >> primVMOffsetToUTC [
	"Returns the offset in minutes between the VM and UTC.
	If the VM does not support UTC times, this is 0.
	Also gives us backward compatibility with old VMs as the primitive will fail and we then can return 0."
	<primitive:'primitiveVMOffsetToUTC' module: 'LocalePlugin'>
	^0
]

{ #category : 'printing' }
Locale >> printOn: aStream  [
	super printOn: aStream.
	aStream nextPutAll:  '(' ; print: id ; nextPutAll:  ')'
]
