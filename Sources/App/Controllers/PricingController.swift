import Vapor
import Fluent

final class PricingController {

    struct PricingResponse: Encodable {
        var tableId: String
        var publishableKey: String
        var clientReferenceId: String
    }
    
    func index(request: Request) async throws -> PricingResponse {
        return PricingResponse(tableId: Environment.stripePricingTableId, publishableKey: Environment.stripePublishableKey, clientReferenceId: "")
    }

}
