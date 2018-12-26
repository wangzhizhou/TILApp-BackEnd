//
//  User.swift
//  App
//
//  Created by joker on 2018/10/21.
//

import Vapor
import FluentPostgreSQL
import Authentication

final class User: Codable {
    var id: UUID?
    var name: String
    var username: String
    var password: String
    var twitterURL: String?
    
    init(name: String, username: String, password: String, twitterURL: String? = nil) {
        self.name = name
        self.username = username
        self.password = password
        self.twitterURL = twitterURL
    }
    
    final class Public: Codable {
        var id: UUID?
        var name: String
        var username: String
        var twitterURL: String?
        init(id: UUID?, name: String, username: String, twitterURL: String? = nil) {
            self.id = id
            self.name = name
            self.username = username
            self.twitterURL = twitterURL
        }
    }
}

extension User: PostgreSQLUUIDModel {}
extension User: Migration {
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: conn, closure: { (builder) in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.name)
            builder.field(for: \.username)
            builder.field(for: \.password)
            builder.unique(on: \.username)
        })
    }
}
extension User: Parameter {}
extension User: Content {}
extension User.Public: Content {}
//获取子数据信息
extension User {
    var acronyms: Children<User, Acronym> {
        return children(\.userID)
    }
}

extension User {
    func convertToPublic() -> User.Public {
        return User.Public(id: self.id, name: self.name, username: self.username, twitterURL: self.twitterURL)
    }
}

extension Future where T: User {
    
    func convertToPublic() -> Future<User.Public> {
        return self.map(to: User.Public.self) { (user) -> User.Public in
            return user.convertToPublic()
        }
    }
}


extension User: BasicAuthenticatable {
    static var usernameKey: WritableKeyPath<User, String> = \.username
    static var passwordKey: WritableKeyPath<User, String> = \.password
}

extension User: TokenAuthenticatable {
    typealias TokenType = Token
}

struct AdminUser: Migration {
    typealias Database = PostgreSQLDatabase
    
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        let password = try? BCrypt.hash("password")
        guard let hashPassword = password else {
            fatalError("Failed Create Admin User!")
        }
        
        let user = User(name: "admin", username: "admin", password: hashPassword)
        return user.save(on: conn).transform(to: ())
    }
    
    static func revert(on conn: PostgreSQLConnection) -> Future<Void> {
        return .done(on: conn)
    }
}

extension User: PasswordAuthenticatable {}
extension User: SessionAuthenticatable {}
