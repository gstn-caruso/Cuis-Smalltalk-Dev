"
I represent the result of an asynchronous message.  Once the message is processed, I will be resolved to a value.  I am typically instantiated by invocations of #futureSend:at:args: (and not by #futureDo:atArgs:).See class-comment of FutureNode.I also implement the Promises/A+ Javascript specification. This allows you to chain my instances to perform arbitrarily complex asynchronous tasks with error handling baked in.A Promise may be in one of three possible states: #pending, #fulfilled or #rejected. A Promise may move from #pending -> #fulfilled (by way of the resolveWith: message), or from #pending -> #rejected (by way of rejectWith:). No other state changes may occur.Once #fulfilled or #rejected, a Promise's value must not change. In keeping with the major Javascript Promise implementations' interpretations of this, calls to resolveWith: or rejectWith: when a Promise is in #fulfilled or #rejected state are simply ignored - an error is not signalled. (See test cases PromiseTest testFirstResolutionWins, testCannotRejectFulfilledPromise and testCannotResolveaRejectedPromise.)
"
Class {
	#name : 'Promise',
	#superclass : 'Object',
	#instVars : [
		'value',
		'resolvers',
		'mutex',
		'state',
		'error',
		'rejecters'
	],
	#category : 'Promise',
	#package : 'Promise'
}

