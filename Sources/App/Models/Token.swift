//
//  Token.swift
//  App
//
//  Created by joker on 2018/11/10.
//

import Foundation
import Vapor
import FluentPostgreSQL
import Authentication

final class Token: Codable {
    var id: UUID?
    var token: String
    var userID: User.ID
    
    init(token: String, userID: User.ID) {
        self.token = token
        self.userID = userID
    }
}

extension Token: PostgreSQLUUIDModel  {}
extension Token: Migration {
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: conn) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.userID, to: \User.id)
        }
    }
}
extension Token: Content {}


extension Token {
    static func generate(for user: User) throws -> Token {
        let random = try CryptoRandom().generateData(count: 16)
        return try Token(token: random.base64EncodedString(), userID: user.requireID())
    }
}

extension Token: Authentication.Token {
    
    typealias UserType = User
    
    static let userIDKey: UserIDKey = \Token.userID
}

extension Token: BearerAuthenticatable {
    static let tokenKey: TokenKey = \Token.token
}
