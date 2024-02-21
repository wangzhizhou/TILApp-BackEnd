//
//  CreateAcronym.swift
//
//
//  Created by joker on 2/22/24.
//

import Fluent

// acronyms数据表在数据库中的迁移逻辑：创建/删除
struct CreateAcronym: AsyncMigration {
    
    // 创建 acronyms 数据表
    func prepare(on database: FluentKit.Database) async throws {
        try await database.schema("acronyms")
            .id()
            .field("short", .string, .required)
            .field("long", .string, .required)
            .create()
    }
    
    // 删除 acronyms 数据表
    func revert(on database: FluentKit.Database) async throws {
        try await database.schema("acronyms").delete()
    }
    
}
