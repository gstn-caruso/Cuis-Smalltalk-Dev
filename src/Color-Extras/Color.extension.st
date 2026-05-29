Extension { #name : 'Color' }

{ #category : '*color-extras-named colors' }
Color >> closestAssocFrom: aColorDict [
	"Answer closest associated color in aColorDict"
"
	((Color r: 0.3 g: 0.2 b: 0.8) closestAssocFrom: (Color colorNamesDict)) explore.
"
	"Filter values for those close in hue (cheap test) then use rgbDistance"
	| closeInHue isClose close distance myHue |
	closeInHue := OrderedCollection new.
	myHue := self hue.
	isClose := [ :assoc | | delta |
		delta := ((assoc value hue) - myHue) abs.
		(delta < 20) or: [ delta > 340 ] "hues within 20 degrees"
	].
	aColorDict  associationsDo:  [ :assoc |
		(isClose value: assoc) ifTrue: [ closeInHue add: assoc ]
	].

	close := nil.
	distance := 1000. "big"
	(closeInHue size > 0)
		ifFalse: [ "fallback -- no color really close"
			aColorDict  associationsDo:  [ :assoc | | dist |
				dist := self rgbDistance: (assoc value). 
				(dist < distance)  ifTrue: [distance := dist. close := assoc]
				]
		]
		ifTrue: [ closeInHue do: [ :assoc | | dist |
				dist := self rgbDistance: (assoc value). 
				(dist < distance)  ifTrue: [distance := dist. close := assoc]
				]
		].
	
	^ close
]

{ #category : '*color-extras-named colors' }
Color >> closestColor [
	"Answer the closest matching color in the colorNames dictionary"

"
	(Color red lighter lighter) closestColor explore.
"
	^ self closestColorFrom: (Color colorNamesDict)
]

{ #category : '*color-extras-named colors' }
Color >> closestColorAssociation [
	"Answer this color's closest name->color match."

"
	(Color blue lighter lighter) closestColorAssociation explore.
"	
	^ self closestAssocFrom: (Color colorNamesDict)
]

{ #category : '*color-extras-named colors' }
Color >> closestColorFrom: aColorDict [
	"Answer closest associated color"
"
	((Color lightBlue) closestColorFrom: (Color css2NamedColors)) explore..
"
	^(self closestAssocFrom: aColorDict) value
]

{ #category : '*color-extras-named colors' }
Color >> closestColorName [
	"Answer the name symbol of the closest matching color in the colorNames dictionary"
"
	(Color red lighter lighter) closestColor name.
"
	
	^ self closestNameFrom: (Color colorNamesDict)
]

{ #category : '*color-extras-named colors' }
Color >> closestNameFrom: aColorDict [
	"Answer closest associated color name"
"
	((Color lightBlue) closestNameFrom: (Color namedColors)) print.
"
	^(self closestAssocFrom: aColorDict) key
]

{ #category : '*color-extras-selection' }
Color >> isBlueGreen [
	"Am I considered BlueGreen ?"

	^self green > self red 
		and: [self red < 0.3]
			and: [(self green - self blue) abs < 0.1]
]

{ #category : '*color-extras-selection' }
Color >> isBright [
	"Am I considered a Bright color ?"

	^self brightness > 0.6
]

{ #category : '*color-extras-selection' }
Color >> isBrown [
	"Am I considered Brown ?"

	^self red >= self green  
		and: [self green > self blue]					
			and: [(self red - self green) < 0.5]	
				and: [(self green - self blue) < 0.3]
]

{ #category : '*color-extras-selection' }
Color >> isDark [
	"Am I considered a Dark color ?"

	^self brightness < 0.5
]

{ #category : '*color-extras-selection' }
Color >> isGray [
	"Am I considered Gray  ?"

	^ self saturation < 0.03
]

{ #category : '*color-extras-selection' }
Color >> isGrey [
	"Am I considered Grey  ?"

	^self isGray
]

{ #category : '*color-extras-selection' }
Color >> isLight [
	"Am I considered a Light color ?"

	^self brightness > 0.6
]

{ #category : '*color-extras-selection' }
Color >> isOrange [
	"Am I considered Orange ?"

	^self red > ((self green max: self blue) + 0.2)  
		and: [self green > (self blue + 0.2)]
]

{ #category : '*color-extras-selection' }
Color >> isPastel [
	"Am I considered Pastel ?"

	^self saturation < 0.4
]

{ #category : '*color-extras-selection' }
Color >> isPink [
	"Am I considered Pink ?"

	^self red > ((self green max: self blue) + 0.3)  
		and: [self blue > (self green + 0.2)]
]

{ #category : '*color-extras-selection' }
Color >> isSaturated [
	"Am I considered to be a Saturated color ?"

	^self saturation > 0.6
]

{ #category : '*color-extras-named colors' }
Color class >> aqua [

	^ ColorNamesDict at: #aqua
]

{ #category : '*color-extras-named colors' }
Color class >> beige [

	^ ColorNamesDict at: #beige
]

{ #category : '*color-extras-selection' }
Color class >> blueColorDict [
	"Answer a dictionary of named colors considered Blue"
"
	Color blueColorDict explore.
"
	^self blueColorDict: ColorNamesDict
]

{ #category : '*color-extras-selection' }
Color class >> blueColorDict: aColorDict [
	"Answer a dictionary of named colors considered Blue"

	| dict |
	dict := Dictionary new.
	aColorDict associationsDo: 
		 [ :assoc |
			((assoc value isBlue)
				or: [assoc key asString asLowercase includesSubString: 'blue'])
			ifTrue: [dict add: assoc]
		].
	^dict
]

{ #category : '*color-extras-selection' }
Color class >> blueGreenColorDict [
	"Answer a dictionary of named colors considered Blue"
"
	Color blueGreenColorDict explore.
"
	^self blueGreenColorDict: ColorNamesDict
]

{ #category : '*color-extras-selection' }
Color class >> blueGreenColorDict: aColorDict [
	"Answer a dictionary of named colors considered Blue"

	| dict |
	dict := Dictionary new.
	aColorDict associationsDo: 
		 [ :assoc |
			((assoc value isBlueGreen)
				or: [assoc key asString asLowercase includesSubString: 'bluegreen'])
			ifTrue: [dict add: assoc]
		].
	^dict
]

{ #category : '*color-extras-selection' }
Color class >> brightColorDict [
	"Answer a dictionary of named colors considered Bright"
"
	Color brightColorDict explore.
"
	^self brightColorDict: ColorNamesDict
]

{ #category : '*color-extras-selection' }
Color class >> brightColorDict: aColorDict [
	"Answer a dictionary of named colors considered Bright"

	| dict |
	dict := Dictionary new.
	aColorDict associationsDo: 
		 [ :assoc |
			(assoc value isBright) ifTrue: [dict add: assoc]
		].
	^dict
]

{ #category : '*color-extras-named colors' }
Color class >> brightGreen [

	^ ColorNamesDict at: #brightGreen
]

{ #category : '*color-extras-selection' }
Color class >> brownColorDict [
	"Answer a dictionary of named colors considered Brown"
"
	Color brownColorDict explore.
"
	^self brownColorDict: ColorNamesDict
]

{ #category : '*color-extras-selection' }
Color class >> brownColorDict: aColorDict [
	"Answer a dictionary of named colors considered Brown"

	| dict |
	dict := Dictionary new.
	aColorDict associationsDo: 
		 [ :assoc |
			((assoc value isBrown)
				or: [assoc key asString asLowercase includesSubString: 'brown'])
			ifTrue: [dict add: assoc]
		].
	^dict
]

{ #category : '*color-extras-color name lookup' }
Color class >> colorNames [
	"Answer the current dictionary of  name->color associations."

	^ColorNamesDict keys
]

{ #category : '*color-extras-cached state access' }
Color class >> colorNamesDict [
	"Answer the current dictionary of  name->color associations."
"
	Color colorNamesDict explore.
"
	^ColorNamesDict
]

{ #category : '*color-extras-named colors' }
Color class >> darkBlue [

	^ ColorNamesDict at: #darkBlue
]

{ #category : '*color-extras-selection' }
Color class >> darkColorDict [
	"Answer a dictionary of named colors considered Dark"
"
	Color darkColorDict explore.
"
	^self darkColorDict: ColorNamesDict
]

{ #category : '*color-extras-selection' }
Color class >> darkColorDict: aColorDict [
	"Answer a dictionary of named colors considered Dark"

	| dict |
	dict := Dictionary new.
	aColorDict associationsDo: 
		 [ :assoc |
			(assoc value isDark) ifTrue: [dict add: assoc]
		].
	^dict
]

{ #category : '*color-extras-named colors' }
Color class >> darkGreen [

	^ ColorNamesDict at: #darkGreen
]

{ #category : '*color-extras-named colors' }
Color class >> darkPink [

	^ ColorNamesDict at: #darkPink
]

{ #category : '*color-extras-named colors' }
Color class >> darkPurple [

	^ ColorNamesDict at: #darkPurple
]

{ #category : '*color-extras-color name lookup' }
Color class >> defaultColorNamesDictionary [
	"Answer a amall but  useful name->color dictionary"
	
	| defaultDict |
	"Meld most used xkcd colors into traditional colors."
	defaultDict := (self traditionalColorNamesDictionary addAll: 
					self xkcdFirst48ColorNamesDictionary; 
					yourself).
		
	"Override traditional names existing in extended XKCD naming"
	defaultDict at: #lightYellow    put: (Color r: 1.0 g: 0.996 b: 0.478).
	defaultDict at: #lightOrange   put: (Color r: 0.992 g: 0.667 b: 0.283).
	defaultDict at: #lightCyan        put: (Color r: 0.674 g: 1.0 b: 0.988).
	defaultDict at: #lightRed          put: (Color r: 1.0 g: 0.279 b: 0.298).
	defaultDict at: #lightMagenta put: (Color r: 0.98 g: 0.372 b: 0.969).
	
	^defaultDict
]

{ #category : '*color-extras-color name lookup' }
Color class >> doesNotUnderstand: aMessage [
	"Some code takes
		 Color colorNames 
	and does
		Color perform: aColorname.
		
	Make this work."

	^(Color colorNamesDict) 
		at: (aMessage selector)
		ifAbsent: [super doesNotUnderstand: aMessage]
]

{ #category : '*color-extras-color name lookup' }
Color class >> exactColorNamed: aColorName [

	"Answer color matching name or nil 
	from my ColorName->Color Dictionary"
	
	^ ColorNamesDict at: (aColorName asSymbol) ifAbsent: [nil]
]

{ #category : '*color-extras-named colors' }
Color class >> forestGreen [

	^ ColorNamesDict at: #forestGreen
]

{ #category : '*color-extras-instance creation' }
Color class >> fromString: aString [
	"For HTML color spec: #FFCCAA. Also support named colors.
	See http://www.w3schools.com/cssref/css_colors_legal.asp"
	"
	Color fromString: '#FFCCAA'.
	Color fromString: 'white'.
	Color fromString: 'orange'
	Color fromString: 'rgb(255,0,98)'
	"
	(self fromHexString: aString) ifNotNil: [ :color |
		^ color ].

	(aString beginsWith: 'rgb')
		ifTrue: [|values r g b|
				values := (aString allButFirst: 4) allButLast findTokens: ','.
				r  := (values first includes: $%)
						ifTrue: [(values first findPositiveInteger min: 100 max: 0) / 100.0]
						ifFalse: [(values first findPositiveInteger min: 255 max: 0) / 255.0].
				g := (values second includes: $%)
						ifTrue: [(values second findPositiveInteger min: 100 max: 0) / 100.0]
						ifFalse: [(values second findPositiveInteger min: 255 max: 0) / 255.0].
				b := (values third includes: $%)
						ifTrue: [(values third findPositiveInteger min: 100 max: 0) / 100.0]
						ifFalse: [(values third findPositiveInteger min: 255 max: 0) / 255.0].
				^self r: r g: g b: b].

	^self exactColorNamed: aString
]

{ #category : '*color-extras-selection' }
Color class >> grayColorDict: aColorDict [
	"Answer a dictionary of named colors considered Grey"

	| dict |
	dict := Dictionary new.
	aColorDict associationsDo: 
		 [ :assoc |
			((assoc value isGrey)
				or: [assoc key asString asLowercase includesSubString: 'grey'])
			ifTrue: [dict add: assoc]
		].
	^dict
]

{ #category : '*color-extras-selection' }
Color class >> greenColorDict [
	"Answer a dictionary of named colors considered Green"
"
	Color greenColorDict explore.
"
	^self greenColorDict: ColorNamesDict
]

{ #category : '*color-extras-selection' }
Color class >> greenColorDict: aColorDict [
	"Answer a dictionary of named colors considered Green"

	| dict |
	dict := Dictionary new.
	aColorDict associationsDo: 
		 [ :assoc |
			((assoc value isGreen)
				or: [assoc key asString asLowercase includesSubString: 'green'])
			ifTrue: [dict add: assoc]
		].
	^dict
]

{ #category : '*color-extras-named colors' }
Color class >> grey [

	^ ColorNamesDict at: #grey
]

{ #category : '*color-extras-selection' }
Color class >> greyColorDict [
	"Answer a dictionary of named colors considered Grey"
"
	Color greyColorDict explore.
"
	^self greyColorDict: ColorNamesDict
]

{ #category : '*color-extras-selection' }
Color class >> greyColorDict: aColorDict [
	"Answer a dictionary of named colors considered Grey"

	| dict |
	dict := Dictionary new.
	aColorDict associationsDo: 
		 [ :assoc |
			((assoc value isGrey)
				or: [assoc key asString asLowercase includesSubString: 'grey'])
			ifTrue: [dict add: assoc]
		].
	^dict
]

{ #category : '*color-extras-named colors' }
Color class >> hotPink [

	^ ColorNamesDict at: #hotPink
]

{ #category : '*color-extras-named colors' }
Color class >> indigo [

	^ ColorNamesDict at: #indigo
]

{ #category : '*color-extras-initialization' }
Color class >> initializeColorExtras [

	ColorNamesDict ifNil: [
		self setColorNamesDict: self defaultColorNamesDictionary ]
]

{ #category : '*color-extras-named colors' }
Color class >> lavender [

	^ ColorNamesDict at: #lavender
]

{ #category : '*color-extras-selection' }
Color class >> lightColorDict [
	"Answer a dictionary of named colors considered light"
"
	Color lightColorDict explore.
"
	^self lightColorDict: ColorNamesDict
]

{ #category : '*color-extras-selection' }
Color class >> lightColorDict: aColorDict [
	"Answer a dictionary of named colors considered Liight"

	^self brightColorDict: aColorDict
]

{ #category : '*color-extras-named colors' }
Color class >> lightPink [

	^ ColorNamesDict at: #lightPink
]

{ #category : '*color-extras-named colors' }
Color class >> lightPurple [

	^ ColorNamesDict at: #lightPurple
]

{ #category : '*color-extras-named colors' }
Color class >> lilac [

	^ ColorNamesDict at: #lilac
]

{ #category : '*color-extras-named colors' }
Color class >> lime [

	^ ColorNamesDict at: #lime
]

{ #category : '*color-extras-named colors' }
Color class >> limeGreen [

	^ ColorNamesDict at: #limeGreen
]

{ #category : '*color-extras-named colors' }
Color class >> maroon [

	^ ColorNamesDict at: #maroon
]

{ #category : '*color-extras-named colors' }
Color class >> mauve [

	^ ColorNamesDict at: #mauve
]

{ #category : '*color-extras-named colors' }
Color class >> mustard [

	^ ColorNamesDict at: #mustard
]

{ #category : '*color-extras-named colors' }
Color class >> navyBlue [

	^ ColorNamesDict at: #navyBlue
]

{ #category : '*color-extras-named colors' }
Color class >> olive [

	^ ColorNamesDict at: #olive
]

{ #category : '*color-extras-named colors' }
Color class >> oliveGreen [

	^ ColorNamesDict at: #oliveGreen
]

{ #category : '*color-extras-selection' }
Color class >> orangeColorDict [
	"Answer a dictionary of named colors considered Orange"
"
	Color orangeColorDict explore.
"
	^self orangeColorDict: ColorNamesDict
]

{ #category : '*color-extras-selection' }
Color class >> orangeColorDict: aColorDict [
	"Answer a dictionary of named colors considered Orange"

	| dict |
	dict := Dictionary new.
	aColorDict associationsDo: 
		 [ :assoc |
			((assoc value isOrange)
				or: [assoc key asString asLowercase includesSubString: 'orange'])
			ifTrue: [dict add: assoc]
		].
	^dict
]

{ #category : '*color-extras-named colors' }
Color class >> paleGreen [

	^ ColorNamesDict at: #paleGreen
]

{ #category : '*color-extras-selection' }
Color class >> pastelColorDict [
	"Answer a dictionary of named colors considered Pastel"
"
	Color pastelColorDict explore.
"
	^self pastelColorDict: ColorNamesDict
]

{ #category : '*color-extras-selection' }
Color class >> pastelColorDict: aColorDict [
	"Answer a dictionary of named colors considered Bright"

	| dict |
	dict := Dictionary new.
	aColorDict associationsDo: 
		 [ :assoc |
			(assoc value isPastel) ifTrue: [dict add: assoc]
		].
	^dict
]

{ #category : '*color-extras-named colors' }
Color class >> peach [

	^ ColorNamesDict at: #peach
]

{ #category : '*color-extras-named colors' }
Color class >> periwinkle [

	^ ColorNamesDict at: #periwinkle
]

{ #category : '*color-extras-selection' }
Color class >> pinkColorDict [
	"Answer a dictionary of named colors considered Pink"
"
	Color pinkColorDict explore.
"
	^self pinkColorDict: ColorNamesDict
]

{ #category : '*color-extras-selection' }
Color class >> pinkColorDict: aColorDict [
	"Answer a dictionary of named colors considered Pink"

	| dict |
	dict := Dictionary new.
	aColorDict associationsDo: 
		 [ :assoc |
			((assoc value isPink)
				or: [assoc key asString asLowercase includesSubString: 'pink'])
			ifTrue: [dict add: assoc]
		].
	^dict
]

{ #category : '*color-extras-selection' }
Color class >> purpleColorDict [
	"Answer a dictionary of named colors considered Purple"
"
	Color purpleColorDict explore.
"
	^self purpleColorDict: ColorNamesDict
]

{ #category : '*color-extras-selection' }
Color class >> purpleColorDict: aColorDict [
	"Answer a dictionary of named colors considered Pink"

	| dict |
	dict := Dictionary new.
	aColorDict associationsDo: 
		 [ :assoc |
			((assoc key asString asLowercase includesSubString: 'purple')
				or: [assoc key asString asLowercase includesSubString: 'violet'])
			ifTrue: [dict add: assoc]
		].
	^dict
]

{ #category : '*color-extras-selection' }
Color class >> redColorDict [
	"Answer a dictionary of named colors considered Red"
"
	Color redColorDict explore.
"
	^self redColorDict: ColorNamesDict
]

{ #category : '*color-extras-selection' }
Color class >> redColorDict: aColorDict [
	"Answer a dictionary of named colors considered Red"

	| dict |
	dict := Dictionary new.
	aColorDict associationsDo: 
		 [ :assoc |
			((assoc value isRed)
				or: [assoc key asString asLowercase includesSubString: 'red'])
			ifTrue: [dict add: assoc]
		].
	^dict
]

{ #category : '*color-extras-named colors' }
Color class >> royalBlue [

	^ ColorNamesDict at: #royalBlue
]

{ #category : '*color-extras-named colors' }
Color class >> salmon [

	^ ColorNamesDict at: #salmon
]

{ #category : '*color-extras-selection' }
Color class >> saturatedColorDict [
	"Answer a dictionary of named colors considered Saturated"
"
	Color saturatedColorDict explore.
"
	^self saturatedColorDict: ColorNamesDict
]

{ #category : '*color-extras-selection' }
Color class >> saturatedColorDict: aColorDict [
	"Answer a dictionary of named colors considered Saturated"

	| dict |
	dict := Dictionary new.
	aColorDict associationsDo: 
		 [ :assoc |
			(assoc value isSaturated) ifTrue: [dict add: assoc]
		].
	^dict
]

{ #category : '*color-extras-named colors' }
Color class >> seaGreen [

	^ ColorNamesDict at: #seaGreen
]

{ #category : '*color-extras-color name lookup' }
Color class >> setColorNamesDict: aNameColorDictionary [
	"Answer the current dictionary of  name->color associations."
	
	"Note: This is a non-standard name because this is a non-standard action!
	Do this if you really, really know what you are doing."
	
	"Some Colors are required for proper system operation"
	Color defaultColorNamesDictionary keysAndValuesDo: [ :colorName :colorValue |
		aNameColorDictionary at: colorName ifAbsentPut: colorValue
	].

	ColorNamesDict := aNameColorDictionary
]

{ #category : '*color-extras-named colors' }
Color class >> skyBlue [

	^ ColorNamesDict at: #skyBlue
]

{ #category : '*color-extras-named colors' }
Color class >> teal [

	^ ColorNamesDict at: #teal
]

{ #category : '*color-extras-color name lookup' }
Color class >> traditionalColorNamesDictionary [
	"Answer a dictionary of Squeak traditional name->color associations.."

	| nameDict |
	nameDict _ Dictionary new.
	nameDict at: #black put: `Color r: 0 g: 0 b: 0`.
	nameDict at: #veryVeryDarkGray put: `Color r: 0.125 g: 0.125 b: 0.125`.
	nameDict at: #veryDarkGray put: `Color r: 0.25 g: 0.25 b: 0.25`.
	nameDict at: #darkGray put: `Color r: 0.375 g: 0.375 b: 0.375`.
	nameDict at: #gray put: `Color r: 0.5 g: 0.5 b: 0.5`.
	nameDict at: #lightGray put: `Color r: 0.625 g: 0.625 b: 0.625`.
	nameDict at: #veryLightGray put: `Color r: 0.75 g: 0.75 b: 0.75`.
	nameDict at: #veryVeryLightGray put: `Color r: 0.875 g: 0.875 b: 0.875`.
	nameDict at: #white put: `Color r: 1.0 g: 1.0 b: 1.0`.
	nameDict at: #red put: `Color r: 1.0 g: 0 b: 0`.
	nameDict at: #yellow put: `Color r: 1.0 g: 1.0 b: 0`.
	nameDict at: #green put: `Color r: 0 g: 1.0 b: 0`.
	nameDict at: #cyan put: `Color r: 0 g: 1.0 b: 1.0`.
	nameDict at: #blue put: `Color r: 0 g: 0 b: 1.0`.
	nameDict at: #magenta put: `Color r: 1.0 g: 0 b: 1.0`.
	nameDict at: #brown put: `Color r: 0.6 g: 0.2 b: 0`.
	nameDict at: #orange put: `Color r: 1.0 g: 0.6 b: 0`.
	nameDict at: #lightRed put: `Color r: 1.0 g: 0.8 b: 0.8`.
	nameDict at: #lightYellow put: `Color r: 1.0 g: 1.0 b: 0.8`.
	nameDict at: #lightGreen put: `Color r: 0.8 g: 1.0 b: 0.6`.
	nameDict at: #lightCyan put: `Color r: 0.4 g: 1.0 b: 1.0`.
	nameDict at: #lightBlue put: `Color r: 0.8 g: 1.0 b: 1.0`.
	nameDict at: #lightMagenta put: `Color r: 1.0 g: 0.8 b: 1.0`.
	nameDict at: #lightBrown put: `Color r: 1.0 g: 0.6 b: 0.2`.
	nameDict at: #lightOrange put: `Color r: 1.0 g: 0.8 b: 0.4`.
	nameDict at: #transparent put: `TranslucentColor r: 0.0 g: 0.0 b: 0.0 alpha: 0.0`.
	
	^nameDict

]

{ #category : '*color-extras-named colors' }
Color class >> turquoise [

	^ ColorNamesDict at: #turquoise
]

{ #category : '*color-extras-named colors' }
Color class >> violet [

	^ ColorNamesDict at: #violet
]

{ #category : '*color-extras-color name lookup' }
Color class >> xkcdFirst48ColorNamesDictionary [
	"XKCD color names are based on a survey oc colors people call by the same name.
	 http://blog.xkcd.com/2010/05/03/color-survey-results/"

	"Answer a dictionary of the most agreed upon first 48 xkcd colors"
"
	Color xkcdFirst48ColorNamesDictionary explore.
"	
	| xkcdDict |
	xkcdDict := Dictionary new
	at: #lightPink put: (Color fromString: '#ffd1df') ;
	at: #mustard put: (Color fromString: '#ceb301') ;
	at: #indigo put: (Color fromString: '#380282') ;
	at: #lime put: (Color fromString: '#aaff32') ;
	at: #seaGreen put: (Color fromString: '#53fca1') ;
	at: #periwinkle put: (Color fromString: '#8e82fe') ;
	at: #darkPink put: (Color fromString: '#cb416b') ;
	at: #oliveGreen put: (Color fromString: '#677a04') ;
	at: #peach put: (Color fromString: '#ffb07c') ;
	at: #paleGreen put: (Color fromString: '#c7fdb5') ;
	at: #lightBrown put: (Color fromString: '#ad8150') ;
	at: #hotPink put: (Color fromString: '#ff028d') ;
	at: #black put: (Color fromString: '#000000') ;
	at: #lilac put: (Color fromString: '#cea2fd') ;
	at: #navyBlue put: (Color fromString: '#001146') ;
	at: #royalBlue put: (Color fromString: '#0504aa') ;
	at: #beige put: (Color fromString: '#e6daa6') ;
	at: #salmon put: (Color fromString: '#ff796c') ;
	at: #olive put: (Color fromString: '#6e750e') ;
	at: #maroon put: (Color fromString: '#650021') ;
	at: #brightGreen put: (Color fromString: '#01ff07') ;
	at: #darkPurple put: (Color fromString: '#35063e') ;
	at: #mauve put: (Color fromString: '#ae7181') ;
	at: #forestGreen put: (Color fromString: '#06470c') ;
	at: #aqua put: (Color fromString: '#13eac9') ;
	at: #cyan put: (Color fromString: '#00ffff') ;
	at: #tan put: (Color fromString: '#d1b26f') ;
	at: #darkBlue put: (Color fromString: '#00035b') ;
	at: #lavender put: (Color fromString: '#c79fef') ;
	at: #turquoise put: (Color fromString: '#06c2ac') ;
	at: #darkGreen put: (Color fromString: '#033500') ;
	at: #violet put: (Color fromString: '#9a0eea') ;
	at: #lightPurple put: (Color fromString: '#bf77f6') ;
	at: #limeGreen put: (Color fromString: '#89fe05') ;
	at: #grey put: (Color fromString: '#929591') ;
	at: #skyBlue put: (Color fromString: '#75bbfd') ;
	at: #yellow put: (Color fromString: '#ffff14') ;
	at: #magenta put: (Color fromString: '#c20078') ;
	at: #lightGreen put: (Color fromString: '#96f97b') ;
	at: #orange put: (Color fromString: '#f97306') ;
	at: #teal put: (Color fromString: '#029386') ;
	at: #lightBlue put: (Color fromString: '#95d0fc') ;
	at: #red put: (Color fromString: '#e50000') ;
	at: #brown put: (Color fromString: '#653700') ;
	at: #pink put: (Color fromString: '#ff81c0') ;
	at: #blue put: (Color fromString: '#0343df') ;
	at: #green put: (Color fromString: '#15b01a') ;
	at: #purple put: (Color fromString: '#7e1e9c') ;
  	yourself.

	^xkcdDict


]

{ #category : '*color-extras-selection' }
Color class >> yellowColorDict [
	"Answer a dictionary of named colors considered Yellow"
"
	Color yellowColorDict explore.
"
	^self yellowColorDict: ColorNamesDict
]

{ #category : '*color-extras-selection' }
Color class >> yellowColorDict: aColorDict [
	"Answer a dictionary of named colors considered Yellow"

	| dict |
	dict := Dictionary new.
	aColorDict associationsDo: 
		 [ :assoc |
			((assoc value isYellow)
				or: [assoc key asString asLowercase includesSubString: 'yellow'])
			ifTrue: [dict add: assoc]
		].
	^dict
]
