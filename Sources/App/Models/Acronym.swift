import Fluent

// Fluent 数据模型需要是class， 并遵循Model协议，支持数据模型和数据库表字段名映射描述，final 禁止数据模型被子类继承
final class Acronym: Model {
    
    // 定义数据库表名称
    static let schema = "acronyms"
    
    // 指定id为数据表的主键
    @ID
    var id: UUID?
    
    // 指定表字段名: short
    @Field(key: "short")
    var short: String
    
    // 指定表字段名: long
    @Field(key: "long")
    var long: String
    
    @Parent(key: "userID")
    var user: User
    
    @Siblings(through: AcronymCategoryPivot.self, from: \.$acronym, to: \.$category)
    var categories: [Category]
    
    // 初始化数据模型
    init(id: UUID? = nil, short: String, long: String, userID: User.IDValue) {
        self.id = id
        self.short = short
        self.long = long
        self.$user.id = userID
    }
    
    // 初始化一个空的数据模型，Fluent内部使用
    init() {}
}

import Vapor

// 支持多种格式编解码, Content 是 Vapor 对 Codable 协议的包装
extension Acronym: Content {}
