import Vapor
import Fluent
import StripeKit

final class StripeWebhookController {

    func index(request: Request) async throws -> HTTPResponse {

        let signature = request.headers["Stripe-Signature"]

        try StripeClient.verifySignature(payload: request.body, header: signature, secret: "whsec_1234")
        
        // Stripe dates come back from the Stripe API as epoch and the StripeModels convert these into swift `Date` types.
        // Use a date and key decoding strategy to successfully parse out the `created` property and snake case strpe properties.
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        decoder.keyDecodingStrategy = .convertFromSnakeCase
            
        let event = try decoder.decode(StripeEvent.self, from: request.body)
        
        switch (event.type, event.data?.object) {
            case (.paymentIntentSucceeded, .paymentIntent(let paymentIntent)):
                print("Payment capture method: \(paymentIntent.captureMethod?.rawValue)")
                return eventLoop.makeSucceededFuture(HTTPResponse(status: .ok))
            default:
                return HTTPResponse(status: .ok)
        }

    }

}
