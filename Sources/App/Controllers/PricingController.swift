import Vapor
import Fluent

final class PricingController {

    func index(request: Request) async throws -> View {

        struct PricingContext: Encodable {
            var tableId: String
            var publishableKey: String
            var clientReferenceId: String
        }

        return try await request.view.render("pricing", PricingContext(tableId: Environment.stripePricingTableId, publishableKey: Environment.stripePublishableKey, clientReferenceId: ""))

    }

}
