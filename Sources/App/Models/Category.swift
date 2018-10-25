//
//  Category.swift
//  App
//
//  Created by joker on 2018/10/22.
//

import Vapor
import FluentPostgreSQL

final class Category: Codable {
    var id: Int?
    var name: String
    
    init(name: String) {
        self.name = name
    }
}

extension Category: Parameter {}
extension Category: Content {}
extension Category: Migration {}
extension Category: PostgreSQLModel {}

extension Category {
    var acronyms: Siblings<Category, Acronym, AcronymCategoryPivot> {
        return siblings()
    }
}
