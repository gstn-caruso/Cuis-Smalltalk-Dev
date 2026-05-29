Class {
	#name : 'ColorExtrasPackage',
	#superclass : 'CodePackage',
	#category : 'Color-Extras',
	#package : 'Color',
	#tag : 'Extras'
}

{ #category : 'installing' }
ColorExtrasPackage class >> postPackageInstall [
	"This gets called after installing all the package code"

	Color initializeColorExtras
]

{ #category : 'installing' }
ColorExtrasPackage class >> prePackageInstall [
	"This gets called after creating the package class and installing its code, but before installing the rest of the package code"

	Color classPool declare: #ColorNamesDict from: Undeclared
]
