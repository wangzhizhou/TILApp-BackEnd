import Vapor
import Fluent

struct AcronymsController: RouteCollection {
    func boot(router: Router) throws {
        let routeGroup = router.grouped("api", "acronyms")
        
        routeGroup.post(Acronym.self,use: createHandler)
        routeGroup.get(use: getAllHandler)
        routeGroup.get(Acronym.parameter, use: getHandler)
        routeGroup.put(Acronym.parameter, use: updateHandler)
        routeGroup.delete(Acronym.parameter, use: deleteHandler)
        routeGroup.get("search", use: searchHandler)
        routeGroup.get("first", use: firstHandler)
        routeGroup.get("sorted", use: sortedHandler)
        routeGroup.get(Acronym.parameter, "user", use: getUserHandler)
        
        routeGroup.post(Acronym.parameter,"categories", Category.parameter, use: addCategoriesHandler)
        routeGroup.get(Acronym.parameter, "categories", use: getCagtegoriesHandler)
        routeGroup.delete(Acronym.parameter, "categories", Category.parameter, use: removeCategoriesHandler)
    }
    
    func createHandler(_ req: Request, acronym: Acronym) throws -> Future<Acronym> {
        return acronym.save(on: req)
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[Acronym]> {
        return Acronym.query(on: req).all()
    }

    func getHandler(_ req: Request) throws -> Future<Acronym> {
        return try req.parameters.next(Acronym.self)
    }

    func updateHandler(_ req: Request) throws -> Future<Acronym> {
        return try flatMap(to: Acronym.self, req.parameters.next(Acronym.self), req.content.decode(Acronym.self)) { (acronym, updateAcronym) -> Future<Acronym> in
            acronym.short = updateAcronym.short
            acronym.long = updateAcronym.long
            acronym.userID = updateAcronym.userID
            
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
        return Acronym.query(on: req).first().map(to: Acronym.self) { (acronym)  in
            guard let acronym = acronym else {
                throw Abort(.notFound)
            }
            return acronym
        }
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
