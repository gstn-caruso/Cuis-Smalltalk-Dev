"
Sonograms are imageMorphs that will repeatedly plot arrays of values as black on white columns moving to the right in time and scrolling left as necessary.
"
Class {
	#name : 'Sonogram',
	#superclass : 'ImageMorph',
	#instVars : [
		'lastX',
		'scrollDelta',
		'columnForm',
		'minVal',
		'maxVal',
		'pixValMap'
	],
	#category : 'Sound-Synthesis',
	#package : 'Sound',
	#tag : 'Synthesis'
}

{ #category : 'all' }
Sonogram >> extent: aPoint minVal: min maxVal: max scrollDelta: d [
	minVal _ min.
	maxVal _ max.
	scrollDelta _ d.
	self morphExtent: aPoint.

" try following with scrolldelta = 1, 20, 200
	| s data |
	s _ Sonogram new extent: 200@50
				minVal: 0.0 maxVal: 1.0 scrollDelta: 20.
	World addMorph: s.
	data _ (1 to: 133) collect: [:i | 0.0].
	1 to: 300 do:
		[:i | data at: (i\\133)+1 put: 1.0.
		s plotColumn: data.
		data at: (i\\133)+1 put: 0.0.
		World doOneCycleNow].
	s delete	
"
]

{ #category : 'geometry' }
Sonogram >> morphExtent: newExtent [
	super image: (Form extent: newExtent depth: Display depth).
	lastX _ -1.
	columnForm _ Form extent: (32//image depth)@(image height) depth: image depth.
	pixValMap _ ((1 to: 256) collect:
			[:i | columnForm pixelValueFor: (Color gray: (256-i)/255.0)])
		as: Bitmap.

]

{ #category : 'all' }
Sonogram >> plotColumn: dataArray [

	| chm1 i normVal r |
	chm1 _ columnForm height - 1.
	0 to: chm1 do: [ :y | 
		i _ y*(dataArray size-1)//chm1 + 1.
		normVal _ ((dataArray at: i) - minVal) / (maxVal - minVal).
		normVal < 0.0 ifTrue: [normVal _ 0.0].
		normVal > 1.0 ifTrue: [normVal _ 1.0].
		columnForm bits at: chm1-y+1 put: (pixValMap at: (normVal * 255.0) truncated + 1)].
	(lastX _ lastX + 1) > (image width - 1) ifTrue:
		[self scroll].
	image copy: (r _ (lastX@0 extent: 1@image height))
			from: (32//image depth-1)@0
			in: columnForm rule: Form over.
	"self changed."
	self invalidateLocalRect: r
]

{ #category : 'all' }
Sonogram >> scroll [
	image copy: (scrollDelta@0 extent: (image width-scrollDelta)@image height)
			from: image to: 0@0 rule: Form over.
	lastX _ lastX - scrollDelta.
	self redrawNeeded
]
