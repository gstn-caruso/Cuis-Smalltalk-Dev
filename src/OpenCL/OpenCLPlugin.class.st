"
Placeholder for a subclass of InterpreterPlugin.

Responsibilities:
	- implement surfaces a-la SurfacePlugin so that we can make a SqueakForm that refers directly to a mapped OpenCL 2D image
	- primitive support to allow OpenCLEvent class>>waitForEvents: to block a single Squeak Process, rather than the main VM thread.  To do this, we need a separate native thread (maybe from a thread-pool?) that will signal a Squeak semaphore... the Process waiting for the primitive will block waiting for that semaphore to be signalled.  
	
	for blocking-waits on a command-queue that occur in a different native thread.  Probably make a subclass of command-queue whose instances register themselves with the plugin, and
"
Class {
	#name : 'OpenCLPlugin',
	#superclass : 'Object',
	#category : 'OpenCL-Plugin',
	#package : 'OpenCL',
	#tag : 'Plugin'
}
