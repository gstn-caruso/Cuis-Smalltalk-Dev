"
Changes the wallpaper of a given WorldMorph.

Example usage:

WallpaperChanger forRunningWorld changeTo: 'pattern-malachite-green-wallpaper.jpeg' asFileEntry

"
Class {
	#name : 'WallpaperChanger',
	#superclass : 'Object',
	#instVars : [
		'world'
	],
	#category : 'Wallpaper',
	#package : 'Wallpaper'
}

{ #category : 'file list services' }
WallpaperChanger class >> fileReaderServicesForFileEntry: aFileEntry suffix: suffix [
	(#('jpg' 'jpeg' 'png') includes: suffix)
		ifTrue: [ ^ {self serviceToChangeWallpaper}  ]
		ifFalse: [ ^#() ]
]

{ #category : 'instance creation' }
WallpaperChanger class >> forRunningWorld [
	^self new initializeWithWorld: self runningWorld.
]

{ #category : 'instance creation' }
WallpaperChanger class >> forWorld: aWorld [
	^self new initializeWithWorld: aWorld.
]

{ #category : 'file list services' }
WallpaperChanger class >> serviceToChangeWallpaper [
	^ (SimpleServiceEntry 
		provider: self forRunningWorld
		label: 'use as wallpaper'
		selector: #changeTo:
		description: 'uses this file as the new world wallpaper'
		buttonLabel: 'content'
		icon: #wallpaperIcon)
			sortOrder: 25;
			argumentGetter: [ :fileList | fileList selectedFileEntry ]
]

{ #category : 'changing' }
WallpaperChanger >> changeTo: anImageFileEntry [
	world backgroundImageData: anImageFileEntry binaryContents.
]

{ #category : 'initialization' }
WallpaperChanger >> initializeWithWorld: aWorld  [
	world _ aWorld.
]
