//
//  CategoryController.swift
//
//
//  Created by joker on 3/2/24.
//

import Vapor

struct CategoryController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        
        let categoryRoutes = routes.grouped("api", "categories")
        
        categoryRoutes.post(use: createHandler)
        
        categoryRoutes.get(use: getAllHandler)
        
        categoryRoutes.get(":categoryID", use: getHandler)
        
    }
}

extension CategoryController {
    
    func createHandler(_ req: Request) async throws -> Category {
        
        let category = try req.content.decode(Category.self)
        
        try await category.save(on: req.db)
        
        return category
    }
    
    func getAllHandler(_ req: Request) async throws -> [Category] {
        
        return try await Category.query(on: req.db).all()
        
    }
    
    func getHandler(_ req: Request) async throws -> Category {
        
        guard let category = try await Category.find(req.parameters.get("categoryID"), on: req.db)
        else {
            throw Abort(.notFound)
        }
        return category
    }
}
