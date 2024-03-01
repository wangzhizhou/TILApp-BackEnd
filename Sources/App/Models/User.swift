//
//  User.swift
//
//
//  Created by joker on 3/1/24.
//

import Fluent

final class User: Model {
    
    static var schema: String = "users"
    
    @ID
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "username")
    var username: String
    
    @Children(for: \.$user)
    var acronyms: [Acronym]
    
    init(id: UUID? = nil, name: String, username: String) {
        self.id = id
        self.name = name
        self.username = username
    }
    
    init() {}
}

import Vapor

extension User: Content {}
