//
//  ZmqRequestProvider.swift
//  Run
//
//  Created by Mihails Tumkins on 03/10/2017.
//

import Vapor
import ZMQ

public final class ZmqRequestProvider: Vapor.Provider {
    private static let configFilename: String = "zmq-request-provider"
    public static var repositoryName: String = "zmq-request-provider"
    
    private var context: ZMQ.Context
    private var host: String
    private var port: String
    
    enum Error: Swift.Error {
        case invalidConfiguration(message: String)
    }
    
    public func boot(_ config: Config) throws {}
    
    public func boot(_ droplet: Droplet) throws {
        
        droplet.console.info("Starting ZmqRequest \(host):\(port)")
        droplet.zmqRequest = try self.context.socket(.request)

        background {
            do {
                try droplet.zmqRequest?.connect("tcp://\(self.host):\(self.port)")
            } catch {
                print(error)
            }
        }
    }
    
    public func beforeRun(_ droplet: Droplet) throws {}
    
    public init(config: Config) throws {

        guard let host = config[ZmqRequestProvider.configFilename, "host"]?.string else {
            throw Error.invalidConfiguration(message: "Missing host variable in \(ZmqRequestProvider.configFilename).json' config file")
        }
        
        guard let port = config[ZmqRequestProvider.configFilename, "port"]?.string else {
            throw Error.invalidConfiguration(message: "Missing port variable in \(ZmqRequestProvider.configFilename).json' config file")
        }
        
        self.host = host
        self.port = port
        self.context = try ZMQ.Context()
    }
}

extension Droplet {
    public internal(set) var zmqRequest: ZMQ.Socket? {
        get {
            return storage[ZmqRequestProvider.repositoryName] as? ZMQ.Socket
        }
        set {
            storage[ZmqRequestProvider.repositoryName] = newValue
        }
    }
}

