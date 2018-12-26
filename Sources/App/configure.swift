import FluentPostgreSQL
import Vapor
import Leaf
import Authentication

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register providers first
    try services.register(FluentPostgreSQLProvider())
    try services.register(AuthenticationProvider())

    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    /// middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    middlewares.use(FileMiddleware.self) //
    middlewares.use(SessionsMiddleware.self)
    services.register(middlewares)


    let databaseName: String
    let databasePort: Int
    
    if(env == .testing) {
        databaseName = "vapor-test"
        if let testPort = Environment.get("DATABASE_PORT") {
            databasePort = Int(testPort) ?? 5433
        } else {
            databasePort = 5433
        }
    } else {
        databaseName = Environment.get("DATABASE_NAME") ?? "vapor"
        databasePort = 5432
    }
    
    let username = Environment.get("DATABASE_USERNAME") ?? "vapor"
    let password = Environment.get("DATABASE_PASSWORD") ?? "password"
    let hostname = Environment.get("DATABASE_HOSTNAME") ?? "localhost"
    
    /// Register the configured SQLite database to the database config.
    let databaseConfig = PostgreSQLDatabaseConfig(hostname: hostname,
                                                  port: databasePort,
                                                  username: username,
                                                  database: databaseName,
                                                  password: password)
    let database = PostgreSQLDatabase(config: databaseConfig)
    
    var databases = DatabasesConfig()
    databases.add(database: database, as: .psql)
    services.register(databases)

    /// Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: User.self, database: .psql)
    migrations.add(model: Token.self, database: .psql)
    migrations.add(model: Acronym.self, database: .psql)
    migrations.add(model: Category.self, database: .psql)
    migrations.add(model: AcronymCategoryPivot.self, database: .psql)
    switch env {
    case .development, .testing:
        migrations.add(migration: AdminUser.self, database: .psql)
    default:
        break
    }
    migrations.add(migration: AddTwitterURLToUser.self, database: .psql)
    migrations.add(migration: MakeCategoriesUnique.self, database: .psql)
    services.register(migrations)

    // 添加Fluent命令到CommandConfig中，可以使用字符串作为标识符执行"revert"命令和"migrate"命令
    var commandConfig  = CommandConfig.default()
    commandConfig.useFluentCommands()
    services.register(commandConfig)
    
    try services.register(LeafProvider())
    config.prefer(LeafRenderer.self, for: ViewRenderer.self)
    config.prefer(MemoryKeyedCache.self, for: KeyedCache.self)
}
