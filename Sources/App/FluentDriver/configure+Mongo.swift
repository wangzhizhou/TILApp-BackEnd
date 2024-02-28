//
//  configure+Mongo.swift
//
//
//  Created by joker on 2024/2/28.
//

import Vapor
import FluentMongoDriver

/// 配置MongoDB数据库
/// - Parameter app: vapor 应用实例
///
/// 数据库服务需要使用Docker创建：
/// ```bash
///  docker run --name mongo          \
///  -e MONOGO_INITDB_DATABASE=vapor  \
///  -p 27017:27017 -d mongo
/// ```
/// 使用 `docker ps`来查看运行中的容器
/// 使用 `docker rm -f mongo`强制停止并删除运行中的docker容器mongo
func configureMongo(_ app: Application) throws {
    app.databases.use(try .mongo(connectionString: "mongodb://localhost:27017/vapor"), as: .mongo)
}
