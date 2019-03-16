import Vapor
import Fluent
import Authentication

struct AcronymCreateData: Content {
    let short: String
    let long: String
}

struct AcronymsController: RouteCollection {
    func boot(router: Router) throws {
        let routeGroup = router.grouped("api", "acronyms")
        
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let protectd = routeGroup.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        protectd.post(AcronymCreateData.self, use: createHandler)
        protectd.put(Acronym.parameter, use: updateHandler)
        protectd.delete(Acronym.parameter, use: deleteHandler)
        protectd.post(Acronym.parameter,"categories", Category.parameter, use: addCategoriesHandler)
        protectd.delete(Acronym.parameter, "categories", Category.parameter, use: removeCategoriesHandler)
        
        routeGroup.get(use: getAllHandler)
        routeGroup.get(Acronym.parameter, use: getHandler)
        routeGroup.get("search", use: searchHandler)
        routeGroup.get("first", use: firstHandler)
        routeGroup.get("sorted", use: sortedHandler)
        routeGroup.get(Acronym.parameter, "user", use: getUserHandler)
        routeGroup.get(Acronym.parameter, "categories", use: getCagtegoriesHandler)
    }
    
    func createHandler(_ req: Request, data: AcronymCreateData) throws -> Future<Acronym> {
        let user = try req.requireAuthenticated(User.self)
        let acronym = try Acronym(short: data.short, long: data.long, userID: user.requireID())
        return acronym.save(on: req)
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[Acronym]> {
        return Acronym.query(on: req).all()
    }

    func getHandler(_ req: Request) throws -> Future<Acronym> {
        return try req.parameters.next(Acronym.self)
    }

    func updateHandler(_ req: Request) throws -> Future<Acronym> {
        return try flatMap(to: Acronym.self, req.parameters.next(Acronym.self), req.content.decode(AcronymCreateData.self)) { (acronym, updateData) -> Future<Acronym> in
            acronym.short = updateData.short
            acronym.long = updateData.long
            
            let user = try req.requireAuthenticated(User.self)
            acronym.userID = try user.requireID()
            
            return acronym.save(on: req)
        }
    }

    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Acronym.self)
            .delete(on: req)
            .transform(to: HTTPStatus.noContent)
    }

    func searchHandler(_ req: Request) throws -> Future<[Acronym]> {
        guard let searchItem = req.query[String.self, at: "term"] else {
            throw Abort(.badRequest)
        }
        return Acronym.query(on: req).group(.or) { (or) in
            or.filter(\.short == searchItem)
            or.filter(\.long == searchItem)
            }
            .all()
    }
    
    func firstHandler(_ req: Request) throws -> Future<Acronym> {
        
        // 使用unwrap可以简化下面的一坨逻辑
        return Acronym.query(on: req).first().unwrap(or: Abort(.notFound))
        
//        // 不使用unwrap的逻辑实现
//        return Acronym.query(on: req).first().map(to: Acronym.self) { (acronym)  in
//            guard let acronym = acronym else {
//                throw Abort(.notFound)
//            }
//            return acronym
//        }
    }
    
    func sortedHandler(_ req: Request) throws -> Future<[Acronym]> {
        return Acronym.query(on: req).sort(\.short, .ascending).all()
    }
    
    func getUserHandler(_ req: Request) throws -> Future<User> {
        return try req.parameters.next(Acronym.self).flatMap(to: User.self) { (acronym) -> Future<User> in
            return acronym.user.get(on: req)
        }
    }
    
    func addCategoriesHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try flatMap(to: HTTPStatus.self,
                           req.parameters.next(Acronym.self),
                           req.parameters.next(Category.self)) { (acronym, category) in
                            return acronym
                                .categories
                                .attach(category, on: req)
                                .transform(to: HTTPStatus.created)
        }
    }
    
    func removeCategoriesHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try flatMap(to: HTTPStatus.self, req.parameters.next(Acronym.self), req.parameters.next(Category.self)) { (acronym, category) in
            return  acronym.categories.detach(category, on: req).transform(to: HTTPStatus.noContent)
        }
    }
    
    func getCagtegoriesHandler(_ req: Request) throws -> Future<[Category]> {
        
        return try req.parameters.next(Acronym.self).flatMap(to: [Category].self) { (acronym) in
            return try acronym.categories.query(on: req).all()
        }
    }
}
