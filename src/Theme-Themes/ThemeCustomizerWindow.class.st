Class {
	#name : 'ThemeCustomizerWindow',
	#superclass : 'SystemWindow',
	#instVars : [
		'backgroundPalette',
		'primaryPalette',
		'labelsPalette',
		'textPalette',
		'secondaryPalette'
	],
	#category : 'Theme-Themes',
	#package : 'Theme',
	#tag : 'Themes'
}

{ #category : 'opening' }
ThemeCustomizerWindow class >> open [

	self new
		model: ThemeCustomizerModel new;
		buildMorphicWindow;
		openInWorld 
]

{ #category : 'menu-world' }
ThemeCustomizerWindow class >> worldMenuOptions [
	^ `{{
			#submenuOf -> TheWorldMenu preferencesLabel.
			#itemGroup 			->  10.
			#itemOrder 			-> 	85.	
			#label 			->	'Theme customizer...'.
			#object 			-> 	ThemeCustomizerWindow.
			#selector 		-> 		#open.
			#icon 			-> 	#appearanceIcon.
			#balloonText 	-> 		'Allows you to customize the personalized theme'.
		} asDictionary}`
]

{ #category : 'palettes' }
ThemeCustomizerWindow >> buildBackgroundPalette [
	
	| sunset ocean forest ash light |
	sunset := OrderedCollection with: (Color fromHexString: '#FE938C') with: 'Sunset'.
	ocean := OrderedCollection with: (Color fromHexString: '#124559') with: 'Ocean'.
	forest := OrderedCollection with: (Color fromHexString: '#788475') with: 'Forest'.
	ash := OrderedCollection with: (Color fromHexString: '#363946') with: 'Ash'.
	light := OrderedCollection with: (Color fromHexString: '#F2DFD7') with: 'Light'.
	
	backgroundPalette := OrderedCollection with: sunset with: ocean with: forest with: ash with: light.
]

{ #category : 'build rows' }
ThemeCustomizerWindow >> buildBackgroundRow [
	
	^self buildRow: 'Background' thatExecutesAction: #changeBackground: forPalette: backgroundPalette.
]

{ #category : 'build - private' }
ThemeCustomizerWindow >> buildButtonForCustomColorThatExecutes: action forRow: row [

	| column buttonMorph argument|
	argument := Array with: action with: row.
	buttonMorph := PluggableButtonMorph model: self stateGetter: nil stateArgument: nil action: #buildCustomColorInputAndDoRowAction: actionArgument: argument label: 'Custom'.
	
	buttonMorph mouseOverColor: Color white; 
	color: self buttonsColor.
	
	column := LayoutMorph newColumn.
	column separation: 5; axisEdgeWeight: 0.5; color: Color gray; borderWidth: 0; addMorph: buttonMorph.
		
	^ column.
]

{ #category : 'build - private' }
ThemeCustomizerWindow >> buildButtonThatExecutes: action hasLabel: label color: buttonColor forRow: row [

	| column buttonMorph argument|
	argument := Array with: buttonColor with: row.
	buttonMorph := PluggableButtonMorph model: self model stateGetter: nil stateArgument: nil action: action actionArgument: argument label: label.
	
	buttonMorph mouseOverColor: buttonColor muchLighter; 
	color: self buttonsColor.
	
	column := LayoutMorph newColumn.
	column separation: 5; axisEdgeWeight: 0.5; color: buttonColor; borderWidth: 0; addMorph: buttonMorph.
		
	^ column.
]

{ #category : 'build - private' }
ThemeCustomizerWindow >> buildButtonWithLabel: aLabelString action: actionSelector [

	| buttonMorph |
	
	buttonMorph := PluggableButtonMorph
		model: self
		stateGetter: nil
		stateArgument: nil
		action: actionSelector
		actionArgument: nil
		label: aLabelString.
	
	buttonMorph
		color: self buttonsColor;
		mouseOverColor: self buttonsColor muchLighter.
		
	^ buttonMorph
]

{ #category : 'build rows' }
ThemeCustomizerWindow >> buildControlButtonsRow [

	| buttonRow saveButton cancelButton manageThemesButton buttonsContainer |
		
	saveButton := self 
		buildButtonWithLabel: 'Save Theme'
		action: #saveThemeAction.

	cancelButton := self 
		buildButtonWithLabel: 'Cancel'
		action: #delete.

	manageThemesButton := self
		buildButtonWithLabel: 'Manage Themes'
		action: #savedThemesMenu.
	
	buttonsContainer := LayoutMorph newRow.
	buttonsContainer
		color: self windowBackColor;
		addMorph: saveButton;
		addMorph: cancelButton;
		addMorph: manageThemesButton.
	
	buttonRow := self buildRow.
	
	buttonRow
		addMorph: buttonsContainer.
		
	^ buttonRow
]

{ #category : 'build - private' }
ThemeCustomizerWindow >> buildCustomColorInputAndDoRowAction: arguments [

	| customColorString action row initialText |
	
	action := arguments first.
	row := arguments second.
	initialText := 'hex code (example: #FFAABB)'.
	customColorString := StringRequestMorph request: 'Enter custom color:' initialAnswer: initialText orCancel: [^''].
	customColorString = initialText ifFalse: [self ensureColorIsHexCode: customColorString andDo: action for: row].
	^customColorString.
]

{ #category : 'build - private' }
ThemeCustomizerWindow >> buildLabelForRowWithText: label [

	| column |
	column := LayoutMorph newColumn.
	column
		separation: 5;
		axisEdgeWeight: 0.5;
		color: self windowBackColor;
		addMorph: (self buildLabelWithNoBordersBold: label
				withColor: self labelsColor).
	^ column.
]

{ #category : 'build - private' }
ThemeCustomizerWindow >> buildLabelWithNoBordersBold: label withColor: labelColor [

	| labelMorph |
	labelMorph := LabelMorph contents: label.
	labelMorph
		emphasis: 1;
		color: labelColor;
		borderWidth: 0.
		
	^ labelMorph.
]

{ #category : 'palettes' }
ThemeCustomizerWindow >> buildLabelsPalette [
	
	| sunset ocean forest ash light |
	sunset := OrderedCollection with: (Color fromHexString: '#fCD89A') with: 'Sunset'.
	ocean := OrderedCollection with: (Color fromHexString: '#EFF6E0') with: 'Ocean'.
	forest := OrderedCollection with: (Color fromHexString: '#8DAA91') with: 'Forest'.
	ash := OrderedCollection with: (Color fromHexString: '#000000') with: 'Ash'.
	light := OrderedCollection with: (Color fromHexString: '#946846') with: 'Light'.
	
	labelsPalette := OrderedCollection with: sunset with: ocean with: forest with: ash with: light.
]

{ #category : 'build rows' }
ThemeCustomizerWindow >> buildLabelsRow [

	^self buildRow: 'Labels' thatExecutesAction: #changeLabels: forPalette: labelsPalette.
]

{ #category : 'initialization' }
ThemeCustomizerWindow >> buildMorphicWindow [

	| themesMorph mainWindowMorph scrollMorph |
	
	themesMorph := self buildThemesMorph.
	scrollMorph := self buildScrollMorphFor: themesMorph.
	mainWindowMorph := LayoutMorph newRow addMorph: scrollMorph proportionalHeight: 1.
	
	self layoutMorph addMorph: mainWindowMorph.
	self setLabel: 'Theme Customizer'
	
	
]

{ #category : 'initialization' }
ThemeCustomizerWindow >> buildPalettes [

	self buildBackgroundPalette.
	self buildPrimaryPalette.
	self buildSecondaryPalette.
	self buildTextPalette.
	self buildLabelsPalette
]

{ #category : 'palettes' }
ThemeCustomizerWindow >> buildPrimaryPalette [
	
	| sunset ocean forest ash light |
	sunset := OrderedCollection with: (Color fromHexString: '#DA627D') with: 'Sunset'.
	ocean := OrderedCollection with: (Color fromHexString: '#598392') with: 'Ocean'.
	forest := OrderedCollection with: (Color fromHexString: '#5E5D5C') with: 'Forest'.
	ash := OrderedCollection with: (Color fromHexString: '#696773') with: 'Ash'.
	light := OrderedCollection with: (Color fromHexString: '#CEB5A7') with: 'Light'.
	
	primaryPalette := OrderedCollection with: sunset with: ocean with: forest with: ash with: light.
]

{ #category : 'build rows' }
ThemeCustomizerWindow >> buildPrimaryRow [

	^self buildRow: 'Primary' thatExecutesAction: #changePrimary: forPalette: primaryPalette.
]

{ #category : 'build - private' }
ThemeCustomizerWindow >> buildRow [

	| row |

	row := LayoutMorph newRow.
	row color: self windowBackColor;
	borderWidth: 5;
	borderColor: self windowBackColor.
	
	
	row separation: 10;
	axisEdgeWeight: 1.
	
	^row.
]

{ #category : 'build - private' }
ThemeCustomizerWindow >> buildRow: rowLabel thatExecutesAction: action forPalette: palette [

	| buttonColor buttonLabel rowName row | 
	
	row := self buildRow.
	
	rowName := self buildLabelForRowWithText: rowLabel.
	row addMorph: rowName.
	
	palette do: [:colorDuo | buttonColor := colorDuo first.
					      buttonLabel := colorDuo second.
					      row addMorph: (self buildButtonThatExecutes: action
									       hasLabel: buttonLabel color: buttonColor forRow: rowName).
					
		].
	
	row addMorph: (self buildButtonForCustomColorThatExecutes: action forRow: rowName).
	
	^row.
]

{ #category : 'initialization' }
ThemeCustomizerWindow >> buildScrollMorphFor: themesMorph [

	| scrollMorph |
	
	scrollMorph := PluggableScrollPane initializedInstance.
	scrollMorph scroller: themesMorph;
	color: self windowBackColor.
	
	^scrollMorph
]

{ #category : 'palettes' }
ThemeCustomizerWindow >> buildSecondaryPalette [
	
	| sunset ocean forest ash light |
	sunset := OrderedCollection with: (Color fromHexString: '#FCA17D') with: 'Sunset'.
	ocean := OrderedCollection with: (Color fromHexString: '#AEC3B0') with: 'Ocean'.
	forest := OrderedCollection with: (Color fromHexString: '#453643') with: 'Forest'.
	ash := OrderedCollection with: (Color fromHexString: '#8D99AE') with: 'Ash '.
	light := OrderedCollection with: (Color fromHexString: '#BCAA99') with: 'Light'.
	
	secondaryPalette := OrderedCollection with: sunset with: ocean with: forest with: ash with: light.
]

{ #category : 'build rows' }
ThemeCustomizerWindow >> buildSecondaryRow [

	^self buildRow: 'Secondary' thatExecutesAction: #changeSecondary: forPalette: secondaryPalette.
]

{ #category : 'palettes' }
ThemeCustomizerWindow >> buildTextPalette [
	
	| sunset ocean forest ash light |
	sunset := OrderedCollection with: (Color fromHexString: '#9E3F3F') with: 'Sunset'.
	ocean := OrderedCollection with: (Color fromHexString: '#01161E') with: 'Ocean'.
	forest := OrderedCollection with: (Color fromHexString: '#28112B') with: 'Forest'.
	ash := OrderedCollection with: (Color fromHexString: '#2B2D42') with: 'Ash'.
	light := OrderedCollection with: (Color fromHexString: '#3C3C3B') with: 'Light'.
	
	textPalette := OrderedCollection with: sunset with: ocean with: forest with: ash with: light.
]

{ #category : 'build rows' }
ThemeCustomizerWindow >> buildTextRow [
	
	^self buildRow: 'Text' thatExecutesAction: #changeText: forPalette: textPalette.
]

{ #category : 'initialization' }
ThemeCustomizerWindow >> buildThemesMorph [

	^ LayoutMorph newColumn ::
		morphExtent: self defaultExtent;
		addMorph: self buildTitleRow;
		addMorph: self buildBackgroundRow;
		addMorph: self buildPrimaryRow;
		addMorph: self buildSecondaryRow;
		addMorph: self buildTextRow;
		addMorph: self buildLabelsRow;
		addMorph: self buildControlButtonsRow.
]

{ #category : 'build rows' }
ThemeCustomizerWindow >> buildTitleRow [

	| titleRow titleLabel |
	
	titleLabel := self buildLabelWithNoBordersBold: 'Make your own theme!' withColor: self initMessageTextColor.
	titleRow := LayoutMorph newRow.
	titleRow
		separation: 10;
		axisEdgeWeight: 1;
		color: self initMessageBackgroundColor;
		addMorph: titleLabel;
		layoutSpec: (LayoutSpec proportionalHeight: 0).

	^ titleRow.
]

{ #category : 'colors' }
ThemeCustomizerWindow >> buttonsColor [

	^ Color white twiceDarker darker darker. 
]

{ #category : 'colors' }
ThemeCustomizerWindow >> colorFromHexString: aHexString [

	^Color fromHexString: aHexString.
]

{ #category : 'initialization' }
ThemeCustomizerWindow >> defaultExtent [
	^ 1400 @ 720.
]

{ #category : 'build - private' }
ThemeCustomizerWindow >> ensureColorIsHexCode: customColorHex andDo: action for: row [
	
	| customColor |
	
	customColor := Color fromHexString: customColorHex.
	customColor isNil 
		ifTrue: [self inform: self errorNotAHexCode]
		ifFalse: [ self model perform: action with: (Array with: customColor with: row) ]


	
]

{ #category : 'error' }
ThemeCustomizerWindow >> errorNotAHexCode [

	^'The entered string is not a valid hex code'.
]

{ #category : 'colors' }
ThemeCustomizerWindow >> initMessageBackgroundColor [

	^self colorFromHexString: '#0d285f'.
]

{ #category : 'colors' }
ThemeCustomizerWindow >> initMessageTextColor [

	^self colorFromHexString: '#e069e0'.
]

{ #category : 'initialization' }
ThemeCustomizerWindow >> initialize [

	super initialize.
	PersonalizedTheme initializeThemeWithDefaultColors.
	self buildPalettes.
	
]

{ #category : 'colors' }
ThemeCustomizerWindow >> labelsColor [
	
	^self colorFromHexString: '#FAF3DD'
]

{ #category : 'manage themes' }
ThemeCustomizerWindow >> saveThemeAction [

	| themeName |
	
	themeName := StringRequestMorph request: 'Name your theme:' initialAnswer: 'My Theme'.
	
	(themeName isNil or: [ themeName isEmpty ]) ifTrue: [ ^self ].
	
	PersonalizedTheme saveCurrentAs: themeName.
	
	self inform: 'Theme saved successfully!'.
]

{ #category : 'manage themes' }
ThemeCustomizerWindow >> savedThemesMenu [
		
	| menu |
	
	menu := MenuMorph new.
	menu 
		addTitle: 'Saved themes'.
		
	PersonalizedTheme savedThemes isEmpty ifTrue: [
		menu add: 'There are no themes saved yet' target: self action: #yourself.
		^ menu popUpInWorld: self runningWorld.
	].
	
	PersonalizedTheme savedThemes keysAndValuesDo: [ :themeName :themeData |
		| subMenu |
		subMenu := MenuMorph new.
		
		subMenu add: 'Apply'
			target: PersonalizedTheme 
			action: #loadThemeNamed: 
			argument: themeName.
			
		subMenu add: 'Delete theme'
			target: PersonalizedTheme
			action: #deleteThemeNamed:
			argument: themeName.
			
		menu add: themeName subMenu: subMenu.
	].
	
	menu popUpInWorld: self runningWorld.



]

{ #category : 'colors' }
ThemeCustomizerWindow >> windowBackColor [

	^(self colorFromHexString: '#9ec7e8') muchDarker.
]
