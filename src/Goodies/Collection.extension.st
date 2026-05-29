Extension { #name : 'Collection' }

{ #category : '*Goodies-Collections' }
Collection >> asIdentitySkipList [
	"Answer a IdentitySkipList whose elements are the elements of the 
	receiver. The sort order is the default less than or equal."

	^ self as: IdentitySkipList
]

{ #category : '*Goodies-Collections' }
Collection >> asSkipList [
	"Answer a SkipList whose elements are the elements of the 
	receiver. The sort order is the default less than or equal."

	^ self as: SkipList
]

{ #category : '*Goodies-Collections' }
Collection >> asSkipList: aSortBlock  [
	"Answer a SkipList whose elements are the elements of the 
	receiver. The sort order is defined by the argument, aSortBlock."

	| skipList |
	skipList _ SkipList new: self size sortBlock: aSortBlock.
	skipList addAll: self.
	^ skipList
]
