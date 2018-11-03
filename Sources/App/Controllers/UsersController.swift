import Vapor

struct UsersController: RouteCollection {
    func boot(router: Router) throws {
        let usersGroup = router.grouped("api", "users")
        usersGroup.post(User.self, use: createHandler)
        usersGroup.get(use: getAllHandler)
        usersGroup.get(User.parameter, use: getHandler)
        usersGroup.put(User.parameter, use: updateHandler)
        usersGroup.delete(User.parameter, use: deleteHandler)
        
        usersGroup.get(User.parameter, "acronyms", use: getAcronymsHandler)
        
    }
    
    
    func createHandler(_ req: Request, user: User) throws -> Future<User> {
        return user.save(on: req)
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[User]> {
        return User.query(on: req).all()
    }
    
    func getHandler(_ req: Request) throws -> Future<User> {
        return try req.parameters.next(User.self)
    }
    
    func updateHandler(_ req: Request) throws -> Future<User> {
        return try flatMap(to: User.self, req.parameters.next(User.self), req.content.decode(User.self)) { (user, updatedUser) -> Future<User> in
            
            user.name = updatedUser.name
            user.username = updatedUser.username
            
            return user.save(on: req)
        }
    }
    
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(User.self)
            .delete(on: req)
            .transform(to: HTTPStatus.noContent)
    }
    
    func getAcronymsHandler(_ req: Request) throws -> Future<[Acronym]> {
        
        return try req.parameters.next(User.self).flatMap(to: [Acronym].self) { (user) -> Future<[Acronym]> in
            return try user.acronyms.query(on: req).all()
        }
    }
    
}