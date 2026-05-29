"
ExternalLibrarty used in FFI tests
"
Class {
	#name : 'FFITestLibrary',
	#superclass : 'ExternalLibrary',
	#category : 'Tests-FFI',
	#package : 'Tests',
	#tag : 'FFI'
}

{ #category : 'primitives' }
FFITestLibrary class >> ffiPrintString: aString [
	"FFITestLibrary ffiPrintString: 'Hello' asUtf8BytesOrByteString"
	<cdecl: char* 'ffiPrintString' (char *) module:'SqueakFFIPrims'>
	^self externalCallFailed
]

{ #category : 'primitives' }
FFITestLibrary class >> ffiTestBiggerStruct: pt1 with: pt2 [
	<cdecl: FFITestBiggerStruct 'ffiTestStructBigger' (FFITestPoint4 FFITestPoint4) module:'SqueakFFIPrims'>
	^self externalCallFailed
]

{ #category : 'primitives' }
FFITestLibrary class >> ffiTestChar: c1 with: c2 with: c3 with: c4 [
	"FFITestLibrary ffiTestChar: $A with: 65 with: 65.0 with: true"
	<cdecl: char 'ffiTestChars' (char char char char) module:'SqueakFFIPrims'>
	^self externalCallFailed
]

{ #category : 'primitives' }
FFITestLibrary class >> ffiTestDoubles: f1 with: f2 [
	"FFITestLibrary ffiTestDoubles: $A with: 65.0"
	<cdecl: double 'ffiTestDoubles' (double double) module:'SqueakFFIPrims'>
	^self externalCallFailed
]

{ #category : 'primitives' }
FFITestLibrary class >> ffiTestDoubles9: f1 d: f2 d: f3 d: f4 d: f5 d: f6 d: f7 d: f8 d: f9 [
	"FFITestLibrary ffiTestDoubles9: 1.0 d: 2.0 d: 3.0 d: 4.0 d: 5.0 d: 6.0 d: 7.0 d: 8.0 d: 9.0"
	<cdecl: double 'ffiTestDoubles9' (double double double double double double double double double) module:'SqueakFFIPrims'>
	^self externalCallFailed
]

{ #category : 'primitives' }
FFITestLibrary class >> ffiTestFloats: f1 with: f2 [
	"FFITestLibrary ffiTestFloats: $A with: 65.0"
	<cdecl: float 'ffiTestFloats' (float float) module:'SqueakFFIPrims'>
	^self externalCallFailed
]

{ #category : 'old typeNames' }
FFITestLibrary class >> ffiTestInt: c1 with: c2 with: c3 with: c4 [
	"FFITestLibrary ffiTestInt: $A with: 65 with: 65.0 with: true"
	<cdecl: long 'ffiTestInts' (long long long long) module:'SqueakFFIPrims'>
	^self externalCallFailed
]

{ #category : 'primitives' }
FFITestLibrary class >> ffiTestInt16: c1 with: c2 with: c3 with: c4 [
	"FFITestLibrary ffiTestInt16: $A with: 65 with: 65.0 with:1"
	<cdecl: int16 'ffiTestShorts' (int16 int16 int16 int16) module:'SqueakFFIPrims'>
	^self externalCallFailed
]

{ #category : 'primitives' }
FFITestLibrary class >> ffiTestInt32: c1 with: c2 with: c3 with: c4 [
	"FFITestLibrary ffiTestInt32: $A with: 65 with: 65.0 with: true"
	<cdecl: int32 'ffiTestInts' (int32 int32 int32 int32) module: 'SqueakFFIPrims'>
	^self externalCallFailed
]

{ #category : 'primitives' }
FFITestLibrary class >> ffiTestInt64: long1 with: long2 [
	"FFITestLibrary ffiTestInt64: 3 with: 4"
	<cdecl: int64 'ffiTestLongLong' (int64 int64) module:'SqueakFFIPrims'>
	^self externalCallFailed
]

{ #category : 'primitives' }
FFITestLibrary class >> ffiTestInt64A1: byte with: long1 with: long2 [
	"FFITestLibrary ffiTestInt64A1: 3 with: 4 with: 5"
	<cdecl: int64 'ffiTestLongLonga1' (char int64 int64) module: 'SqueakFFIPrims'>
	^self externalCallFailed
]

{ #category : 'primitives' }
FFITestLibrary class >> ffiTestInt64A3: byte1 with: long1 with: byte2 [
	"FFITestLibrary ffiTestInt64A3: 3 with: 4 with: 5"
	<cdecl: int64 'ffiTestLongLonga3' (char int64 char) module:'SqueakFFIPrims'>
	^self externalCallFailed
]

{ #category : 'old typeNames' }
FFITestLibrary class >> ffiTestLongLong: long1 with: long2 [
	"FFITestLibrary ffiTestLongLong: 3 with: 4"
	<cdecl: longlong 'ffiTestLongLong' (longlong longlong) module:'SqueakFFIPrims'>
	^self externalCallFailed
]

{ #category : 'old typeNames' }
FFITestLibrary class >> ffiTestLongLongA1: byte with: long1 with: long2 [
	"FFITestLibrary ffiTestLongLongA1: 3 with: 4 with: 5"
	<cdecl: longlong 'ffiTestLongLonga1' (char longlong longlong) module:'SqueakFFIPrims'>
	^self externalCallFailed
]

{ #category : 'old typeNames' }
FFITestLibrary class >> ffiTestLongLongA3: byte1 with: long1 with: byte2 [
	"FFITestLibrary ffiTestLongLongA3: 3 with: 4 with: 5"
	<cdecl: longlong 'ffiTestLongLonga3' (char longlong char) module:'SqueakFFIPrims'>
	^self externalCallFailed
]

{ #category : 'primitives' }
FFITestLibrary class >> ffiTestMixedDoublesInt32AndStruct: f1 d: f2 d: f3 d: f4 d: f5 d: f6 d: f7 d: f8 d: f9 i: i1 s: s1 [
	"FFITestLibrary ffiTestMixedDoublesIntAndStruct: 1.0 d: 2.0 d: 3.0 d: 4.0 d: 5.0 d: 6.0 d: 7.0 d: 8.0 d: 9.0 i: 42
		s: (FFITestPoint4 new x: 3; y: 4; z: 5; w:6)"
	<cdecl: double 'ffiTestMixedDoublesIntAndStruct' (double double double double double double double double double int32 FFITestPoint4) module:'SqueakFFIPrims'>
	^self externalCallFailed
]

{ #category : 'old typeNames' }
FFITestLibrary class >> ffiTestMixedDoublesIntAndStruct: f1 d: f2 d: f3 d: f4 d: f5 d: f6 d: f7 d: f8 d: f9 i: i1 s: s1 [
	"FFITestLibrary ffiTestMixedDoublesIntAndStruct: 1.0 d: 2.0 d: 3.0 d: 4.0 d: 5.0 d: 6.0 d: 7.0 d: 8.0 d: 9.0 i: 42
		s: (FFITestPoint4 new x: 3; y: 4; z: 5; w:6)"
	<cdecl: double 'ffiTestMixedDoublesIntAndStruct' (double double double double double double double double double long FFITestPoint4) module:'SqueakFFIPrims'>
	^self externalCallFailed
]

{ #category : 'primitives' }
FFITestLibrary class >> ffiTestMixedFloatsAndDouble: f1 with: d1 with: f2 with: f3 [
	"FFITestLibrary ffiTestMixedFloatsAndDouble: 1.2 with: 3.4 with: 5.6 with: 7.8"
	<cdecl: double 'ffiTestMixedFloatsAndDouble' (float double float float) module:'SqueakFFIPrims'>
	^self externalCallFailed
]

{ #category : 'primitives' }
FFITestLibrary class >> ffiTestMixedIntAndStruct: i with: pt1 with: pt2 [
	"FFITestLibrary ffiTestMixedIntAndStruct: 2 with: (FFITestPoint2 new x: 3; y: 4) with: (FFITestPoint2 new x: 5; y: 6)"
	<cdecl: int32 'ffiTestMixedIntAndStruct' (int32 FFITestPoint2 FFITestPoint2) module:'SqueakFFIPrims'>
	^self externalCallFailed
]

{ #category : 'primitives' }
FFITestLibrary class >> ffiTestMixedIntAndStruct2: i with: pt4 [
	"FFITestLibrary ffiTestMixedIntAndStruct2: 2 with: (FFITestPoint4 new x: 3; y: 4; z: 5; w:6)"
	<cdecl: int32 'ffiTestMixedIntAndStruct2' (int32 FFITestPoint4) module:'SqueakFFIPrims'>
	^self externalCallFailed
]

{ #category : 'primitives' }
FFITestLibrary class >> ffiTestMixedIntAndStruct3: i with: anFFISmallStruct1 [
	"FFITestLibrary ffiTestMixedIntAndStruct3: 2 with: (FFISmallStruct1 new x: 3; y: 4)"
	<cdecl: int32 'ffiTestMixedIntAndStruct3' (int32 FFISmallStruct1) module:'SqueakFFIPrims'>
	^self externalCallFailed
]

{ #category : 'primitives' }
FFITestLibrary class >> ffiTestPoint2: pt1 with: pt2 [
	<cdecl: FFITestPoint2 'ffiTestStruct64' (FFITestPoint2 FFITestPoint2) module:'SqueakFFIPrims'>
	^self externalCallFailed
]

{ #category : 'primitives' }
FFITestLibrary class >> ffiTestPoint4: pt1 with: pt2 [
	<cdecl: FFITestPoint4 'ffiTestStructBig' (FFITestPoint4 FFITestPoint4) module:'SqueakFFIPrims'>
	^self externalCallFailed
]

{ #category : 'primitives' }
FFITestLibrary class >> ffiTestPointers: pt1 with: pt2 [
	<cdecl: FFITestPoint4* 'ffiTestPointers' (FFITestPoint4* FFITestPoint4*) module:'SqueakFFIPrims'>
	^self externalCallFailed
]

{ #category : 'old typeNames' }
FFITestLibrary class >> ffiTestShort: c1 with: c2 with: c3 with: c4 [
	"FFITestLibrary ffiTestShort: $A with: 65 with: 65.0 with:1"
	<cdecl: short 'ffiTestShorts' (short short short short) module:'SqueakFFIPrims'>
	^self externalCallFailed
]

{ #category : 'primitives' }
FFITestLibrary class >> ffiTestSmallStructReturn [
	"FFITestLibrary ffiTestSmallStructReturn"
	<cdecl: FFISmallStruct1 'ffiTestSmallStructReturn' (void) module:'SqueakFFIPrims'>
	^self externalCallFailed
]

{ #category : 'primitives' }
FFITestLibrary class >> ffiTestUInt32: c1 with: c2 with: c3 with: c4 [
	"FFITestLibrary ffiTestUInt32: 3103854339 with: 3103854339 with: 3103854339 with: 3103854339"
	<cdecl: int32 'ffiTestInts' (uint32 uint32 uint32 uint32) module:'SqueakFFIPrims'>
	^self externalCallFailed
]

{ #category : 'old typeNames' }
FFITestLibrary class >> ffiTestUlong: c1 with: c2 with: c3 with: c4 [
	"FFITestLibrary ffiTestUlong: 3103854339 with: 3103854339 with: 3103854339 with: 3103854339"
	<cdecl: long 'ffiTestInts' (ulong ulong ulong ulong) module:'SqueakFFIPrims'>
	^self externalCallFailed
]

{ #category : 'accessing' }
FFITestLibrary class >> moduleName [
	"Use the fully qualified VM name so we ensure testing loading a library"
	^'SqueakFFIPrims'
]

{ #category : 'primitives' }
FFITestLibrary >> ffiPrintString: aString [
	"FFITestLibrary new ffiPrintString: 'Hello' asUtf8BytesOrByteString"
	<cdecl: char* 'ffiPrintString' (char *)>
	^self externalCallFailed
]

{ #category : 'primitives' }
FFITestLibrary >> ffiTestBiggerStruct: pt1 with: pt2 [
	<cdecl: FFITestBiggerStruct 'ffiTestStructBigger' (FFITestPoint4 FFITestPoint4) module:'SqueakFFIPrims'>
	^self externalCallFailed
]

{ #category : 'primitives' }
FFITestLibrary >> ffiTestChar: c1 with: c2 with: c3 with: c4 [
	"FFITestLibrary new ffiTestChar: $A with: 65 with: 65.0 with: true"
	<cdecl: char 'ffiTestChars' (char char char char)>
	^self externalCallFailed
]

{ #category : 'primitives' }
FFITestLibrary >> ffiTestDoubles: f1 with: f2 [
	"FFITestLibrary new ffiTestDoubles: $A with: 65.0"
	<cdecl: double 'ffiTestDoubles' (double double)>
	^self externalCallFailed
]

{ #category : 'primitives' }
FFITestLibrary >> ffiTestFloats: f1 with: f2 [
	"FFITestLibrary new ffiTestFloats: $A with: 65.0"
	<cdecl: float 'ffiTestFloats' (float float)>
	^self externalCallFailed
]

{ #category : 'old typeNames' }
FFITestLibrary >> ffiTestInt: c1 with: c2 with: c3 with: c4 [
	"FFITestLibrary new ffiTestInt: $A with: 65 with: 65.0 with: $A"
	<cdecl: long 'ffiTestInts' (long long long long)>
	^self externalCallFailed
]

{ #category : 'primitives' }
FFITestLibrary >> ffiTestInt16: c1 with: c2 with: c3 with: c4 [
	"FFITestLibrary new ffiTestInt16: $A with: 65 with: 65.0 with: $A"
	<cdecl: int16 'ffiTestShorts' (int16 int16 int16 int16)>
	^self externalCallFailed
]

{ #category : 'primitives' }
FFITestLibrary >> ffiTestInt32: c1 with: c2 with: c3 with: c4 [
	"FFITestLibrary new ffiTestInt: $A with: 65 with: 65.0 with: $A"
	<cdecl: int32 'ffiTestInts' (int32 int32 int32 int32)>
	^self externalCallFailed
]

{ #category : 'old typeNames' }
FFITestLibrary >> ffiTestShort: c1 with: c2 with: c3 with: c4 [
	"FFITestLibrary new ffiTestShort: $A with: 65 with: 65.0 with: $A"
	<cdecl: short 'ffiTestShorts' (short short short short)>
	^self externalCallFailed
]
