"
To be used with FormLayout.
Read 'FormLayout examples' in LayoutMorph class.

- 'topLeftEdgesWeight' and 'bottomRightEdgesWeight' are points representing the ox and oy positionning, expressed in percentage in [0;1], of the top left and bottom right corners of the morph, in its FormLayoutMorph owner.
- topLeftOffset and bottomLeftOffset are points representing the ox and oy shifts from the above edges weights, expressed in pixels, postive or negative.

Therefore, the positionning of the morph in its FormLayout owner is determined by its top left and right bottom corners, computed by its 4 edge weights (percentage) in its owner and corrected by its 4 pixel offsets.

"
Class {
	#name : 'LayoutEdgesSpec',
	#superclass : 'LayoutSpec',
	#instVars : [
		'topLeftEdgesWeight',
		'topLeftOffset',
		'bottomRightEdgesWeight',
		'bottomRightOffset'
	],
	#category : 'Morphic-Layouts',
	#package : 'Morphic',
	#tag : 'Layouts'
}

{ #category : 'instance creation' }
LayoutEdgesSpec class >> tlEdgesWeight: tlWeight offset: tlOffset brEdgesWeight: brWeight offset: brOffset [

	^LayoutEdgesSpec new
		topLeftEdgesWeight: tlWeight;
		topLeftOffset: tlOffset;
		bottomRightEdgesWeight: brWeight;
		bottomRightOffset: brOffset
]

{ #category : 'accessing' }
LayoutEdgesSpec >> bottomRightEdgesWeight [
	^bottomRightEdgesWeight
]

{ #category : 'accessing' }
LayoutEdgesSpec >> bottomRightEdgesWeight: aPoint [
	"Argument x and y must be in [0.0 .. 1.0]"
	bottomRightEdgesWeight := aPoint.
	self updateContainingLayout.
]

{ #category : 'accessing' }
LayoutEdgesSpec >> bottomRightOffset [
	^bottomRightOffset
]

{ #category : 'accessing' }
LayoutEdgesSpec >> bottomRightOffset: aPoint [
	bottomRightOffset := aPoint.
	self updateContainingLayout.
]

{ #category : 'testing' }
LayoutEdgesSpec >> isLayoutEdgesSpec [
	^true
]

{ #category : 'layout' }
LayoutEdgesSpec >> minimumSpecExtent [
	"We specify position, but not extent."

	^0@0
]

{ #category : 'accessing' }
LayoutEdgesSpec >> topLeftEdgesWeight [
	^topLeftEdgesWeight
]

{ #category : 'accessing' }
LayoutEdgesSpec >> topLeftEdgesWeight: aPoint [
	"Argument x and y must be in [0.0 .. 1.0]"
	topLeftEdgesWeight := aPoint.
	self updateContainingLayout.
]

{ #category : 'accessing' }
LayoutEdgesSpec >> topLeftOffset [
	^topLeftOffset
]

{ #category : 'accessing' }
LayoutEdgesSpec >> topLeftOffset: aPoint [
	topLeftOffset := aPoint.
	self updateContainingLayout.
]

{ #category : 'updating' }
LayoutEdgesSpec >> updateFor: targetBounds in: availableSpace [
	"Update ourselves so as to compute targetBounds if applied to availableSpace."

	self updateHorizontalWeightsAndOffsetsFor: targetBounds in: availableSpace.
	self updateVerticalWeightsAndOffsetsFor: targetBounds in: availableSpace.

	self updateContainingLayout.
]

{ #category : 'updating' }
LayoutEdgesSpec >> updateHorizontalWeightsAndOffsetsFor: targetBounds in: availableSpace [

	| newLeftOffset newLeftWeight newRightOffset newRightWeight |

	((#[0.0 0.5 1.0 ] includes: topLeftEdgesWeight x) or: [topLeftOffset x ~= 0])
		ifTrue: [				"Keep weight, adjust offset."
			newLeftWeight := topLeftEdgesWeight x.
			newLeftOffset := targetBounds left - (availableSpace left + (availableSpace width * newLeftWeight)) ]
		ifFalse: [				"Keep offset, adjust weight."
			newLeftOffset := topLeftOffset x.
			newLeftWeight := (targetBounds left - (availableSpace left + newLeftOffset)) / availableSpace width ].

	(bottomRightEdgesWeight x = topLeftEdgesWeight x)
		ifTrue: [				"Use left weight, adjust offset"
			newRightWeight := newLeftWeight.
			newRightOffset := targetBounds right - (availableSpace left + (availableSpace width * newRightWeight)) ]
		ifFalse: [
			((#[0.0 0.5 1.0 ] includes: bottomRightEdgesWeight x) or: [bottomRightOffset x ~= 0])
				ifTrue: [		"Keep weight, adjust offset"
					newRightWeight := bottomRightEdgesWeight x.
					newRightOffset := targetBounds right - (availableSpace left + (availableSpace width * newRightWeight)) ]
				ifFalse: [		"Keep offset, adjust weight."
					newRightOffset := bottomRightOffset x.
					newRightWeight := (targetBounds right - (availableSpace left + newRightOffset)) / availableSpace width ]].

	topLeftEdgesWeight := newLeftWeight @  topLeftEdgesWeight y.
	topLeftOffset := newLeftOffset @topLeftOffset y.
	bottomRightEdgesWeight := newRightWeight @bottomRightEdgesWeight y.
	bottomRightOffset := newRightOffset @ bottomRightOffset y.
]

{ #category : 'updating' }
LayoutEdgesSpec >> updateVerticalWeightsAndOffsetsFor: targetBounds in: availableSpace [

	| newTopOffset newTopWeight newBottomOffset newBottomWeight |

	((#[0.0 0.5 1.0 ] includes: topLeftEdgesWeight y) or: [topLeftOffset y ~= 0])
		ifTrue: [				"Keep weight, adjust offset."
			newTopWeight := topLeftEdgesWeight y.
			newTopOffset := targetBounds top - (availableSpace top + (availableSpace height * newTopWeight)) ]
		ifFalse: [				"Keep offset, adjust weight."
			newTopOffset := topLeftOffset y.
			newTopWeight := (targetBounds top - (availableSpace top + newTopOffset)) / availableSpace height ].

	(bottomRightEdgesWeight y = topLeftEdgesWeight y)
		ifTrue: [				"Use left weight, adjust offset"
			newBottomWeight := newTopWeight.
			newBottomOffset := targetBounds bottom - (availableSpace top + (availableSpace height * newBottomWeight)) ]
		ifFalse: [
			((#[0.0 0.5 1.0 ] includes: bottomRightEdgesWeight y) or: [bottomRightOffset y ~= 0])
				ifTrue: [		"Keep weight, adjust offset"
					newBottomWeight := bottomRightEdgesWeight y.
					newBottomOffset := targetBounds bottom - (availableSpace top + (availableSpace height * newBottomWeight)) ]
				ifFalse: [		"Keep offset, adjust weight."
					newBottomOffset := bottomRightOffset y.
					newBottomWeight := (targetBounds bottom - (availableSpace top + newBottomOffset)) / availableSpace height ]].

	topLeftEdgesWeight := topLeftEdgesWeight x @ newTopWeight.
	topLeftOffset := topLeftOffset x @ newTopOffset.
	bottomRightEdgesWeight := bottomRightEdgesWeight x @ newBottomWeight.
	bottomRightOffset := bottomRightOffset x @ newBottomOffset.
]
