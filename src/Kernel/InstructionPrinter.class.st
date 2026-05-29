"
My instances can print the object code of a CompiledMethod in symbolic format. They print into an instance variable, stream, and uses oldPC to determine how many bytes to print in the listing. The variable method  is used to hold the method being printed.
"
Class {
	#name : 'InstructionPrinter',
	#superclass : 'InstructionClient',
	#instVars : [
		'method',
		'scanner',
		'stream',
		'oldPC',
		'innerIndents',
		'indent',
		'printPC',
		'indentSpanOfFollowingJump'
	],
	#category : 'Kernel-Methods',
	#package : 'Kernel',
	#tag : 'Methods'
}

{ #category : 'printing' }
InstructionPrinter class >> on: aMethod [
	^self new method: aMethod.
	
]

{ #category : 'printing' }
InstructionPrinter class >> printClass: class  [
	"Create a file whose name is the argument followed by '.bytes'. Store on 
	the file the symbolic form of the compiled methods of the class."

	DirectoryEntry fileOutsDirQuery: (class name , '.bytes') writeStreamDo: [ :fileStream |
		class selectorsDo: [ :sel | 
			fileStream newLine; nextPutAll: sel; newLine.
			(self on: (class compiledMethodAt: sel)) printInstructionsOn: fileStream ]].

	"
	InstructionPrinter printClass: Parser.
	"
]

{ #category : 'instruction decoding' }
InstructionPrinter >> blockReturnConstant: value  [
	"Print the Return Constant From Block bytecode."

	self print: 'blockReturn: ', value printString
]

{ #category : 'instruction decoding' }
InstructionPrinter >> blockReturnTop [
	"Print the ReturnTopOfStack bytecode."
	self print: 'blockReturn'
]

{ #category : 'instruction decoding' }
InstructionPrinter >> callPrimitive: index [
	"Print the callPrimitive bytecode."

	self print: 'callPrimitive: ' , index printString
]

{ #category : 'instruction decoding' }
InstructionPrinter >> directedSuperSend: selector "<Symbol>" numArgs: numArgs "<SmallInteger>" [
	self print: 'directedSuperSend: ' , (self stringForSelector: selector numArgs: numArgs)
]

{ #category : 'instruction decoding' }
InstructionPrinter >> doDup [
	"Print the Duplicate Top of Stack bytecode."
	self print: 'dup'
]

{ #category : 'instruction decoding' }
InstructionPrinter >> doNop [
	"Print the Do Nothing Operation bytecode."
	self print: 'nop'
]

{ #category : 'instruction decoding' }
InstructionPrinter >> doPop [
	"Print the Remove Top of Stack bytecode."
	self print: 'pop'
]

{ #category : 'accessing' }
InstructionPrinter >> indent [

	^ indent ifNil: [0]
]

{ #category : 'initialization' }
InstructionPrinter >> indent: numTabs [

	indent := numTabs
]

{ #category : 'instruction decoding' }
InstructionPrinter >> jump: offset [
	"Print the Unconditional Jump bytecode."

	self print: 'jumpTo: ' , (scanner pc + offset) printString.
	indentSpanOfFollowingJump ifTrue:
		[indentSpanOfFollowingJump := false.
		 innerIndents atAll: (scanner pc to: scanner pc + offset - 1) put: (innerIndents at: scanner pc - 1) + 1]
]

{ #category : 'instruction decoding' }
InstructionPrinter >> jump: offset if: condition  [
	"Print the Conditional Jump bytecode."

	self print: 
		(condition
			ifTrue: ['jumpTrue: ']
			ifFalse: ['jumpFalse: '])
			, (scanner pc + offset) printString
]

{ #category : 'accessing' }
InstructionPrinter >> method [
	^method.
]

{ #category : 'accessing' }
InstructionPrinter >> method: aMethod [
	method :=  aMethod.
	printPC := true.
	indentSpanOfFollowingJump := false
]

{ #category : 'instruction decoding' }
InstructionPrinter >> methodReturnConstant: value  [
	"Print the Return Constant bytecode."
	self print: 'return: ' , value printString
]

{ #category : 'instruction decoding' }
InstructionPrinter >> methodReturnReceiver [
	"Print the Return Self bytecode."
	self print: 'returnSelf'
]

{ #category : 'instruction decoding' }
InstructionPrinter >> methodReturnTop [
	"Print the Return Top of Stack bytecode."
	self print: 'returnTop'
]

{ #category : 'instruction decoding' }
InstructionPrinter >> popIntoLiteralVariable: anAssociation  [
	"Print the Removes the Top of the Stack and Stores it into a Literal Variable
	bytecode."
	self print: 'popIntoLit: ' , anAssociation key
]

{ #category : 'instruction decoding' }
InstructionPrinter >> popIntoReceiverVariable: offset  [
	"Print the Remove Top Of Stack And Store Into Instance Variable bytecode."

	self print: 'popIntoRcvr: ' , (self stringForReceiverVariableOffset: offset)
]

{ #category : 'instruction decoding' }
InstructionPrinter >> popIntoRemoteTemp: remoteTempIndex inVectorAt: tempVectorIndex [
	self print: 'popIntoTemp: ', remoteTempIndex printString, ' inVectorAt: ', tempVectorIndex printString
]

{ #category : 'instruction decoding' }
InstructionPrinter >> popIntoTemporaryVariable: offset  [
	"Print the Removes the Top of the Stack and Stores it into a Temporary Variable
	bytecode."
	self print: 'popIntoTemp: ' , offset printString
]

{ #category : 'printing' }
InstructionPrinter >> print: instruction  [
	"Append to the receiver a description of the bytecode, instruction." 

	| code |
	stream tab: self indent.
	printPC ifTrue: [stream print: oldPC; space].
	stream tab: (innerIndents at: oldPC).
	stream nextPut: $<.
	oldPC to: scanner pc - 1 do: 
		[:i | 
		code := (method at: i) printStringBase: 16.
		stream nextPut: 
			(code size < 2
				ifTrue: [$0]
				ifFalse: [code at: 1]).
		stream nextPut: code last; space].
	stream skipBack.
	stream nextPut: $>.
	stream space.
	stream nextPutAll: instruction.
	stream newLine.
	oldPC := scanner pc.
	"(InstructionPrinter compiledMethodAt: #print:) symbolic."

]

{ #category : 'initialization' }
InstructionPrinter >> printInstructionsOn: aStream  [
	"Append to the stream, aStream, a description of each bytecode in the
	 instruction stream."
	
	| end |
	stream := aStream.
	scanner := InstructionStream on: method.
	end := method endPC.
	oldPC := scanner pc.
	innerIndents := Array new: end withAll: 0.
	[scanner pc <= end] whileTrue:
		[scanner interpretNextInstructionFor: self]
]

{ #category : 'initialization' }
InstructionPrinter >> printInstructionsOn: aStream do: aBlock [
	"Append to the stream, aStream, a description of each bytecode in the
	 instruction stream. Evaluate aBlock with the receiver, the scanner and
	 the stream after each instruction."

	| end |
	stream := aStream.
	scanner := InstructionStream on: method.
	end := method endPC.
	oldPC := scanner pc.
	innerIndents := Array new: end withAll: 0.
	[scanner pc <= end] whileTrue:
		[scanner interpretNextInstructionFor: self.
		 aBlock value: self value: scanner value: stream]
]

{ #category : 'accessing' }
InstructionPrinter >> printPC [
	^printPC
]

{ #category : 'accessing' }
InstructionPrinter >> printPC: aBoolean [
	printPC := aBoolean
]

{ #category : 'instruction decoding' }
InstructionPrinter >> pushActiveContext [
	"Print the Push the Active Context on the Top of its Own Stack bytecode."
	self print: 'pushThisContext: '
]

{ #category : 'instruction decoding' }
InstructionPrinter >> pushClosureCopyNumCopiedValues: numCopied numArgs: numArgs blockSize: blockSize [
	self print: 'closureNumCopied: ', numCopied printString
			, ' numArgs: ', numArgs printString
			, ' bytes ', scanner pc printString
			, ' to ', (scanner pc + blockSize - 1) printString.
	innerIndents
		atAll: (scanner pc to: scanner pc + blockSize - 1)
		put: (innerIndents at: scanner pc - 1) + 1
]

{ #category : 'instruction decoding' }
InstructionPrinter >> pushConsArrayWithElements: numElements  [
	self print: 'pop ', numElements printString, ' into (Array new: ', numElements printString, ')'
]

{ #category : 'instruction decoding' }
InstructionPrinter >> pushConstant: obj [
	"Print the Push Constant, obj, on Top Of Stack bytecode."

	self print: (String streamContents:
				[:s |
				s nextPutAll: 'pushConstant: '.
				obj isVariableBinding
					ifFalse: [obj printOn: s]
					ifTrue: [obj key
						ifNotNil: [s nextPutAll: '##'; nextPutAll: obj key]
						ifNil: [s nextPutAll: '###'; nextPutAll: obj value soleInstance name]]]).

	(obj is: #CompiledMethod) ifTrue:
		[obj longPrintOn: stream indent: self indent + 2.
		^self].
]

{ #category : 'instruction decoding' }
InstructionPrinter >> pushLiteralVariable: anAssociation [
	"Print the Push the Contents of anAssociation on the Top of the Stack bytecode."
	self print: 'pushLit: ' , anAssociation key
]

{ #category : 'instruction decoding' }
InstructionPrinter >> pushNewArrayOfSize: numElements  [
	self print: 'push: (Array new: ', numElements printString, ')'
]

{ #category : 'instruction decoding' }
InstructionPrinter >> pushReceiver [
	"Print the Push the Active Context's Receiver on the Top of the Stack bytecode."
	self print: 'self'
]

{ #category : 'instruction decoding' }
InstructionPrinter >> pushReceiverVariable: offset [
	"Print the Push Contents Of the Receiver's Instance Variable Whose Index 
	is the argument, offset, On Top Of Stack bytecode."

	self print: 'pushRcvr: ' , (self stringForReceiverVariableOffset: offset)
]

{ #category : 'instruction decoding' }
InstructionPrinter >> pushRemoteTemp: remoteTempIndex inVectorAt: tempVectorIndex  [
	self print: 'pushTemp: ', remoteTempIndex printString, ' inVectorAt: ', tempVectorIndex printString
]

{ #category : 'instruction decoding' }
InstructionPrinter >> pushTemporaryVariable: offset [
	"Print the Push the Contents of the Temporary Variable whose Index is the
	argument, offset, on the Top of the Stack bytecode."
	self print: 'pushTemp: ' , offset printString
]

{ #category : 'instruction decoding' }
InstructionPrinter >> send: selector super: supered numArgs: numArgs [
	"Print the Send Message With Selector, selector, bytecode. The argument, 
	supered, indicates whether the receiver of the message is specified with 
	'super' in the source method. The arguments of the message are found in 
	the top numArguments locations on the stack and the receiver just 
	below them."

	self print: (supered
				ifTrue: ['superSend: ']
				ifFalse: ['send: '])
			, (self stringForSelector: selector numArgs: numArgs)
]

{ #category : 'instruction decoding' }
InstructionPrinter >> storeIntoLiteralVariable: anAssociation  [
	"Print the Store the Top of the Stack into a Literal Variable of the Method bytecode."
	self print: 'storeIntoLit: ' , anAssociation key
]

{ #category : 'instruction decoding' }
InstructionPrinter >> storeIntoReceiverVariable: offset  [
	"Print the Store Top Of Stack Into Instance Variable Of Method bytecode."

	self print: 'storeIntoRcvr: ' , (self stringForReceiverVariableOffset: offset)
]

{ #category : 'instruction decoding' }
InstructionPrinter >> storeIntoRemoteTemp: remoteTempIndex inVectorAt: tempVectorIndex  [
	self print: 'storeIntoTemp: ', remoteTempIndex printString, ' inVectorAt: ', tempVectorIndex printString
]

{ #category : 'instruction decoding' }
InstructionPrinter >> storeIntoTemporaryVariable: offset  [
	"Print the Store the Top of the Stack into a Temporary Variable of the Method
	bytecode."
	self print: 'storeIntoTemp: ' , offset printString
]

{ #category : 'printing' }
InstructionPrinter >> stringForReceiverVariableOffset: offset [
	| tmpStream |
	tmpStream := WriteStream on: (String new: 16).
	offset printOn: tmpStream.
	method methodClass ifNotNil:
		[:class|
		class isBehavior ifTrue:
			[(class instVarNameForIndex: offset + 1) ifNotNil:
				[:instVarName|
				tmpStream nextPutAll: ' "'; nextPutAll: instVarName; nextPut: $"]]].
	^tmpStream contents
]

{ #category : 'printing' }
InstructionPrinter >> stringForSelector: selector numArgs: numArgs [
	^(selector isSymbol and: [selector numArgs = numArgs])
		ifTrue: [selector]
		ifFalse: [selector printString
				, (numArgs = 1
					ifTrue: [' (1 arg)']
					ifFalse: [' (', numArgs printString, ' args)'])]
]

{ #category : 'instruction decoding' }
InstructionPrinter >> trapIfNotInstanceOf: behaviorOrArrayOfBehavior [
	"If the top of stack is not an instance of either the argument, or, if the argument is an Array,
	  any of the elements of the argument, send the class trap message to the current context."
	self print: 'trapIfNotInstanceOf: ', behaviorOrArrayOfBehavior printString
]
