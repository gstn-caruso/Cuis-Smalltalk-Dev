"
The Spur FreeLists object is pretty special. It is very much like a regular Smalltalk Array. But it is used by the VM to hold machine pointers, not oops. So, it is a numeric array, closer to ByteArray. Additionally, it is not visible from the Smalltalk side. So, it is not an instance of any class.

There are two possible variants, for Spur64 and Spur32. It has a number of slots (64 or 32). Its format is 9 (64 bits indexable) or 10 (32 bits indexable). Hash is set to 0. ClassIndex is set to 19 or 18. These are not actual class indexes, they don't refer to any class! See VMMaker SpurMemoryManager>>#sixtyFourBitLongsClassIndexPun and VMMaker SpurMemoryManager>>#thirtyTwoBitLongsClassIndexPun.

The purpose of this class is to create correctly these objects in a new Spur image.

'/Users/juanvuletich/Cuis-Smalltalk/Cuis-Smalltalk-Dev/Cuis6.0-5797.image'  asFileEntry readStreamDo: [ :fs | fs binary. cuisSpur64ImageFirstBytes := fs next: 1000 ].
'/Users/juanvuletich/Cuis-Smalltalk/Cuis-Smalltalk-Dev/Cuis6.0-5797-32.image'  asFileEntry readStreamDo: [ :fs | fs binary. cuisSpur32ImageFirstBytes := fs next: 1000 ].

(cuisSpur64ImageFirstBytes uint64At: 128+1+(8*6) bigEndian: false) hex. '16r 40  000000    09  000013' 
slots: 16r40=64
hash:0
format: 9 (64 bits indexable)
classIndex: 16r13=19 (VMMaker SpurMemoryManager>>#sixtyFourBitLongsClassIndexPun, not a class!)
Siguen 64*8=512 bytes en cero. Despues viene el HiddenRoots, que es un objeto de mas de 255 slots!
(cuisSpur64ImageFirstBytes uint64At: 128+1+(8*6)+8+512 bigEndian: false) hex.


(cuisSpur32ImageFirstBytes uint64At: 64+1+(8*6) bigEndian: false) hex. '16r 20  000000   0A  000012' 
slots: 16r20=32
hash=0
format: 0A (32 bits indexable)
classIndex: 16r12=18 (VMMaker SpurMemoryManager>>#thirtyTwoBitLongsClassIndexPun, not a class!)
siguen 32*4=128 bytes en cero. Despues viene el HiddenRoots, que es un objeto de mas de 255 slots!
(cuisSpur32ImageFirstBytes uint64At: 64+1+(8*6)+8+128 bigEndian: false) hex.
"
Class {
	#name : 'Spur32FreeListsForeignObject',
	#superclass : 'AllocatedForeignObject',
	#category : 'Bootstrap-Foreign Objects',
	#package : 'Bootstrap',
	#tag : 'Foreign Objects'
}

{ #category : 'accessing' }
Spur32FreeListsForeignObject >> slotCount [
	"Answer the number of slots used by our representedObject"

	^32
]

{ #category : 'accessing' }
Spur32FreeListsForeignObject >> slotWidth [
	"Answer the size of each slot, in bytes, used by our representedObject.
	Our slots are 32 bit integers, handled only by the VM to store private raw pointers."

	^4
]

{ #category : 'accessing' }
Spur32FreeListsForeignObject >> spurClassIndexFor: aSpurImageBuilder [
	"Not a regular Smalltalk object.
	See class comment."

	^ 18
]

{ #category : 'accessing' }
Spur32FreeListsForeignObject >> spurObjectFormat [
	"Answer the format 5 bit field for Object Header in Spur.
	Our size is fixed and even, we don't need to worry about the padding low bit and format 11."

	^10
]

{ #category : 'serialization' }
Spur32FreeListsForeignObject >> writeSlotsOn: byteStream forSpur: anImageBuilder [
	"Just a bunch of zeros. It is up to the VM to use this as desired."

	byteStream nextPutAll: (ByteArray new: self slotCount * self slotWidth).
]
