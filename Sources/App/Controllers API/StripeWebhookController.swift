import Vapor
import Fluent
import StripeKit

final class StripeWebhookController {

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
            case (.checkoutSessionCompleted, .checkoutSession(let checkoutCompletion)):
                return try await checkoutCompleted(request: request, session: checkoutCompletion)
        case (.invoicePaymentSucceeded, .invoice(let invoice)):
                return try await invoiceUpdate(request: request, invoice: invoice)
            default:
                return Response(status: .ok)
        }

    }
    
    func invoiceUpdate(request: Request, invoice: StripeInvoice) async throws -> Response {
        
        guard let stripeSubscription = invoice.$subscription else {
            Swift.print("Missing subscription object")
            return Response(status: .ok)
        }
        
        guard
            let subscriptionPlanId = stripeSubscription.items?.data?.first?.plan?.id,
            let currentPeriodEnd = stripeSubscription.currentPeriodEnd,
            let cancelAtPeriodEnd = stripeSubscription.cancelAtPeriodEnd,
            let status = stripeSubscription.status?.rawValue else {
            Swift.print("Subscription items missing")
            return Response(status: .ok)
        }
        
        guard let subscription = try await Subscription.query(on: request.db).filter(\.$stripeId, .equal, stripeSubscription.id).first() else {
            Swift.print("Subscription not found")
            return Response(status: .ok)
        }
                                
        subscription.currentPeriodEnd = currentPeriodEnd
        subscription.cancelAtPeriodEnd = cancelAtPeriodEnd
        subscription.stripeId = stripeSubscription.id
        subscription.stripePlanId = subscriptionPlanId
        subscription.stripeStatus = status
        subscription.canceledAt = stripeSubscription.canceledAt
        
        try await subscription.save(on: request.db)
        
        return Response(status: .ok)

    }
    
    func checkoutCompleted(request: Request, session: StripeSession) async throws -> Response {
        
        guard let stripeSubscription = session.$subscription else {
            Swift.print("Missing subscription object")
            return Response(status: .ok)
        }
        
        guard let customerEmail = session.customerEmail else {
            Swift.print("Missing customer email")
            return Response(status: .ok)
        }
        
        guard let customerId = session.customer else {
            Swift.print("Missing client reference id")
            return Response(status: .ok)
        }
        
        guard
            let subscriptionPlanId = stripeSubscription.items?.data?.first?.plan?.id,
            let currentPeriodEnd = stripeSubscription.currentPeriodEnd,
            let cancelAtPeriodEnd = stripeSubscription.cancelAtPeriodEnd,
            let status = stripeSubscription.status?.rawValue else {
            Swift.print("Subscription items missing")
            return Response(status: .ok)
        }
        
        let user = try await User.createIfNotExist(db: request.db, email: customerEmail, stripeCustomerId: customerId)
        
        let userId = try user.requireID()
        
        let optionalSubscription = try await Subscription.query(on: request.db).filter(\.$stripeId, .equal, stripeSubscription.id).first()
                
        let subscription = optionalSubscription ?? Subscription()
                
        subscription.currentPeriodEnd = currentPeriodEnd
        subscription.cancelAtPeriodEnd = cancelAtPeriodEnd
        subscription.$user.id = userId
        subscription.stripeId = stripeSubscription.id
        subscription.stripePlanId = subscriptionPlanId
        subscription.stripeStatus = status
        subscription.canceledAt = stripeSubscription.canceledAt
        
        try await subscription.save(on: request.db)
        
        return Response(status: .ok)
        
    }

}
