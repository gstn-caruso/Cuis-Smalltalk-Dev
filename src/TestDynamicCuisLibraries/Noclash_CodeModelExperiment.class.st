Class {
	#name : 'Noclash_CodeModelExperiment',
	#superclass : 'Object',
	#category : 'TestDynamicCuisLibraries-SubjectClassesBasic',
	#package : 'TestDynamicCuisLibraries',
	#tag : 'SubjectClassesBasic'
}

{ #category : 'sample methods' }
Noclash_CodeModelExperiment >> method01 [
	"Just for testing.
	"

	| a b1 b2 b3 b4 b5 c d |
	a := Smalltalk.  								"Method literal is a ReadOnlyVariableBinding"
	b1 := Point.  								"Method literal is a ReadOnlyVariableBinding"
	b2 := Point class.  								"Method literal is a ReadOnlyVariableBinding."
	b3 := Smalltalk at: #Point.  								"Additional method literal is the symbol #Point"
	b4 := `Smalltalk at: #Point`. 								"Method literal is class Point"
	b5 := `(Smalltalk at: #Point) class`. 								"Method literal is metaclass Point"
	c := Display.  								"Method literal is an Association"
	d := `Smalltalk at: #Display`.  								"Method literal is the instance of DisplayScreen"
	^ {a. b1. b2. b3. b4. b5. c. d}.
"Qué cosas pueden ser literal de un metodo?
+ isLiteral == true (Booleans, Numbers, String, Arrays, NumericArrays...
+ Association / ReadOnlyVariableBinding (Globales, classvars, poolDict elements)
+ literales arbitrarios (`code`) - PERO NO TENEMOS COMPILADOR!!!!!!!!! 
	Usar `ReferenceStream streamedRepresentationOf: aLiteral` y después `ReferenceStream unStream: aByteArray`?"
]
