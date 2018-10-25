//
//  User.swift
//  App
//
//  Created by joker on 2018/10/21.
//

import Vapor
import FluentPostgreSQL

final class User: Codable {
    var id: UUID?
    var name: String
    var username: String
    
    init(name: String, username: String) {
        self.name = name
        self.username = username
    }
}

extension User: PostgreSQLUUIDModel {}
extension User: Migration {}
extension User: Parameter {}
extension User: Content {}
//获取子数据信息
extension User {
    var acronyms: Children<User, Acronym> {
        return children(\.userID)
    }
}
