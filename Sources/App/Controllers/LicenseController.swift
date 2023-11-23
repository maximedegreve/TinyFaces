import Vapor
import Fluent

struct PriceBracket: Content {
    var maxPeople: Int
    var price: Int
}

final class LicenseController {

    let prices = [
        PriceBracket(maxPeople: 3, price: 3),
        PriceBracket(maxPeople: 10, price: 10),
        PriceBracket(maxPeople: 25, price: 25),
        PriceBracket(maxPeople: 50, price: 50),
        PriceBracket(maxPeople: 100, price: 100),
        PriceBracket(maxPeople: 150, price: 150),
        PriceBracket(maxPeople: 250, price: 250),
        PriceBracket(maxPeople: 500, price: 500),
        PriceBracket(maxPeople: 750, price: 750),
        PriceBracket(maxPeople: 1000, price: 1000),
        PriceBracket(maxPeople: 1250, price: 2500),
        PriceBracket(maxPeople: 1500, price: 3000),
        PriceBracket(maxPeople: 1750, price: 3500),
        PriceBracket(maxPeople: 2000, price: 4000),
        PriceBracket(maxPeople: 2500, price: 7500),
        PriceBracket(maxPeople: 3000, price: 9000),
        PriceBracket(maxPeople: 4000, price: 12000),
        PriceBracket(maxPeople: 5000, price: 15000),
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
