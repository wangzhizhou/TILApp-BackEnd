import Fluent
import Vapor

func routes(_ app: Application) throws {
    
    // 注册零散的路由，如果数据太多会不好维护
    
    app.get { req async throws in
        try await req.view.render("index", ["title": "Hello Vapor!"])
    }
    
    app.get("hello") { req async -> String in
        "Hello, world!"
    }
    
    app.get("hello", ":name") { req async throws -> String in
        
        guard let name = req.parameters.get("name")
        else {
            throw Abort(.internalServerError)
        }
        return "Hello, \(name)!"
    }
        
    app.post("info") { req async throws -> String in
        
        let data = try req.content.decode(InfoData.self)
        
        return "Hello, \(data.name)!"
        
    }
        
    app.post("info", "json") { req async throws -> InfoResponse in
        
        let data = try req.content.decode(InfoData.self)
        
        return InfoResponse(request: data)
        
    }
    
    // 注册路由集合，方便模块化维护
    try app.register(collection: TodoController())
}

struct InfoData: Content {
    
    let name: String
}

struct InfoResponse: Content {
    
    let request: InfoData
}
