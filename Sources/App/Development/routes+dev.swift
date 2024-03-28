//
//  routes+dev.swift
//
//
//  Created by joker on 2024/3/28.
//

import Vapor

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
