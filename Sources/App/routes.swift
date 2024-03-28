import Fluent
import Vapor
import HTMLKitVapor

func routes(_ app: Application) throws {
    
    // 注册零散的路由，如果太多会不好维护, 路由发生变化时，需要调整的位置比较多
    if app.environment == .development {
        try scatteredRoutes(app)
    }
    // ---

    // 注册路由集合，方便模块化维护
    try app.register(collection: TodoController())
    try app.register(collection: AcronymsController())
    try app.register(collection: WebController())
    try app.register(collection: UserController())
    try app.register(collection: CategoryController())
}
