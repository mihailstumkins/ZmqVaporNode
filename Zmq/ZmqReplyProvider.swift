//
//  ZmqReplyProvider.swift
//  Run
//
//  Created by Mihails Tumkins on 03/10/2017.
//

import Vapor
import ZMQ

public final class ZmqReplyProvider: Vapor.Provider {
    private static let configFilename: String = "zmq-reply-provider"
    public static var repositoryName: String = "zmq-reply-provider"
    
    private var context: ZMQ.Context
    private var host: String
    private var port: String

    enum Error: Swift.Error {
        case invalidConfiguration(message: String)
    }
    
    public func boot(_ config: Config) throws {}
    
    public func boot(_ droplet: Droplet) throws {

        droplet.console.info("Starting ZmqReply \(host):\(port)")
        droplet.zmqReply = try context.socket(.reply)
        try droplet.zmqReply?.bind("tcp://\(host):\(port)")

        background {
            while true {
                do {
                    if let data = try droplet.zmqReply?.recv() {
                        print("Received \(data)")
                        try droplet.zmqReply?.send(string: data)
                    }
                } catch {
                    print(error)
                }
            }
        }
    }
    
    public func beforeRun(_ droplet: Droplet) throws {}
    
    public init(config: Config) throws {

        guard let host = config[ZmqReplyProvider.configFilename, "host"]?.string else {
            throw Error.invalidConfiguration(message: "Missing host variable in \(ZmqReplyProvider.configFilename).json' config file")
        }
        
        guard let port = config[ZmqReplyProvider.configFilename, "port"]?.string else {
            throw Error.invalidConfiguration(message: "Missing port variable in \(ZmqReplyProvider.configFilename).json' config file")
        }
        
        self.host = host
        self.port = port
        self.context = try ZMQ.Context()
    }
}

extension Droplet {
    public internal(set) var zmqReply: ZMQ.Socket? {
        get {
            return storage[ZmqReplyProvider.repositoryName] as? ZMQ.Socket
        }
        set {
            storage[ZmqReplyProvider.repositoryName] = newValue
        }
    }
}
