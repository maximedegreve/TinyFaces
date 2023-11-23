import Vapor
import Fluent

struct PriceBracket: Content {
    var maxPeople: Int
    var price: Int
}

final class LicenseController {

    let prices = [
        PriceBracket(maxPeople: 1000, price: 1),
        PriceBracket(maxPeople: 2000, price: 2),
        PriceBracket(maxPeople: 200000, price: 3),
    ]

    func commercial(request: Request) async throws -> View {

        struct CommercialContext: Encodable {
            var prices: [PriceBracket]
        }

        return try await request.view.render("license-commercial", CommercialContext(prices: prices))

    }
    
    func commercialLicenseDoc(request: Request) async throws -> View {
        
        let user = try request.auth.require(User.self)
        let subscription = try await user.activeSubscriptions(req: request).first

        guard subscription != nil else {
            throw Abort.redirect(to: "/dashboard")
        }
        
        return try await request.view.render("license-commercial-doc")

    }

    func commercialCalculate(request: Request) async throws -> View {

        struct RequestData: Error, Content {
            var total: String?
        }

        let requestData = try request.content.decode(RequestData.self)
        let user = try request.auth.require(User.self)

        struct CommercialContext: Encodable {
            var price: Int?
            var contact: Bool?
            var paymentUrl: String?
        }

        if let total = requestData.total, total == "more" {
            return try await request.view.render("license-calculation", CommercialContext(price: nil, contact: true, paymentUrl: nil))
        }

        guard let total = requestData.total, let totalInt = Int(total) else {
            return try await commercial(request: request)
        }

        let optionalBracket = prices.first { e in
            e.maxPeople == totalInt
        }

        guard let bracket = optionalBracket else {
            return try await commercial(request: request)
        }
        
        let returnUrl = Environment.apiUrl + "/dashboard"
        let lineItems = [
            [
                "price": Environment.stripePrice,
                "quantity": bracket.maxPeople
            ]
        ]
        
        var customerId = user.stripeCustomerId
        
        if customerId == nil {
            customerId = try await request.stripe.customers.create(email: user.email).get().id
        }
        
        user.stripeCustomerId = customerId
        try await user.save(on: request.db)
        
        let url = try await request.stripe.sessions.create(cancelUrl: returnUrl, paymentMethodTypes: [.card], successUrl: returnUrl, customer: customerId, lineItems: lineItems, mode: .subscription).get()

        return try await request.view.render("license-calculation", CommercialContext(price: bracket.price, contact: false, paymentUrl: url.url))

    }

    func nonCommercial(request: Request) throws -> EventLoopFuture<View> {
        return request.view.render("license-non-commercial")
    }

}
