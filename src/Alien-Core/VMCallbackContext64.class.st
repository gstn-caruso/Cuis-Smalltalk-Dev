"
A VMCallbackContext64 is an Alien for the 64-bit version of VMCallbackContext (defined in the VMMaker package), a struct that maintains all the necessary context for a callback.

typedef struct {
    void *thunkp;
    char *stackptr;
    long *intRegArgs;
    double *floatRegArgs;
    void *savedCStackPointer;
    void *savedCFramePointer;
    union {
                            long vallong;
                            struct { int low, high; } valleint64;
                            struct { int high, low; } valbeint64;
                            double valflt64;
                            struct { void *addr; long size; } valstruct;
                        }   rvs;
    jmp_buf trampoline;
 } VMCallbackContext;

Instance Variables

"
Class {
	#name : 'VMCallbackContext64',
	#superclass : 'AbstractVMCallbackContext',
	#category : 'Alien-Core',
	#package : 'Alien',
	#tag : 'Core'
}

{ #category : 'instance creation' }
VMCallbackContext64 class >> dataSize [
	"We only access the fields before trampoline, so this is fine."
	^64
]

{ #category : 'accessing' }
VMCallbackContext64 >> floatResult: aFloat [
	self doubleAt: 49 put: aFloat.
	^3
]

{ #category : 'accessing' }
VMCallbackContext64 >> floatregargsp [
	^Alien forPointer: (self unsignedLongLongAt: 25)
]

{ #category : 'accessing' }
VMCallbackContext64 >> intregargsp [
	^Alien forPointer: (self unsignedLongLongAt: 17)
]

{ #category : 'accessing' }
VMCallbackContext64 >> oopResult: anObject [
	"Accept any object."
	self oopAt: 49 put: anObject.
	^1
]

{ #category : 'accessing-debugging' }
VMCallbackContext64 >> savedMostRecentCallbackContext [
	^self unsignedLongLongAt: 73
]

{ #category : 'accessing' }
VMCallbackContext64 >> singleFloatResult: aFloat [
	self floatAt: 49 put: aFloat.
	^3
]

{ #category : 'accessing' }
VMCallbackContext64 >> stackp [
	^Alien forPointer: (self unsignedLongLongAt: 9)
]

{ #category : 'accessing' }
VMCallbackContext64 >> thunkp [
	^self unsignedLongLongAt: 1
]

{ #category : 'accessing' }
VMCallbackContext64 >> wordResult: aValue [
	"Accept any value in the -2^63 to 2^64-1 range or booleans."
	| anInteger |
	anInteger := aValue isInteger
						ifTrue: [aValue]
						ifFalse:  "Will provoke a mustBeBoolean error if not a boolean."
							[aValue ifTrue: [1] ifFalse: [0]].
	anInteger >= 0
		ifTrue: [self unsignedLongLongAt: 49 put: anInteger]
		ifFalse: [self signedLongLongAt: 49 put: anInteger].
	^1
]

{ #category : 'accessing' }
VMCallbackContext64 >> wordSize [
	^8
]
