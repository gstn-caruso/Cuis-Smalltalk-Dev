Extension { #name : 'SystemDictionary' }

{ #category : '*Bootstrap-examples' }
SystemDictionary >> bootstrappedExample01Stdout [
	"A simple demo to be run in a bootstrapped Cuis image, with a minimal class library"

	StdIOWriteStream stdout
		nextPutAll: 'Hello, World!'; newLine;
		nextPutAll: 'This is Bootstrapped Cuis!'; newLine;
		nextPutAll: '3 + 4 is ', (3 + 4) printString; newLine;
		flush.

	self quitPrimitive: 42.
]

{ #category : '*Bootstrap-examples' }
SystemDictionary >> bootstrappedExample02DoesNotUnderstand [
	"A simple demo to be run in a bootstrapped Cuis image, with a minimal class library"

	StdIOWriteStream stdout
		nextPutAll: 'Hello, World!'; newLine;
		nextPutAll: 'This is Bootstrapped Cuis!'; newLine;
		nextPutAll: '3 + 4 is '; nextPutAll: (3 + 4) printString; newLine;
		flush.

	"To test handling of DNU"
	Smalltalk zork.

	self quitPrimitive: 42.
]

{ #category : '*Bootstrap-examples' }
SystemDictionary >> bootstrappedExample03Float [
	"A simple demo to be run in a bootstrapped Cuis image, with a minimal class library"
	StdIOWriteStream stdout
		nextPutAll: 'Hello, World!'; newLine;
		nextPutAll: 'This is Bootstrapped Cuis!'; newLine;
		nextPutAll: '3 + 4 is '; nextPutAll: (3 + 4) printString; newLine;
		nextPutAll: '3 * 4 is '; nextPutAll: (3 * 4) printString; newLine;
		flush.

	Float initialize.
	StdIOWriteStream stdout
		nextPutAll: 'Pi is approximately 355.0 / 113: '; nextPutAll: (355.0 / 113) printString; newLine;
		flush.

	self quitPrimitive: 42.
]

{ #category : '*Bootstrap-examples' }
SystemDictionary >> bootstrappedExample04SymbolExperiments [
	"A simple demo to be run in a bootstrapped Cuis image, with a minimal class library"

	| i s msg sym |

	"Better do it during image build..."
	Symbol initialize. 

	StdIOWriteStream stdout
		nextPutAll: 'Hello, World!'; newLine;
		nextPutAll: 'This is Bootstrapped Cuis!'; newLine;
		flush.

	StdIOWriteStream stdout
		nextPutAll: 'Symbol allInstancesOrNil size: ';
		nextPutAll: Symbol allInstancesOrNil size printString; newLine;
		nextPutAll: 'Symbol estimatedCount: ';
		nextPutAll: Symbol estimatedCount printString; newLine; newLine;
		flush.

	i := 0.
	[
		i := i + 1.
		s := i printString.
		(Symbol lookup: s) notNil ] whileTrue.
	s.
	msg := (Symbol lookup: s) isNil
		ifTrue: [ '* does not exist' ]
		ifFalse: [ '* exists' ].
	StdIOWriteStream stdout
		nextPutAll: 'Symbol Lookup'; newLine;
		nextPutAll: 'The String: *';
		nextPutAll: s;
		nextPutAll: msg;
		nextPutAll: ' as a Symbol'; newLine;
		nextPutAll: 'Will attempt to create it'; newLine;
		flush.

	sym := s asSymbol.
	StdIOWriteStream stdout
		nextPutAll: 'Result of Symbol creation attempt was: *'.
	sym printOn: StdIOWriteStream stdout.
	StdIOWriteStream stdout
		nextPutAll: '*'; newLine; newLine;
		flush.

	msg := (Symbol lookup: s) isNil
		ifTrue: [ '* does not exist' ]
		ifFalse: [ '* now exists' ].
	StdIOWriteStream stdout
		nextPutAll: 'Symbol Lookup'; newLine;
		nextPutAll: 'The String: *';
		nextPutAll: s;
		nextPutAll: msg;
		nextPutAll: ' as a Symbol'; newLine; newLine;
		flush.

	StdIOWriteStream stdout
		nextPutAll: 'Symbol allInstancesOrNil size: ';
		nextPutAll: Symbol allInstancesOrNil size printString; newLine;
		nextPutAll: 'Symbol estimatedCount: ';
		nextPutAll: Symbol estimatedCount printString; newLine; newLine;
		nextPutAll: 'Thats all, Folks!'; newLine;
		flush.

	self quitPrimitive: 42.
]

{ #category : '*Bootstrap-examples' }
SystemDictionary >> bootstrappedExample05FileExperiments [
	"A simple demo to be run in a bootstrapped Cuis image, with a minimal class library"

	| i s fileContents |
	StdIOWriteStream stdout
		nextPutAll: 'Hello, World!'; newLine;
		nextPutAll: 'This is Bootstrapped Cuis!'; newLine;
		nextPutAll: '3 + 4 is '; nextPutAll: (3 + 4) printString; newLine;
		nextPutAll: 'primImageName: '; nextPutAll: (Smalltalk primImageName); newLine;
		nextPutAll: 'primWorkingDirectory: '; nextPutAll: (BasicFileServices primWorkingDirectory); newLine;
		nextPutAll: 'platformName: '; nextPutAll: (Smalltalk platformName); newLine;
		flush.
	i := 0.
	s := '---Built in Modules---'.
	[
		StdIOWriteStream stdout nextPutAll: s; newLine; flush.
		i := i + 1.
		s := Smalltalk listBuiltinModule: i.
		s == nil] whileFalse.
	StdIOWriteStream stdout nextPutAll: 'They were: '; nextPutAll: (i-1) printString; newLine; flush.

	i := 0.
	s := '---Loaded Modules---'.
	[
		StdIOWriteStream stdout nextPutAll: s; newLine; flush.
		i := i + 1.
		s := Smalltalk listLoadedModule: i.
		s == nil] whileFalse.
	StdIOWriteStream stdout nextPutAll: 'They were: '; nextPutAll: (i-1) printString; newLine; flush.
	StdIOWriteStream stdout
		nextPutAll: 'primVmFileName: '; nextPutAll: (Smalltalk primVmFileName); newLine;
		nextPutAll: 'primVmPath: '; nextPutAll: (Smalltalk primVmPath); newLine;
		flush.

	fileContents := BasicFileServices binaryContentsOf: 'comoVamos.txt'		.
	fileContents isNil
		ifTrue: [
			StdIOWriteStream stdout
				nextPutAll: 'File could not be read'; newLine;
				flush ]
		ifFalse: [
			StdIOWriteStream stdout
				nextPutAll: fileContents size printString; newLine.
			fileContents printOn: StdIOWriteStream stdout.
			StdIOWriteStream stdout newLine.
			1 to: fileContents size do: [ :ii |
				StdIOWriteStream stdout nextPutAll: ' '; nextPutAll: (fileContents at: ii) printString ].
			StdIOWriteStream stdout
				newLine;
				flush ].

	self quitPrimitive: 42.
]

{ #category : '*Bootstrap-examples' }
SystemDictionary >> bootstrappedExample06LoadDynamicLibrary [
	"A simple demo to be run in a bootstrapped Cuis image, with a minimal class library"

	| className |
	"Better do it during image build..."
	Symbol initialize. 
	
	StdIOWriteStream stdout
		nextPutAll: 'Hello, World!'; newLine;
		nextPutAll: 'This is Bootstrapped Cuis!'; newLine;
		nextPutAll: 'Lets try some dcl'; newLine; newLine;
		flush.

	className := #DclExample03.
	StdIOWriteStream stdout
		nextPutAll: 'Do we include the library? ';
		nextPutAll: ((Smalltalk includesKey: className) ifTrue: ['yes'] ifFalse: ['no']); newLine;
		nextPutAll: 'Lets load it'; newLine;
		flush.

	(DynamicCuisLibrary readFromFileNamed: 'DclExample03.dcl')
		canBeInstalled;
		installLibrary.

	StdIOWriteStream stdout
		nextPutAll: 'Do we include the library? ';
		nextPutAll: ((Smalltalk includesKey: className) ifTrue: ['yes!!!'] ifFalse: ['no']); newLine;
		flush.

	StdIOWriteStream stdout
		nextPutAll: 'Lets instantiate and compute stuff: ';
		nextPutAll: ((Smalltalk at: #DclExample03) new combined) printString;
		newLine;
		nextPutAll: 'Thats all, Folks!'; newLine;
		flush.

	self quitPrimitive: 42.
]

{ #category : '*Bootstrap-examples' }
SystemDictionary >> bootstrappedExample07LoadDynamicLibrary [
	"A simple demo to be run in a bootstrapped Cuis image, with a minimal class library"

	| l t1 t2 t3 t4 t5 t6 |
	"Better do it during image build..."
	Symbol initialize. 
	
	StdIOWriteStream stdout
		nextPutAll: 'Hello, World!'; newLine;
		nextPutAll: 'This is Bootstrapped Cuis!'; newLine;
		nextPutAll: 'Lets try some dcl'; newLine; newLine;
		flush.

	StdIOWriteStream stdout
		nextPutAll: '1-Do we include the libraries? ';
		nextPutAll: ((Smalltalk includesKey: #MorphXX) ifTrue: ['yes'] ifFalse: ['no']); newLine;
		nextPutAll: 'Lets load it'; newLine;
		flush.

	t1 := [l := DynamicCuisLibrary readFromFileNamed: 'DclExample07MorphXX.dcl'] timeToRun.
	t2 := [l canBeInstalled] timeToRun.
	t3 := [l installLibrary] timeToRun.

	StdIOWriteStream stdout
		nextPutAll: '2-Do we include fist library? ';
		nextPutAll: ((Smalltalk includesKey: #MorphXX) ifTrue: ['yes!!!'] ifFalse: ['no']); newLine;
		flush.

	StdIOWriteStream stdout
		nextPutAll: 'times ', t1 printString, ' ', t2 printString, ' ', t3 printString;
		newLine;
		flush.

	t4 := [l := DynamicCuisLibrary readFromFileNamed: 'DclExample07MorphXX10.dcl'] timeToRun.
	t5 := [l canBeInstalled] timeToRun.
	t6 := [l installLibrary] timeToRun.

	StdIOWriteStream stdout
		nextPutAll: '3-Do we include second library? ';
		nextPutAll: ((Smalltalk includesKey: #MorphXX9) ifTrue: ['yes!!!'] ifFalse: ['no']); newLine;
		flush.

	StdIOWriteStream stdout
		nextPutAll: 'times ', t4 printString, ' ', t5 printString, ' ', t6 printString;
		newLine;
		flush.

	StdIOWriteStream stdout
		nextPutAll: 'Thats all, Folks!'; newLine;
		flush.

	self quitPrimitive: 42.
]
