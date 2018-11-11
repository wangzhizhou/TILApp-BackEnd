//
//  Application+Testable.swift
//  App
//
//  Created by joker on 2018/10/24.
//
@testable import App
import Vapor
import Authentication


extension Application {
    static func testable(envArgs: [String]? = nil) throws -> Application {
        // 创建默认配置对象
        var config = Config.default()
        // 测试环境
        var env = Environment.testing
        // 创建默认服务对象
        var services = Services.default()
        
        if let environmentArgs = envArgs {
            env.arguments = environmentArgs
        }
        // 使用 config和env来配置服务
        try App.configure(&config, &env, &services)
        // 使用config、env和services来初始化一个应用对象
        let app = try Application(config: config, environment: env, services: services)
        // 作一些应用初始化之后要做的工作
        try App.boot(app)
        
        return app
    }
    
    static func reset() throws {
        let revertEnvironmentArgs = ["vapor", "revert", "--all", "-y"]
        try Application.testable(envArgs: revertEnvironmentArgs).asyncRun().wait()
        
        let migrateEnvironmentArgs = ["vapor", "migrate", "-y"]
        try Application.testable(envArgs: migrateEnvironmentArgs).asyncRun().wait()
    }
    
    // 因为模板函数不接收nil，所有定义一个空内容来代替
    struct EmptyContent: Content {}
    
    func sendRequest<T>(
        to path: String,
        method: HTTPMethod,
        headers: HTTPHeaders = .init(),
        body: T? = nil,
        loggedInRequest: Bool = false,
        loggedInUser: User? = nil
        ) throws -> Response where T: Content {
        var headers = headers
        if loggedInRequest || loggedInUser != nil {
            let username: String
            if let user = loggedInUser {
                username = user.username
            } else {
                username = "admin"
            }
            let credentials = BasicAuthorization(username: username, password: "password")
            
            var tokenHeaders = HTTPHeaders()
            tokenHeaders.basicAuthorization = credentials
            
            let tokenResponse = try self.sendRequest(to: "/api/users/login", method: .POST, headers:  tokenHeaders)
            
            let token = try tokenResponse.content.syncDecode(Token.self)
            headers.add(name: .authorization, value: "Bearer \(token.token)")
        }
        // 创建一个和发送到app的HTTP请求
        let request = HTTPRequest(method: method,
                                  url: URL(string: path)!,
                                  headers: headers)
        let wrappedRequest = Request(http: request, using: self)
        
        if let body = body {
            try wrappedRequest.content.encode(body)
        }
        
        // 因为app本身没有正式运行，所以这里手动进行j响应
        let responder = try self.make(Responder.self)
        return try responder.respond(to: wrappedRequest).wait()
    }
    
    func sendRequest(
        to path: String,
        method: HTTPMethod,
        headers: HTTPHeaders = .init(),
        loggedInRequest: Bool = false,
        loggedInUser: User? = nil
        ) throws -> Response {
        let emptyContent: EmptyContent? = nil
        return try sendRequest(to: path,
                               method: method,
                               headers: headers,
                               body: emptyContent,
                               loggedInRequest:loggedInRequest,
                               loggedInUser: loggedInUser)
    }
    
    func sendRequest<T>(
        to path: String,
        method: HTTPMethod,
        headers: HTTPHeaders,
        data: T,
        loggedInRequest: Bool = false,
        loggedInUser: User? = nil
        ) throws where T: Content {
        
        _ =  try self.sendRequest(to: path,
                                  method: method,
                                  headers: headers,
                                  body: data,
                                  loggedInRequest: loggedInRequest,
                                  loggedInUser: loggedInUser)
    }
    
    
    func getResponse<C, T>(
        to path: String,
        method: HTTPMethod = .GET,
        headers: HTTPHeaders = .init(),
        data: C? = nil,
        decodeTo type: T.Type,
        loggedInRequest: Bool = false,
        loggedInUser: User? = nil
        ) throws -> T where C: Content, T: Decodable {
        
        let response = try self.sendRequest(to: path,
                                            method: method,
                                            headers: headers,
                                            body: data,
                                            loggedInRequest: loggedInRequest,
                                            loggedInUser: loggedInUser)
        // 从响应数据中解析出用户数据，也即从数据库中检索出来的用户数据
        return try response.content.decode(type).wait()
    }
    
    func getResponse<T> (
        to path: String,
        method: HTTPMethod = .GET,
        headers: HTTPHeaders = .init(),
        decodeTo type: T.Type,
        loggedInRequest: Bool = false,
        loggedInUser: User? = nil
        ) throws -> T where T: Decodable {
        let emptyContent: EmptyContent? = nil
        return try self.getResponse(to: path,
                                    method: method,
                                    headers: headers,
                                    data: emptyContent,
                                    decodeTo: type,
                                    loggedInRequest: loggedInRequest,
                                    loggedInUser: loggedInUser)
    }
}
