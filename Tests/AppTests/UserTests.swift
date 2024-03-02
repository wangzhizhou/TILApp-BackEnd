//
//  UserTests.swift
//
//
//  Created by joker on 3/2/24.
//

@testable import App
import XCTVapor

final class UserTests: XCTestCase {
    
    let usersName = "Alice"
    
    let usersUsername = "alice"
    
    let usersURI = "api/users"
    
    var app: Application!
    
    override func setUp() async throws {
        
        app = try await .testable()
    }
    
    override func tearDown() async throws {
        
        app.shutdown()
    }
    
    func testUsersCanBeRetrievedFromAPI() async throws {
        
        let user = try await User.create(name: usersName, username: usersUsername, on: app.db)
        
        _ = try await User.create(on: app.db)
        
        try app.test(.GET, usersURI) { response in
            
            XCTAssertEqual(response.status, .ok)
            
            let users = try response.content.decode([User].self)
            
            XCTAssertEqual(users.count, 2)
            XCTAssertEqual(users[0].name, usersName)
            XCTAssertEqual(users[0].username, usersUsername)
            XCTAssertEqual(users[0].id, user.id)
        }
        
    }
    
    func testUserCanBeSavedWithAPI() async throws {
        
        let user = User(name: usersName, username: usersUsername)
        
        try app.test(.POST, usersURI, beforeRequest: { request in
            
            try request.content.encode(user)
            
        }, afterResponse: { response in
            
            let receivedUser = try response.content.decode(User.self)
            
            XCTAssertEqual(response.status, .ok)
            XCTAssertEqual(receivedUser.name, usersName)
            XCTAssertEqual(receivedUser.username, usersUsername)
            XCTAssertNotNil(receivedUser.id)
            
            try app.test(.GET, usersURI) { response in
                
                let users = try response.content.decode([User].self)
                
                XCTAssertEqual(users.count, 1)
                XCTAssertEqual(users[0].name, usersName)
                XCTAssertEqual(users[0].username, usersUsername)
                XCTAssertEqual(users[0].id, receivedUser.id)
            }
        })
    }
    
    func testGettingASingleUserFromAPI() async throws {
        
        let user = try await User.create(name: usersName, username: usersUsername, on: app.db)
        
        try app.test(.GET, "\(usersURI)/\(user.id!)") { response in
            
            let receivedUser = try response.content.decode(User.self)
            
            XCTAssertEqual(response.status, .ok)
            XCTAssertEqual(receivedUser.name, usersName)
            XCTAssertEqual(receivedUser.username, usersUsername)
            XCTAssertEqual(receivedUser.id, user.id)
            
        }
    }
    
    func testGettingAUserAcronymsFromAPI() async throws {
        
        let user = try await User.create(on: app.db)
        
        let acronymShort = "OMG"
        
        let acronymLong = "Oh My God"
        
        let acronym1 = try await Acronym.create(
            short: acronymShort,
            long: acronymLong,
            user: user,
            on: app.db)
        
        let _ = try await Acronym.create(
            short: "LOL",
            long: "Laugh Out Loud",
            user: user,
            on: app.db)
        
        try app.test(.GET, "\(usersURI)/\(user.id!)/acronyms") { response in
            
            let acronyms = try response.content.decode([Acronym].self)
            
            XCTAssertEqual(response.status, .ok)
            XCTAssertEqual(acronyms.count, 2)
            XCTAssertEqual(acronyms[0].id, acronym1.id)
            XCTAssertEqual(acronyms[0].short, acronym1.short)
            XCTAssertEqual(acronyms[0].long, acronym1.long)
        }
    }
}
