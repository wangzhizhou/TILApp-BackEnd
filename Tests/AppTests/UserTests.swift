@testable import App
import XCTest
import Vapor
import FluentPostgreSQL

final class UserTests: XCTestCase {
    
    let usersName = "Alice"
    let usersUsername = "alice"
    let usersURI = "/api/users/"
    var app: Application!
    var conn: PostgreSQLConnection!
    
    override func setUp() {
        // 重置数据库
        try! Application.reset()
        // 可测试
        app = try! Application.testable()
        // 创建一个app到PostgreSQL数据库的连接，表示app使用PostgreSQL数据库连接成功
        conn = try! app.newConnection(to: .psql).wait()
    }
    
    override func tearDown() {
        // 关闭对数据库的连接，停止使用数据库
        conn.close()
    }
    
    func testUsersCanBeRetrievedFromAPI() throws {
        
        // 创建两个测试用户数据
        let user = try User.create(name: usersName,
                                   username: usersUsername,
                                   on: conn)
        _ = try User.create(on: conn)
        
        // 发请求并获得响应
        let users = try app.getResponse(to: usersURI, decodeTo: [User.Public].self)
        
        // 进行验证
        XCTAssertEqual(users.count, 3)
        XCTAssertEqual(users[1].name, usersName)
        XCTAssertEqual(users[1].username, usersUsername)
        XCTAssertEqual(users[1].id, user.id)
    }
    
    func testUserCanBeSavedWithAPI() throws {
        
        let user = User(name: usersName, username: usersUsername, password: "password")
        
        let receivedUser = try app.getResponse(to: usersURI,
                                               method: .POST,
                                               headers: ["Content-Type":"application/json"],
                                               data: user,
                                               decodeTo: User.Public.self,
                                               loggedInRequest: true)
        
        XCTAssertEqual(receivedUser.name, usersName)
        XCTAssertEqual(receivedUser.username, usersUsername)
        XCTAssertNotNil(receivedUser.id)
        
        let users = try app.getResponse(to: usersURI,
                                        decodeTo: [User.Public].self)
        
        XCTAssertEqual(users.count, 2)
        XCTAssertEqual(users[1].name, usersName)
        XCTAssertEqual(users[1].username, usersUsername)
        XCTAssertEqual(users[1].id, receivedUser.id)
    }
    
    func testGettingASingleUserFromTheAPI() throws {
        
        let user = try User.create(name: usersName, username: usersUsername, on: conn)
        
        let receivedUser = try app.getResponse(to: "\(usersURI)\(user.id!)", decodeTo: User.Public.self)
        
        XCTAssertEqual(receivedUser.name, usersName)
        XCTAssertEqual(receivedUser.username, usersUsername)
        XCTAssertEqual(receivedUser.id, user.id)
    }
    
    func testGettingAUsersAcronymsFromTheAPI() throws {
        let user = try User.create(on: conn)
        
        let acronymShort = "OMG"
        let acronymLong = "Oh My God"
        
        let acronym1 = try Acronym.create(short: acronymShort, long: acronymLong, user: user, on: conn)
        _ = try Acronym.create(short: "LOL", long: "Laugh Out Loud", user: user, on: conn)
        
        let acronyms = try app.getResponse(to: "\(usersURI)\(user.id!)/acronyms", decodeTo: [Acronym].self)
        
        XCTAssertEqual(acronyms.count, 2)
        XCTAssertEqual(acronyms[0].id, acronym1.id)
        XCTAssertEqual(acronyms[0].short, acronymShort)
        XCTAssertEqual(acronyms[0].long, acronymLong)
    }
    
    static let allTests = [
        ("testUsersCanBeRetrievedFromAPI", testUsersCanBeRetrievedFromAPI),
        ("testUserCanBeSavedWithAPI", testUserCanBeSavedWithAPI),
        ("testGettingASingleUserFromTheAPI", testGettingASingleUserFromTheAPI),
        ("testGettingAUsersAcronymsFromTheAPI", testGettingAUsersAcronymsFromTheAPI)
    ]
}
