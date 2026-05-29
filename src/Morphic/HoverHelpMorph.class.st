"
A balloon with text used for the display of explanatory information.
"
Class {
	#name : 'HoverHelpMorph',
	#superclass : 'ColoredBoxMorph',
	#instVars : [
		'target',
		'getter',
		'doAutoWordWrap',
		'contents',
		'textComposition'
	],
	#category : 'Morphic-Composite Widgets',
	#package : 'Morphic',
	#tag : 'Composite Widgets'
}

{ #category : 'new-morph participation' }
HoverHelpMorph class >> categoryInNewMorphMenu [

	^ 'User Interface'
]

{ #category : 'instance creation' }
HoverHelpMorph class >> contents: aStringOrText [
	"Make up and return a HoverHelp for morph.
	(HoverHelpMorph contents: 'This is a HoverHelpMorph with a rather largish contents, to show the effect of word wrap.') openInHand
	"

	^ self contents: aStringOrText doWordWrap: true
]

{ #category : 'instance creation' }
HoverHelpMorph class >> contents: aStringOrText doWordWrap: aBoolean [
	"Make up and return a HoverHelp for morph.
	(HoverHelpMorph contents: 'This is a HoverHelpMorph with a rather largish contents, to show the effect of word wrap.' doWordWrap: true) openInHand
	(HoverHelpMorph contents: 'This is a HoverHelpMorph with a rather largish contents, to show the effect of word wrap.' blue doWordWrap: false) openInHand
	Contenido fijo. decision de wrappear en creacion. openInWorld a cargo del usuario.
	Este parece ser el unico lugr donde se determina un ancho razonable al cual wrappear.
	Solo hacerlo si hay que autowrappear, pero en todos lados!
	"

	| answer |
	answer := self new.
	answer doAutoWordWrap: aBoolean.
	answer contents: aStringOrText wrappedTo: nil.
	^answer
]

{ #category : 'instance creation' }
HoverHelpMorph class >> contents: aStringOrText wrappedTo: wordWrapWidthOrNil [
	"Make up and return a HoverHelp for morph.
	(HoverHelpMorph contents: 'This is a HoverHelpMorph with a rather long contents to see how it gets wrapped. Is this long enough? Maybe a few more words are in order.'
		wrappedTo: 150) openInHand
	(HoverHelpMorph contents: 'This is a HoverHelpMorph with a rather long contents to see how it gets wrapped. Is this long enough? Maybe a few more words are in order.'
		wrappedTo: nil) openInHand
	"
	| answer |
	answer := self new.
	answer doAutoWordWrap: wordWrapWidthOrNil notNil.
	answer contents: aStringOrText wrappedTo: wordWrapWidthOrNil.
	^answer
]

{ #category : 'instance creation' }
HoverHelpMorph class >> initializedInstance [
	"Answer an instance of the receiver which in some sense is initialized.  In the case of Morphs, this will yield an instance that can be attached to the Hand after having received the same kind of basic initialization that would be obtained from an instance chosen from the 'new morph' menu.
	Return nil if the receiver is reluctant for some reason to return such a thing"

	^ self contents: 'A Hover Help'
]

{ #category : 'instance creation' }
HoverHelpMorph class >> target: aTargetMorph getter: aSelector [
	"Make up and return a HoverHelp for morph.
	"

	^self new target: aTargetMorph getter: aSelector
]

{ #category : 'accessing' }
HoverHelpMorph >> contents: aStringOrText wrappedTo: wordWrapWidthOrNil [
	"Do wordwrap as set up.
	If requested, honor wordWrapWidthOrNil or find a good default if nil.
	If not requested, make the morph as wide as needed"

	| contentsToCompose lastIsLineSeparator width |
	contents := aStringOrText.
	contents isEmptyOrNil ifTrue: [
		textComposition := nil.
		^self ].
	contentsToCompose := aStringOrText.
	lastIsLineSeparator := aStringOrText last isLineSeparator.
	lastIsLineSeparator ifTrue: [
		contentsToCompose := aStringOrText allButLast ].
	width := (doAutoWordWrap ifNil: [lastIsLineSeparator not])
		ifTrue: [
			wordWrapWidthOrNil ifNil: [
				FontFamily defaultLineSpacing * (aStringOrText size sqrt * 2.0 max: 13)]]
		ifFalse: [9999999].
	textComposition := TextComposition new.
	textComposition
		setModel: (TextModel withText: contentsToCompose asText);
		extentForComposing: width@9999999.
	textComposition composeAll.
	self morphExtent: textComposition usedExtent + 8.
]

{ #category : 'initialization' }
HoverHelpMorph >> defaultColor [

	^ Theme current hoverHelp
]

{ #category : 'accessing' }
HoverHelpMorph >> defaultLayerNumber [
	"Morphs with smaller layer number will always cover those with larger ones.
	We want to be on top."

	^10
]

{ #category : 'accessing' }
HoverHelpMorph >> doAutoWordWrap: aBooleanOrNil [
	"true -> do it
	false -> don't do it
	nil -> Let contents decide.
		Do it unless contents last is newline character.
		Add a bogus newline at the end if your contents
		is a single line and you don't want wordwrap."

	doAutoWordWrap := aBooleanOrNil.
]

{ #category : 'drawing' }
HoverHelpMorph >> drawOn: aCanvas [

	| r |
	
	contents isEmptyOrNil ifTrue: [ ^self ].
	
	r := self localBounds.
	aCanvas roundRect: r color: color radius: 4.
	aCanvas
		drawTextComposition: textComposition
		at: `4@4`
		extent: extent - 8
		color: `Color black`
		selectionColor: (Theme current textHighlightFocused: false).
]

{ #category : 'testing' }
HoverHelpMorph >> isIncludedInTaskbar [
	"Answer true a button for us should be added to any TaskbarMorph."

	^ false
]

{ #category : 'initialization' }
HoverHelpMorph >> popUpForHand: aHand [
	"Pop up the receiver as balloon help for the given hand"

	| dynamicContents newPos x y |
	dynamicContents := target
		ifNil: [ contents ]
		ifNotNil: [
			getter
				ifNotNil: [target perform: getter]
				ifNil: [target balloonText]].
	self contents: dynamicContents wrappedTo: nil.
	"Tooltip ABOVE mouse pointer"
	"x := aHand morphPosition x - (extent x // 4)
		min: aHand world morphWidth - extent x - 10
		max: 10.
	y := aHand morphPosition y - extent y - 10.
	y < 5 ifTrue: [
		y := aHand morphPosition y + (Cursor currentCursor height * 3//2) ]."
	"Tooltip BELOW mouse pointer (standard in most UIs)"
	x := aHand morphPosition x min: aHand world morphWidth - extent x - 10.
	y := aHand morphPosition y + Cursor currentCursor height.
	y + extent y > aHand world morphHeight ifTrue: [
		y := aHand morphPosition y - extent y - 12].
	newPos := x@y.
	aHand world addMorphFront: self position: newPos.
	aHand balloonHelp: self.
]

{ #category : 'accessing' }
HoverHelpMorph >> target [
	^target
]

{ #category : 'accessing' }
HoverHelpMorph >> target: aTargetMorph getter: aSelector [
	target := aTargetMorph.
	getter := aSelector.
]
