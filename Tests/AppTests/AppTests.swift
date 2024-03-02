@testable import App
import XCTVapor

final class AppTests: XCTestCase {
    
    var app: Application!
    
    override func setUp() async throws {
        
        app = try await .testable()
    }
    
    override func tearDown() async throws {
        
        app.shutdown()
    }

    func testHelloWorld() async throws {

        try app.test(.GET, "", afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.body.string, """
            <!doctype html>
            <html lang="en">
            <head>
              <meta charset="utf-8">

              <title>Hello Vapor!</title>
            </head>

            <body>
              <h1>Hello Vapor!</h1>
            </body>
            </html>
            """)
        })

        try app.test(.GET, "hello", afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.body.string, "Hello, world!")
        })

        try app.test(.GET, "hello/joker", afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.body.string, "Hello, joker!")
        })

        try app.test(.POST, "info", beforeRequest: { req in
            let body = InfoData(name: "vapor")
            try req.content.encode(body)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.body.string, "Hello, vapor!")
        })

        try app.test(.POST, "info/json", beforeRequest: { req in
            let body = InfoData(name: "vapor")
            try req.content.encode(body)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.body.string, """
            {"request":{"name":"vapor"}}
            """)
        })
        
    }
}
