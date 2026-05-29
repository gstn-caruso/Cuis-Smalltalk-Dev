"
A VMCallbackContext is an Alien for the VMCallbackContext (defined in the VMMaker package), a struct that maintains all the necessary context for a callback. The callback struct looks like the following, but the sizes and alignments of fields will vary, especially between 32 and 64 bit.  Subclasses provide the concrete details for particular platforms.

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
	#name : 'AbstractVMCallbackContext',
	#superclass : 'Alien',
	#category : 'Alien-Core',
	#package : 'Alien',
	#tag : 'Core'
}

{ #category : 'instance creation' }
AbstractVMCallbackContext class >> dataSize [
	"We only access the fields before trampoline, so this is fine."
	^32
]

{ #category : 'primitives' }
AbstractVMCallbackContext >> primSignal: aSemaphore andReturnAs: anIntegerTypeCode fromContext: aContext [
	"Attempt to return from a callback. This must be done in LIFO order.  The IA32ABI
	 plugin maintains a linked list of vmCallbackContextAddresses to record this order.
	 If vmCallbackContextAddress *is* that of the most recent Callback then return from
	 the callback and do not return here.  If vmCallbackContextAddress *is not* that of
	 the most recent Callback then succeed but answer false. In either case, signal the
	 first process waiting on aSemaphore.  See Alien class>> invokeCallbackContext:
	 for a full explanation. Fail if the arguments are not of the expected type."
	<primitive: 'primReturnAsFromContextThrough' module: 'IA32ABI' error: ec>
	^self primitiveFailed
]

{ #category : 'accessing' }
AbstractVMCallbackContext >> voidResult [
	"Actually return garbage via retword"
	^1
]
