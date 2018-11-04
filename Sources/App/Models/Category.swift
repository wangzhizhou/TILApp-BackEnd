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
    
    static func addCategory(_ name: String,
                            to acronym: Acronym,
                            on req: Request
        ) throws -> Future<Void> {
        return Category.query(on: req).filter(\.name == name).first()
            .flatMap(to: Void.self) { foundCategory in
                if let existingCategory = foundCategory {
                    return acronym.categories.attach(existingCategory, on: req)
                    .transform(to: ())
                }
                else {
                    let category = Category(name: name)
                    return category.save(on: req).flatMap(to: Void.self) { savedCategory in
                        return acronym.categories.attach(savedCategory, on: req).transform(to: ())
                        
                    }
                }
        }
    }
}
