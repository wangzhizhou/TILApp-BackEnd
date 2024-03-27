//
//  WebController.swift
//
//
//  Created by joker on 3/1/24.
//

import Vapor
import Leaf

struct WebController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        
        routes.get(use: indexHandler)
        routes.get("acronyms", ":acronymID", use: acronymHandler)
        routes.get("users", ":userID", use: userHandler)
        routes.get("users", use: allUserHandler)
        routes.get("categories", use: allCategoriesHandler)
        routes.get("categories", ":categoryID", use: categoryHandler)

        routes.get("acronyms", "create", use: createAcronymHandler)
        routes.post("acronyms", "create", use: createAcronymPostHandler)

        routes.get("acronyms", ":acronymID", "edit", use: editAcronymHandler)
        routes.post("acronyms", ":acronymID", "edit", use: editAcronymPostHandler)
        routes.post("acronyms", ":acronymID", "delete", use: deleteAcronymHandler)
    }

    func indexHandler(_ req: Request) async throws -> View {
        let acronyms = try await Acronym.query(on: req.db).all()
        let context = IndexContext(
            title: "Home Page",
            acronyms: acronyms
        )
        return try await req.view.render("index", context)
    }

    func acronymHandler(_ req: Request) async throws -> View {
        guard let acronym = try await Acronym.find(req.parameters.get("acronymID"), on: req.db)
        else {
            throw Abort(.notFound)
        }
        let user = try await acronym.$user.get(on: req.db)
        let categories = try await acronym.$categories.get(on: req.db)
        let context = AcronymContext(
            title: acronym.short,
            acronym: acronym,
            user: user,
            categories: categories
        )
        return try await req.view.render("acronym", context)
    }

    func userHandler(_ req: Request) async throws -> View {
        guard let user = try await User.find(req.parameters.get("userID"), on: req.db)
        else {
            throw Abort(.notFound)
        }
        let acronyms = try await user.$acronyms.get(on: req.db)
        let context = UserContext(title: user.name, user: user, acronyms: acronyms)
        return try await req.view.render("user", context)
    }

    func allUserHandler(_ req: Request) async throws -> View {
        let allUser = try await User.query(on: req.db).all()
        let context = AllUserContext(title: "All Users", users: allUser)
        return try await req.view.render("allUser", context)
    }

    func allCategoriesHandler(_ req: Request) async throws -> View {
        let allCategories = try await Category.query(on: req.db).all()
        let context = AllCategoriesContext(title: "All Categories", categories: allCategories)
        return try await req.view.render("allCategories", context)
    }

    func categoryHandler(_ req: Request) async throws -> View {
        guard let category = try await Category.find(req.parameters.get("categoryID"), on: req.db)
        else {
            throw Abort(.notFound)
        }
        let acronyms = try await category.$acronyms.get(on: req.db)
        let context = CategoryContext(
            title: category.name,
            category: category,
            acronyms: acronyms
        )
        return try await req.view.render("category", context)
    }

    func createAcronymHandler(_ req: Request) async throws -> View {
        let allUsers = try await User.query(on: req.db).all()
        let context = CreateAcronymContext(users: allUsers)
        return try await req.view.render("createAcronym", context)
    }

    func createAcronymPostHandler(_ req: Request) async throws -> Response {
        let acronymData = try req.content.decode(CreateAcronymFormData.self)
        let acronym = Acronym(
            short: acronymData.short,
            long: acronymData.long,
            userID: acronymData.userID
        )
        try await acronym.save(on: req.db)
        guard let acronymID = acronym.id
        else {
            throw Abort(.internalServerError)
        }
        for category in acronymData.categories ?? [] {
            try await Category.addCategory(category, to: acronym, on: req)
        }
        return req.redirect(to: "/acronyms/\(acronymID)")
    }

    func editAcronymHandler(_ req: Request) async throws -> View {
        guard let acronym = try await Acronym.find(req.parameters.get("acronymID"), on: req.db)
        else {
            throw Abort(.notFound)
        }
        let allUsers = try await User.query(on: req.db).all()
        let categories = try await acronym.$categories.get(on: req.db)
        let context = EditAcronymContext(acronym: acronym, users: allUsers, categories: categories)
        return try await req.view.render("createAcronym", context)
    }

    func editAcronymPostHandler(_ req: Request) async throws -> Response {
        let acronymData = try req.content.decode(CreateAcronymFormData.self)
        guard let acronym = try await Acronym.find(req.parameters.get("acronymID"), on: req.db)
        else{
            throw Abort(.notFound)
        }
        acronym.short = acronymData.short
        acronym.long = acronymData.long
        acronym.$user.id = acronymData.userID
        try await acronym.save(on: req.db)
        guard let acronymID = acronym.id
        else {
            throw Abort(.internalServerError)
        }
        let categories = try await acronym.$categories.get(on: req.db)

        let existCategories = Set<String>(categories.map { $0.name })
        let updateCategories = Set<String>(acronymData.categories ?? [])
        let categoriesToAdd = updateCategories.subtracting(existCategories)
        let categoriesToRemove = existCategories.subtracting(updateCategories)
        for categoryToAdd in categoriesToAdd {
            try await Category.addCategory(categoryToAdd, to: acronym, on: req)
        }
        for categoryToRemove in categoriesToRemove {
            if let existCategory = categories.first(where: { $0.name == categoryToRemove}) {
                try await acronym.$categories.detach(existCategory, on: req.db)
            }
        }
        return req.redirect(to: "/acronyms/\(acronymID)")
    }

    func deleteAcronymHandler(_ req: Request) async throws -> Response {
        guard let acronym = try await Acronym.find(req.parameters.get("acronymID"), on: req.db)
        else {
            throw Abort(.notFound)
        }
        try await acronym.delete(on: req.db)
        return req.redirect(to: "/")
    }
}

struct IndexContext: Encodable {
    let title: String
    let acronyms: [Acronym]?
}

struct AcronymContext: Encodable {
    let title: String
    let acronym: Acronym
    let user: User
    let categories: [Category]
}

struct UserContext: Encodable {
    let title: String
    let user: User
    let acronyms: [Acronym]
}

struct AllUserContext: Encodable {
    let title: String
    let users: [User]
}

struct AllCategoriesContext: Encodable {
    let title: String
    let categories: [Category]
}

struct CategoryContext: Encodable {
    let title: String
    let category: Category
    let acronyms: [Acronym]?
}

struct CreateAcronymContext: Encodable {
    let title = "Create An Acronym"
    let users: [User]
}

struct EditAcronymContext: Encodable {
    let title = "Edit Acronym"
    let acronym: Acronym
    let users: [User]
    let editing = true
    let categories: [Category]
}

struct CreateAcronymFormData: Content {
    let userID: UUID
    let short: String
    let long: String
    let categories: [String]?
}
