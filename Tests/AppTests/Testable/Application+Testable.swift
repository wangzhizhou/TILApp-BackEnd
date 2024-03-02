//
//  Application+Testable.swift
//
//
//  Created by joker on 3/2/24.
//

import Vapor
import App

extension Application {
    
    static func testable() async throws -> Application {
        
        let app = Application(.testing)
        
        try await configure(app)
        
        try await app.autoRevert()
        
        try await app.autoMigrate()
        
        return app
    }
}
