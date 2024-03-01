//
//  AcronymsController.swift
//
//
//  Created by joker on 3/1/24.
//

import Vapor
import Fluent

struct AcronymsController: RouteCollection {
    
    func boot(routes: Vapor.RoutesBuilder) throws {
        
        let acronymsRoutes = routes.grouped("api", "acronyms")
        
        acronymsRoutes.post(use: createHandler)
        
        acronymsRoutes.delete(":acronymID", use: deleteHandler)
        
        acronymsRoutes.put(":acronymID", use: updateHandler)
        
        acronymsRoutes.get(":acronymID", use: getHandler)
        
        acronymsRoutes.get("search", use: searchHandler)
        
        acronymsRoutes.get("first", use: getFirstHandler)
        
        acronymsRoutes.get("sorted", use: sortedHandler)
        
        acronymsRoutes.get(use:getAllHandler)
        
        acronymsRoutes.get(":acronymID", "user", use: getUserHandler)
    }
}

extension AcronymsController {
    
    func createHandler(_ req: Request) async throws -> Acronym {
        
        let data = try req.content.decode(CreateAcronymData.self)
        
        let acronym = Acronym(
            short: data.short,
            long: data.long,
            userID: data.userID
        )
        
        try await acronym.save(on: req.db)
        
        return acronym
    }
    
    func deleteHandler(_ req: Request) async throws -> HTTPStatus {
        
        guard let acronym = try await Acronym.find(req.parameters.get("acronymID"), on: req.db)
        else {
            throw Abort(.notFound)
        }
        
        try await acronym.delete(on: req.db)
        
        return .noContent
    }
    
    func updateHandler(_ req: Request) async throws -> Acronym {
        
        let updateData = try req.content.decode(CreateAcronymData.self)
        
        guard let acronym = try await Acronym.find(req.parameters.get("acronymID"), on: req.db)
        else {
            throw Abort(.notFound)
        }
        
        acronym.long = updateData.long
        acronym.short = updateData.short
        acronym.$user.id = updateData.userID
        
        try await acronym.save(on: req.db)
        
        return acronym
    }
    
    func getHandler(_ req: Request) async throws -> Acronym {
        
        guard let ret = try await Acronym.find(req.parameters.get("acronymID"), on: req.db)
        else {
            throw Abort(.notFound)
        }
        
        return ret
    }
    
    func searchHandler(_ req: Request) async throws -> [Acronym] {
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
    
    func getFirstHandler(_ req: Request) async throws -> Acronym {
        guard let first = try await Acronym.query(on: req.db).first()
        else {
            throw Abort(.notFound)
        }
        return first
    }
    
    func sortedHandler(_ req: Request) async throws -> [Acronym] {
        try await Acronym.query(on: req.db).sort(\.$short, .ascending).all()
    }
    
    func getAllHandler(_ req: Request) async throws -> [Acronym] {
        
        return try await Acronym.query(on: req.db).all()
    }
    
    func getUserHandler(_ req: Request) async throws -> User {
        
        guard let acronym = try await Acronym.find(req.parameters.get("acronymID"), on: req.db)
        else {
            throw Abort(.notFound)
        }
        
        return try await acronym.$user.get(on: req.db)
        
    }
}

struct CreateAcronymData: Content {
    let short: String
    let long: String
    let userID: UUID
}
