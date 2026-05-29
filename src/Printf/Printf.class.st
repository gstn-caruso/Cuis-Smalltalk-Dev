Class {
	#name : 'Printf',
	#superclass : 'Object',
	#category : 'Printf',
	#package : 'Printf'
}

{ #category : 'documentation' }
Printf >> changeLog [
	^ nil 
"

==== [NM] on 16-jan-2022 =========================
. Added new test, started numbering of new tests. Easier to reference them, Easier to 
follow them when studying a new package. PLEASE, keep numbering the test progressively
if you add more. 

. added support for prettyprintinf float numbers, that is, with thousand separator and decimal
separator. These can be also set by the user, making the work locale independent. 
Please see tests 100, 102, 103.

. discovered bug, exposed in test 101, still to be corrected. it relates to the printing of large numbers. 

. added the method 'hackMe' , to contain some minimal documentation about how to add stuff
to this package. 

=======================================
"
]

{ #category : 'documentation' }
Printf >> hackIt [
	^ nil 
"

====== [NM] on  16-Jan-2022 =============================

. This package is not so easy to understand, when i started i underestimated the complexity.

. Suppose you are adding a new function character 'z', the first thing you need to get working is
 the third line, the others are examples. 
PrintfFormatDescriptor scanFrom: (ReadStream on: 'd'). 
PrintfFormatDescriptor scanFrom: (ReadStream on: '-s'). 
PrintfFormatDescriptor scanFrom: (ReadStream on: 'z'). 

. The recognized charactes (%d, %s, %f ... ) and flags are defined in: 
PrintfFormatDescriptor class >> initialize 

. Who does the number printinting are, for example:
PrintfNumberFormatDescription >> applyOperator: anObject. 
  [ the anObject here is for example: 123 ]
PrintfFloatFormatDescription >> applyOperator: anObject.
[ the anObject here is for example: 123.123 ] 



=====================================================

"
]

{ #category : 'documentation' }
Printf >> history [
	^ nil 
"
This package was ported from Squeak to Cuis on 20 Aug 2021 by Dr. Nicola Mingotti [NM]. 

It was taken from the Squeak release: Printf-eem.12.mcz.

At the moment of porting the package has 12 tests. 7 Pass, 5 give errors. 
The same outcome apply in Squeak as in Cuis. 

On date 30-Aug-2021 [NM] has made a few changes. Now all tests are green.
To make 2 test pass [NM] has to convert '\n' to NewLines instead of CR as it 
was set in 2 tests. 

Extracted from: http://www.squeaksource.com/Printf.html 
------
Creator: 	Dominic Letz
Admin: 	Eliot Miranda, Michael Rueger, Dominic Letz
------	
		
	
"
]

{ #category : 'documentation' }
Printf >> readme [
	^ nil 
"

. 'printf' is the name an extremely popular function for string formatting in the language C. 
. It has been ported to several languages
. in Printf you will find implemented several, but not all, the features of the original 'printf',

=================================================
======== Examples ==================================
==================================================

-] substitute an integer in string
'foo %d bar' printf: {123}.                 =>  'foo 123 bar' 

-] substitute a float in string with a fixed number of decimals
'foo %.5f bar' printf: {123.12}.         =>  'foo 123.12000 bar' 

----- ADD MORE !

==================================================
======= Features of C printf still unavailable in Printf ============
===================================================



----- TODO 


"
]
