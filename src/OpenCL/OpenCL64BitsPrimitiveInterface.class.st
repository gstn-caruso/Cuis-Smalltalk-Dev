"
64 bit platforms
"
Class {
	#name : 'OpenCL64BitsPrimitiveInterface',
	#superclass : 'OpenCLPrimitiveInterface',
	#category : 'OpenCL',
	#package : 'OpenCL'
}

{ #category : 'code generation' }
OpenCL64BitsPrimitiveInterface class >> generateFFICall: returnType name: funcName args: args cat: category [

	"Compile."
	| publicMethod opaqueHandlerTypes answersHandle answerClass |
	"Not if not needed"
	opaqueHandlerTypes _ self opaqueHandlerTypes.
	answersHandle _ opaqueHandlerTypes includes: returnType.
	(answersHandle or: [
		(args anySatisfy: [ :arg | self opaqueHandlerTypes includes: arg key])]) ifFalse: [
			^ super generateFFICall: returnType name: funcName args: args cat: category ].
	
	"The method calling the external library is now private"
	self class
		compile: (self generateMethod: 'private_', funcName returnType: returnType name: funcName args: args)
		classified: ('FFI-generated-private-', category) 
		withStamp: nil
		notifying: nil
		logSource: true.

	"Add a public method"
	publicMethod _ String streamContents: [ :stream |
		"Write the method signature."
		self generateFFICallSignatureName: funcName args: args on: stream.
		stream newLine; newLine; tab; nextPutAll: '"Public method. Needed for calling #getHandle on OpenCLOpaqueHandle arguments"'.
		stream newLine; newLine; tab; nextPutAll: '| answer |'.
		stream newLine; tab; nextPutAll: 'answer := self '.
		self generateFFIPrivateCallName: 'private_', funcName args: args on: stream.
		stream newLine.
		answersHandle ifTrue: [
			answerClass _ self typeMap at: returnType.
			stream newLine; tab; nextPutAll: 'answer := ', answerClass, ' new setHandle: answer getHandle asByteArrayPointer.'.
			].
		stream newLine; tab; nextPutAll: '^ answer'.
	].

	self class
		compile: publicMethod
		classified: ('FFI-generated-', category) 
		withStamp: nil
		notifying: nil
		logSource: true
]

{ #category : 'code generation' }
OpenCL64BitsPrimitiveInterface class >> generateFFIPrivateCallName: funcName args: args on: stream [
	"Write the method signature.  Each argument after the first gets a keyword that tells about the C type."
	stream nextPutAll: funcName.
	(args size > 0) ifTrue: [stream nextPutAll: '__' ].
	args do: [ :arg |
		| argType argName |
		argType := self adaptType: arg key.
		stream nextPutAll: argType; nextPut: $:.
		argName := arg value.
		argName at: 1 put: argName first asLowercase.
		"Some are array-types (i.e 'origin[3]'), so strip off the end."
		argName := argName upTo: $[.
		"Write the name."
		stream space; nextPutAll: argName; space.
		"Add #getHandler call if needed"
		(self opaqueHandlerTypes includes: arg key) ifTrue: [
			stream nextPutAll: 'getHandle asExternalPointer'
			].
	] separatedBy: [
		stream newLineTab: 6.
	].
	stream nextPut: $.
]

{ #category : 'code generation' }
OpenCL64BitsPrimitiveInterface class >> typeOf: inputTypeName [
	(self opaqueHandlerTypes includes: inputTypeName) ifTrue: [
		^'void*'].
	^ super typeOf: inputTypeName
]
