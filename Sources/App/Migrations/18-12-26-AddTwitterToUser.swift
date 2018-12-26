//
//  18-12-26-AddTwitterToUser.swift
//  App
//
//  Created by joker on 2018/12/26.
//

import FluentPostgreSQL
import Vapor

struct AddTwitterURLToUser: Migration {
    
    typealias Database = PostgreSQLDatabase

    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        return Database.update(User.self, on: conn) { builder in
            builder.field(for: \.twitterURL)
        }
    }
    
    static func revert(on conn: PostgreSQLConnection) -> Future<Void> {
        return Database.update(User.self, on: conn) { builder in
            builder.deleteField(for: \.twitterURL)
        }
    }
}
