"
This class represents an identity dictionary with weak keys.
"
Class {
	#name : 'WeakIdentityKeyDictionary',
	#superclass : 'WeakKeyDictionary',
	#category : 'WeakDictionaries',
	#package : 'WeakDictionaries'
}

{ #category : 'private' }
WeakIdentityKeyDictionary >> scanFor: anObject [
	"ar 10/21/2000: The method has been copied to this location to indicate that whenever #scanFor: changes #scanForNil: must be changed in the receiver as well."
	"Scan the key array for the first slot containing either a nil (indicating an empty slot) or an element that matches anObject. Answer the index of that slot or zero if no slot is found. This method will be overridden in various subclasses that have different interpretations for matching elements."
	| finish scale start element |
	finish := array size.
	scale := finish // (Smalltalk maxIdentityHash + 1).
	scale = 0 ifTrue: [scale := 1].
	start := anObject identityHash * scale \\ finish + 1.

	"Search from (hash mod size) to the end."
	start to: finish do:
		[:index | ((element := array at: index) == nil or: [element key == anObject])
			ifTrue: [^ index ]].

	"Search from 1 to where we started."
	1 to: start-1 do:
		[:index | ((element := array at: index) == nil or: [element key == anObject])
			ifTrue: [^ index ]].

	^ 0  "No match AND no empty slot"
]

{ #category : 'private' }
WeakIdentityKeyDictionary >> scanForNil: anObject [
	"Private. Scan the key array for the first slot containing nil (indicating an empty slot). Answer the index of that slot."

	| finish scale start |
	finish := array size.
	scale := finish // (Smalltalk maxIdentityHash + 1).
	scale = 0 ifTrue: [scale := 1].
	start := anObject identityHash * scale \\ finish + 1.

	"Search from (hash mod size) to the end."
	start to: finish do:
		[:index | (array at: index) == nil ifTrue: [^ index ]].

	"Search from 1 to where we started."
	1 to: start-1 do:
		[:index | (array at: index) == nil ifTrue: [^ index ]].

	^ 0  "No match AND no empty slot"
]
