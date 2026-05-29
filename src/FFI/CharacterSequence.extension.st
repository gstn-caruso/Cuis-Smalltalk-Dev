Extension { #name : 'CharacterSequence' }

{ #category : '*FFI-Kernel' }
CharacterSequence >> asNullTerminated [
	"Answer the receiver with a null as the last character"

	(self isNullTerminated) 
		ifTrue:[^self].
	^self copyWith: Character null
]

{ #category : '*FFI-Kernel' }
CharacterSequence >> asUtf16BytesLENoBOM [
	"Answer the receiver as UTF16 bytes in little endian with no BOM"

	^UnicodeString utf16BytesFromUtf8: self asUtf8Bytes bigEndian: false includeBOM: false
]

{ #category : '*FFI-Kernel' }
CharacterSequence >> isNullTerminated [
	"Answer true if the receiver is null terminated"
	
	^(self size > 0) and:[self last = Character null] 
]
