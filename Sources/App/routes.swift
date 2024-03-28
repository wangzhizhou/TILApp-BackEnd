import Fluent
import Vapor
import HTMLKitVapor

func routes(_ app: Application) throws {
    
    // 注册零散的路由，如果太多会不好维护, 路由发生变化时，需要调整的位置比较多
    try scatteredRoutes(app)
    
    // 注册路由集合，方便模块化维护
    try app.register(collection: TodoController())
    try app.register(collection: AcronymsController())
    try app.register(collection: WebController())
    try app.register(collection: UserController())
    try app.register(collection: CategoryController())
}

func scatteredRoutes(_ app: Application) throws {
    
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

    app.get("htmlkit") { req async throws -> View in
        return try await req.htmlkit.render(ExampleView(context: InfoData(name: "htmlKit views")))
    }
}

struct InfoData: Content {
    
    let name: String
}

struct InfoResponse: Content {
    
    let request: InfoData
}
