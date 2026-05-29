"
Show a terse guide to Cuis in a system window. The window has a text pane with a list pane beside it. The text pane is a kind of Workspace which has the behavior that statements in it can be Done (Cmd-d) or Printed (Cmd-p) in order to observe their effect.

TerseGuideWindow openTerseGuide

"
Class {
	#name : 'TerseGuideWindow',
	#superclass : 'WorkspaceWindow',
	#instVars : [
		'textModelM',
		'list1'
	],
	#category : 'TerseGuide',
	#package : 'TerseGuide'
}

{ #category : 'instance creation' }
TerseGuideWindow class >> openTerseGuide [
"
	TerseGuideWindow openTerseGuide.
"
	| window help |

	(window _ TerseGuideWindow open: (help _ TerseGuideHelp new) label: 'Terse Guide')
		setWindowColor:  Theme current workspace.
	help textPane: window textModelM.
	help 
		contents: '';
		window: window
]

{ #category : 'initialization' }
TerseGuideWindow >> buildMorphicWindow [
	"Define the window layout for Terse Guide"
	| row |
	
	list1 := (PluggableListMorph
			withModel: model
			listGetter: #topicList
			indexGetter: #topicListIndex
			indexSetter: #topicListIndex:)
				name: 'Topic List'.
	textModelM := TextModelMorph withModel: model.
	textModelM
		askBeforeDiscardingEdits: false;
		name: 'Work Space'.
	model when: #topicListIndex send: #update: to: list1 withArguments: #(#topicListIndex).
	row := LayoutMorph newRow.
	row
		name: #Row;
		addMorph: list1 proportionalWidth: 0.2;
		addAdjusterAndMorph: textModelM proportionalWidth: 0.8.
	self layoutMorph
		addMorph: row.
	self setLabel: 'Terse Guide'
]

{ #category : 'accessing' }
TerseGuideWindow >> textModelM [
	"Answer the value of textModelM"

	^ textModelM
]
