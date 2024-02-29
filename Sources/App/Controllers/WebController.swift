//
//  WebController.swift
//
//
//  Created by joker on 3/1/24.
//

import Vapor


struct WebController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        
        routes.get { req async throws in
            try await req.view.render("index", ["title": "Hello Vapor!"])
        }
    }
}