{ #category : 'instance creation' }
Promise class >> ifRejected: aBlock [
	^ self basicNew initializeWithIfRejected: aBlock.
]

{ #category : 'instance creation' }
Promise class >> unit: anObject [
	"Return a resolved Promise. #new is the other half of Promise's unit function; #new returns an unresolved Promise."
	^ self basicNew initializeWithResolvedValue: anObject.
]

{ #category : 'monad' }
Promise >> >> resolvedBlock [
	"Like >>=, but discards the result of the promise."
	^ self then: [:v | resolvedBlock value]
]

{ #category : 'monad' }
Promise >> >>= resolvedBlock [
	"Alias for `then:` allowing convenient chaining."
	^ self then: resolvedBlock
]

{ #category : 'accessing' }
Promise >> error [
	^ error.
]

{ #category : 'private' }
Promise >> evaluateRejecter: rejecterBlock [
	^ rejecterBlock valueWithPossibleArgument: error.
]

{ #category : 'private' }
Promise >> evaluateResolver: resolverBlock [
	^ resolverBlock valueWithPossibleArgument: value.
]

{ #category : 'resolving' }
Promise >> fulfillWith: aBlock [
	self fulfillWith: aBlock passErrors: rejecters isEmpty
]

{ #category : 'resolving' }
Promise >> fulfillWith: aBlock passErrors: aBoolean [
	"Evaluate aBlock. If it signals an exception, reject this promise with the exception
	as the argument; if it returns a value [or another Promise], resolve this promise
	with the result.
	
	If aBoolean is true, and an exception is signaled, it is passed out to the caller.
	If aBoolean is false, signaled exceptions are considered handled after the promise
	has been rejected."
	[ self resolveWith: aBlock value ]
		on: Exception
		do: [ :ex |
			(ex isKindOf: Halt)
				ifTrue: [ex pass]
				ifFalse: [
					self rejectWith: ex.
					aBoolean ifTrue: [ ex pass ] ]]
]

{ #category : 'monad' }
Promise >> ifRejected: errBlock [
	^ self then: nil ifRejected: errBlock
]

{ #category : 'initialize' }
Promise >> initialize [
	state := #pending.
	resolvers := #().
	rejecters := #().
	mutex := Mutex new.
]

{ #category : 'initialize' }
Promise >> initializeWithIfRejected: aBlock [
	self initialize.
	rejecters := {aBlock}.
]

{ #category : 'initialize' }
Promise >> initializeWithResolvedValue: anObject [
	self initialize.
	self resolveWith: anObject.
]

{ #category : 'testing' }
Promise >> isPromise [
	^ true
]

{ #category : 'testing' }
Promise >> isRejected [
	^ state == #rejected.
]

{ #category : 'testing' }
Promise >> isResolved [
	^ state == #fulfilled.
]

{ #category : 'printing' }
Promise >> printOn: aStream [
	aStream nextPutAll: 'a Promise'.
	self isResolved ifTrue: [
		aStream
			nextPutAll: '(resolved: ';
			nextPutAll: value printString;
			nextPutAll: ')'].
	self isRejected ifTrue: [
		aStream
			nextPutAll: '(rejected: ';
			nextPutAll: error printString;
			nextPutAll: ')'].
]

{ #category : 'resolving' }
Promise >> reject [

	self rejectWith: nil
]

{ #category : 'resolving' }
Promise >> rejectWith: anObject [
	"Reject this promise."
	mutex critical: [
		(state == #pending) ifTrue: [ | worklist |
			error := anObject.
			state := #rejected.
			worklist := rejecters.
			resolvers := #().
			rejecters := #().
			worklist do: [:r | self evaluateRejecter: r]]]
]

{ #category : 'resolving' }
Promise >> resolve [
	
	self resolveWith: nil
]

{ #category : 'resolving' }
Promise >> resolveWith: arg [
	"Resolve this promise. If arg is itself a Promise, make this promise depend upon it,
	as detailed in the Promises/A+ spec:
		https://promisesaplus.com/#the-promise-resolution-procedure"

	arg isPromise
		ifTrue: [
			arg whenResolved: [:v | self resolveWith: v].
			arg whenRejected: [:e | self rejectWith: e]]
		ifFalse: [
			mutex critical: [
				(state == #pending) ifTrue: [ | worklist |
					value := arg.
					state := #fulfilled.
					worklist := resolvers.
					resolvers := #().
					rejecters := #().
					worklist do: [:r | self evaluateResolver: r]]]]
]

{ #category : 'monad' }
Promise >> then: resolvedBlock [
	^ self then: resolvedBlock ifRejected: nil
]

{ #category : 'monad' }
Promise >> then: resolvedBlock ifRejected: errBlock [
	"Return a Promise that, if it resolves, runs the resolvedBlock. If resolution throws an Exception, it runs the errBlock."
	| p |
	p := self species new.
	resolvedBlock
		ifNil: [self whenResolved: [:v | p resolveWith: v]]
		ifNotNil: [
			self whenResolved: [:v |
				[p resolveWith: (resolvedBlock value: v)]
					on: Error do: [:e | p rejectWith: e]]].
	errBlock
		ifNil: [self whenRejected: [:e | p rejectWith: e]]
		ifNotNil: [
			self whenRejected: [:e |
				[p resolveWith: (errBlock value: e)]
					on: Error do: [:e2 | p rejectWith: e2]]].
	^ p.
]

{ #category : 'accessing' }
Promise >> value [
	^value
]

{ #category : 'waiting' }
Promise >> wait [
	"Wait unconditionally for this promise to become fulfilled or rejected."
	| sema |
	sema := Semaphore new.
	self whenResolved:[sema signal].
	self whenRejected:[sema signal].
	sema wait.
	^ self isResolved
		ifTrue: [ value ]
		ifFalse: [ BrokenPromise new promise: self; signal ]
]

{ #category : 'waiting' }
Promise >> waitTimeoutMSecs: msecs [
	"Wait for at most the given number of milliseconds for this promise to settle.
	Answer true if it is resolved, false otherwise. False can therefore mean EITHER 'timeout' OR 'rejected'."
	| sema delay |
	sema := Semaphore new.
	self whenResolved: [sema signal].
	self whenRejected: [sema signal].
	delay := Delay timeoutSemaphore: sema afterMSecs: msecs.
	[sema wait] ensure: [delay unschedule].
	^ self isResolved.
]

{ #category : 'waiting' }
Promise >> waitTimeoutSeconds: seconds [
	"Wait for at most the given number of seconds for this promise to resolve. Answer true if it is resolved, false otherwise."
	^self waitTimeoutMSecs: seconds*1000
]

{ #category : 'resolving' }
Promise >> whenRejected: aBlock [
	"Evaluate aBlock when I am rejected"
	aBlock numArgs <= 1 ifFalse: [self error: 'Must be 0- or 1-argument block'].
	mutex critical: [
		(state == #pending)
			ifTrue: [rejecters := rejecters copyWith: aBlock]
			ifFalse: [self isRejected ifTrue: [self evaluateRejecter: aBlock]]].
	^ nil
]

{ #category : 'resolving' }
Promise >> whenResolved: aBlock [
	"Evaluate aBlock when I am resolved"
	aBlock numArgs <= 1 ifFalse:[self error: 'Must be 0- or 1-argument block'].
	mutex critical: [
		(state == #pending)
			ifTrue: [resolvers := resolvers copyWith: aBlock]
			ifFalse: [self isResolved ifTrue: [self evaluateResolver: aBlock]]].
	^ nil
]
