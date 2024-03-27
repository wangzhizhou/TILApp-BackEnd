//
//  Category.swift
//
//
//  Created by joker on 3/2/24.
//

import Fluent

final class Category: Model {
    
    static var schema: String = "categories"
    
    @ID
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Siblings(through: AcronymCategoryPivot.self, from: \.$category, to: \.$acronym)
    var acronyms: [Acronym]
    
    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
    
    init() {}
    
}

import Vapor
extension Category: Content {}


extension Category {
    static func addCategory(_ name: String, to acronym: Acronym, on req: Request) async throws {
        if let existCategory = try await Category.query(on: req.db).filter(\.$name == name).first() {
            try await acronym.$categories.attach(existCategory, on: req.db)
        } else {
            let category = Category(name: name)
            try await category.save(on: req.db)
            try await acronym.$categories.attach(category, on: req.db)
        }
    }
}
