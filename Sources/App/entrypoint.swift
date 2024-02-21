import Vapor
import Logging

// @main 指定命令行应用的入口类型
@main
enum Entrypoint {
    
    // 命令行应用进程运行入口
    static func main() async throws {
        
        // 获取环境变量
        var env = try Environment.detect()
        
        // 启动日志系统
        try LoggingSystem.bootstrap(from: &env)
        
        // 创建应用实例
        let app = Application(env)
        
        // 程序结束前，关闭应用
        defer { app.shutdown() }
        
        do {
            // 配置应用
            try await configure(app)
            
        } catch {
            
            // 配置失败时打印错误日志
            app.logger.report(error: error)
            
            // 抛出错误异常
            throw error
        }
        
        // 启动应用
        try await app.execute()
    }
}
