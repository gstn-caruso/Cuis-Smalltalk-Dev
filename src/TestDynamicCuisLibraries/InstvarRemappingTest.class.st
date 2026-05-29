Class {
	#name : 'InstvarRemappingTest',
	#superclass : 'TestCase',
	#category : 'TestDynamicCuisLibraries-Tests',
	#package : 'TestDynamicCuisLibraries',
	#tag : 'Tests'
}

{ #category : 'subject code' }
InstvarRemappingTest >> classDeclarationString [
^ 'Object subclass: #LargeClassIvarR01
  	instanceVariableNames: ''a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12 a13 a14 a15 a16 a17 a18 a19 a20 a21 a22 a23 a24 a25 a26 a27 a28 a29 a30 a31 a32 a33 a34 a35 a36 a37 a38 a39 a40 a41 a42 a43 a44 a45 a46 a47 a48 a49 a50 a51 a52 a53 a54 a55 a56 a57 a58 a59 a60 a61 a62 a63 a64 a65 a66 a67 a68 a69 a70 a71 a72 a73 a74 a75 a76 a77 a78 a79 a80 a81 a82 a83 a84 a85 a86 a87 a88 a89 a90 a91 a92 a93 a94 a95 a96 a97 a98 a99 a100 a101 a102 a103 a104 a105 a106 a107 a108 a109 a110 a111 a112 a113 a114 a115 a116 a117 a118 a119 a120 a121 a122 a123 a124 a125 a126 a127 a128 a129 a130 a131 a132 a133 a134 a135 a136 a137 a138 a139 a140 a141 a142 a143 a144 a145 a146 a147 a148 a149 a150 a151 a152 a153 a154 a155 a156 a157 a158 a159 a160 a161 a162 a163 a164 a165 a166 a167 a168 a169 a170 a171 a172 a173 a174 a175 a176 a177 a178 a179 a180 a181 a182 a183 a184 a185 a186 a187 a188 a189 a190 a191 a192 a193 a194 a195 a196 a197 a198 a199 a200 a201 a202 a203 a204 a205 a206 a207 a208 a209 a210 a211 a212 a213 a214 a215 a216 a217 a218 a219 a220 a221 a222 a223 a224 a225 a226 a227 a228 a229 a230 a231 a232 a233 a234 a235 a236 a237 a238 a239 a240 a241 a242 a243 a244 a245 a246 a247 a248 a249 a250 a251 a252 a253 a254 a255 a256 a257 a258 a259 a260 a261 a262''
  	classVariableNames: ''''
  	poolDictionaries: ''''
  	category: ''TestDynamicCuisLibraries-Transient'''
]

{ #category : 'failing' }
InstvarRemappingTest >> expectedFailures [
	"Answer an array o selectors that are expected to fail.
	Usually this is done for tests that document incorrect behavior for which there is not yet a proper fix available."
	"Only for Sista!
	Also see #setUp"

	^CompiledMethod preferredBytecodeSetEncoderClass name == #EncoderForSistaV1
		ifTrue: [#()]
		ifFalse: [#(testInstVarRemapping01 testInstVarRemapping02 testInstVarRemapping03 testInstVarRemapping04 testInstVarRemapping05 testInstVarRemapping06 testLongInstVarAcessConversion01 testLongInstVarAcessConversion02 testLongInstVarAcessConversion03 testLongInstVarAcessConversion04)]
]

{ #category : 'bytecode code' }
InstvarRemappingTest >> m01Bytecode [
	^
'73 <51> pushConstant: 1
74 <50> pushConstant: 0
75 <63> send: >
76 <C4> jumpFalse: 82
77 <E8 63> pushConstant: 99
79 <F3 04> storeIntoRcvr: 4 "a5"
81 <B3> jumpTo: 86
82 <E8 62> pushConstant: 98
84 <F3 04> storeIntoRcvr: 4 "a5"
86 <D8> pop
87 <20> pushConstant: ''a1''
88 <CD> popIntoRcvr: 5 "a6"
89 <5F> nop
90 <12> pushLit: Float
91 <81> send: pi
92 <CE> popIntoRcvr: 6 "a7"
93 <5F> nop
94 <23> pushConstant: #[11 22 33 44]
95 <CF> popIntoRcvr: 7 "a8"
96 <5F> nop
97 <4C> self
98 <04> pushRcvr: 4 "a5"
99 <5F> nop
100 <E8 63> pushConstant: 99
102 <66> send: =
103 <94> send: assert:
104 <D8> pop
105 <4C> self
106 <05> pushRcvr: 5 "a6"
107 <5F> nop
108 <20> pushConstant: ''a1''
109 <66> send: =
110 <94> send: assert:
111 <D8> pop
112 <4C> self
113 <06> pushRcvr: 6 "a7"
114 <5F> nop
115 <12> pushLit: Float
116 <81> send: pi
117 <66> send: =
118 <94> send: assert:
119 <D8> pop
120 <4C> self
121 <07> pushRcvr: 7 "a8"
122 <5F> nop
123 <23> pushConstant: #[11 22 33 44]
124 <66> send: =
125 <94> send: assert:
126 <D8> pop
127 <58> returnSelf
'.

]

{ #category : 'bytecode code' }
InstvarRemappingTest >> m01BytecodeLongIvarAcessAndJumps [
	^
'73 <51> pushConstant: 1
74 <50> pushConstant: 0
75 <63> send: >
76 <E1 00 EF 0A> jumpFalse: 90
80 <E8 63> pushConstant: 99
82 <E0 00 F3 04> storeIntoRcvr: 4 "a5"
86 <E1 00 ED 06> jumpTo: 96
90 <E8 62> pushConstant: 98
92 <E0 00 F3 04> storeIntoRcvr: 4 "a5"
96 <D8> pop
97 <20> pushConstant: ''a1''
98 <E0 00 CD> popIntoRcvr: 5 "a6"
101 <5F> nop
102 <12> pushLit: Float
103 <81> send: pi
104 <E0 00 CE> popIntoRcvr: 6 "a7"
107 <5F> nop
108 <23> pushConstant: #[11 22 33 44]
109 <E0 00 CF> popIntoRcvr: 7 "a8"
112 <5F> nop
113 <4C> self
114 <E0 00 04> pushRcvr: 4 "a5"
117 <5F> nop
118 <E8 63> pushConstant: 99
120 <66> send: =
121 <94> send: assert:
122 <D8> pop
123 <4C> self
124 <E0 00 05> pushRcvr: 5 "a6"
127 <5F> nop
128 <20> pushConstant: ''a1''
129 <66> send: =
130 <94> send: assert:
131 <D8> pop
132 <4C> self
133 <E0 00 06> pushRcvr: 6 "a7"
136 <5F> nop
137 <12> pushLit: Float
138 <81> send: pi
139 <66> send: =
140 <94> send: assert:
141 <D8> pop
142 <4C> self
143 <E0 00 07> pushRcvr: 7 "a8"
146 <5F> nop
147 <23> pushConstant: #[11 22 33 44]
148 <66> send: =
149 <94> send: assert:
150 <D8> pop
151 <58> returnSelf
'.
]

{ #category : 'subject code' }
InstvarRemappingTest >> m01SourceCode [
	^ 'test01AccessLowVariables
 
 	"Short #genStorePopInstVar: (up to 8 inst vars is Spur)"
 	1 > 0
 		ifTrue: [ a5 := 99 ]
 		ifFalse: [ a5 := 98 ].
 	a6 := ''a1''.
 	a7 := Float pi.
 	a8 := #[11 22 33 44].
 	
 	"Short #genPushInstVar: (up to 16 inst vars in Spur)"
 	self assert: a5 = 99.
 	self assert: a6 = ''a1''.
 	self assert: a7 = Float pi.
 	self assert: a8 = #[11 22 33 44].'
]

{ #category : 'bytecode code' }
InstvarRemappingTest >> m02Bytecode [
	^
'73 <20> pushConstant: ''a1''
74 <F0 18> popIntoRcvr: 24 "a25"
76 <E8 02> pushConstant: 2
78 <F0 19> popIntoRcvr: 25 "a26"
80 <12> pushLit: Float
81 <81> send: pi
82 <F0 1A> popIntoRcvr: 26 "a27"
84 <23> pushConstant: #[11 22 33 44]
85 <F0 1B> popIntoRcvr: 27 "a28"
87 <51> pushConstant: 1
88 <50> pushConstant: 0
89 <63> send: >
90 <C4> jumpFalse: 96
91 <E8 63> pushConstant: 99
93 <F3 F4> storeIntoRcvr: 244 "a245"
95 <B3> jumpTo: 100
96 <E8 62> pushConstant: 98
98 <F3 F4> storeIntoRcvr: 244 "a245"
100 <D8> pop
101 <20> pushConstant: ''a1''
102 <F0 F5> popIntoRcvr: 245 "a246"
104 <12> pushLit: Float
105 <81> send: pi
106 <F0 F6> popIntoRcvr: 246 "a247"
108 <23> pushConstant: #[11 22 33 44]
109 <F0 F7> popIntoRcvr: 247 "a248"
111 <4C> self
112 <E2 18> pushRcvr: 24 "a25"
114 <20> pushConstant: ''a1''
115 <66> send: =
116 <94> send: assert:
117 <D8> pop
118 <4C> self
119 <E2 19> pushRcvr: 25 "a26"
121 <E8 02> pushConstant: 2
123 <66> send: =
124 <94> send: assert:
125 <D8> pop
126 <4C> self
127 <E2 1A> pushRcvr: 26 "a27"
129 <12> pushLit: Float
130 <81> send: pi
131 <66> send: =
132 <94> send: assert:
133 <D8> pop
134 <4C> self
135 <E2 1B> pushRcvr: 27 "a28"
137 <23> pushConstant: #[11 22 33 44]
138 <66> send: =
139 <94> send: assert:
140 <D8> pop
141 <4C> self
142 <E2 F4> pushRcvr: 244 "a245"
144 <E8 63> pushConstant: 99
146 <66> send: =
147 <94> send: assert:
148 <D8> pop
149 <4C> self
150 <E2 F5> pushRcvr: 245 "a246"
152 <20> pushConstant: ''a1''
153 <66> send: =
154 <94> send: assert:
155 <D8> pop
156 <4C> self
157 <E2 F6> pushRcvr: 246 "a247"
159 <12> pushLit: Float
160 <81> send: pi
161 <66> send: =
162 <94> send: assert:
163 <D8> pop
164 <4C> self
165 <E2 F7> pushRcvr: 247 "a248"
167 <23> pushConstant: #[11 22 33 44]
168 <66> send: =
169 <94> send: assert:
170 <D8> pop
171 <58> returnSelf
'.

]

{ #category : 'bytecode code' }
InstvarRemappingTest >> m02BytecodeLongIvarAcessAndJumps [
	^
'73 <20> pushConstant: ''a1''
74 <E0 00 F0 18> popIntoRcvr: 24 "a25"
78 <E8 02> pushConstant: 2
80 <E0 00 F0 19> popIntoRcvr: 25 "a26"
84 <12> pushLit: Float
85 <81> send: pi
86 <E0 00 F0 1A> popIntoRcvr: 26 "a27"
90 <23> pushConstant: #[11 22 33 44]
91 <E0 00 F0 1B> popIntoRcvr: 27 "a28"
95 <51> pushConstant: 1
96 <50> pushConstant: 0
97 <63> send: >
98 <E1 00 EF 0A> jumpFalse: 112
102 <E8 63> pushConstant: 99
104 <E0 00 F3 F4> storeIntoRcvr: 244 "a245"
108 <E1 00 ED 06> jumpTo: 118
112 <E8 62> pushConstant: 98
114 <E0 00 F3 F4> storeIntoRcvr: 244 "a245"
118 <D8> pop
119 <20> pushConstant: ''a1''
120 <E0 00 F0 F5> popIntoRcvr: 245 "a246"
124 <12> pushLit: Float
125 <81> send: pi
126 <E0 00 F0 F6> popIntoRcvr: 246 "a247"
130 <23> pushConstant: #[11 22 33 44]
131 <E0 00 F0 F7> popIntoRcvr: 247 "a248"
135 <4C> self
136 <E0 00 E2 18> pushRcvr: 24 "a25"
140 <20> pushConstant: ''a1''
141 <66> send: =
142 <94> send: assert:
143 <D8> pop
144 <4C> self
145 <E0 00 E2 19> pushRcvr: 25 "a26"
149 <E8 02> pushConstant: 2
151 <66> send: =
152 <94> send: assert:
153 <D8> pop
154 <4C> self
155 <E0 00 E2 1A> pushRcvr: 26 "a27"
159 <12> pushLit: Float
160 <81> send: pi
161 <66> send: =
162 <94> send: assert:
163 <D8> pop
164 <4C> self
165 <E0 00 E2 1B> pushRcvr: 27 "a28"
169 <23> pushConstant: #[11 22 33 44]
170 <66> send: =
171 <94> send: assert:
172 <D8> pop
173 <4C> self
174 <E0 00 E2 F4> pushRcvr: 244 "a245"
178 <E8 63> pushConstant: 99
180 <66> send: =
181 <94> send: assert:
182 <D8> pop
183 <4C> self
184 <E0 00 E2 F5> pushRcvr: 245 "a246"
188 <20> pushConstant: ''a1''
189 <66> send: =
190 <94> send: assert:
191 <D8> pop
192 <4C> self
193 <E0 00 E2 F6> pushRcvr: 246 "a247"
197 <12> pushLit: Float
198 <81> send: pi
199 <66> send: =
200 <94> send: assert:
201 <D8> pop
202 <4C> self
203 <E0 00 E2 F7> pushRcvr: 247 "a248"
207 <23> pushConstant: #[11 22 33 44]
208 <66> send: =
209 <94> send: assert:
210 <D8> pop
211 <58> returnSelf
'.
]

{ #category : 'subject code' }
InstvarRemappingTest >> m02SourceCode [
	^ 'test02AccessMidVariables
 
 	"Med #genStorePopInstVar:. Use two bytes each in Spur."
 	a25 := ''a1''.
 	a26 := 2.
 	a27 := Float pi.
 	a28 := #[11 22 33 44].
 	1 > 0
 		ifTrue: [ a245 := 99 ]
 		ifFalse: [ a245 := 98 ].
 	a246 := ''a1''.
 	a247 := Float pi.
 	a248 := #[11 22 33 44].
 	
 	"Med #genPushInstVar: . Use two bytes each in Spur."
 	self assert: a25 = ''a1''.
 	self assert: a26 = 2.
 	self assert: a27 = Float pi.
 	self assert: a28 = #[11 22 33 44].
 	self assert: a245 = 99.
 	self assert: a246 = ''a1''.
 	self assert: a247 = Float pi.
 	self assert: a248 = #[11 22 33 44].'
]

{ #category : 'bytecode code' }
InstvarRemappingTest >> m03Bytecode [
	^
'73 <51> pushConstant: 1
74 <50> pushConstant: 0
75 <63> send: >
76 <C4> jumpFalse: 82
77 <E8 63> pushConstant: 99
79 <F3 FE> storeIntoRcvr: 254 "a255"
81 <B3> jumpTo: 86
82 <E8 62> pushConstant: 98
84 <F3 FE> storeIntoRcvr: 254 "a255"
86 <D8> pop
87 <20> pushConstant: ''a1''
88 <F0 FF> popIntoRcvr: 255 "a256"
90 <12> pushLit: Float
91 <81> send: pi
92 <E0 01 F0 00> popIntoRcvr: 256 "a257"
96 <23> pushConstant: #[11 22 33 44]
97 <E0 01 F0 01> popIntoRcvr: 257 "a258"
101 <4C> self
102 <E2 FE> pushRcvr: 254 "a255"
104 <E8 63> pushConstant: 99
106 <66> send: =
107 <94> send: assert:
108 <D8> pop
109 <4C> self
110 <E2 FF> pushRcvr: 255 "a256"
112 <20> pushConstant: ''a1''
113 <66> send: =
114 <94> send: assert:
115 <D8> pop
116 <4C> self
117 <E0 01 E2 00> pushRcvr: 256 "a257"
121 <12> pushLit: Float
122 <81> send: pi
123 <66> send: =
124 <94> send: assert:
125 <D8> pop
126 <4C> self
127 <E0 01 E2 01> pushRcvr: 257 "a258"
131 <23> pushConstant: #[11 22 33 44]
132 <66> send: =
133 <94> send: assert:
134 <D8> pop
135 <58> returnSelf
'.

]

{ #category : 'bytecode code' }
InstvarRemappingTest >> m03BytecodeLongIvarAcessAndJumps [
	^
'73 <51> pushConstant: 1
74 <50> pushConstant: 0
75 <63> send: >
76 <E1 00 EF 0A> jumpFalse: 90
80 <E8 63> pushConstant: 99
82 <E0 00 F3 FE> storeIntoRcvr: 254 "a255"
86 <E1 00 ED 06> jumpTo: 96
90 <E8 62> pushConstant: 98
92 <E0 00 F3 FE> storeIntoRcvr: 254 "a255"
96 <D8> pop
97 <20> pushConstant: ''a1''
98 <E0 00 F0 FF> popIntoRcvr: 255 "a256"
102 <12> pushLit: Float
103 <81> send: pi
104 <E0 01 F0 00> popIntoRcvr: 256 "a257"
108 <23> pushConstant: #[11 22 33 44]
109 <E0 01 F0 01> popIntoRcvr: 257 "a258"
113 <4C> self
114 <E0 00 E2 FE> pushRcvr: 254 "a255"
118 <E8 63> pushConstant: 99
120 <66> send: =
121 <94> send: assert:
122 <D8> pop
123 <4C> self
124 <E0 00 E2 FF> pushRcvr: 255 "a256"
128 <20> pushConstant: ''a1''
129 <66> send: =
130 <94> send: assert:
131 <D8> pop
132 <4C> self
133 <E0 01 E2 00> pushRcvr: 256 "a257"
137 <12> pushLit: Float
138 <81> send: pi
139 <66> send: =
140 <94> send: assert:
141 <D8> pop
142 <4C> self
143 <E0 01 E2 01> pushRcvr: 257 "a258"
147 <23> pushConstant: #[11 22 33 44]
148 <66> send: =
149 <94> send: assert:
150 <D8> pop
151 <58> returnSelf
'.
]

{ #category : 'subject code' }
InstvarRemappingTest >> m03SourceCode [
	^ 'test03AccessHighVariables
 	1 > 0
 		ifTrue: [ a255 := 99 ]
 		ifFalse: [ a255 := 98 ].
 	a256 := ''a1''.
 	a257 := Float pi.
 	a258 := #[11 22 33 44].
 	self assert: a255 = 99.
 	self assert: a256 = ''a1''.
 	self assert: a257 = Float pi.
 	self assert: a258 = #[11 22 33 44].'
]

{ #category : 'bytecode code' }
InstvarRemappingTest >> m04Bytecode [
	^
'89 <51> pushConstant: 1
90 <50> pushConstant: 0
91 <63> send: >
92 <C7> jumpFalse: 101
93 <E8 63> pushConstant: 99
95 <F3 FE> storeIntoRcvr: 254 "a255"
97 <E1 01 ED 3F> jumpTo: 420
101 <21> pushConstant: ''La tota''
102 <E7 81> pop 1 into (Array new: 1)
104 <80> send: print
105 <D8> pop
106 <21> pushConstant: ''La tota''
107 <E7 81> pop 1 into (Array new: 1)
109 <80> send: print
110 <D8> pop
111 <21> pushConstant: ''La tota''
112 <E7 81> pop 1 into (Array new: 1)
114 <80> send: print
115 <D8> pop
116 <21> pushConstant: ''La tota''
117 <E7 81> pop 1 into (Array new: 1)
119 <80> send: print
120 <D8> pop
121 <21> pushConstant: ''La tota''
122 <E7 81> pop 1 into (Array new: 1)
124 <80> send: print
125 <D8> pop
126 <21> pushConstant: ''La tota''
127 <E7 81> pop 1 into (Array new: 1)
129 <80> send: print
130 <D8> pop
131 <21> pushConstant: ''La tota''
132 <E7 81> pop 1 into (Array new: 1)
134 <80> send: print
135 <D8> pop
136 <21> pushConstant: ''La tota''
137 <E7 81> pop 1 into (Array new: 1)
139 <80> send: print
140 <D8> pop
141 <21> pushConstant: ''La tota''
142 <E7 81> pop 1 into (Array new: 1)
144 <80> send: print
145 <D8> pop
146 <21> pushConstant: ''La tota''
147 <E7 81> pop 1 into (Array new: 1)
149 <80> send: print
150 <D8> pop
151 <21> pushConstant: ''La tota''
152 <E7 81> pop 1 into (Array new: 1)
154 <80> send: print
155 <D8> pop
156 <21> pushConstant: ''La tota''
157 <E7 81> pop 1 into (Array new: 1)
159 <80> send: print
160 <D8> pop
161 <21> pushConstant: ''La tota''
162 <E7 81> pop 1 into (Array new: 1)
164 <80> send: print
165 <D8> pop
166 <21> pushConstant: ''La tota''
167 <E7 81> pop 1 into (Array new: 1)
169 <80> send: print
170 <D8> pop
171 <21> pushConstant: ''La tota''
172 <E7 81> pop 1 into (Array new: 1)
174 <80> send: print
175 <D8> pop
176 <21> pushConstant: ''La tota''
177 <E7 81> pop 1 into (Array new: 1)
179 <80> send: print
180 <D8> pop
181 <21> pushConstant: ''La tota''
182 <E7 81> pop 1 into (Array new: 1)
184 <80> send: print
185 <D8> pop
186 <21> pushConstant: ''La tota''
187 <E7 81> pop 1 into (Array new: 1)
189 <80> send: print
190 <D8> pop
191 <21> pushConstant: ''La tota''
192 <E7 81> pop 1 into (Array new: 1)
194 <80> send: print
195 <D8> pop
196 <21> pushConstant: ''La tota''
197 <E7 81> pop 1 into (Array new: 1)
199 <80> send: print
200 <D8> pop
201 <21> pushConstant: ''La tota''
202 <E7 81> pop 1 into (Array new: 1)
204 <80> send: print
205 <D8> pop
206 <21> pushConstant: ''La tota''
207 <E7 81> pop 1 into (Array new: 1)
209 <80> send: print
210 <D8> pop
211 <21> pushConstant: ''La tota''
212 <E7 81> pop 1 into (Array new: 1)
214 <80> send: print
215 <D8> pop
216 <21> pushConstant: ''La tota''
217 <E7 81> pop 1 into (Array new: 1)
219 <80> send: print
220 <D8> pop
221 <21> pushConstant: ''La tota''
222 <E7 81> pop 1 into (Array new: 1)
224 <80> send: print
225 <D8> pop
226 <21> pushConstant: ''La tota''
227 <E7 81> pop 1 into (Array new: 1)
229 <80> send: print
230 <D8> pop
231 <21> pushConstant: ''La tota''
232 <E7 81> pop 1 into (Array new: 1)
234 <80> send: print
235 <D8> pop
236 <21> pushConstant: ''La tota''
237 <E7 81> pop 1 into (Array new: 1)
239 <80> send: print
240 <D8> pop
241 <21> pushConstant: ''La tota''
242 <E7 81> pop 1 into (Array new: 1)
244 <80> send: print
245 <D8> pop
246 <21> pushConstant: ''La tota''
247 <E7 81> pop 1 into (Array new: 1)
249 <80> send: print
250 <D8> pop
251 <21> pushConstant: ''La tota''
252 <E7 81> pop 1 into (Array new: 1)
254 <80> send: print
255 <D8> pop
256 <21> pushConstant: ''La tota''
257 <E7 81> pop 1 into (Array new: 1)
259 <80> send: print
260 <D8> pop
261 <21> pushConstant: ''La tota''
262 <E7 81> pop 1 into (Array new: 1)
264 <80> send: print
265 <D8> pop
266 <21> pushConstant: ''La tota''
267 <E7 81> pop 1 into (Array new: 1)
269 <80> send: print
270 <D8> pop
271 <21> pushConstant: ''La tota''
272 <E7 81> pop 1 into (Array new: 1)
274 <80> send: print
275 <D8> pop
276 <21> pushConstant: ''La tota''
277 <E7 81> pop 1 into (Array new: 1)
279 <80> send: print
280 <D8> pop
281 <21> pushConstant: ''La tota''
282 <E7 81> pop 1 into (Array new: 1)
284 <80> send: print
285 <D8> pop
286 <21> pushConstant: ''La tota''
287 <E7 81> pop 1 into (Array new: 1)
289 <80> send: print
290 <D8> pop
291 <21> pushConstant: ''La tota''
292 <E7 81> pop 1 into (Array new: 1)
294 <80> send: print
295 <D8> pop
296 <21> pushConstant: ''La tota''
297 <E7 81> pop 1 into (Array new: 1)
299 <80> send: print
300 <D8> pop
301 <21> pushConstant: ''La tota''
302 <E7 81> pop 1 into (Array new: 1)
304 <80> send: print
305 <D8> pop
306 <21> pushConstant: ''La tota''
307 <E7 81> pop 1 into (Array new: 1)
309 <80> send: print
310 <D8> pop
311 <21> pushConstant: ''La tota''
312 <E7 81> pop 1 into (Array new: 1)
314 <80> send: print
315 <D8> pop
316 <21> pushConstant: ''La tota''
317 <E7 81> pop 1 into (Array new: 1)
319 <80> send: print
320 <D8> pop
321 <21> pushConstant: ''La tota''
322 <E7 81> pop 1 into (Array new: 1)
324 <80> send: print
325 <D8> pop
326 <21> pushConstant: ''La tota''
327 <E7 81> pop 1 into (Array new: 1)
329 <80> send: print
330 <D8> pop
331 <21> pushConstant: ''La tota''
332 <E7 81> pop 1 into (Array new: 1)
334 <80> send: print
335 <D8> pop
336 <21> pushConstant: ''La tota''
337 <E7 81> pop 1 into (Array new: 1)
339 <80> send: print
340 <D8> pop
341 <21> pushConstant: ''La tota''
342 <E7 81> pop 1 into (Array new: 1)
344 <80> send: print
345 <D8> pop
346 <21> pushConstant: ''La tota''
347 <E7 81> pop 1 into (Array new: 1)
349 <80> send: print
350 <D8> pop
351 <21> pushConstant: ''La tota''
352 <E7 81> pop 1 into (Array new: 1)
354 <80> send: print
355 <D8> pop
356 <21> pushConstant: ''La tota''
357 <E7 81> pop 1 into (Array new: 1)
359 <80> send: print
360 <D8> pop
361 <21> pushConstant: ''La tota''
362 <E7 81> pop 1 into (Array new: 1)
364 <80> send: print
365 <D8> pop
366 <21> pushConstant: ''La tota''
367 <E7 81> pop 1 into (Array new: 1)
369 <80> send: print
370 <D8> pop
371 <21> pushConstant: ''La tota''
372 <E7 81> pop 1 into (Array new: 1)
374 <80> send: print
375 <D8> pop
376 <21> pushConstant: ''La tota''
377 <E7 81> pop 1 into (Array new: 1)
379 <80> send: print
380 <D8> pop
381 <21> pushConstant: ''La tota''
382 <E7 81> pop 1 into (Array new: 1)
384 <80> send: print
385 <D8> pop
386 <21> pushConstant: ''La tota''
387 <E7 81> pop 1 into (Array new: 1)
389 <80> send: print
390 <D8> pop
391 <21> pushConstant: ''La tota''
392 <E7 81> pop 1 into (Array new: 1)
394 <80> send: print
395 <D8> pop
396 <21> pushConstant: ''La tota''
397 <E7 81> pop 1 into (Array new: 1)
399 <80> send: print
400 <D8> pop
401 <21> pushConstant: ''La tota''
402 <E7 81> pop 1 into (Array new: 1)
404 <80> send: print
405 <D8> pop
406 <21> pushConstant: ''La tota''
407 <E7 81> pop 1 into (Array new: 1)
409 <80> send: print
410 <D8> pop
411 <21> pushConstant: ''La tota''
412 <E7 81> pop 1 into (Array new: 1)
414 <80> send: print
415 <D8> pop
416 <E8 62> pushConstant: 98
418 <F3 FE> storeIntoRcvr: 254 "a255"
420 <D8> pop
421 <22> pushConstant: ''a1''
422 <F0 FF> popIntoRcvr: 255 "a256"
424 <14> pushLit: Float
425 <83> send: pi
426 <E0 01 F0 00> popIntoRcvr: 256 "a257"
430 <25> pushConstant: #[11 22 33 44]
431 <E0 01 F0 01> popIntoRcvr: 257 "a258"
435 <4C> self
436 <E2 FE> pushRcvr: 254 "a255"
438 <E8 63> pushConstant: 99
440 <66> send: =
441 <96> send: assert:
442 <D8> pop
443 <4C> self
444 <E2 FF> pushRcvr: 255 "a256"
446 <22> pushConstant: ''a1''
447 <66> send: =
448 <96> send: assert:
449 <D8> pop
450 <4C> self
451 <E0 01 E2 00> pushRcvr: 256 "a257"
455 <14> pushLit: Float
456 <83> send: pi
457 <66> send: =
458 <96> send: assert:
459 <D8> pop
460 <4C> self
461 <E0 01 E2 01> pushRcvr: 257 "a258"
465 <25> pushConstant: #[11 22 33 44]
466 <66> send: =
467 <96> send: assert:
468 <D8> pop
469 <58> returnSelf
'
]

{ #category : 'bytecode code' }
InstvarRemappingTest >> m04BytecodeLongIvarAcessAndJumps [
	^
'89 <51> pushConstant: 1
90 <50> pushConstant: 0
91 <63> send: >
92 <E1 00 EF 0A> jumpFalse: 106
96 <E8 63> pushConstant: 99
98 <E0 00 F3 FE> storeIntoRcvr: 254 "a255"
102 <E1 01 ED 41> jumpTo: 427
106 <21> pushConstant: ''La tota''
107 <E7 81> pop 1 into (Array new: 1)
109 <80> send: print
110 <D8> pop
111 <21> pushConstant: ''La tota''
112 <E7 81> pop 1 into (Array new: 1)
114 <80> send: print
115 <D8> pop
116 <21> pushConstant: ''La tota''
117 <E7 81> pop 1 into (Array new: 1)
119 <80> send: print
120 <D8> pop
121 <21> pushConstant: ''La tota''
122 <E7 81> pop 1 into (Array new: 1)
124 <80> send: print
125 <D8> pop
126 <21> pushConstant: ''La tota''
127 <E7 81> pop 1 into (Array new: 1)
129 <80> send: print
130 <D8> pop
131 <21> pushConstant: ''La tota''
132 <E7 81> pop 1 into (Array new: 1)
134 <80> send: print
135 <D8> pop
136 <21> pushConstant: ''La tota''
137 <E7 81> pop 1 into (Array new: 1)
139 <80> send: print
140 <D8> pop
141 <21> pushConstant: ''La tota''
142 <E7 81> pop 1 into (Array new: 1)
144 <80> send: print
145 <D8> pop
146 <21> pushConstant: ''La tota''
147 <E7 81> pop 1 into (Array new: 1)
149 <80> send: print
150 <D8> pop
151 <21> pushConstant: ''La tota''
152 <E7 81> pop 1 into (Array new: 1)
154 <80> send: print
155 <D8> pop
156 <21> pushConstant: ''La tota''
157 <E7 81> pop 1 into (Array new: 1)
159 <80> send: print
160 <D8> pop
161 <21> pushConstant: ''La tota''
162 <E7 81> pop 1 into (Array new: 1)
164 <80> send: print
165 <D8> pop
166 <21> pushConstant: ''La tota''
167 <E7 81> pop 1 into (Array new: 1)
169 <80> send: print
170 <D8> pop
171 <21> pushConstant: ''La tota''
172 <E7 81> pop 1 into (Array new: 1)
174 <80> send: print
175 <D8> pop
176 <21> pushConstant: ''La tota''
177 <E7 81> pop 1 into (Array new: 1)
179 <80> send: print
180 <D8> pop
181 <21> pushConstant: ''La tota''
182 <E7 81> pop 1 into (Array new: 1)
184 <80> send: print
185 <D8> pop
186 <21> pushConstant: ''La tota''
187 <E7 81> pop 1 into (Array new: 1)
189 <80> send: print
190 <D8> pop
191 <21> pushConstant: ''La tota''
192 <E7 81> pop 1 into (Array new: 1)
194 <80> send: print
195 <D8> pop
196 <21> pushConstant: ''La tota''
197 <E7 81> pop 1 into (Array new: 1)
199 <80> send: print
200 <D8> pop
201 <21> pushConstant: ''La tota''
202 <E7 81> pop 1 into (Array new: 1)
204 <80> send: print
205 <D8> pop
206 <21> pushConstant: ''La tota''
207 <E7 81> pop 1 into (Array new: 1)
209 <80> send: print
210 <D8> pop
211 <21> pushConstant: ''La tota''
212 <E7 81> pop 1 into (Array new: 1)
214 <80> send: print
215 <D8> pop
216 <21> pushConstant: ''La tota''
217 <E7 81> pop 1 into (Array new: 1)
219 <80> send: print
220 <D8> pop
221 <21> pushConstant: ''La tota''
222 <E7 81> pop 1 into (Array new: 1)
224 <80> send: print
225 <D8> pop
226 <21> pushConstant: ''La tota''
227 <E7 81> pop 1 into (Array new: 1)
229 <80> send: print
230 <D8> pop
231 <21> pushConstant: ''La tota''
232 <E7 81> pop 1 into (Array new: 1)
234 <80> send: print
235 <D8> pop
236 <21> pushConstant: ''La tota''
237 <E7 81> pop 1 into (Array new: 1)
239 <80> send: print
240 <D8> pop
241 <21> pushConstant: ''La tota''
242 <E7 81> pop 1 into (Array new: 1)
244 <80> send: print
245 <D8> pop
246 <21> pushConstant: ''La tota''
247 <E7 81> pop 1 into (Array new: 1)
249 <80> send: print
250 <D8> pop
251 <21> pushConstant: ''La tota''
252 <E7 81> pop 1 into (Array new: 1)
254 <80> send: print
255 <D8> pop
256 <21> pushConstant: ''La tota''
257 <E7 81> pop 1 into (Array new: 1)
259 <80> send: print
260 <D8> pop
261 <21> pushConstant: ''La tota''
262 <E7 81> pop 1 into (Array new: 1)
264 <80> send: print
265 <D8> pop
266 <21> pushConstant: ''La tota''
267 <E7 81> pop 1 into (Array new: 1)
269 <80> send: print
270 <D8> pop
271 <21> pushConstant: ''La tota''
272 <E7 81> pop 1 into (Array new: 1)
274 <80> send: print
275 <D8> pop
276 <21> pushConstant: ''La tota''
277 <E7 81> pop 1 into (Array new: 1)
279 <80> send: print
280 <D8> pop
281 <21> pushConstant: ''La tota''
282 <E7 81> pop 1 into (Array new: 1)
284 <80> send: print
285 <D8> pop
286 <21> pushConstant: ''La tota''
287 <E7 81> pop 1 into (Array new: 1)
289 <80> send: print
290 <D8> pop
291 <21> pushConstant: ''La tota''
292 <E7 81> pop 1 into (Array new: 1)
294 <80> send: print
295 <D8> pop
296 <21> pushConstant: ''La tota''
297 <E7 81> pop 1 into (Array new: 1)
299 <80> send: print
300 <D8> pop
301 <21> pushConstant: ''La tota''
302 <E7 81> pop 1 into (Array new: 1)
304 <80> send: print
305 <D8> pop
306 <21> pushConstant: ''La tota''
307 <E7 81> pop 1 into (Array new: 1)
309 <80> send: print
310 <D8> pop
311 <21> pushConstant: ''La tota''
312 <E7 81> pop 1 into (Array new: 1)
314 <80> send: print
315 <D8> pop
316 <21> pushConstant: ''La tota''
317 <E7 81> pop 1 into (Array new: 1)
319 <80> send: print
320 <D8> pop
321 <21> pushConstant: ''La tota''
322 <E7 81> pop 1 into (Array new: 1)
324 <80> send: print
325 <D8> pop
326 <21> pushConstant: ''La tota''
327 <E7 81> pop 1 into (Array new: 1)
329 <80> send: print
330 <D8> pop
331 <21> pushConstant: ''La tota''
332 <E7 81> pop 1 into (Array new: 1)
334 <80> send: print
335 <D8> pop
336 <21> pushConstant: ''La tota''
337 <E7 81> pop 1 into (Array new: 1)
339 <80> send: print
340 <D8> pop
341 <21> pushConstant: ''La tota''
342 <E7 81> pop 1 into (Array new: 1)
344 <80> send: print
345 <D8> pop
346 <21> pushConstant: ''La tota''
347 <E7 81> pop 1 into (Array new: 1)
349 <80> send: print
350 <D8> pop
351 <21> pushConstant: ''La tota''
352 <E7 81> pop 1 into (Array new: 1)
354 <80> send: print
355 <D8> pop
356 <21> pushConstant: ''La tota''
357 <E7 81> pop 1 into (Array new: 1)
359 <80> send: print
360 <D8> pop
361 <21> pushConstant: ''La tota''
362 <E7 81> pop 1 into (Array new: 1)
364 <80> send: print
365 <D8> pop
366 <21> pushConstant: ''La tota''
367 <E7 81> pop 1 into (Array new: 1)
369 <80> send: print
370 <D8> pop
371 <21> pushConstant: ''La tota''
372 <E7 81> pop 1 into (Array new: 1)
374 <80> send: print
375 <D8> pop
376 <21> pushConstant: ''La tota''
377 <E7 81> pop 1 into (Array new: 1)
379 <80> send: print
380 <D8> pop
381 <21> pushConstant: ''La tota''
382 <E7 81> pop 1 into (Array new: 1)
384 <80> send: print
385 <D8> pop
386 <21> pushConstant: ''La tota''
387 <E7 81> pop 1 into (Array new: 1)
389 <80> send: print
390 <D8> pop
391 <21> pushConstant: ''La tota''
392 <E7 81> pop 1 into (Array new: 1)
394 <80> send: print
395 <D8> pop
396 <21> pushConstant: ''La tota''
397 <E7 81> pop 1 into (Array new: 1)
399 <80> send: print
400 <D8> pop
401 <21> pushConstant: ''La tota''
402 <E7 81> pop 1 into (Array new: 1)
404 <80> send: print
405 <D8> pop
406 <21> pushConstant: ''La tota''
407 <E7 81> pop 1 into (Array new: 1)
409 <80> send: print
410 <D8> pop
411 <21> pushConstant: ''La tota''
412 <E7 81> pop 1 into (Array new: 1)
414 <80> send: print
415 <D8> pop
416 <21> pushConstant: ''La tota''
417 <E7 81> pop 1 into (Array new: 1)
419 <80> send: print
420 <D8> pop
421 <E8 62> pushConstant: 98
423 <E0 00 F3 FE> storeIntoRcvr: 254 "a255"
427 <D8> pop
428 <22> pushConstant: ''a1''
429 <E0 00 F0 FF> popIntoRcvr: 255 "a256"
433 <14> pushLit: Float
434 <83> send: pi
435 <E0 01 F0 00> popIntoRcvr: 256 "a257"
439 <25> pushConstant: #[11 22 33 44]
440 <E0 01 F0 01> popIntoRcvr: 257 "a258"
444 <4C> self
445 <E0 00 E2 FE> pushRcvr: 254 "a255"
449 <E8 63> pushConstant: 99
451 <66> send: =
452 <96> send: assert:
453 <D8> pop
454 <4C> self
455 <E0 00 E2 FF> pushRcvr: 255 "a256"
459 <22> pushConstant: ''a1''
460 <66> send: =
461 <96> send: assert:
462 <D8> pop
463 <4C> self
464 <E0 01 E2 00> pushRcvr: 256 "a257"
468 <14> pushLit: Float
469 <83> send: pi
470 <66> send: =
471 <96> send: assert:
472 <D8> pop
473 <4C> self
474 <E0 01 E2 01> pushRcvr: 257 "a258"
478 <25> pushConstant: #[11 22 33 44]
479 <66> send: =
480 <96> send: assert:
481 <D8> pop
482 <58> returnSelf
'
]

{ #category : 'subject code' }
InstvarRemappingTest >> m04SourceCode [
	^ 'test04LongJumps
 	1 > 0
 		ifTrue: [ a255 := 99 ]
 		ifFalse: [
 			{''La tota''} print.{''La tota''} print.{''La tota''} print.{''La tota''} print.{''La tota''} print.{''La tota''} print.{''La tota''} print.
 			{''La tota''} print.{''La tota''} print.{''La tota''} print.{''La tota''} print.{''La tota''} print.{''La tota''} print.{''La tota''} print.
 			{''La tota''} print.{''La tota''} print.{''La tota''} print.{''La tota''} print.{''La tota''} print.{''La tota''} print.{''La tota''} print.
 			{''La tota''} print.{''La tota''} print.{''La tota''} print.{''La tota''} print.{''La tota''} print.{''La tota''} print.{''La tota''} print.
 			{''La tota''} print.{''La tota''} print.{''La tota''} print.{''La tota''} print.{''La tota''} print.{''La tota''} print.{''La tota''} print.
 			{''La tota''} print.{''La tota''} print.{''La tota''} print.{''La tota''} print.{''La tota''} print.{''La tota''} print.{''La tota''} print.
 			{''La tota''} print.{''La tota''} print.{''La tota''} print.{''La tota''} print.{''La tota''} print.{''La tota''} print.{''La tota''} print.
 			{''La tota''} print.{''La tota''} print.{''La tota''} print.{''La tota''} print.{''La tota''} print.{''La tota''} print.{''La tota''} print.
 			{''La tota''} print.{''La tota''} print.{''La tota''} print.{''La tota''} print.{''La tota''} print.{''La tota''} print.{''La tota''} print.
 			a255 := 98 ].
 	a256 := ''a1''.
 	a257 := Float pi.
 	a258 := #[11 22 33 44].
 	self assert: a255 = 99.
 	self assert: a256 = ''a1''.
 	self assert: a257 = Float pi.
 	self assert: a258 = #[11 22 33 44].'
]

{ #category : 'setUp/tearDown' }
InstvarRemappingTest >> setUp [
	"Only for Sista!
	Also see #expectedFailures"
	| cls |
	Smalltalk at: #LargeClassIvarR01 ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
	CompiledMethod preferredBytecodeSetEncoderClass name == #EncoderForSistaV1
		ifTrue: [
			Compiler evaluate: self classDeclarationString.
			cls := Smalltalk at: #LargeClassIvarR01.
			cls
				compile: self m01SourceCode notifying: nil;
				compile: self m02SourceCode notifying: nil;
				compile: self m03SourceCode notifying: nil;
				compile: self m04SourceCode notifying: nil ].
]

{ #category : 'setUp/tearDown' }
InstvarRemappingTest >> tearDown [
	"
	InstvarRemappingTest new setUp test01
	"
	Smalltalk at: #LargeClassIvarR01 ifPresent: [ :leftover | leftover removeFromSystemUnlogged ].
]

{ #category : 'tests' }
InstvarRemappingTest >> testInstVarRemapping01 [
	"
	Excercise remapping. Stay in the low (1 byte) area.
	InstvarRemappingTest new setUp testInstVarRemapping01
	"
	| cls method |
	cls := Smalltalk at: #LargeClassIvarR01.
	method := cls >> #test03AccessHighVariables.
	self assert: method decompile decompileString = 'test03AccessHighVariables
	1 > 0
		ifTrue: [ a255 := 99 ]
		ifFalse: [ a255 := 98 ].
	a256 := ''a1''.
	a257 := Float pi.
	a258 := #[11 22 33 44].
	self assert: a255 = 99.
	self assert: a256 = ''a1''.
	self assert: a257 = Float pi.
	self assert: a258 = #[11 22 33 44].'.
	
	cls new test03AccessHighVariables.

	EncoderForSistaV1 remapInstVarAccessesIn: method asPer: {255->234} asDictionary doIt: true.

	self assert: method decompile decompileString = 'test03AccessHighVariables
	1 > 0
		ifTrue: [ a234 := 99 ]
		ifFalse: [ a234 := 98 ].
	a256 := ''a1''.
	a257 := Float pi.
	a258 := #[11 22 33 44].
	self assert: a234 = 99.
	self assert: a256 = ''a1''.
	self assert: a257 = Float pi.
	self assert: a258 = #[11 22 33 44].'.
	
	cls addSelectorSilently: method selector withMethod: method.
	cls new test03AccessHighVariables.
]

{ #category : 'tests' }
InstvarRemappingTest >> testInstVarRemapping02 [
	"
	Excercise remapping. Stay in the 2 byte area.
	InstvarRemappingTest new setUp testInstVarRemapping02
	"
	| cls method |
	cls := Smalltalk at: #LargeClassIvarR01.
	method := cls >> #test03AccessHighVariables.
	self assert: method decompile decompileString = 'test03AccessHighVariables
	1 > 0
		ifTrue: [ a255 := 99 ]
		ifFalse: [ a255 := 98 ].
	a256 := ''a1''.
	a257 := Float pi.
	a258 := #[11 22 33 44].
	self assert: a255 = 99.
	self assert: a256 = ''a1''.
	self assert: a257 = Float pi.
	self assert: a258 = #[11 22 33 44].'.
	
	cls new test03AccessHighVariables.
	
	EncoderForSistaV1 remapInstVarAccessesIn: method asPer: {258->262} asDictionary doIt: true.

	self assert: method decompile decompileString = 'test03AccessHighVariables
	1 > 0
		ifTrue: [ a255 := 99 ]
		ifFalse: [ a255 := 98 ].
	a256 := ''a1''.
	a257 := Float pi.
	a262 := #[11 22 33 44].
	self assert: a255 = 99.
	self assert: a256 = ''a1''.
	self assert: a257 = Float pi.
	self assert: a262 = #[11 22 33 44].'.
	
	cls addSelectorSilently: method selector withMethod: method.
	cls new test03AccessHighVariables.
]

{ #category : 'tests' }
InstvarRemappingTest >> testInstVarRemapping03 [
	"
	Excercise remapping. Cross the 256 ivar barrier.
	InstvarRemappingTest new setUp testInstVarRemapping03
	"
	| cls method |
	cls := Smalltalk at: #LargeClassIvarR01.
	method := cls >> #test03AccessHighVariables.
	self assert: method decompile decompileString = 'test03AccessHighVariables
	1 > 0
		ifTrue: [ a255 := 99 ]
		ifFalse: [ a255 := 98 ].
	a256 := ''a1''.
	a257 := Float pi.
	a258 := #[11 22 33 44].
	self assert: a255 = 99.
	self assert: a256 = ''a1''.
	self assert: a257 = Float pi.
	self assert: a258 = #[11 22 33 44].'.
	
	cls new test03AccessHighVariables.

	"Needs to convert 2 byte bytecodes into 4 byte bytecodes"
	self shouldFail: [ EncoderForSistaV1 remapInstVarAccessesIn: method asPer: {255->262} asDictionary doIt: true ].
	
	method := method encoderClass withLongInstVarAccessBytecodes: method.
	
	EncoderForSistaV1 remapInstVarAccessesIn: method asPer: {255->262} asDictionary doIt: true.

	self assert: method decompile decompileString = 'test03AccessHighVariables
	1 > 0
		ifTrue: [ a262 := 99 ]
		ifFalse: [ a262 := 98 ].
	a256 := ''a1''.
	a257 := Float pi.
	a258 := #[11 22 33 44].
	self assert: a262 = 99.
	self assert: a256 = ''a1''.
	self assert: a257 = Float pi.
	self assert: a258 = #[11 22 33 44].'.
	
	EncoderForSistaV1 remapInstVarAccessesIn: method asPer: {262->255} asDictionary doIt: true.

	self assert: method decompile decompileString = 'test03AccessHighVariables
	1 > 0
		ifTrue: [ a255 := 99 ]
		ifFalse: [ a255 := 98 ].
	a256 := ''a1''.
	a257 := Float pi.
	a258 := #[11 22 33 44].
	self assert: a255 = 99.
	self assert: a256 = ''a1''.
	self assert: a257 = Float pi.
	self assert: a258 = #[11 22 33 44].'.
	
	cls addSelectorSilently: method selector withMethod: method.
	cls new test03AccessHighVariables.
]

{ #category : 'tests' }
InstvarRemappingTest >> testInstVarRemapping04 [
	"
	Excercise remapping. Cross the 256 ivar barrier.
	InstvarRemappingTest new setUp testInstVarRemapping04
	"
	| cls method |
	cls := Smalltalk at: #LargeClassIvarR01.
	method := cls >> #test03AccessHighVariables.
	self assert: method decompile decompileString = 'test03AccessHighVariables
	1 > 0
		ifTrue: [ a255 := 99 ]
		ifFalse: [ a255 := 98 ].
	a256 := ''a1''.
	a257 := Float pi.
	a258 := #[11 22 33 44].
	self assert: a255 = 99.
	self assert: a256 = ''a1''.
	self assert: a257 = Float pi.
	self assert: a258 = #[11 22 33 44].'.
	
	cls new test03AccessHighVariables.

	"Needs to convert 2 byte bytecodes into 4 byte bytecodes"
	self shouldFail: [ EncoderForSistaV1 remapInstVarAccessesIn: method asPer: {255->262} asDictionary doIt: true ].
	
	method := method encoderClass withLongInstVarAccessBytecodes: method.
	
	EncoderForSistaV1 remapInstVarAccessesIn: method asPer: {255->262} asDictionary doIt: true.

	self assert: method decompile decompileString = 'test03AccessHighVariables
	1 > 0
		ifTrue: [ a262 := 99 ]
		ifFalse: [ a262 := 98 ].
	a256 := ''a1''.
	a257 := Float pi.
	a258 := #[11 22 33 44].
	self assert: a262 = 99.
	self assert: a256 = ''a1''.
	self assert: a257 = Float pi.
	self assert: a258 = #[11 22 33 44].'.
	
	EncoderForSistaV1 remapInstVarAccessesIn: method asPer: {262->6} asDictionary doIt: true.

	self assert: method decompile decompileString = 'test03AccessHighVariables
	1 > 0
		ifTrue: [ a6 := 99 ]
		ifFalse: [ a6 := 98 ].
	a256 := ''a1''.
	a257 := Float pi.
	a258 := #[11 22 33 44].
	self assert: a6 = 99.
	self assert: a256 = ''a1''.
	self assert: a257 = Float pi.
	self assert: a258 = #[11 22 33 44].'.
	
	cls addSelectorSilently: method selector withMethod: method.
	cls new test03AccessHighVariables.
]

{ #category : 'tests' }
InstvarRemappingTest >> testInstVarRemapping05 [
	"
	Excercise remapping. Go from short form to full 1 byte.
	InstvarRemappingTest new setUp testInstVarRemapping05
	"
	| cls method |
	cls := Smalltalk at: #LargeClassIvarR01.
	method := cls >> #test01AccessLowVariables.
	self assert: method decompile decompileString = 'test01AccessLowVariables
	1 > 0
		ifTrue: [ a5 := 99 ]
		ifFalse: [ a5 := 98 ].
	a6 := ''a1''.
	a7 := Float pi.
	a8 := #[11 22 33 44].
	self assert: a5 = 99.
	self assert: a6 = ''a1''.
	self assert: a7 = Float pi.
	self assert: a8 = #[11 22 33 44].' .
	
	cls new test01AccessLowVariables.

	EncoderForSistaV1 remapInstVarAccessesIn: method asPer: {8->234} asDictionary doIt: true.

	self assert: method decompile decompileString = 'test01AccessLowVariables
	1 > 0
		ifTrue: [ a5 := 99 ]
		ifFalse: [ a5 := 98 ].
	a6 := ''a1''.
	a7 := Float pi.
	a234 := #[11 22 33 44].
	self assert: a5 = 99.
	self assert: a6 = ''a1''.
	self assert: a7 = Float pi.
	self assert: a234 = #[11 22 33 44].' .
	
	cls addSelectorSilently: method selector withMethod: method.
	cls new test01AccessLowVariables.
]

{ #category : 'tests' }
InstvarRemappingTest >> testInstVarRemapping06 [
	"
	Excercise remapping. Go from short form to over 256.
	InstvarRemappingTest new setUp testInstVarRemapping06
	"
	| cls method |
	cls := Smalltalk at: #LargeClassIvarR01.
	method := cls >> #test01AccessLowVariables.
	self assert: method decompile decompileString = 'test01AccessLowVariables
	1 > 0
		ifTrue: [ a5 := 99 ]
		ifFalse: [ a5 := 98 ].
	a6 := ''a1''.
	a7 := Float pi.
	a8 := #[11 22 33 44].
	self assert: a5 = 99.
	self assert: a6 = ''a1''.
	self assert: a7 = Float pi.
	self assert: a8 = #[11 22 33 44].' .
	
	cls new test01AccessLowVariables.

	self shouldFail: [ EncoderForSistaV1 remapInstVarAccessesIn: method asPer: {8->261} asDictionary doIt: true ].

	method := method encoderClass withLongInstVarAccessBytecodes: method.
	
	EncoderForSistaV1 remapInstVarAccessesIn: method asPer: {8->261} asDictionary doIt: true.
	
	self assert: method decompile decompileString = 'test01AccessLowVariables
	1 > 0
		ifTrue: [ a5 := 99 ]
		ifFalse: [ a5 := 98 ].
	a6 := ''a1''.
	a7 := Float pi.
	a261 := #[11 22 33 44].
	self assert: a5 = 99.
	self assert: a6 = ''a1''.
	self assert: a7 = Float pi.
	self assert: a261 = #[11 22 33 44].' .
	
	cls addSelectorSilently: method selector withMethod: method.
	cls new test01AccessLowVariables.
]

{ #category : 'tests' }
InstvarRemappingTest >> testLongInstVarAcessConversion01 [
	"
	InstvarRemappingTest new setUp testLongInstVarAcessConversion01
	"
	| cls original converted |
	cls := Smalltalk at: #LargeClassIvarR01.
	original := cls >> #test01AccessLowVariables.
	converted := original encoderClass withLongInstVarAccessBytecodes: original.
	
	self assert: original symbolic = self m01Bytecode.
	self assert: converted symbolic = self m01BytecodeLongIvarAcessAndJumps.

	cls new test01AccessLowVariables.
	cls addSelectorSilently: converted selector withMethod: converted.
	cls new test01AccessLowVariables.
]

{ #category : 'tests' }
InstvarRemappingTest >> testLongInstVarAcessConversion02 [
	"
	InstvarRemappingTest new setUp testLongInstVarAcessConversion02
	"
	| cls original converted |
	cls := Smalltalk at: #LargeClassIvarR01.
	original := cls >> #test02AccessMidVariables.
	converted := original encoderClass withLongInstVarAccessBytecodes: original.
	
	self assert: original symbolic = self m02Bytecode.
	self assert: converted symbolic = self m02BytecodeLongIvarAcessAndJumps.

	cls new test02AccessMidVariables.
	cls addSelectorSilently: converted selector withMethod: converted.
	cls new test02AccessMidVariables.
]

{ #category : 'tests' }
InstvarRemappingTest >> testLongInstVarAcessConversion03 [
	"
	InstvarRemappingTest new setUp testLongInstVarAcessConversion03
	"
	| cls original converted |
	cls := Smalltalk at: #LargeClassIvarR01.
	original := cls >> #test03AccessHighVariables.
	converted := original encoderClass withLongInstVarAccessBytecodes: original.
	
	self assert: original symbolic = self m03Bytecode.
	self assert: converted symbolic = self m03BytecodeLongIvarAcessAndJumps.

	cls new test03AccessHighVariables.
	cls addSelectorSilently: converted selector withMethod: converted.
	cls new test03AccessHighVariables.
]

{ #category : 'tests' }
InstvarRemappingTest >> testLongInstVarAcessConversion04 [
	"
	InstvarRemappingTest new setUp testLongInstVarAcessConversion04
	"
	| cls original converted |
	cls := Smalltalk at: #LargeClassIvarR01.
	original := cls >> #test04LongJumps.
	converted := original encoderClass withLongInstVarAccessBytecodes: original.
	
	self assert: original symbolic = self m04Bytecode.
	self assert: converted symbolic = self m04BytecodeLongIvarAcessAndJumps.

	cls new test04LongJumps.
	cls addSelectorSilently: converted selector withMethod: converted.
	cls new test04LongJumps.
]
