import Vapor
import Crypto
import Fluent
import JWT

final class DashboardController {

    func index(request: Request) async throws -> View {

        struct DashboardContext: Encodable {
            var subscription: Subscription?
        }

        let user = try request.auth.require(User.self)
        let subscription = try await user.activeSubscriptions(req: request).first

        return try await request.view.render("dashboard", DashboardContext(subscription: subscription))
    }

}
