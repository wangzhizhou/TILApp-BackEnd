//
//  CreateCategory.swift
//  
//
//  Created by joker on 3/2/24.
//

import Fluent

struct CreateCategory: AsyncMigration {
    
    func prepare(on database: Database) async throws {
        try await database.schema("categories")
            .id()
            .field("name", .string, .required)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema("categories").delete()
    }
}
