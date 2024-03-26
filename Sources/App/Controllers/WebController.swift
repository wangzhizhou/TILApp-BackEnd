//
//  WebController.swift
//
//
//  Created by joker on 3/1/24.
//

import Vapor
import Leaf

struct WebController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        
        routes.get(use: indexHandler)
        routes.get("acronyms", ":acronymID", use: acronymHandler)

    }

    func indexHandler(_ req: Request) async throws -> View {
        let acronyms = try await Acronym.query(on: req.db).all()
        let context = IndexContext(
            title: "Home Page",
            acronyms: acronyms
        )
        return try await req.view.render("index", context)
    }

    func acronymHandler(_ req: Request) async throws -> View {
        guard let acronym = try await Acronym.find(req.parameters.get("acronymID"), on: req.db)
        else {
            throw Abort(.notFound)
        }
        let user = try await acronym.$user.get(on: req.db)
        let context = AcronymContext(title: acronym.short, acronym: acronym, user: user)
        return try await req.view.render("acronym", context)
    }
}

struct IndexContext: Encodable {
    let title: String
    let acronyms: [Acronym]?
}

struct AcronymContext: Encodable {
    let title: String
    let acronym: Acronym
    let user: User
}
