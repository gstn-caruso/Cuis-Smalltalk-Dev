Class {
	#name : 'PromiseTest',
	#superclass : 'TestCase',
	#category : 'Tests-Promise',
	#package : 'Tests',
	#tag : 'Promise'
}

{ #category : 'tests - monad' }
PromiseTest >> testAnErrorInOnRejectedRejectsPromise [
	"https://promisesaplus.com section 2.2.7.2"
	| p q error |
	p := Promise new.
	q := p ifRejected: [:e | (error := KeyNotFound new) signal].
	p rejectWith: 1.
	self assert: p isRejected description: 'Original Promise not rejected'.
	self assert: q isRejected description: 'Broken Promise not rejected'.
	self assert: p error = 1.
	self assert: q error == error.
]

{ #category : 'tests - monad' }
PromiseTest >> testAnErrorInThenRejectsPromise [
	"https://promisesaplus.com section 2.2.7.2"
	| p q error |
	p := Promise new.
	q := p then: [:v | (error := KeyNotFound new) signal].
	p resolveWith: 1.
	self deny: p isRejected description: 'Original Promise rejected'.
	self assert: q isRejected description: 'Broken Promise not rejected'.
	self assert: p value = 1.
	self assert: q error == error.
]

{ #category : 'tests - monad' }
PromiseTest >> testCanRejectPromise [
	| p |
	p := Promise new.
	p rejectWith: Error new.
]

{ #category : 'tests - monad' }
PromiseTest >> testCannotRejectFulfilledPromise [
	| p |
	p := Promise unit: 1.
	p rejectWith: Error new.
	self assert: p isResolved.
	self assert: 1 equals: p value.

]

{ #category : 'tests - monad' }
PromiseTest >> testCannotResolveaRejectedPromise [
	| p e |
	p := Promise new.
	e := Error new.
	p rejectWith: e.
	p resolveWith: 1.
	self assert: p isRejected.
	self assert: p error == e.

]

{ #category : 'tests' }
PromiseTest >> testChainedResolvers [
	| promise1 promise2 result |
	promise1 := Promise new.
	promise2 := Promise new.
	promise1 whenResolved: [:bool | promise2 resolveWith: bool not].
	promise2 whenResolved: [:bool | result := bool].
	promise1 resolveWith: false.
	self should: [result].
]

{ #category : 'tests - monad' }
PromiseTest >> testCollapsesChainsOfPromises [
	"The monadic bind operator has signature (m a -> (a -> m b) -> m b): that is, in our setting,
	the block given to `then:` is expected to return a *Promise* of a value, not a value directly.
	It is convenient to accept non-promise values and automatically lift them into the monad,
	but we must also ensure we treat the case where a `then:`-block yields a Promise correctly."
	| p q r |
	p := Promise new.
	q := p then: [:v | Promise unit: v * 2].
	r := q then: [:v | Promise unit: v + 1].
	p resolveWith: 4.
	self assert: 4 * 2 equals: q value.
	self assert: (4 * 2 + 1) equals: r value.
]

{ #category : 'tests - monad' }
PromiseTest >> testFirstResolutionWins [
	| p |
	p := Promise new.
	p resolveWith: 1.
	p resolveWith: 2.
	self assert: p isResolved.
	self assert: p value == 1.

]

{ #category : 'tests' }
PromiseTest >> testFulfillWithError [
	| p |
	p := Promise new.
	p fulfillWith: [ 1 / 0 ] passErrors: false.
	self assert: p isRejected.
	self assert: ZeroDivide equals: p error class.
]

{ #category : 'tests' }
PromiseTest >> testFulfillWithHaltAndResult [
	| p |
	p := Promise new.
	[
		p fulfillWith: [ self halt. 3 + 4 ]
	] on: Halt do: [:ex | ex resume].
	self assert: p isResolved.
	self assert: 7 equals: p value.
]

{ #category : 'tests' }
PromiseTest >> testFulfillWithResult [
	| p |
	p := Promise new.
	p fulfillWith: [ 3 + 4 ].
	self assert: p isResolved.
	self assert: 7 equals: p value.
]

{ #category : 'tests' }
PromiseTest >> testMultipleResolvers [
	| promise sum |
	sum := 0.
	promise := Promise new.
	5 timesRepeat: [
		promise whenResolved: [:val | sum := sum + val].
	].
	promise resolveWith: 5.
	self should: [sum = 25].
	
]

{ #category : 'tests - monad' }
PromiseTest >> testNilErrBlockPropagation [
	"https://promisesaplus.com section 2.2.7.4"
	| p q |
	p := Promise new.
	q := p then: [:v | self error: 'Shouldn''t call resolvedBlock'] ifRejected: nil.
	p rejectWith: 1.
	self assert: p isRejected.
	self assert: q isRejected.
	self assert: p error equals: 1.
	self assert: q error equals: 1.
]

{ #category : 'tests - monad' }
PromiseTest >> testNilResolvedBlockPropagation [
	"https://promisesaplus.com section 2.2.7.3"
	| p q |
	p := Promise new.
	q := p then: nil ifRejected: [:e | self error: 'Shouldn''t call errBlock'].
	p resolveWith: 1.
	self assert: p isResolved.
	self assert: q isResolved.
	self assert: p value equals: 1.
	self assert: q value equals: 1.
]

{ #category : 'tests - monad' }
PromiseTest >> testRejectWithInvokesErrorHandlers [
	| p error returnedError |
	returnedError := nil.
	error := KeyNotFound new.
	p := Promise ifRejected: [:e | returnedError := e].
	p rejectWith: error.
	self assert: returnedError notNil description: 'Error block did not run.'.
	self assert: error equals: returnedError description: 'Error not passed into block'.
	self assert: error equals: p error description: 'Promise didn''t store error'.
]

{ #category : 'tests' }
PromiseTest >> testSingleResolver [
	| promise sum |
	sum := 0.
	promise := Promise new.
	promise whenResolved: [:val | sum := sum + val].
	promise resolveWith: 5.
	self assert: 5 equals: sum.
	
]

{ #category : 'tests - monad' }
PromiseTest >> testThenPermitsChainingOfPromises [
	| p q r |
	p := Promise new.
	q := p then: [:v | v * 2].
	r := q then: [:v | v + 1].
	p resolveWith: 4.
	self assert: 4 * 2 equals: q value.
	self assert: (4 * 2 + 1) equals: r value.
]

{ #category : 'tests - monad' }
PromiseTest >> testThenReturnsaPromise [
	| p |
	p := Promise new then: [:v | v * 2].
	self assert: Promise equals: p class.
]

{ #category : 'tests' }
PromiseTest >> testTimeout [
	| promise |
	promise := Promise new.
	self shouldnt: [promise waitTimeoutMSecs: 1].
	self shouldnt: [promise isResolved].
	self shouldnt: [promise isRejected].
	promise resolveWith: 45.
	self should: [promise waitTimeoutMSecs: 1].
	self should: [promise isResolved].
	self shouldnt: [promise isRejected].
]

{ #category : 'tests' }
PromiseTest >> testTimeoutRejected [
	| promise |
	promise := Promise new.
	self shouldnt: [promise waitTimeoutMSecs: 1].
	self shouldnt: [promise isResolved].
	self shouldnt: [promise isRejected].
	promise rejectWith: 45.
	self shouldnt: [promise waitTimeoutMSecs: 1].
	self shouldnt: [promise isResolved].
	self should: [promise isRejected].
]

{ #category : 'tests - monad' }
PromiseTest >> testUnitReturnsaPromise [
	| p |
	p := Promise unit: 1.
	self assert: Promise equals: p class.
	self assert: p isResolved.
]

{ #category : 'tests - monad' }
PromiseTest >> testWaitForRejection [
	| p |
	p := Promise new.
	[ (Delay forMilliseconds: 1) wait. p rejectWith: Error new ] fork.
	self should: [ p wait ] raise: BrokenPromise.
]

{ #category : 'tests - monad' }
PromiseTest >> testWaitForResolution [
	| p |
	p := Promise new.
	[ (Delay forMilliseconds: 1) wait. p resolveWith: #ok ] fork.
	self assert: [ p wait = #ok ]
]

{ #category : 'tests - monad' }
PromiseTest >> testWaitRejectionYieldsCorrectBrokenPromise [
	| p |
	p := Promise new.
	[ (Delay forMilliseconds: 1) wait. p rejectWith: Error new ] fork.
	[ p wait ] on: BrokenPromise do: [ :bp | ^ self assert: [ bp promise == p ] ].
	self fail: 'Should not reach this point'
]

{ #category : 'tests - monad' }
PromiseTest >> testifRejectedDoesNotRunBlockIfPromiseResolves [
	| p q error |
	error := nil.
	p := Promise new.
	q := p ifRejected: [:e | error := e].
	p resolveWith: 1.
	self deny: q isRejected.
	self assert: nil equals: error.
]

{ #category : 'tests - monad' }
PromiseTest >> testifRejectedRunsBlockIfPromiseFails [
	"https://promisesaplus.com section 2.2.7.1"
	| p q error |
	error := nil.
	p := Promise new.
	q := p ifRejected: [:e | error := e "N.B. returns a value, does not signal an Exception"].
	p rejectWith: KeyNotFound new.
	self assert: q isResolved.
	self assert: KeyNotFound equals: error class.
	self assert: q value == error.
]

{ #category : 'private' }
PromiseTest >> waitUntil: aBlock orCycleCount: anInteger [
	"This is a gross hack that depends on running the tests in Morphic.
	We simply repeatedly do a cycle of the interaction loop, which happens
	to also be the way that the queue of pending futures gets serviced."
	| counter |
	counter := 0.
	[
		aBlock value ifTrue: [^ true].
		Project current world doOneSubCycle.
		counter := counter + 1.
		counter >= anInteger ifTrue: [^ false].
	] repeat
]
