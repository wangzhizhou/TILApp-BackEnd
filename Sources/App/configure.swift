import NIOSSL
import Fluent
import FluentPostgresDriver
import Leaf
import Vapor

public func configure(_ app: Application) async throws {
    
    // 配置中间件，使用`Public/`目录进行文件服务
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    // 设置日志级别
    app.logger.logLevel = .debug
    
    // 配置使用的数据库连接参数
    // 数据库服务需要使用Docker创建：
    // ```bash
    //  docker run --name postgres          \
    //  -e POSTGRES_DB=vapor_database       \
    //  -e POSTGRES_USER=vapor_username     \
    //  -e POSTGRES_PASSWORD=vapor_password \
    //  -p 5432:5432 -d postgres
    // ```
    // 使用 `docker ps`来查看运行中的容器
    // 使用 `docker rm -f postgres`强制停止并删除运行中的docker容器postgres
    app.databases.use(DatabaseConfigurationFactory.postgres(configuration: .init(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? SQLPostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
        database: Environment.get("DATABASE_NAME") ?? "vapor_database",
        tls: .prefer(try .init(configuration: .clientDefault)))
    ), as: .psql)

    // 关联数据模型和数据库表
    app.migrations.add(CreateTodo())
    app.migrations.add(CreateAcronym())
    
    // 触发数据库表创建
    try await app.autoMigrate()

    // 配置使用Leaf模板引擎，引擎默认使用Resources/Views/*.leaf模型文件
    app.views.use(.leaf)

    // 注册路由
    try routes(app)
}
