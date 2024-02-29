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

    app.post("api", "acronyms") { req async throws -> Acronym in

        let acronym = try req.content.decode(Acronym.self)

        try await acronym.save(on: req.db)

        return acronym
    }
    
    app.get("api", "acronyms") { req async throws -> [Acronym] in
        
        return try await Acronym.query(on: req.db).all()
    }
    
    app.get("api", "acronyms", ":acronymID") { req async throws -> Acronym in
        
        guard let ret = try await Acronym.find(req.parameters.get("acronymID"), on: req.db)
        else {
            throw Abort(.notFound)
        }
        return ret
    }
    
    app.put("api", "acronyms", ":acronymID") { req async throws -> Acronym in
        
        let updatedAcronym = try req.content.decode(Acronym.self)
        
        guard let acronym = try await Acronym.find(req.parameters.get("acronymID"), on: req.db)
        else {
            throw Abort(.notFound)
        }
        
        acronym.long = updatedAcronym.long
        acronym.short = updatedAcronym.short
        
        try await acronym.save(on: req.db)
        
        return acronym
    }
    
    app.delete("api", "acronyms", ":acronymID") { req async throws -> HTTPStatus in
        guard let acronym = try await Acronym.find(req.parameters.get("acronymID"), on: req.db)
        else {
            throw Abort(.notFound)
        }
        
        try await acronym.delete(on: req.db)
        
        return .noContent
    }
    
    app.get("api", "acronyms", "search") { req async throws -> [Acronym] in
        guard let searchTerm = req.query[String.self, at: "term"]
        else {
            throw Abort(.notFound)
        }
        return try await Acronym.query(on: req.db)
            .group(.or) { or in
                or.filter(\.$short == searchTerm)
                or.filter(\.$long == searchTerm)
            }.all()
    }
    
    app.get("api", "acronyms", "first") { req async throws -> Acronym in
        guard let first = try await Acronym.query(on: req.db).first()
        else {
            throw Abort(.notFound)
        }
        return first
    }
    
    app.get("api", "acronyms", "sorted") { req async throws -> [Acronym] in
        try await Acronym.query(on: req.db).sort(\.$short, .ascending).all()
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
