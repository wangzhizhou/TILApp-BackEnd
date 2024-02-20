@testable import App
import XCTVapor

final class AppTests: XCTestCase {

    func testHelloWorld() async throws {

        let app = Application(.testing)
        defer { app.shutdown() }
        try await configure(app)

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

        try await app.test(.POST, "info", beforeRequest: { req async throws in 
            let body = InfoData(name: "vapor")
            try req.content.encode(body)
        }, afterResponse: { res in 
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.body.string, "Hello, vapor!")
        })

        try await app.test(.POST, "info/json", beforeRequest: { req async throws in 
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
