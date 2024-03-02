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
