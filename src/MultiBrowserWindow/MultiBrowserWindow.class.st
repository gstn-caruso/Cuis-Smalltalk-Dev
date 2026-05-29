"
BrowserWindow new openInWorld
MultiBrowserWindow new openInWorld

BrowserWindow findAndBrowseClass
BrowserWindow fullOnClass: Float selector: #abs
BrowserWindow hierarchyOnClass: Float selector: #abs

MultiBrowserWindow findAndBrowseClass
MultiBrowserWindow fullOnClass: Float selector: #abs
MultiBrowserWindow openOnClasses: (Magnitude withAllSubclasses select: [ :c | c hasSubclasses ])
MultiBrowserWindow openOnClasses: {Number. Float. Point} selectors: { #abs. #abs. #x}
"
Class {
	#name : 'MultiBrowserWindow',
	#superclass : 'BrowserWindow',
	#instVars : [
		'browserWindowsState'
	],
	#category : 'MultiBrowserWindow',
	#package : 'MultiBrowserWindow'
}

{ #category : 'utilities' }
MultiBrowserWindow class >> beDefaultBrowserWindowClass [
	PreferenceSet sysPreferences
		name: #browserWindowClass
		category: #programming
		value: self
]

{ #category : 'class initialization' }
MultiBrowserWindow class >> initialize [
	self beDefaultBrowserWindowClass
]

{ #category : 'class initialization' }
MultiBrowserWindow class >> install [
	self beDefaultBrowserWindowClass
]

{ #category : 'instance creation' }
MultiBrowserWindow class >> openOnClasses: aCollection [
	"
	MultiBrowserWindow openOnClasses: (Magnitude withAllSubclasses select: [ :c | c hasSubclasses ])
	"
	| w |
	w := self fullOnClass: nil selector: nil.
	aCollection
		do: 	[ :c |
			w model 
				setSelectedSystemCategory: c category;
				selectClass: c ]
		separatedBy:
			[ w addNew ].
	w showTab: 1.

]

{ #category : 'instance creation' }
MultiBrowserWindow class >> openOnClasses: aCollection selectors: another [
	"
	MultiBrowserWindow openOnClasses: {Number. Float. Point} selectors: { #abs. #abs. #x}
	"
	| w |
	w := self fullOnClass: nil selector: nil.
	aCollection with: another
		do: 	[ :c :s |
			w model 
				setSelectedSystemCategory: c category;
				selectClass: c;
				selectedMessageName: s;
				showHomeCategory ]
		separatedBy:
			[ w addNew ].
	w showTab: 1.

]

{ #category : 'menu commands' }
MultiBrowserWindow >> addNew [
	| browser |
	browser := Browser new.
	self model: browser.
	layoutMorph := nil.
	self beColumn.
	self buildMorphicWindow.
	self adoptWidgetsColor: borderColor.
	self extentChanged: extent.
	self update: #relabel.
]

{ #category : 'private' }
MultiBrowserWindow >> browserModelAt: i [
	^(browserWindowsState at: i) browserModel
]

{ #category : 'private' }
MultiBrowserWindow >> browserModelsDo: aBlock [
	browserWindowsState do: [ :m | aBlock value: m browserModel ].
]

{ #category : 'GUI building' }
MultiBrowserWindow >> buildMorphicWindow [

	super buildMorphicWindow.
	browserWindowsState add:
		(BrowserWindowState model: model mainLayout: layoutMorph codePane: codePane).
	self browserModelsDo: [ :m |
		m addDependent: self ].
]

{ #category : 'menu commands' }
MultiBrowserWindow >> closeTab [
	| i |
	browserWindowsState size > 1 ifTrue: [
		i := self indexOfModel.
		browserWindowsState removeAt: i.
		self showTab: 1 ].
]

{ #category : 'private' }
MultiBrowserWindow >> codePaneAt: i [
	^(browserWindowsState at: i) codePane
]

{ #category : 'initialization' }
MultiBrowserWindow >> createMultiBrowserCloseButton [
	^ (PluggableButtonMorph model: self action: #closeTab)
		iconDrawSelector: #drawSquareCloseIcon;
		setBalloonText: 'close this browser tab';
		morphExtent: Theme current titleBarButtonsExtent
]

{ #category : 'initialization' }
MultiBrowserWindow >> createMultiBrowserMenuButton [
	^ (PluggableButtonMorph model: self action: #offerMultiBrowserMenu)
		iconDrawSelector: #drawSquareMenuIcon;
		setBalloonText: 'multi browser menu';
		morphExtent: Theme current titleBarButtonsExtent
]

{ #category : 'initialization' }
MultiBrowserWindow >> createMultiBrowserNextButton [
	^ (PluggableButtonMorph model: self action: #nextTab)
		iconDrawSelector: #drawRightIcon;
		setBalloonText: 'next browser';
		morphExtent: Theme current titleBarButtonsExtent
]

{ #category : 'initialization' }
MultiBrowserWindow >> createMultiBrowserPrevButton [
	^ (PluggableButtonMorph model: self action: #prevTab)
		iconDrawSelector: #drawLeftIcon;
		setBalloonText: 'prev browser';
		morphExtent: Theme current titleBarButtonsExtent
]

{ #category : 'geometry' }
MultiBrowserWindow >> extentChanged: oldExtent [
	| pos e |
	super extentChanged: oldExtent.
	pos := self interiorOrigin.
	e := self interiorExtent.
	self mainLayoutsDo: [ :lm |
		lm position: pos extent: e ].
]

{ #category : 'menu commands' }
MultiBrowserWindow >> findClass [

	self addNew.
	super findClass
]

{ #category : 'private' }
MultiBrowserWindow >> indexOfModel [
	^browserWindowsState findFirst: [ :bws | bws browserModel = model ]
]

{ #category : 'initialization' }
MultiBrowserWindow >> initialize [
	browserWindowsState := OrderedCollection new.
	super initialize.

]

{ #category : 'initialization' }
MultiBrowserWindow >> initializeLabelArea [
	"Initialize the label area (titlebar) for the window."

	| topLeft spacing |
	super initializeLabelArea.
	topLeft := (self labelHeight + borderWidth - Theme current titleBarButtonsExtent / 2) ceiling asPoint.
	spacing := Theme current titleBarButtonsExtent x *13//10.
	self addMorph: self createMultiBrowserPrevButton position: spacing*4@0 + topLeft.
	self addMorph: self createMultiBrowserMenuButton position: spacing*5@0 + topLeft.
	self addMorph: self createMultiBrowserCloseButton position: spacing*6@0 + topLeft.
	self addMorph: self createMultiBrowserNextButton position: spacing*7@0 + topLeft.
]

{ #category : 'geometry' }
MultiBrowserWindow >> labelXPosition [
	| f |
	f := Preferences at: #windowTitleFont.
	^ f lineSpacing * 9 + borderWidth
]

{ #category : 'private' }
MultiBrowserWindow >> mainLayoutAt: i [
	^(browserWindowsState at: i) mainLayout
]

{ #category : 'private' }
MultiBrowserWindow >> mainLayoutsDo: aBlock [
	browserWindowsState do: [ :bws | aBlock value: bws mainLayout ].
]

{ #category : 'menu commands' }
MultiBrowserWindow >> nextTab [
	| i |
	i := self indexOfModel.
	i := i-1+1 \\ browserWindowsState size + 1.
	self showTab: i.
]

{ #category : 'menu' }
MultiBrowserWindow >> offerMultiBrowserMenu [
	"
	1. window title
	2. other window title
	new window
	copy this window
	remove this window
	"

	| aMenu |

	aMenu := MenuMorph new defaultTarget: self.
	browserWindowsState withIndexDo: [ :each :i | | menuItem |
		menuItem := aMenu add: i printString, '-', each browserModel labelString action: #showTab: argument: i.
		each mainLayout canDiscardEdits ifFalse: [
			menuItem color: Color red ]].
	aMenu add: 'Add new Browser' action: #addNew.
	browserWindowsState size > 1 ifTrue: [
		aMenu add: 'Close current' action: #closeTab ].

	aMenu popUpInWorld: self world
]

{ #category : 'menu commands' }
MultiBrowserWindow >> prevTab [
	| i |
	i := self indexOfModel.
	i := i-1-1 \\ browserWindowsState size + 1.
	self showTab: i.
]

{ #category : 'label' }
MultiBrowserWindow >> setLabel: aString [
	super setLabel: self indexOfModel printString, '. ', aString.
]

{ #category : 'menu commands' }
MultiBrowserWindow >> showTab: i [
	model := self browserModelAt: i.
	layoutMorph := self mainLayoutAt: i.
	codePane := self codePaneAt: i.
	self mainLayoutsDo: [ :each | each visible: each = layoutMorph ].
	self update: #relabel.
]
