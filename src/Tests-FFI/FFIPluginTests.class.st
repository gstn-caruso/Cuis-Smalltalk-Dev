"
SUnitized tests for the FFI (mostly the plugin side)
"
Class {
	#name : 'FFIPluginTests',
	#superclass : 'TestCase',
	#category : 'Tests-FFI',
	#package : 'Tests',
	#tag : 'FFI'
}

{ #category : 'structure tests' }
FFIPluginTests >> testBiggerStruct [
	"Test passing and returning up of structures > 64 bit"
	| pt1 pt2 pt3 |
	pt1 := FFITestPoint4 new.
	pt1 x: 1. pt1 y: 2. pt1 z: 3. pt1 w: 4.
	pt2 := FFITestPoint4 new.
	pt2 x: 5. pt2 y: 6. pt2 z: 7. pt2 w: 8.
	pt3 := FFITestLibrary ffiTestBiggerStruct: pt1 with: pt2.
	self assert: pt3 x = 1.
	self assert: pt3 y = 2.
	self assert: pt3 z = 3.
	self assert: pt3 w = 4.
	self assert: pt3 r = 5.
	self assert: pt3 s = 6.
	self assert: pt3 t = 7.
	self assert: pt3 u = 8.
]

{ #category : 'external form tests' }
FFIPluginTests >> testBlitToAndFromExternalForm [
	"Ensure that we can blit to/from all 4 permutatations of Form and ExternalForm."
	| source external1 external2 destination |
	"Avoid translucency."
	source := (Cursor waitCursor asCursorForm asFormOfDepth: 1) asFormOfDepth: 32.
	destination := Form extent: source extent depth: 32.
	external1 := ExternalForm extent: source extent depth: 32.
	external1 allocateSpace.
	external2 := ExternalForm extent: source extent depth: 32.
	external2 allocateSpace.
	self shouldnt: [source bits = destination bits].
	source displayOn: external1.
	external1 displayOn: external2.
	external2 displayOn: destination.
	self should: [source bits = destination bits].
]

{ #category : 'simple tests' }
FFIPluginTests >> testConstructedCharCall [
	"Test using generic FFI spec"
	| result meth |
	meth := ExternalLibraryFunction
		name:'ffiTestChars' module: FFITestLibrary moduleName 
		callType: 0 returnType: ExternalType char
		argumentTypes: ((1 to: 4) collect:[:i| ExternalType char]).
	result := meth invokeWith: $A with: 65 with: 65.0 with: true.
	self assert: result class = Character.
	self assert: result codePoint = 130
]

{ #category : 'simple tests' }
FFIPluginTests >> testConstructedDoubleCall [
	"Test using generic FFI spec"
	| result meth |
	meth := ExternalLibraryFunction
		name:'ffiTestDoubles' module: FFITestLibrary moduleName 
		callType: 0 returnType: ExternalType double
		argumentTypes: ((1 to: 2) collect:[:i| ExternalType double]).
	result := meth invokeWithArguments: (Array with: 41 with: true).
	self assert: result = 42.0
]

{ #category : 'simple tests' }
FFIPluginTests >> testConstructedFloatCall [
	"Test using generic FFI spec"
	| result meth |
	meth := ExternalLibraryFunction
		name:'ffiTestFloats' module: FFITestLibrary moduleName 
		callType: 0 returnType: ExternalType float
		argumentTypes: ((1 to: 2) collect:[:i| ExternalType float]).
	result := meth invokeWith: $A with: 65.0.
	self assert: result = 130.0
]

{ #category : 'simple tests' }
FFIPluginTests >> testConstructedInt16Call [
	"Test using generic FFI spec"
	| result meth |
	meth := ExternalLibraryFunction
		name:'ffiTestShorts' module: FFITestLibrary moduleName 
		callType: 0 returnType: ExternalType int16
		argumentTypes: ((1 to: 4) collect:[:i| ExternalType int16]).
	result := meth invokeWithArguments: (Array with: $A with: 65 with: 65.0 with: true).
	self assert: result = 130.
]

{ #category : 'simple tests' }
FFIPluginTests >> testConstructedInt32Call [
	"Test using generic FFI spec"
	| result meth |
	meth := ExternalLibraryFunction
		name:'ffiTestInts' module: FFITestLibrary moduleName
		callType: 0 returnType: ExternalType int32
		argumentTypes: ((1 to: 4) collect:[:i| ExternalType int32]).
	result := meth invokeWith: $A with: 65 with: 65.0 with: true.
	self assert: result = 130.
]

{ #category : 'simple tests' }
FFIPluginTests >> testConstructedPrintString [
	"Test using generic FFI spec"
	| result meth |
	meth := ExternalLibraryFunction
		name:'ffiPrintString' module: FFITestLibrary moduleName 
		callType: 0 returnType: ExternalType string
		argumentTypes: ((1 to: 1) collect:[:i| ExternalType string]).
	result := meth invokeWith:'Hello World!'.
	self assert: result = 'Hello World!'.
]

{ #category : 'simple tests' }
FFIPluginTests >> testGenericCharCall [
	"Test using generic FFI spec"
	| result |
	result := FFITestLibrary ffiTestChar: $A with: 65 with: 65.0 with: true.
	self assert: result class = Character.
	self assert: result codePoint = 130
]

{ #category : 'simple tests' }
FFIPluginTests >> testGenericDoubleCall [
	"Test using generic FFI spec"
	| result |
	result := FFITestLibrary ffiTestDoubles: $A with: 65.0.
	self assert: result = 130.0
]

{ #category : 'simple tests' }
FFIPluginTests >> testGenericDoubleCall2 [
	"Test using generic FFI spec"
	| result |
	result := FFITestLibrary ffiTestDoubles9: 1.0 d: 2.0 d: 3.0 d: 4.0 d: 5.0 d: 6.0 d: 7.0 d: 8.0 d: 9.0.
	self assert: result = 45.0
]

{ #category : 'simple tests' }
FFIPluginTests >> testGenericFloatCall [
	"Test using generic FFI spec"
	| result |
	result := FFITestLibrary ffiTestFloats: $A with: 65.0.
	self assert: result = 130.0
]

{ #category : 'simple tests' }
FFIPluginTests >> testGenericInt16Call [
	"Test using generic FFI spec"
	| result |
	result := FFITestLibrary ffiTestInt16: $A with: 65 with: 65.0 with: true.
	self assert: result = 130.
]

{ #category : 'simple tests' }
FFIPluginTests >> testGenericInt32Call [
	"Test using generic FFI spec"
	| result |
	result := FFITestLibrary ffiTestInt32: $A with: 65 with: 65.0 with: true.
	self assert: result = 130.
]

{ #category : 'old typeNames tests' }
FFIPluginTests >> testGenericIntCall [
	"Test using generic FFI spec"
	| result |
	result := FFITestLibrary ffiTestInt: $A with: 65 with: 65.0 with: true.
	self assert: result = 130.
]

{ #category : 'simple tests' }
FFIPluginTests >> testGenericMixedDoublesInt32AndStruct [
	"Test using generic FFI spec"
	| result int struct |
	int := 42.
	struct := FFITestPoint4 new.
	struct x: 1. struct y: 2. struct z: 3. struct w: 4.
	result := FFITestLibrary ffiTestMixedDoublesInt32AndStruct: 1.0 d: 2.0 d: 3.0 d: 4.0 d: 5.0 d: 6.0 d: 7.0 d: 8.0 d: 9.0 i: int s: struct.
	self assert: result = (45.0 + 42 + 10)
]

{ #category : 'old typeNames tests' }
FFIPluginTests >> testGenericMixedDoublesIntAndStruct [
	"Test using generic FFI spec"
	| result int struct |
	int := 42.
	struct := FFITestPoint4 new.
	struct x: 1. struct y: 2. struct z: 3. struct w: 4.
	result := FFITestLibrary ffiTestMixedDoublesIntAndStruct: 1.0 d: 2.0 d: 3.0 d: 4.0 d: 5.0 d: 6.0 d: 7.0 d: 8.0 d: 9.0 i: int s: struct.
	self assert: result = (45.0 + 42 + 10)
]

{ #category : 'simple tests' }
FFIPluginTests >> testGenericMixedFloatsAndDouble [
	"Test using generic FFI spec"
	| result |
	result := FFITestLibrary ffiTestMixedFloatsAndDouble: 1.2 with: 3.4 with: 5.6 with: 7.8.
	self assert: (1.2 + 3.4 + 5.6 + 7.8 - result) abs < 1.0e-6
]

{ #category : 'simple tests' }
FFIPluginTests >> testGenericPrintString [
	"Test using generic FFI spec"
	| result |
	result := FFITestLibrary ffiPrintString:'Hello World!' asUtf8BytesOrByteString.
	self assert: result = 'Hello World!'.
]

{ #category : 'old typeNames tests' }
FFIPluginTests >> testGenericShortCall [
	"Test using generic FFI spec"
	| result |
	result := FFITestLibrary ffiTestShort: $A with: 65 with: 65.0 with: true.
	self assert: result = 130.
]

{ #category : 'simple tests' }
FFIPluginTests >> testInt64A1 [
	"Test passing a char and two int64s."
	| byte long1 long2 long3 |
	byte := 42.
	long1 := 16r123456789012.
	long2 := (-1 << 31).
	long3 := FFITestLibrary ffiTestInt64A1: byte with: long1 with: long2.
	self assert: long3 = (byte + long1 + long2)
]

{ #category : 'simple tests' }
FFIPluginTests >> testInt64A3 [
	"Test passing a char, a int64, and another char."
	| byte1 long1 byte2 long2 |
	byte1 := 3.
	long1 := 16r123456789012.
	byte2 := 4.
	long2 := FFITestLibrary ffiTestInt64A3: byte1 with: long1 with: byte2.
	self assert: long2 = (byte1 + long1 + byte2)
]

{ #category : 'structure tests' }
FFIPluginTests >> testInt64s [
	"Test passing and returning int64s"
	| long1 long2 long3 |
	long1 := 16r123456789012.
	long2 := (-1 << 31).
	long3 := FFITestLibrary ffiTestInt64: long1 with: long2.
	self assert: long3 = (long1 + long2)
]

{ #category : 'callback tests' }
FFIPluginTests >> testLibcQsort [
	"Use libc's qsort to sort some floats"

	| sizeofDouble size_t_Type rand nElements values dataSize qsort callback callbackCount orig sort usecs |
	sizeofDouble := ExternalType double byteSize.
	size_t_Type := Smalltalk wordSize = 8 ifTrue: [ExternalType uint64] ifFalse: [ExternalType uint32].
	qsort := ExternalLibraryFunction
				name:'qsort' module: Alien libcName
				callType: 0 returnType: ExternalType void
				argumentTypes: {ExternalType void asPointerType. size_t_Type. size_t_Type. ExternalType void asPointerType}.
	callbackCount := 0.
	callback := Callback
					signature:  #(int (*)(const void *, const void *))
					block: [ :arg1 :arg2 |
							callbackCount := callbackCount + 1.
							((arg1 doubleAt: 1) - (arg2 doubleAt: 1)) sign].

	rand := Random new.
	values := ExternalAddress gcallocate: (dataSize := (nElements := 100) * sizeofDouble).
	1 to: dataSize by: sizeofDouble do:
		[:i| values doubleAt: i put: rand next].
	orig := (1 to: dataSize by: sizeofDouble) collect: [:i| values doubleAt: i].
	self assert: ((1 to: nElements - 1) anySatisfy: [:i| (orig at: i) > (orig at: i + 1)]).
	usecs := Time microsecondsToRun: [qsort	
											invokeWith: values
											with: nElements
											with: sizeofDouble
											with: callback thunk].
	sort := (1 to: dataSize by: sizeofDouble) collect: [:i| values doubleAt: i].
	self deny: orig = sort.
	1 to: nElements - 1 do:
		[:i| self assert: (sort at: i) <= (sort at: i + 1)].
	values free.
	^{ orig. sort. usecs. callbackCount }
]

{ #category : 'simple tests' }
FFIPluginTests >> testLibraryCharCall [
	"Test using call from ExternalLibrary"
	| result |
	result := FFITestLibrary new ffiTestChar: $A with: 65 with: 65.0 with: true.
	self assert: result class = Character.
	self assert: result codePoint = 130
]

{ #category : 'simple tests' }
FFIPluginTests >> testLibraryDoubleCall [
	"Test using call from ExternalLibrary"
	| result |
	result := FFITestLibrary new ffiTestDoubles: $A with: 65.0.
	self assert: result = 130.0
]

{ #category : 'simple tests' }
FFIPluginTests >> testLibraryFloatCall [
	"Test using call from ExternalLibrary"
	| result |
	result := FFITestLibrary new ffiTestFloats: $A with: 65.0.
	self assert: result = 130.0
]

{ #category : 'simple tests' }
FFIPluginTests >> testLibraryInt32Call [
	"Test using call from ExternalLibrary"
	| result |
	result := FFITestLibrary new ffiTestInt32: $A with: 65 with: 65.0 with: true.
	self assert: result = 130.
]

{ #category : 'old typeNames tests' }
FFIPluginTests >> testLibraryIntCall [
	"Test using call from ExternalLibrary"
	| result |
	result := FFITestLibrary new ffiTestInt: $A with: 65 with: 65.0 with: true.
	self assert: result = 130.
]

{ #category : 'simple tests' }
FFIPluginTests >> testLibraryPrintString [
	"Test using call from ExternalLibrary"
	| result |
	result := FFITestLibrary new ffiPrintString:'Hello World!' asUtf8BytesOrByteString.
	self assert: result = 'Hello World!'.
]

{ #category : 'other tests' }
FFIPluginTests >> testLoadSymbolFromModule [
	| address |
	
	"Ok"
	address := ExternalAddress loadSymbol: 'ffiTestFloats' asUtf8BytesOrByteString module: FFITestLibrary moduleName asUtf8BytesOrByteString.
	self deny: address isNil.
	self deny: address isNull.
	"Symbol does not exists"
	self 
		should: [ ExternalAddress loadSymbol: 'ffi_does_not_exist' asUtf8BytesOrByteString module: FFITestLibrary moduleName asUtf8BytesOrByteString ]
		raise: Error.
	"Module does not exists"
	self 
		should: [ ExternalAddress loadSymbol: 'ffiTestFloats' asUtf8BytesOrByteString module: 'NonExistingModule' asUtf8BytesOrByteString ]
		raise: Error.		
]

{ #category : 'old typeNames tests' }
FFIPluginTests >> testLongLongA1 [
	"Test passing a char and two longlongs."
	| byte long1 long2 long3 |
	byte := 42.
	long1 := 16r123456789012.
	long2 := (-1 << 31).
	long3 := FFITestLibrary ffiTestLongLongA1: byte with: long1 with: long2.
	self assert: long3 = (byte + long1 + long2)
]

{ #category : 'old typeNames tests' }
FFIPluginTests >> testLongLongA3 [
	"Test passing a char, a longlong, and another char."
	| byte1 long1 byte2 long2 |
	byte1 := 3.
	long1 := 16r123456789012.
	byte2 := 4.
	long2 := FFITestLibrary ffiTestLongLongA3: byte1 with: long1 with: byte2.
	self assert: long2 = (byte1 + long1 + byte2)
]

{ #category : 'old typeNames tests' }
FFIPluginTests >> testLongLongs [
	"Test passing and returning longlongs"
	| long1 long2 long3 |
	long1 := 16r123456789012.
	long2 := (-1 << 31).
	long3 := FFITestLibrary ffiTestLongLong: long1 with: long2.
	self assert: long3 = (long1 + long2)
]

{ #category : 'structure tests' }
FFIPluginTests >> testMixedIntAndStruct [
	"Test passing an integer and two structures."
	| i1 pt1 pt2 result |
	i1 := 42.
	pt1 := FFITestPoint2 new.
	pt1 x: 3. pt1 y: 4.
	pt2 := FFITestPoint2 new.
	pt2 x: 5. pt2 y: 6.
	result := FFITestLibrary ffiTestMixedIntAndStruct: i1 with: pt1 with: pt2.
	self assert: result = 60.
]

{ #category : 'structure tests' }
FFIPluginTests >> testMixedIntAndStruct2 [
	"Test passing an integer and two structures."
	| i1 pt1 result |
	i1 := 42.
	pt1 := FFITestPoint4 new.
	pt1 x: 3. pt1 y: 4. pt1 z: 5. pt1 w: 6.
	result := FFITestLibrary ffiTestMixedIntAndStruct2: i1 with: pt1.
	self assert: result = 60.
]

{ #category : 'structure tests' }
FFIPluginTests >> testMixedIntAndStruct3 [
	"Test passing an integer and a small structure."
	| i1 pt1 result |
	i1 := 42.
	pt1 := FFISmallStruct1 new.
	pt1 x: 3. pt1 y: 4.
	result := FFITestLibrary ffiTestMixedIntAndStruct3: i1 with: pt1.
	self assert: result = 49
]

{ #category : 'structure tests' }
FFIPluginTests >> testPoint2 [
	"Test passing and returning up of structures >32bit and <= 64 bit"
	| pt1 pt2 pt3 |
	pt1 := FFITestPoint2 new.
	pt1 x: 1. pt1 y: 2.
	pt2 := FFITestPoint2 new.
	pt2 x: 3. pt2 y: 4.
	pt3 := FFITestLibrary ffiTestPoint2: pt1 with: pt2.
	self assert: pt3 x = 4.
	self assert: pt3 y = 6.
]

{ #category : 'structure tests' }
FFIPluginTests >> testPoint4 [
	"Test passing and returning up of structures > 64 bit"
	| pt1 pt2 pt3 |
	pt1 := FFITestPoint4 new.
	pt1 x: 1. pt1 y: 2. pt1 z: 3. pt1 w: 4.
	pt2 := FFITestPoint4 new.
	pt2 x: 5. pt2 y: 6. pt2 z: 7. pt2 w: 8.
	pt3 := FFITestLibrary ffiTestPoint4: pt1 with: pt2.
	self assert: pt3 x = 6.
	self assert: pt3 y = 8.
	self assert: pt3 z = 10.
	self assert: pt3 w = 12.
]

{ #category : 'structure tests' }
FFIPluginTests >> testPointers [
	"Test passing and returning of pointers to structs"
	| pt1 pt2 pt3 |
	pt1 := FFITestPoint4 new.
	pt1 x: 1. pt1 y: 2. pt1 z: 3. pt1 w: 4.
	pt2 := FFITestPoint4 new.
	pt2 x: 5. pt2 y: 6. pt2 z: 7. pt2 w: 8.
	pt3 := FFITestLibrary ffiTestPointers: pt1 with: pt2.
	self assert: pt3 x = 6.
	self assert: pt3 y = 8.
	self assert: pt3 z = 10.
	self assert: pt3 w = 12.
]

{ #category : 'structure tests' }
FFIPluginTests >> testSmallStructureReturn [
	"Test returning small structures (<4 bytes) which are returned in a register on some platforms."
	| pt1 |

	pt1 := FFITestLibrary ffiTestSmallStructReturn.
	self assert: pt1 x = 3.
	self assert: pt1 y = 4.
]

{ #category : 'simple tests' }
FFIPluginTests >> testUint32Range [
	"Simple test for making sure the FFI can call certain numbers in the uint32 range"
	| result |
	self shouldnt:[result := FFITestLibrary ffiTestUInt32: 3103854339 with: 3103854339 with: 3103854339 with: 3103854339] raise: Error.
	self should: result =  1912741382.
]

{ #category : 'old typeNames tests' }
FFIPluginTests >> testUlongRange [
	"Simple test for making sure the FFI can call certain numbers in the ulong range"
	| result |
	self shouldnt:[result := FFITestLibrary ffiTestUlong: 3103854339 with: 3103854339 with: 3103854339 with: 3103854339] raise: Error.
	self should: result =  1912741382.
]
