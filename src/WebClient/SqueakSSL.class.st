"
SqueakSSL provides an interface to the platforms SSL/TLS facilities.

"
Class {
	#name : 'SqueakSSL',
	#superclass : 'Object',
	#instVars : [
		'handle',
		'readBlock',
		'writeBlock'
	],
	#category : 'WebClient-SqueakSSL-Core',
	#package : 'WebClient',
	#tag : 'SqueakSSL-Core'
}

{ #category : 'utilities' }
SqueakSSL class >> checkCert: certName [
	"Attempt to verify the cert with the given name by performing 
	an SSL handshake. Raises an error if there is an issue with the cert,
	returns the peer name from the cert if successful."

	| sslClient sslServer inbuf outbuf result |
	inbuf := ByteArray new: 4096.
	outbuf := ByteArray new: 4096.

	["Perform the SSL handshake"
	sslClient := SqueakSSL new.
	sslServer := SqueakSSL new.
	sslServer certName: certName.

	result := 0.
	[result := sslClient connect: inbuf from: 1 to: result into: outbuf.
	result = 0] whileFalse:[
		result < -1 ifTrue:[^self error: 'SSL handshake failed (client code: ', result printString, ')'].
		result := sslServer accept: outbuf from: 1 to: result into: inbuf.
		result < -1 ifTrue:[^self error: 'SSL handshake failed (server code: ', result printString, ')'].
	].

	"Handshake complete. Check the cert status"
	sslClient certState = 0 ifFalse:[
		^self error: 'Certificate validation failed (code: ', sslClient certState, ')'.
	].

	"When successful, just return the peer name to the caller"
	^sslClient peerName
	
	] ensure:[
		sslClient ifNotNil:[sslClient destroy].
		sslServer ifNotNil:[sslServer destroy].
	].
]

{ #category : 'examples' }
SqueakSSL class >> ensureSampleCert [
	"Ensure that we have a sample certificate for the tests"

	SqueakSSL platformName caseOf: {
		['unix'] -> [^self ensureSampleCertFile].
		['Win32'] -> [^self ensureSampleCertInStore].
	} otherwise: [^nil].

]

{ #category : 'examples' }
SqueakSSL class >> ensureSampleCertFile [
	"On Unix, we can simply create a valid cert file"

	| certName file |
	SqueakSSL platformName = 'unix' ifFalse:[^self].
	certName := self name, 'Cert.pem'.
	file _ DirectoryEntry currentDirectory // certName.
	file exists ifFalse: [
		 file writeStreamDo: [ :stream |
			stream nextPutAll: self exampleCertFile ]].
	^file pathName
]

{ #category : 'examples' }
SqueakSSL class >> ensureSampleCertInStore [
	"Ensure that we have a valid certificate in the Windows certificate store"

	SqueakSSL platformName = 'Win32' ifFalse:[^self].
	"Undocumented. Allows importing a pfx w/o password.
	For the sole purpose of being able to run tests reliably"
	SqueakSSL new setStringProperty: 10001 to: self exampleCertPFX.
	^'testcert'. "Friendly name of test cert"

]

{ #category : 'examples' }
SqueakSSL class >> exampleCertFile [
^'-----BEGIN RSA PRIVATE KEY-----
MIICXQIBAAKBgQDnCv/gxDCb2yq15qkNwYtdMOHfW609Ck7wfwjVgzSNg+Hw+1R4
+krWhYRsWoXZUcy9xPC9WhnFCFijcnROcWp7vByVukFkVPYgzk1OBFT484ZCLBme
08GqLSzZrjgu7c1Yu5M9MZQdZKObBvZzDFsnvFccfM7G5mX/FgATasYaLQIDAQAB
AoGBAMpUJ6B+LtNOKykAxir1w0Xo+OTRM/SwglC57tKMBAmp5MNUVbVb+w3B/yWk
YHLf35yQSwKHVOnnVThNkuzfBY+MBxnaZwCByKknB4viP1ihPmfwdtqW4QXt1CTH
53sc9BVPjs3Nn1eEVrc582RK0MhORmjvlz+GkTswXCiKD3tBAkEA+6/au8T8XUeM
y/KrtJ+U84seviw5nY93Yg7495n4ir1fojp4wFbWq1JTeM22zspZQOKzEsjxfHUi
UH3buH//OwJBAOsAlJdIZqTIJponBXho+jqLHqcZYXBz3znDzHZU1PLfyfq2DuVe
gt8UWa4VwlCZNtPi7g/iFPEcLOlf2XY3hbcCQFU7voVsNlKYknPW4JMwn87CREz+
yRw0o6dPjry7JdJGQ4a66n2oatZl8OKuN8Rb/lHc8+vepPkS6eX8WVZn8lUCQE2r
F3EYgLQdYoS4ONqe93S53hukC8w6v6A70iuZxfevdvXhjfLI1cAc3bbngh1ZRgGp
kry1H+7APSe0gg7MMukCQQD3jdsVoc4yhziMdpUMyw6R6vYCMJbMEr/tI6CJYBG4
lW+zdcLK2d6GNpZU80F49HOvxH4HMg1Qv+UUiuxT7jpG
-----END RSA PRIVATE KEY-----
-----BEGIN CERTIFICATE-----
MIICxTCCAi6gAwIBAgIJAN/0HUpkM5dvMA0GCSqGSIb3DQEBBQUAMEwxCzAJBgNV
BAYTAkdCMRIwEAYDVQQIEwlCZXJrc2hpcmUxEDAOBgNVBAcTB05ld2J1cnkxFzAV
BgNVBAoTDk15IENvbXBhbnkgTHRkMB4XDTExMDYwNjE0MzcyMFoXDTEyMDYwNTE0
MzcyMFowTDELMAkGA1UEBhMCR0IxEjAQBgNVBAgTCUJlcmtzaGlyZTEQMA4GA1UE
BxMHTmV3YnVyeTEXMBUGA1UEChMOTXkgQ29tcGFueSBMdGQwgZ8wDQYJKoZIhvcN
AQEBBQADgY0AMIGJAoGBAOcK/+DEMJvbKrXmqQ3Bi10w4d9brT0KTvB/CNWDNI2D
4fD7VHj6StaFhGxahdlRzL3E8L1aGcUIWKNydE5xanu8HJW6QWRU9iDOTU4EVPjz
hkIsGZ7TwaotLNmuOC7tzVi7kz0xlB1ko5sG9nMMWye8Vxx8zsbmZf8WABNqxhot
AgMBAAGjga4wgaswHQYDVR0OBBYEFGFwXmx2B6FB25yKMBm6g884lB2xMHwGA1Ud
IwR1MHOAFGFwXmx2B6FB25yKMBm6g884lB2xoVCkTjBMMQswCQYDVQQGEwJHQjES
MBAGA1UECBMJQmVya3NoaXJlMRAwDgYDVQQHEwdOZXdidXJ5MRcwFQYDVQQKEw5N
eSBDb21wYW55IEx0ZIIJAN/0HUpkM5dvMAwGA1UdEwQFMAMBAf8wDQYJKoZIhvcN
AQEFBQADgYEAbjMF7YzNQGovKD4NRjsnnKzQnUCTw6UquY2Oz/5SeLcPfLm8DudF
qppAjJjNpAgYC0yWoWcIxatYF/AsgGc2WL3hzI8oK7by6STfVi5RfLA6jS7lIDOv
4BUVsWZKADbEPsfiwed9b9MLLx8gpLLBrrr2rZpSyeDu4v16haV6wg8=
-----END CERTIFICATE-----
'
]

{ #category : 'examples' }
SqueakSSL class >> exampleCertPFX [
	^ #[48 130 7 50 2 1 3 48 130 6 248 6 9 42 134 72 134 247 13 1 7 1 160 130 6 233 4 130 6 229 48 130 6 225 48 130 3 191 6 9 42 134 72 134 247 13 1 7 6 160 130 3 176 48 130 3 172 2 1 0 48 130 3 165 6 9 42 134 72 134 247 13 1 7 1 48 28 6 10 42 134 72 134 247 13 1 12 1 6 48 14 4 8 88 63 142 234 51 170 181 1 2 2 8 0 128 130 3 120 247 113 35 203 188 93 48 77 162 13 174 138 246 211 61 198 135 133 35 173 48 145 17 17 215 165 194 254 211 158 248 98 76 208 35 117 179 66 160 245 118 213 71 174 220 87 29 165 94 87 52 172 173 229 251 165 205 43 242 114 250 65 123 9 113 132 130 241 182 211 44 155 163 177 90 52 4 72 47 37 0 101 149 229 33 113 144 29 160 38 44 28 178 1 193 134 122 194 233 165 233 236 242 121 119 47 72 143 91 146 148 29 155 94 202 17 124 77 21 110 194 197 228 149 28 9 129 74 139 76 1 180 245 235 1 191 177 175 158 159 16 12 52 96 80 243 34 26 155 45 210 192 183 217 230 122 13 19 197 214 172 29 151 24 153 136 8 203 72 220 199 79 22 79 251 248 83 204 246 117 242 216 219 53 20 182 121 148 173 221 177 210 171 107 56 101 159 63 110 23 37 168 47 25 252 163 244 206 125 220 122 108 251 223 93 219 129 242 137 229 199 216 254 230 235 62 33 236 39 211 255 184 37 134 152 51 188 182 195 242 18 43 29 134 16 183 48 35 0 100 231 121 145 91 99 171 183 225 246 126 56 190 198 188 79 227 107 211 1 65 113 64 71 9 120 185 75 138 171 220 155 182 35 226 180 121 108 83 253 1 232 183 151 97 160 73 117 218 140 182 224 58 227 40 171 59 143 213 187 41 57 174 185 115 190 81 111 110 81 149 122 114 170 14 10 168 113 248 120 13 247 231 160 162 14 4 227 41 48 249 153 2 107 130 176 16 144 160 116 41 25 241 225 126 110 24 7 69 221 205 108 141 73 164 61 76 219 248 94 142 69 171 109 44 45 75 34 179 205 40 62 161 191 222 79 131 239 230 86 201 124 48 226 212 13 178 187 248 29 191 81 98 229 199 91 204 153 220 112 227 71 116 233 131 134 160 244 78 77 84 128 144 63 123 210 148 221 133 201 44 41 218 89 64 253 172 106 220 127 130 151 11 88 155 57 172 192 196 165 93 177 197 139 128 45 223 88 64 196 6 15 153 160 156 168 3 202 102 129 134 25 75 61 51 190 216 218 178 101 250 91 255 169 245 170 55 228 47 111 197 10 145 196 180 96 217 97 49 104 134 62 228 86 203 242 207 75 246 77 115 20 81 40 173 107 113 251 9 172 18 21 10 102 117 86 63 252 91 190 64 190 140 1 146 70 75 130 110 94 129 107 155 24 253 117 204 162 32 30 102 75 62 42 204 19 159 205 62 23 26 192 23 79 128 205 18 72 198 84 83 107 16 234 121 61 33 101 48 72 32 197 119 216 2 24 213 8 133 63 181 65 15 192 138 240 203 219 69 207 68 66 233 168 195 13 212 235 34 22 142 226 141 25 131 250 123 202 13 163 142 214 170 179 240 5 21 201 143 103 4 70 139 84 104 115 140 248 163 15 71 220 197 222 251 170 15 158 82 26 214 186 154 139 37 245 77 174 37 29 218 103 99 14 230 36 75 72 140 186 89 146 99 10 10 94 68 150 159 234 64 234 32 254 117 187 160 102 46 25 25 77 184 134 151 2 236 109 63 58 186 148 239 251 122 59 123 200 29 42 70 51 118 54 71 184 71 0 111 178 10 81 141 247 59 254 67 191 214 239 78 238 217 142 184 87 107 111 14 102 97 61 229 94 118 187 52 204 25 52 233 177 250 17 62 113 22 163 2 250 13 5 238 103 80 143 201 25 73 33 93 212 81 126 207 29 138 72 191 60 182 132 255 76 97 254 188 96 81 72 73 43 118 191 106 118 41 112 45 96 255 148 59 79 111 89 61 199 106 75 199 154 21 60 25 124 156 168 42 233 7 102 203 120 161 126 125 118 110 114 229 174 26 31 215 140 120 85 171 146 207 176 159 100 102 215 83 142 39 61 255 84 12 19 235 207 44 199 229 220 98 38 167 113 24 88 66 31 115 135 184 70 133 129 3 57 44 202 230 225 37 70 222 228 126 130 216 185 247 48 130 3 26 6 9 42 134 72 134 247 13 1 7 1 160 130 3 11 4 130 3 7 48 130 3 3 48 130 2 255 6 11 42 134 72 134 247 13 1 12 10 1 2 160 130 2 166 48 130 2 162 48 28 6 10 42 134 72 134 247 13 1 12 1 3 48 14 4 8 157 82 4 247 110 231 147 241 2 2 8 0 4 130 2 128 81 141 63 61 170 27 13 87 195 101 166 17 185 109 40 123 79 40 85 18 112 106 87 142 32 19 113 12 131 155 36 149 204 92 237 1 142 195 36 34 134 117 241 52 38 4 223 121 9 207 149 114 168 232 16 31 38 128 191 205 129 96 20 210 13 246 170 175 72 206 132 163 135 42 227 200 61 4 223 65 246 136 48 139 206 95 243 12 78 111 152 17 172 160 235 19 185 107 248 215 171 69 17 108 110 12 143 48 163 35 112 60 104 210 180 61 97 35 132 190 185 52 214 94 137 51 90 103 115 176 108 81 179 254 43 128 230 0 178 229 102 142 136 122 52 213 218 150 93 29 251 227 151 124 220 211 152 14 214 57 253 134 5 216 20 70 142 9 67 253 187 20 45 239 144 60 149 38 118 94 5 240 92 240 11 163 131 39 237 219 228 68 198 176 184 23 155 181 19 149 188 2 73 215 118 95 52 169 186 179 142 106 201 222 98 38 7 72 12 167 242 23 217 58 8 48 98 75 203 68 202 230 50 109 112 231 34 77 8 212 132 34 53 120 195 211 170 209 138 45 25 22 249 200 39 170 102 104 35 23 165 199 0 180 149 231 66 55 227 101 212 227 111 140 202 218 21 211 142 227 95 228 34 59 29 23 212 43 142 132 36 100 19 58 38 124 136 77 192 186 174 111 82 162 61 13 207 31 123 138 16 236 169 94 182 156 137 71 11 3 223 81 146 185 230 164 108 87 82 126 167 121 216 202 201 21 197 50 204 62 46 30 80 245 60 157 124 81 50 79 225 144 130 55 141 182 176 61 62 128 88 105 3 206 168 97 81 180 145 20 211 135 252 195 71 185 42 209 139 98 27 47 3 181 252 89 41 67 246 238 34 71 224 211 65 165 130 115 138 102 130 153 126 248 225 200 42 33 247 34 83 47 161 223 179 49 244 240 108 184 244 229 129 42 34 208 77 62 142 125 57 121 39 2 223 123 75 83 35 184 136 71 228 58 15 61 16 21 111 21 72 84 107 99 66 51 251 47 132 92 62 85 53 197 90 170 118 254 28 232 170 69 119 55 25 30 210 189 113 231 121 214 151 141 218 11 54 90 17 40 94 143 41 72 221 16 204 7 126 200 220 28 157 75 159 142 181 56 44 244 2 206 93 230 121 110 124 181 108 157 161 2 131 121 119 22 99 4 194 228 137 124 193 89 196 239 216 79 206 88 233 84 70 205 120 107 79 1 95 117 198 73 112 207 18 52 174 188 81 59 75 238 227 184 57 166 66 12 188 200 97 251 40 146 239 27 44 6 104 216 90 153 8 161 189 194 32 200 124 180 43 124 169 200 80 238 28 234 114 46 216 243 192 75 180 149 181 215 39 214 64 69 183 205 159 252 238 50 141 132 214 2 245 5 251 219 32 217 37 146 78 226 201 81 209 79 74 174 108 65 49 70 48 31 6 9 42 134 72 134 247 13 1 9 20 49 18 30 16 0 116 0 101 0 115 0 116 0 99 0 101 0 114 0 116 48 35 6 9 42 134 72 134 247 13 1 9 21 49 22 4 20 161 19 18 59 76 168 198 72 97 179 205 74 244 65 111 116 223 140 145 154 48 49 48 33 48 9 6 5 43 14 3 2 26 5 0 4 20 182 216 177 70 221 73 183 142 238 169 97 22 175 148 97 145 207 223 75 54 4 8 178 120 42 60 194 226 96 245 2 2 8 0]
]

{ #category : 'examples' }
SqueakSSL class >> google: query [
	"An example HTTPS query to encrypted.google.com.
	Example:
		SqueakSSL google: 'squeak'.
		SqueakSSL google: 'SqueakSSL'.
	"

	| hostName address socket ssl |

	"Change the host name to try an https request to some other host"
	hostName := 'encrypted.google.com'.

	address := NetNameResolver addressForName: hostName.
	socket := Socket newTCP.

	"Connect the TCP socket"
	socket connectTo: address port: 443.
	socket waitForConnectionFor: 10.

	"Set up SqueakSSL using the convenience APIs"
	ssl := SqueakSSL on: socket.

	["Let SqueakSSL handle the client handshake"
	ssl connect.

	"Verify that the cert is valid"
	ssl certState = 0 ifFalse:[
		self error: 'The certificate is invalid (code: ', ssl certState,')'.
	].

	"If the certificate is valid, make sure we're were we wanted to go"
	(ssl peerName match: hostName) ifFalse:[
		self error: 'Host name mismatch: ', ssl peerName.
	].

	"Send encrypted data"
	ssl sendData:
		'GET /search?q=', query,' HTTP/1.0', String crlfString,
		'Host: ', hostName, String crlfString,
		'Connection: close', String crlfString,
		String crlfString.

	"Wait for the response"
	^String streamContents:[:s|
		[socket isConnected | socket dataAvailable] 
			whileTrue:[s nextPutAll: ssl receiveData]].
	] ensure:[ssl destroy].

]

{ #category : 'instance creation' }
SqueakSSL class >> on: aSocket [
	"Convenience API. Create a SqueakSSL operating on a standard TCP socket.
	Generally not very useful for real applications (it lacks error handling etc) 
	but very helpful for debugging and other experiments."

	^self new on: aSocket
]

{ #category : 'utilities' }
SqueakSSL class >> platformName [
	"Return the name of the platform we're running on."

	^Smalltalk getSystemAttribute: 1001
]

{ #category : 'instance creation' }
SqueakSSL class >> secureSocket [
	"Answer the class to use as secure socket implementation.
	Provided here so that users only need a dependency on SqueakSSL."

	^SecureSocket
]

{ #category : 'instance creation' }
SqueakSSL class >> secureSocketStream [
	"Answer the class to use as secure socket stream implementation.
	Provided here so that users only need a dependency on SqueakSSL."

	^SecureSocketStream
]

{ #category : 'examples' }
SqueakSSL class >> serverOn: port certName: certName [
	"An HTTPS server example. Fires up a listener at the given port such that
	you can point a browser to that https url. Responds with a single line of text
	and closes the listener after the first connection.

		SqueakSSL 
			serverOn: 8443
			certName: 'Internet Widgits Pty'.

		SqueakSSL 
			serverOn: 8443 
			certName: '/home/andreas/certs/testcert.pem'.

	"
	| listener socket ssl |
	"Set up the listener socket"
	listener := Socket newTCP.
	listener listenOn: port backlogSize: 8.
	[socket := listener waitForAcceptFor: 30.
	socket == nil] whileTrue.
	listener destroy.

	"Set up SqueakSSL for the just accepted connection"
	[ssl := SqueakSSL on: socket.

	"The SSL needs the cert name."
	ssl certName: certName.

	"Let SqueakSSL do the server handshake"
	ssl accept.

	"Read out the HTTPS request"
	ssl receiveData.
	
	"And send the response"
	ssl sendData:
		'HTTP/1.0 200 OK', String crlfString,
		'Connection: close', String crlfString,
		'Content-Type: text/plain', String crlfString,
		'Server: SqueakSSL', String crlfString,
		String crlfString,
		'This is a successful SqueakSSL response.'.

	socket close.

	] ensure:[
		ssl destroy.
		socket destroy.
	].
]

{ #category : 'convenience' }
SqueakSSL >> accept [
	"Convenience API. Perform an SSL server handshake.
	Raises an error if something goes wrong."

	| inbuf outbuf count result |

	inbuf := ByteArray new: 4096.
	outbuf := ByteArray new: 4096.
	count := 0.

	[self isConnected] whileFalse:[
		"Read input"
		count := self readDataInto: inbuf.
		result := self accept: inbuf from: 1 to: count into: outbuf.

		"Check for errors first"
		result < -1 ifTrue:[^self error: 'SSL accept failed with code: ', result printString].

		"If a token has been produced in the handshake, send it to the remote"
		result > 0 ifTrue:[self writeData: outbuf count: result].
	].

]

{ #category : 'operations' }
SqueakSSL >> accept: srcBuf from: start to: stop into: dstBuf [
	"Start or continue the server handshake using the given input token."

	^self primitiveSSL: handle accept: srcBuf startingAt: start count: stop-start+1 into: dstBuf
]

{ #category : 'accessing' }
SqueakSSL >> certName [
	"The name of the (local) certificate to provide to the remote peer."

	^self primitiveSSL: handle getStringProperty: 1
]

{ #category : 'accessing' }
SqueakSSL >> certName: aString [
	"Sets the name of the (local) certificate to provide to the remote peer.
	OpenSSL:
		The name is the full path to a .pem file.
	WinSSL:
		The name is matched against the 'friendly name' of a certificate in the cert store.
	"

	^self primitiveSSL: handle setStringProperty: 1 toValue: (aString ifNil:[''])
]

{ #category : 'accessing' }
SqueakSSL >> certState [
	"Returns the certificate verification bits. The returned value indicates
	whether the certificate is valid. The two standard values are:

		0 - The certificate is valid.
		-1 - No certificate has been provided by the peer.

	Otherwise, the result is a bit mask of the following values:

		1 - If set, there is an unspecified issue with the cert (generic error)
		2 - If set, the root CA is untrusted (usually a self-signed cert)
		4 - If set, the certificate is expired.
		8 - If set, the certificate is used for the wrong purpose
		16 - If set, the CN of the certificate is invalid.
		32 - If set, the certificate was revoked.

	"
	^self primitiveSSL: handle getIntProperty: 3
]

{ #category : 'convenience' }
SqueakSSL >> connect [
	"Convenience API. Perform an SSL client handshake. 
	Raises an error if something goes wrong."

	| inbuf outbuf count result |

	inbuf := ByteArray new: 4096.
	outbuf := ByteArray new: 4096.
	count := 0.

	"Begin the SSL handshake"
	[result := self connect: inbuf from: 1 to: count into: outbuf.
	result = 0] whileFalse:[
		"Check for errors first"
		result < -1 ifTrue:[^self error: 'SSL connect failed with code: ', result printString].

		"If a token has been produced in the handshake, send it to the remote"
		result > 0 ifTrue:[self writeData: outbuf count: result].

		"Read more input and repeat"
		count := self readDataInto: inbuf.
	].
]

{ #category : 'operations' }
SqueakSSL >> connect: srcBuf from: start to: stop into: dstBuf [
	"Start or continue the server handshake using the given input token."

	| r |
	r := self primitiveSSL: handle connect: srcBuf startingAt: start count: stop-start+1 into: dstBuf.
	r <= 0 ifTrue:
		[Processor yield].
	^r
]

{ #category : 'convenience' }
SqueakSSL >> decrypt: data [
	"Convenience API. Decrypt incoming data and return the result.

	Warning: This method may produce more or less results than expected
	unless called with exactly one SSL/TLS frame."

	| buf count |
	buf := data class new: 4096.
	count := self decrypt: data from: 1 to: data size into: buf.
	count < 0 ifTrue:[self error: 'Decryption failed, code: ', count].
	^buf copyFrom: 1 to: count
]

{ #category : 'operations' }
SqueakSSL >> decrypt: srcBuf from: start to: stop into: dstBuf [
	"Decrypt the input in srcBuf into the provided output buffer.

	Clients are expected to adhere to the following rules:
		* The size of dstBuf must be large enough for the largest encrypted packet.
		* Clients must not call this method with a huge srcBuf (tens of kb of data)
		* After having called this method with new input, clients must call it 
		   with NO input until all data has been 'drained' for example:
			count := squeakSSL decrypt: srcBuf into: dstBuf.
			[count > 0] whileTrue:[
				count := squeakSSL decrypt: #[] into: dstBuf.
			].
	"

	^self primitiveSSL: handle decrypt: srcBuf startingAt: start count: stop-start+1 into: dstBuf
]

{ #category : 'initialize' }
SqueakSSL >> destroy [
	"Destroys the underlying platform handle"

	handle ifNotNil:[
		self primitiveSSLDestroy: handle.
		handle := nil.
	].
]

{ #category : 'convenience' }
SqueakSSL >> encrypt: data [
	"Convenience API. Encrypt incoming data and return the result."

	| buf count |
	buf := data class new: data size + 100.
	count := self encrypt: data from: 1 to: data size into: buf.
	count < 0 ifTrue:[self error: 'Decryption failed, code: ', count].
	^buf copyFrom: 1 to: count
]

{ #category : 'operations' }
SqueakSSL >> encrypt: srcBuf from: start to: stop into: dstBuf [
	"Encrypt the input in srcBuf into the provided output buffer.
	The output buffer must be large enough to include the framing information."

	^self primitiveSSL: handle encrypt: srcBuf startingAt: start count: stop-start+1 into: dstBuf
]

{ #category : 'initialize' }
SqueakSSL >> initialize [
	"Initialize the receiver"

	handle := self primitiveSSLCreate.

]

{ #category : 'testing' }
SqueakSSL >> isConnected [
	"Returns true if the SSL handshake has been completed"

	^self sslState = 3
]

{ #category : 'accessing' }
SqueakSSL >> logLevel [
	"Returns the log level of the ssl instance"

	^self primitiveSSL: handle getIntProperty: 1
]

{ #category : 'accessing' }
SqueakSSL >> logLevel: aNumber [
	"Sets the log level of the ssl instance"

	^self primitiveSSL: handle setIntProperty: 1 toValue: aNumber
]

{ #category : 'initialize' }
SqueakSSL >> on: aSocket [
	"Convenience API. Set up SqueakSSL to operate on a standard TCP socket.
	Generally not very useful for real applications (it lacks error handling etc) 
	but very helpful for debugging and other experiments."

	self readBlock:[:inbuf|
		aSocket waitForDataIfClosed:[].
		aSocket receiveDataInto: inbuf.
	].
	self writeBlock:[:outbuf :count|
		aSocket sendData: (outbuf copyFrom: 1 to: count).
	].
]

{ #category : 'accessing' }
SqueakSSL >> peerName [
	"Returns the certificate name of the remote peer.
	The method only returns a name if the certificate has been verified."

	^self primitiveSSL: handle getStringProperty: 0
]

{ #category : 'accessing' }
SqueakSSL >> pluginVersion [
	"Returns the version of the plugin"

	^self primitiveSSL: handle getIntProperty: 0
]

{ #category : 'primitives' }
SqueakSSL >> primitiveSSL: sslHandle accept: srcbuf startingAt: start count: length into: dstbuf [
	"Primitive. Starts or continues a server handshake using the provided data.
	Will eventually produce output to be sent to the server.
	Returns:
		> 0	 - Number of bytes to be sent to the server
		0	 - Success. The connection is established.
		-1 	 - More input is required.
		< -1 - Other errors
	"
	<primitive: 'primitiveAccept' module: 'SqueakSSL'>
	^self primitiveFailed
]

{ #category : 'primitives' }
SqueakSSL >> primitiveSSL: sslHandle connect: srcbuf startingAt: start count: length into: dstbuf [
	"Primitive. Starts or continues a client handshake using the provided data.
	Will eventually produce output to be sent to the server.
	Returns:
		> 0	 - Number of bytes to be sent to the server
		0	 - Success. The connection is established.
		-1 	 - More input is required.
		< -1 - Other errors
	"
	<primitive: 'primitiveConnect' module: 'SqueakSSL'>
	^self primitiveFailed
]

{ #category : 'primitives' }
SqueakSSL >> primitiveSSL: sslHandle decrypt: srcbuf startingAt: start count: length into: dstbuf [
	"Primitive. Takes incoming data for decryption and continues to decrypt data.
	Returns the number of bytes produced in the output"

	<primitive: 'primitiveDecrypt' module: 'SqueakSSL'>
	^self primitiveFailed
]

{ #category : 'primitives' }
SqueakSSL >> primitiveSSL: sslHandle encrypt: srcbuf startingAt: start count: length into: dstbuf [
	"Primitive. Encrypts the incoming buffer into the result buffer.
	Returns the number of bytes produced as a result."

	<primitive: 'primitiveEncrypt' module: 'SqueakSSL'>
	^self primitiveFailed
]

{ #category : 'primitives' }
SqueakSSL >> primitiveSSL: sslHandle getIntProperty: propID [
	"Primitive. Returns a string property from an SSL session."

	<primitive: 'primitiveGetIntProperty' module: 'SqueakSSL'>
	^self primitiveFailed
]

{ #category : 'primitives' }
SqueakSSL >> primitiveSSL: sslHandle getStringProperty: propID [
	"Primitive. Returns a string property from an SSL session."

	<primitive: 'primitiveGetStringProperty' module: 'SqueakSSL'>
	^self primitiveFailed
]

{ #category : 'primitives' }
SqueakSSL >> primitiveSSL: sslHandle setIntProperty: propID toValue: anInteger [
	"Primitive. Sets a string property in an SSL session."

	<primitive: 'primitiveSetIntProperty' module: 'SqueakSSL'>
	^self primitiveFailed
]

{ #category : 'primitives' }
SqueakSSL >> primitiveSSL: sslHandle setStringProperty: propID toValue: aString [
	"Primitive. Sets a string property in an SSL session."

	<primitive: 'primitiveSetStringProperty' module: 'SqueakSSL'>
	^self primitiveFailed
]

{ #category : 'primitives' }
SqueakSSL >> primitiveSSLCreate [
	"Primitive. Creates and returns a new SSL handle"

	<primitive: 'primitiveCreate' module: 'SqueakSSL'>
	^self primitiveFailed
]

{ #category : 'primitives' }
SqueakSSL >> primitiveSSLDestroy: sslHandle [
	"Primitive. Destroys the SSL session handle"

	<primitive: 'primitiveDestroy' module: 'SqueakSSL'>
	^self primitiveFailed
]

{ #category : 'accessing' }
SqueakSSL >> readBlock [
	"The block used to read data where required. The block takes one argument,
	the buffer to fill with data and is expected to return the number of bytes read."

	^readBlock
]

{ #category : 'accessing' }
SqueakSSL >> readBlock: aBlock [
	"The block used to read data where required. The block takes one argument,
	the buffer to fill with data and is expected to return the number of bytes read."

	readBlock := aBlock
]

{ #category : 'private' }
SqueakSSL >> readDataInto: aBuffer [
	"Private. Read actual data into the given buffer.
	Return the number of bytes read."

	^readBlock value: aBuffer
]

{ #category : 'convenience' }
SqueakSSL >> receiveData [
	"Convenience API. Receive data and decrypt it."

	| inbuf outbuf count |
	inbuf := String new: 4096.
	outbuf := String new: 4096.

	^String streamContents:[:s|
		"Read the next input bytes"
		count := self readDataInto: inbuf.
		"Push the input bytes into the SSL"
		count := self decrypt: inbuf from: 1 to: count into: outbuf.
		"And keep draining as long as output is being produced"
		[count > 0] whileTrue:[
			s next: count putAll: outbuf.
			count := self decrypt: inbuf from: 1 to: 0 into: outbuf.
		].
	].
]

{ #category : 'convenience' }
SqueakSSL >> sendData: inbuf [
	"Convenience API. Encrypt and send data"

	| outbuf count |
	outbuf := inbuf class new: inbuf size + 100.
	count := self encrypt: inbuf from: 1 to: inbuf size into: outbuf.
	^self writeData: outbuf count: count.
]

{ #category : 'accessing' }
SqueakSSL >> serverName: aString [
	"Sets the name to use with the Server Name Indication TLS extension. Which should be a valid FQDN. No WinSSL support yet."

	^[ self primitiveSSL: handle setStringProperty: 2 toValue: aString ]
		on: Error
		do: [ "nothing" ]
]

{ #category : 'private' }
SqueakSSL >> setStringProperty: index to: aString [
	"Private. Use with caution"

	^self primitiveSSL: handle setStringProperty: index toValue: aString
]

{ #category : 'accessing' }
SqueakSSL >> sslState [
	"Returns the current state of the SSL connection:
		0 - Unused.
		1 - In accept handshake.
		2 - In connect handshake.
		3 - Connected.
	"
	^self primitiveSSL: handle getIntProperty: 2
		
]

{ #category : 'accessing' }
SqueakSSL >> writeBlock [
	"The block used to write data where required. The block takes two arguments,
	the buffer and the number of bytes to be written from the buffer."

	^writeBlock
]

{ #category : 'accessing' }
SqueakSSL >> writeBlock: aBlock [
	"The block used to write data where required. The block takes two arguments,
	the buffer and the number of bytes to be written from the buffer."

	writeBlock := aBlock
]

{ #category : 'private' }
SqueakSSL >> writeData: aBuffer count: count [
	"Private. Write actual data from the given buffer."

	writeBlock value: aBuffer value: count
]
