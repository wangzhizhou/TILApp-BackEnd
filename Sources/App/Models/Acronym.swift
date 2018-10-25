import Vapor
import FluentPostgreSQL

// 负责对数据的编解码存储，例如：持久化
final class Acronym: Codable {
    var id: Int?
    var short: String
    var long: String
    
    // 一个用户创建一个缩略语
    var userID: User.ID
    
    init(short: String, long: String, userID: User.ID) {
        self.short = short
        self.long = long
        self.userID = userID
    }
}

// 在数据库中保存模型
extension Acronym: PostgreSQLModel {}

// 在数据库中创建表及外键约束, sqlite不支持外键约束，之后考虑使用postgreSQL
extension Acronym: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        
        // 创建Acronym在数据库中的表
        return Database.create(self, on: connection) { (builder) in
            
            // 添加Acronym所有属性到表中
            try addProperties(to: builder)
            
            // 这一句添加了Acronym.userID到User.id的外键约束
            builder.reference(from: \.userID, to: \User.id)
        }
    }
}

// 负责在各种数据格式间转换
extension Acronym: Content {}

// 使可以作为请求参数
extension Acronym: Parameter {}

// 获取父关系数据
extension Acronym {
    var user: Parent<Acronym, User> {
        return parent(\.userID)
    }
}

// 获取兄弟关系数据
extension Acronym {
    var categories: Siblings<Acronym, Category, AcronymCategoryPivot> {
        return siblings()
    }
}
