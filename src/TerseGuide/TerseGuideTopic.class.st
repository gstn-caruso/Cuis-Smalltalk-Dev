"
I represent a topic that can be added to the TerseGuide. Subclasses of me should implement #title and #examples. For instance:

>>title
    ^ 'Numbers'

>> examples
     ^ {
            { #code -> '4 factorial' . #category -> 'Common functions' . #description -> 'factorial' } as: Dictionary.
            { #code -> '2 even' . #category -> 'Common functions' . #description -> 'check if a number is even' } as: Dictionary.
        }
"
Class {
	#name : 'TerseGuideTopic',
	#superclass : 'Object',
	#category : 'TerseGuide',
	#package : 'TerseGuide'
}

{ #category : 'private - script building' }
TerseGuideTopic >> append: example toScript: stream [

	stream
		nextPutAll: (example at: #code);
		nextPutAll: '. ';
		nextPutAll: (self commentFor: example);
		newLine
]

{ #category : 'private - script building' }
TerseGuideTopic >> commentFor: example [

	^ '"' , (example at: #category) , ' - ' , (example at: #description) , '"'
]

{ #category : 'accessing' }
TerseGuideTopic >> examples [

	^ #()
]

{ #category : 'accessing' }
TerseGuideTopic >> script [

	^ String streamContents: [ :stream |
		self examples do: [ :example |
			self append: example toScript: stream
		]
	]
]

{ #category : 'accessing' }
TerseGuideTopic >> title [

	self subclassResponsibility
]
