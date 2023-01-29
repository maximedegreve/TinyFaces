import Vapor
import Fluent
import StripeKit

final class StripeWebhookController {

    // stripe trigger checkout.session.completed
    func index(request: Request) async throws -> Response {

        let optionalBuffer = request.body.data
        let optionalSignature = request.headers["Stripe-Signature"].first
                
        guard let buffer = optionalBuffer, let signature = optionalSignature else {
            return Response(status: .ok)
        }
        
        let payload = Data(buffer: buffer)
        try StripeClient.verifySignature(payload: payload, header: signature, secret: Environment.stripeSecretKey)
        
        // Stripe dates come back from the Stripe API as epoch and the StripeModels convert these into swift `Date` types.
        // Use a date and key decoding strategy to successfully parse out the `created` property and snake case strpe properties.
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        decoder.keyDecodingStrategy = .convertFromSnakeCase
            
        let event = try request.content.decode(StripeEvent.self)
        
        switch (event.type, event.data?.object) {
            case (.paymentIntentSucceeded, .paymentIntent(let paymentIntent)):
                print("Payment capture method: \(paymentIntent)")
                return Response(status: .ok)
            default:
                return Response(status: .ok)
        }

    }

}
