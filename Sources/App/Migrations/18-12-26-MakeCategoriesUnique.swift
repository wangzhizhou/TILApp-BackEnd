//
//  18-12-26-MakeCategoriesUnique.swift
//  App
//
//  Created by joker on 2018/12/27.
//

import FluentPostgreSQL
import Vapor

struct MakeCategoriesUnique: Migration {
    
    typealias Database = PostgreSQLDatabase
    
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        return Database.update(Category.self, on: conn) {
            builder in
            builder.unique(on: \.name)
        }
    }
    
    static func revert(on conn: PostgreSQLConnection) -> Future<Void> {
        return Database.update(Category.self, on: conn) { builder in
            builder.deleteUnique(from: \.name)
        }
    }
}
