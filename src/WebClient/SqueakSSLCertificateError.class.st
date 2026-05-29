Class {
	#name : 'SqueakSSLCertificateError',
	#superclass : 'Error',
	#category : 'WebClient-SqueakSSL-Core',
	#package : 'WebClient',
	#tag : 'SqueakSSL-Core'
}

{ #category : 'testing' }
SqueakSSLCertificateError >> isResumable [
	"Determine whether an exception is resumable."

	^true
]
