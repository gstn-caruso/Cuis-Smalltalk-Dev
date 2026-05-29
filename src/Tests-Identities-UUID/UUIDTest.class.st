Class {
	#name : 'UUIDTest',
	#superclass : 'TestCase',
	#category : 'Tests-Identities-UUID',
	#package : 'Tests',
	#tag : 'Identities-UUID'
}

{ #category : 'as yet unclassified' }
UUIDTest >> testComparison [
	"Test if the comparison operators define a total sort function."

	#(
		#[3 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0] #[2 4 0 0 0 0 0 0 0 0 0 0 0 0 0 0]
		#[0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 1] #[0 0 0 0 0 0 0 0 0 0 0 0 0 0 2 4]
		#[2 4 0 0 0 0 0 0 0 0 0 0 0 0 0 0] #[3 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0]
		#[0 0 0 0 0 0 0 0 0 0 0 0 0 0 2 4] #[0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 1]
		#[0 0 0 0 0 0 0 0 0 0 0 0 0 0 2 4] #[0 0 0 0 0 0 0 0 0 0 0 0 0 0 2 4]
	) pairsDo: [ :x :y |
		| a b c d |
		a := UUID newFrom: x.
		b := UUID newFrom: y.
		c := x asString.
		d := y asString.
		"Check if the comparison is lexicographical, just like strings'."
		#(< > <= >= = ~=) do: [ :operation | 
			self assert: (a perform: operation with: b) = (c perform: operation with: d) ].
		"And a few more"
		self
			assert: (a < b) = (a >= b) not;
			assert: (a > b) = (a <= b) not;
			assert: (a = b) = (a ~= b) not;
			assert: (a < b) = (b > a);
			assert: (a > b) = (b < a);
			assert: (a >= b) = (b <= a);
			assert: (a <= b) = (b >= a);
			assert: (a = b) = (b = a);
			assert: (a ~= b) = (b ~= a);
			assert: (a > b) = ((a >= b) & (a ~= b));
			assert: (a < b) = ((a <= b) & (a ~= b));
			assert: (a >= b) = ((a = b) | (a > b));
			assert: (a <= b) = ((a = b) | (a < b));
			assert: (a ~= b) = ((a < b) | (a > b));
			assert: (a <= b) & (b <= a) = (a = b);
			assert: (a >= b) & (b >= a) = (a = b);
			assert: (a <= b) | (b <= a);
			"assert: (a = b) asBit + (a < b) asBit + (b < a) asBit = 1"
			assert: (((a = b) and: (a < b)) not) = (((a = b) xor: (a < b)) xor: (b < a)) ]
]
