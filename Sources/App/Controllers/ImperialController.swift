//
//  ImperialController.swift
//  App
//
//  Created by joker on 2018/12/16.
//

import Vapor
import Authentication
import Imperial

struct GoogleUserInfo: Content {
    let email: String
    let name: String
}

extension Google {
    static func getUser(on req: Request) throws -> Future<GoogleUserInfo> {
        var headers = HTTPHeaders()
        headers.bearerAuthorization = try BearerAuthorization(token: req.accessToken())
        
        let googleAPIURL = "https://www.googleapis.com/oauth2/v1/userinfo?alt=json"
        
        return try req.client().get(googleAPIURL, headers: headers).map(to: GoogleUserInfo.self, { res in
            guard res.http.status == .ok else {
                if res.http.status == .unauthorized {
                    throw Abort.redirect(to: "/login-google")
                } else {
                    throw Abort(.internalServerError)
                }
            }
            return try res.content.syncDecode(GoogleUserInfo.self)
        })
    }
}

struct ImperialController: RouteCollection {
    func boot(router: Router) throws {
        
        guard let callbackURL = Environment.get("GOOGLE_CALLBACK_URL") else {
            fatalError("Callback URL not set")
        }
        
        try router.oAuth(
            from: Google.self,
            authenticate: "login-google",
            callback: callbackURL,
            scope: ["profile", "email"],
            completion: processGoogleLogin)
    }
    
    func processGoogleLogin(_ req: Request, token: String) throws -> Future<ResponseEncodable> {
        return try Google.getUser(on: req).flatMap(to: ResponseEncodable.self, { userInfo in
            return User.query(on: req).filter(\.username == userInfo.email).first().flatMap(to: ResponseEncodable.self, { foundUser in
                guard let existingUser = foundUser else {
                    let user = User(name: userInfo.name, username: userInfo.email, password: "")
                    return user.save(on: req).map(to: ResponseEncodable.self, { user in
                        try req.authenticate(user)
                        return req.redirect(to: "/")
                    })
                }
                
                try req.authenticateSession(existingUser)
                return req.future(req.redirect(to: "/"))
                
            })
        })
    }
}



