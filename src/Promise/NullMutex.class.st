"
A Mutex is a light-weight MUTual EXclusion object being used when two or more processes need to access a shared resource concurrently. A Mutex grants ownership to a single process and will suspend any other process trying to aquire the mutex while in use. Waiting processes are granted access to the mutex in the order the access was requested.This Mutex DOES NOT mutually exclude anything. It just implements the same protocol.
"
Class {
	#name : 'NullMutex',
	#superclass : 'Object',
	#instVars : [
		'semaphore',
		'owner'
	],
	#category : 'Promise',
	#package : 'Promise'
}

{ #category : 'mutual exclusion' }
NullMutex >> critical: aBlock [
	^ aBlock value.
]
