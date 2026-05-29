Extension { #name : 'Form' }

{ #category : '*extendedClipboard-Win32' }
Form >> fromWin32BitMap: bitmapBits [
	0 to: self height-1 do: [:y |
		1 to: self width do: [:x |
			bits integerAt: (y*width) + x put: ((bitmapBits unsignedLongAt: 1 + (y*width*4) + ((x-1) *4)) bitOr: 16rFF000000)
	]].

]

{ #category : '*extendedClipboard-Win32' }
Form class >> fromWin32BitMap: bitmap bits: bits [
	| form |
	form := self extent: bitmap bmWidth@bitmap bmHeight depth: bitmap bmBitsPixel.
	form fromWin32BitMap: bits.
	^form
]
