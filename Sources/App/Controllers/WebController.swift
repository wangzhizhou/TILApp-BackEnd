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
        let context = AcronymContext(title: acronym.short, acronym: acronym, user: user)
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
        let acronymData = try req.content.decode(CreateAcronymData.self)
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
        return req.redirect(to: "/acronyms/\(acronymID)")
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
