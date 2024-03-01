//
//  CreateUser.swift
//
//
//  Created by joker on 3/1/24.
//

import Fluent

struct CreateUser: AsyncMigration {
    
    func prepare(on database: FluentKit.Database) async throws {
        try await database.schema("users")
            .id()
            .field("name", .string, .required)
            .field("username", .string, .required)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema("users").delete()
    }
}
