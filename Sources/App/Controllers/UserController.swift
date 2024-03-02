//
//  UserController.swift
//  
//
//  Created by joker on 3/1/24.
//

import Vapor

struct UserController: RouteCollection {
    
    func boot(routes: Vapor.RoutesBuilder) throws {
        
        let userRoutes = routes.grouped("api", "users")
        
        userRoutes.post(use: createHandler)
        
        userRoutes.get(use: getAllHandler)
        
        userRoutes.get(":userID", use: getHandler)
        
        userRoutes.get(":userID", "acronyms", use: getAcronymsHandler)
    }
    
    func createHandler(_ req: Request) async throws -> User {
        
        let user = try req.content.decode(User.self)
        
        try await user.save(on: req.db)
        
        return user
        
    }
    
    func getAllHandler(_ req: Request) async throws -> [User] {
        
        return try await User.query(on: req.db).all()
    }
    
    func getHandler(_ req: Request) async throws -> User {
        
        guard let user = try await User.find(req.parameters.get("userID"), on: req.db)
        else {
            throw Abort(.notFound)
        }
        
        return user
        
    }
    
    func getAcronymsHandler(_ req: Request) async throws -> [Acronym] {
        
        guard let user = try await User.find(req.parameters.get("userID"), on: req.db)
        else {
            throw Abort(.notFound)
        }
        
        let acronyms = try await user.$acronyms.get(on: req.db)
        
        return acronyms
        
    }
}
