import Vapor
import Crypto

struct UsersController: RouteCollection {
    func boot(router: Router) throws {
        let usersGroup = router.grouped("api", "users")
        
        usersGroup.get(use: getAllHandler)
        usersGroup.get(User.parameter, use: getHandler)
        usersGroup.put(User.parameter, use: updateHandler)
        usersGroup.delete(User.parameter, use: deleteHandler)
        usersGroup.get(User.parameter, "acronyms", use: getAcronymsHandler)
        
        let basicAuthMiddleware = User.basicAuthMiddleware(using: BCryptDigest())
        let basicAuthGroup = usersGroup.grouped(basicAuthMiddleware)
        basicAuthGroup.post("login", use: login)
        
        
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenAuthGroup = usersGroup.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        tokenAuthGroup.post(User.self, use: createHandler)
        
    }
    func login(_ req: Request) throws -> Future<Token> {
        let user = try req.requireAuthenticated(User.self)
        let token = try Token.generate(for: user)
        return token.save(on: req)
    }
    
    func createHandler(_ req: Request, user: User) throws -> Future<User.Public> {
        user.password = try BCrypt.hash(user.password)
        return user.save(on: req).convertToPublic()
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[User.Public]> {
        return User.query(on: req).decode(data: User.Public.self).all()
    }
    
    func getHandler(_ req: Request) throws -> Future<User.Public> {
        return try req.parameters.next(User.self).convertToPublic()
    }
    
    func updateHandler(_ req: Request) throws -> Future<User.Public> {
        return try flatMap(to: User.Public.self, req.parameters.next(User.self), req.content.decode(User.self)) { (user, updatedUser) -> Future<User.Public> in
            
            user.name = updatedUser.name
            user.username = updatedUser.username
            
            return user.save(on: req).convertToPublic()
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
