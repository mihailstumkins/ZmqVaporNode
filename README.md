## ØMQ & Vapor node example

#### Requirements:

install zeromq before using

#### Description:

Proof of concept for vapor with zeromq

zeromq communication is done via swift-zmq (https://github.com/azawawi/swift-zmq)

if /zmq-request/{message} route is hit via GET request node connects via request interface
issues a request command with message, the reply node (in this demo it is same node) echos message back
to request node and after that message is returned to http client

zmq-reply-provider.json contains reply interface network config
zmq-request-provider.json contains request interface network config


