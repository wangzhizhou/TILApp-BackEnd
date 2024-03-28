import Vapor
import Fluent
import Leaf

public func configure(_ app: Application) async throws {
    
    // 配置中间件，使用`Public/`目录进行文件服务
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    // 设置日志级别
    app.logger.logLevel = .debug
    if app.environment == .production {
        app.logger.logLevel = .info
    }

    // 配置使用的数据库连接参数
    try configurePostgreSQL(app)
    // configureSQLite(app, configuration: .memory)
    // configureSQLite(app, configuration: .file("db.sqlite"))
    // configureMySQL(app)
    // try configureMongo(app)


    // 关联数据模型和数据库表
    app.migrations.add(CreateTodo())
    app.migrations.add(CreateUser())
    app.migrations.add(CreateAcronym())
    app.migrations.add(CreateCategory())
    app.migrations.add(CreateAcronymCategoryPivot())
    
    // 触发数据库表创建
    try await app.autoMigrate()

    // 配置使用Leaf模板引擎，引擎默认使用Resources/Views/*.leaf模型文件
    app.views.use(.leaf)

    // 注册路由
    try routes(app)
}
