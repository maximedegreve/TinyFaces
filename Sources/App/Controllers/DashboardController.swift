import Vapor
import Crypto
import Fluent
import JWT

final class DashboardController {
        
    func index(request: Request) async throws -> View {
        try request.auth.require(User.self)
        return try await request.view.render("dashboard")
    }
    
}
