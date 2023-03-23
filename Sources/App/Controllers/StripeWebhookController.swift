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
        try StripeClient.verifySignature(payload: payload, header: signature, secret: Environment.stripeWebhookSecret)

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
    
    func portalRedirect(request: Request) async throws -> Response {
        
        let user = try request.auth.require(User.self)
        let subscription = try await user.activeSubscriptions(req: request).first

        guard subscription != nil else {
            throw Abort.redirect(to: "/dashboard")
        }
        
        let returnUrl = Environment.apiUrl + "/dashboard"

        guard let customerId = user.stripeCustomerId else {
            throw Abort.redirect(to: "/dashboard")
        }
        
        let session = try await request.stripe.portalSession.create(customer: customerId, returnUrl: returnUrl, configuration: nil, onBehalfOf: nil, expand: nil).get()
        
        guard let url = session.url else {
            throw Abort.redirect(to: "/dashboard")
        }
        
        return request.redirect(to: url)
        
    }

    func invoiceUpdate(request: Request, invoice: StripeInvoice) async throws -> Response {

        guard let stripeSubscription = invoice.$subscription else {
            return Response(status: .ok)
        }

        guard
            let productId = stripeSubscription.items?.data?.first?.plan?.product,
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
        subscription.stripeProductId = productId
        subscription.stripeStatus = status
        subscription.canceledAt = stripeSubscription.canceledAt

        try await subscription.save(on: request.db)

        return Response(status: .ok)

    }

    func checkoutCompleted(request: Request, session: StripeSession) async throws -> Response {

        let stripeSessionSubscription = try await request.stripe.sessions.retrieve(id: session.id, expand: ["subscription"]).get()

        guard let stripeSubscription = stripeSessionSubscription.$subscription else {
            Swift.print("Subscription is missing")
            return Response(status: .ok)
        }

        guard
            let currentPeriodEnd = stripeSubscription.currentPeriodEnd,
            let cancelAtPeriodEnd = stripeSubscription.cancelAtPeriodEnd,
            let status = stripeSubscription.status?.rawValue,
            let productId = stripeSubscription.items?.data?.first?.plan?.product,
            let stripeCustomerEmail = stripeSessionSubscription.customerDetails?.email,
            let stripeCustomerId = stripeSessionSubscription.customer else {
            return Response(status: .ok)
        }

        let user = try await User.createIfNotExist(db: request.db, email: stripeCustomerEmail, stripeCustomerId: stripeCustomerId)

        let userId = try user.requireID()

        let optionalSubscription = try await Subscription.query(on: request.db).filter(\.$stripeId, .equal, stripeSubscription.id).first()

        let subscription = optionalSubscription ?? Subscription()

        subscription.currentPeriodEnd = currentPeriodEnd
        subscription.cancelAtPeriodEnd = cancelAtPeriodEnd
        subscription.$user.id = userId
        subscription.stripeId = stripeSubscription.id
        subscription.stripeProductId = productId
        subscription.stripeStatus = status
        subscription.canceledAt = stripeSubscription.canceledAt

        try await subscription.save(on: request.db)

        return Response(status: .ok)

    }

}
