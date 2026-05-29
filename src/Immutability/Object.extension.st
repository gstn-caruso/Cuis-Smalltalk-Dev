Extension { #name : 'Object' }

{ #category : '*Immutability' }
Object >> at: index put: value  [
	"Primitive. Assumes receiver is indexable. Store the argument value in 
	the indexable element of the receiver indicated by index. Fail if the 
	index is not an Integer or is out of bounds. Or fail if the value is not of 
	the right type for this kind of collection. Answer the value that was 
	stored. Essential. See Object documentation whatIsAPrimitive."

	<primitive: 61>
	
	self isImmutable 
		ifTrue: [ ^ self modificationForbiddenFor: #at:put: index: index value: value ].

	index isInteger ifTrue:
		[self class isVariable
			ifTrue: [(index >= 1 and: [index <= self size])
					ifTrue: [self errorImproperStore]
					ifFalse: [self errorSubscriptBounds: index]]
			ifFalse: [self errorNotIndexable]].
	index isNumber
		ifTrue: [^self at: index asInteger put: value]
		ifFalse: [self errorNonIntegerIndex]
]

{ #category : '*Immutability' }
Object >> attemptToAssign: value withIndex: index  [

	"Called by the VM when assigning an instance variable of an immutable object.
	Upon return, executing will resume *after* the inst var assignment. If the inst var mutation has to be 
	performed, do it manually here in the call back with instVarAt:put:.
	This method has to return *no* value by jumping to the context's sender
	Implementation copied from Pharo"
	
	self modificationForbiddenFor: #instVarAt:put: index: index value: value.
	
	thisContext sender jump
	"CAN'T REACH"
]

{ #category : '*Immutability' }
Object >> basicAt: index put: value  [
	"Primitive. Assumes receiver is indexable. Store the second argument 
	value in the indexable element of the receiver indicated by index. Fail 
	if the index is not an Integer or is out of bounds. Or fail if the value is 
	not of the right type for this kind of collection. Answer the value that 
	was stored. Essential. Do not override in a subclass. See Object 
	documentation whatIsAPrimitive."

	<primitive: 61>
	
	self isImmutable 
		ifTrue: [ ^ self modificationForbiddenFor: #basicAt:put: index: index value: value ].

	index isInteger
		ifTrue: [(index >= 1 and: [index <= self size])
					ifTrue: [self errorImproperStore]
					ifFalse: [self errorSubscriptBounds: index]].
	index isNumber
		ifTrue: [^self basicAt: index asInteger put: value]
		ifFalse: [self errorNonIntegerIndex]
]

{ #category : '*Immutability' }
Object >> beImmutable [
	
	" If the VM supports read-only objects it will not write to read-only objects.
	 An attempt to write to an instance variable of a read-only object will
	 cause the VM to send attemptToAssign:withIndex: to the read-only object.
	 An attempt to modify a read-only object in a primitive will cause the
	 primitive to fail with a #'no modification' error code
	
	Classes whose instances are composed by other objects, should redefine
	#beImmutable and #beMutable to make its parts immutable/mutable.
	See OrderedCollection>>#beImmutabe for an example"
	
	^self beImmutable: true
]

{ #category : '*Immutability' }
Object >> beImmutable: aBoolean [

	<primitive: 164 error: ec>
	^self primitiveFailed

]

{ #category : '*Immutability' }
Object >> beMutable [
	
	^self beImmutable: false
]

{ #category : '*Immutability' }
Object >> instVarAt: index put: anObject [
	"Primitive. Store a value into a fixed variable in an object. The numbering of the
	 variables corresponds to the named instance variables, followed by the indexed
	 instance variables. Fail if the index is not an Integer or is not the index of a fixed
	 variable. Essential. See Object documentation whatIsAPrimitive."

	<primitive: 174 error: ec>
	"The classic InterpreterVMs don't support primitives 173 and 174.
	See http://forum.world.st/Some-test-where-Spur-more-slow-than-Cog-td4867810.html#a4867888
	Use primitives 73 and 74 in such case."
	Smalltalk isRunningCog ifFalse: [
		^ self instVarAtPrim74: index put: anObject ].
	
	self isImmutable 
		ifTrue: [ ^ self modificationForbiddenFor: #instVarAt:put: index: index value: anObject ].

	self primitiveFailed
]

{ #category : '*Immutability' }
Object >> isImmutable [

	<primitive: 163 error: ec>
	^self class isImmediateClass 
]

{ #category : '*Immutability' }
Object >> modificationForbiddenFor: selector index: index value: value [

	^ ModificationForbidden 
		signalFor: self
		at: index
		with: value
		retrySelector: selector
]

{ #category : '*Immutability' }
Object >> rawBasicAt: index put: value  [
	"A verbatim copy of #basicAt:put:
	To be used when subclasses might redefine #basicAt:, but unaltered, raw behavior is desired.
	For example, when studying Floats, and understanding FFI, etc."
	"Primitive. Assumes receiver is indexable. Store the second argument 
	value in the indexable element of the receiver indicated by index. Fail 
	if the index is not an Integer or is out of bounds. Or fail if the value is 
	not of the right type for this kind of collection. Answer the value that 
	was stored. Essential. Do not override in a subclass. See Object 
	documentation whatIsAPrimitive."

	<primitive: 61>
	self isImmutable 
		ifTrue: [ ^ self modificationForbiddenFor: #rawBasicAt:put: index: index value: value ].

	index isInteger
		ifTrue: [(index >= 1 and: [index <= self size])
					ifTrue: [self errorImproperStore]
					ifFalse: [self errorSubscriptBounds: index]].
	index isNumber
		ifTrue: [^self rawBasicAt: index asInteger put: value]
		ifFalse: [self errorNonIntegerIndex]
]

{ #category : '*Immutability' }
Object >> setIsReadOnlyObject: aBoolean [
	"If the VM supports read-only objects it will not write to read-only objects.
	 An attempt to write to an instance variable of a read-only object will
	 cause the VM to send attemptToAssign:withIndex: to the read-only object.
	 An attempt to modify a read-only object in a primitive will cause the
	 primitive to fail with a #'no modification' error code.
	 This primitive sets the read-only flag of the receiver to the given
	 value and answers the previous vaue of the flag.
	 Note: Some objects can't be read-only, currently contexts and objects related
	 to process scheduling (Processor, Process instances, Semaphore instances, ...)"
	<primitive: 164 error: ec>
	^self primitiveFailed
	
]
