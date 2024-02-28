//
//  configure+PostgreSQL.swift
//
//
//  Created by joker on 2024/2/28.
//

import Vapor
import FluentPostgresDriver

/// 配置PostgreSQL数据库
/// - Parameter app: vapor 应用实例
///
/// 数据库服务需要使用Docker创建：
/// ```bash
///  docker run --name postgres          \
///  -e POSTGRES_DB=vapor_database       \
///  -e POSTGRES_USER=vapor_username     \
///  -e POSTGRES_PASSWORD=vapor_password \
///  -p 5432:5432 -d postgres
/// ```
/// 使用 `docker ps`来查看运行中的容器
/// 使用 `docker rm -f postgres`强制停止并删除运行中的docker容器postgres
func configurePostgreSQL(_ app: Application) throws {
    app.databases.use(.postgres(configuration: .init(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? SQLPostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
        database: Environment.get("DATABASE_NAME") ?? "vapor_database",
        tls: .prefer(try .init(configuration: .clientDefault)))
    ), as: .psql)
}
