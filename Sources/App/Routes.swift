import Vapor

extension Droplet {
    func setupRoutes() throws {
        get("hello") { req in
            var json = JSON()
            try json.set("hello", "world")
            return json
        }

        get("plaintext") { req in
            return "Hello, world!"
        }

        // response to requests to /info domain
        // with a description of the request
        get("info") { req in
            return req.description
        }

        get("description") { req in return req.description }
        
        get("zmq-request", String.parameter) { req in
            let message = try req.parameters.next(String.self)
            try self.zmqRequest?.send(string: message)
            guard let resp = try self.zmqRequest?.recv() else {
                throw Abort(.badRequest)
            }
            return resp
        }
        
        try resource("posts", PostController.self)
    }
}
