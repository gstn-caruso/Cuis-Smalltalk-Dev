Extension { #name : 'CharacterSequence' }

{ #category : '*Gettext' }
CharacterSequence >> translated [
"answer the receiver translated to the default language"
	^ NaturalLanguageTranslator translate: self

]

{ #category : '*Gettext' }
CharacterSequence >> translatedTo: localeID  [
	"answer the receiver translated to the given locale id"
	^ NaturalLanguageTranslator translate: self toLocale: localeID
]
