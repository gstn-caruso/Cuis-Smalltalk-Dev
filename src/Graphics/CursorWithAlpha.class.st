"
A 32-bit ARGB Cursor of arbitrary extent (some platforms may limit the size). Compositing assumes alpha is pre-multiplied.
"
Class {
	#name : 'CursorWithAlpha',
	#superclass : 'Cursor',
	#instVars : [
		'fallback'
	],
	#category : 'Graphics-Display Objects',
	#package : 'Graphics',
	#tag : 'Display Objects'
}

{ #category : 'converting' }
CursorWithAlpha >> asCursorForm [

	^ self as: Form
]

{ #category : 'accessing' }
CursorWithAlpha >> fallback [
	^fallback ifNil: [self class cursorAt: #normalCursor]
]

{ #category : 'accessing' }
CursorWithAlpha >> fallback: aCursor [
	fallback := aCursor
]

{ #category : 'testing' }
CursorWithAlpha >> hasMask [
	"Alpha behaves quite like a mask. Please don't convert into a CursorWithMask."
	^true
]

{ #category : 'primitives' }
CursorWithAlpha >> installCursor [
	<primitive: 101>
	self fallback installCursor
]
