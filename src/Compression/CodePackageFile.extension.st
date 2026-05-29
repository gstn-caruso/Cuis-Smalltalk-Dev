Extension { #name : 'CodePackageFile' }

{ #category : '*Compression' }
CodePackageFile class >> monticelloPackageNameFrom: fullName [
	| localName |
	localName _ fullName asFileEntry name.
	^(localName prefixAndSuffix: $-)
		ifNotNil: [ :ary | ary first ]
		ifNil: [ localName withoutSuffix: '.mcz' ]
]
