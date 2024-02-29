//
//  File.swift
//
//
//  Created by joker on 2024/2/28.
//

import Vapor
import FluentMySQLDriver

/// 配置MySQL数据库
/// - Parameter app: vapor 应用实例
///
/// 数据库服务需要使用Docker创建：
/// ```bash
/// docker run --name mysql           \
/// -e MYSQL_USER=vapor_username      \
/// -e MYSQL_PASSWORD=vapor_password  \
/// -e MYSQL_DATABASE=vapor_database  \
/// -e MYSQL_RANDOM_ROOT_PASSWORD=yes \
/// -p 3306:3306 -d mysql
/// ```
/// 使用 `docker ps`来查看运行中的容器
/// 使用 `docker rm -f mysql`强制停止并删除运行中的docker容器mysql
func configureMySQL(_ app: Application) {
    app.databases.use(
        .mysql(
            hostname: Environment.get("DATABASE_HOST") ?? "localhost",
            username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
            password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
            database: Environment.get("DATABASE_NAME") ?? "vapor_database",
            tlsConfiguration: .makePreSharedKeyConfiguration()
        ), as: .mysql)
}
