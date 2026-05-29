"
I am a dictionary holding only weakly on my keys. This is a bit dangerous since at any time my keys can go away. Clients are responsible to register my instances by WeakArray such that the appropriate actions can be taken upon loss of any keys.

"
Class {
	#name : 'WeakKeyDictionary',
	#superclass : 'Dictionary',
	#category : 'WeakDictionaries',
	#package : 'WeakDictionaries'
}

{ #category : 'adding' }
WeakKeyDictionary >> add: anAssociation [
	self at: anAssociation key put: anAssociation value.
	^ anAssociation
]

{ #category : 'accessing' }
WeakKeyDictionary >> associationClass [

	^WeakKeyAssociation
]

{ #category : 'accessing' }
WeakKeyDictionary >> at: key put: anObject  [
	"Set the value at key to be anObject.  If key is not found, create a new
	entry for key and set is value to anObject. Answer anObject."
	
	key ifNil: [ ^anObject ].
	^super at: key put: anObject
]

{ #category : 'finalization' }
WeakKeyDictionary >> finalizeValues [
	"remove all nil keys and rehash the receiver afterwards"
	| assoc |
	1 to: array size do:[:i|
		assoc := array at: i.
		(assoc notNil and:[assoc key == nil]) ifTrue:[array at: i put: nil].
	].
	self rehash.
]

{ #category : 'finalization' }
WeakKeyDictionary >> finalizeValues: finiObjects [
	"Remove all associations with key == nil and value is in finiObjects.
	This method is folded with #rehash for efficiency."
	| oldArray assoc newIndex |
	oldArray := array.
	array := Array new: oldArray size.
	tally := 0.
	1 to: array size do:[:i|
		assoc := oldArray at: i.
		assoc ifNotNil:[
			(assoc key == nil and:[finiObjects includes: assoc value]) ifFalse:[
				newIndex := self scanForNil: assoc key.
				self atNewIndex: newIndex put: assoc].
		].
	].
]

{ #category : 'private' }
WeakKeyDictionary >> fixCollisionsFrom: oldIndex [
	"The element at index has been removed and replaced by nil."
	self rehash. "Do it the hard way - we may have any number of nil keys and #rehash deals with them"
]

{ #category : 'accessing' }
WeakKeyDictionary >> keysDo: aBlock  [
	"Evaluate aBlock for each of the receiver's keys."
	self associationsDo: [:association | 
		association key ifNotNil:[aBlock value: association key]].
]

{ #category : 'private' }
WeakKeyDictionary >> rehash [
	"Rehash the receiver. Reimplemented to allow for multiple nil keys"
	| oldArray assoc newIndex |
	oldArray := array.
	array := Array new: oldArray size.
	tally := 0.
	1 to: array size do:[:i|
		assoc := oldArray at: i.
		assoc ifNotNil:[
			newIndex := self scanForNil: assoc key.
			self atNewIndex: newIndex put: assoc.
		].
	].
]

{ #category : 'private' }
WeakKeyDictionary >> scanFor: anObject [
	"ar 10/21/2000: The method has been copied to this location to indicate that whenever #scanFor: changes #scanForNil: must be changed in the receiver as well."
	"Scan the key array for the first slot containing either a nil (indicating an empty slot) or an element that matches anObject. Answer the index of that slot or zero if no slot is found. This method will be overridden in various subclasses that have different interpretations for matching elements."
	| element start finish |
	start := (anObject hash \\ array size) + 1.
	finish := array size.

	"Search from (hash mod size) to the end."
	start to: finish do:
		[:index | ((element := array at: index) == nil or: [element key = anObject])
			ifTrue: [^ index ]].

	"Search from 1 to where we started."
	1 to: start-1 do:
		[:index | ((element := array at: index) == nil or: [element key = anObject])
			ifTrue: [^ index ]].

	^ 0  "No match AND no empty slot"
]

{ #category : 'private' }
WeakKeyDictionary >> scanForNil: anObject [
	"Private. Scan the key array for the first slot containing nil (indicating an empty slot). Answer the index of that slot."
	| start finish |
	start := (anObject hash \\ array size) + 1.
	finish := array size.

	"Search from (hash mod size) to the end."
	start to: finish do:
		[:index | (array at: index) == nil ifTrue: [^ index ]].

	"Search from 1 to where we started."
	1 to: start-1 do:
		[:index | (array at: index) == nil ifTrue: [^ index ]].

	^ 0  "No match AND no empty slot"
]

{ #category : 'public' }
WeakKeyDictionary >> slowSize [
	"Careful! Answer the maximum amount
	of elements in the receiver, not the
	exact amount"

	| count |
	count := 0.
	1 to: array size do: [ :index |
		(array at: index) ifNotNil: [ :object |
			object key ifNotNil: [
				count := count + 1 ] ] ].
	^count
]
