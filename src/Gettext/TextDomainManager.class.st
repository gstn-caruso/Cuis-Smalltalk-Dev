"
I manages mapping from class category to textdomain (.mo files).

Usage:
	TextDomainManager registerCategoryPrefix: 'DrGeo' domain: 'drgeo'.
	TextDomainManager unregisterDomain: 'DrGeo'.

	TextDomainManager registerClass: #TerseGuideHelp domain: 'guides'.

The domain name map to a .mo file in {image|vm}Path/locale/{lang}/LC_MESSAGES/domain.mo
For example locale/fr/LC_MESSAGES/drgeo.mo
{lang} is the host language locale resolved by the Locales package.

Class variables:
 ClassCategories				IdentityDictionary -- classCategory -> domainName 
 Classes				IdentityDictionary -- class name (a Symbol) -> domainName   (a cache only!)
 DefaultDomain				String -- the default domain name
 DomainInfos				Dictionary -- domainName -> a TextDomainInfo
 LoneClasses				IdentityDictionary -- class name (a Symbol) -> domainName.  For classes whose entire category are not all in the same domain (BookMorph and QuickGuideMorph)


"
Class {
	#name : 'TextDomainManager',
	#superclass : 'Object',
	#classVars : [
		'ClassCategories',
		'Classes',
		'DefaultDomain',
		'DomainInfos',
		'LoneClasses'
	],
	#category : 'Gettext',
	#package : 'Gettext'
}

{ #category : 'accessing' }
TextDomainManager class >> allKnownDomains [
	| domains |
	domains _ Set new.
	domains addAll: ClassCategories values.
	domains add: self defaultDomain.
	^domains

]

{ #category : 'accessing' }
TextDomainManager class >> defaultDomain [
	^DefaultDomain
]

{ #category : 'accessing' }
TextDomainManager class >> defaultDomain: aDomainName [
	DefaultDomain _ aDomainName
]

{ #category : 'accessing' }
TextDomainManager class >> domainForClass: aClass [
	^Classes at: aClass theNonMetaClass name ifAbsent: [self defaultDomain]
]

{ #category : 'accessing' }
TextDomainManager class >> domainForClassCategory: aCategorySymbol [
	^ClassCategories at: aCategorySymbol ifAbsent: [self defaultDomain]
]

{ #category : 'private' }
TextDomainManager class >> domainInfoFor: domainName [
	^DomainInfos at: domainName ifAbsentPut: [ self registerDomain: domainName]
]

{ #category : 'private' }
TextDomainManager class >> domainInfos [
	^DomainInfos
]

{ #category : 'class initialization' }
TextDomainManager class >> initialize [
	"	TextDomainManager initialize	"

	ClassCategories _ IdentityDictionary new.
	Classes _ IdentityDictionary new.
	LoneClasses _ IdentityDictionary new.
	DomainInfos _ Dictionary new.
	self defaultDomain: 'cuis'.
]

{ #category : 'private' }
TextDomainManager class >> refresh [
	ClassCategories _ IdentityDictionary new.
	Classes _ IdentityDictionary new.
	DomainInfos keysAndValuesDo: [:domainName :domainInfo |
		domainInfo matchedSystemCategories do: [:cat |
			ClassCategories at: cat ifPresent: [self error: 'category ', (cat asString) , '  belongs to multiple domains'].
			ClassCategories at: cat put: domainName.
			(SystemOrganization listAtCategoryNamed: cat ) do: [ :cls |
				Classes at: cls put: domainName.
			]
		]
	].
	Classes addAll: LoneClasses.
]

{ #category : 'accessing' }
TextDomainManager class >> registerCategoryPrefix: aString domain: aDomainName [
	| domInfo |
	domInfo _ self domainInfoFor: aDomainName.
	domInfo categoryPrefixes add: aString.
	self refresh.
]

{ #category : 'accessing' }
TextDomainManager class >> registerClass: className domain: aDomainName [
	LoneClasses at: className put: aDomainName.
	self refresh.	"moves it to Classes"

]

{ #category : 'accessing' }
TextDomainManager class >> registerClassCategory: categorySymbol domain: aDomainName [
	| domInfo |
	domInfo _ self domainInfoFor: aDomainName.
	domInfo categories add: categorySymbol.
	self refresh.

]

{ #category : 'accessing' }
TextDomainManager class >> registerDomain: domainName [
	| domInfo |
	domInfo _ TextDomainInfo new.
	DomainInfos at: domainName put: domInfo.
	NaturalLanguageTranslator domainRegistered: domainName.
	^domInfo
]

{ #category : 'accessing' }
TextDomainManager class >> unregisterDomain: domainName [
	DomainInfos removeKey: domainName.
	self refresh.
	NaturalLanguageTranslator domainUnregistered: domainName.

]
