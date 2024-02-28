//
//  configure+SQLite.swift
//
//
//  Created by joker on 2024/2/28.
//

import Vapor
import FluentSQLiteDriver

/// 配置SQLite数据库
/// - Parameter app: vapor 应用实例
/// - Parameter configuration: 配置使用内存数据库，还是文件数据库，默认使用内存数据库
func configureSQLite(_ app: Application, configuration: SQLiteConfiguration = .memory) {
    app.databases.use(.sqlite(configuration), as: .sqlite)
}
