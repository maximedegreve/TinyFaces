import Vapor
import Fluent

struct PriceBracket: Content {
    var maxPeople: Int
    var price: Int
}

final class LicenseController {

    let prices = [
        PriceBracket(maxPeople: 3, price: 60),
        PriceBracket(maxPeople: 10, price: 160),
        PriceBracket(maxPeople: 25, price: 380),
        PriceBracket(maxPeople: 50, price: 980),
        PriceBracket(maxPeople: 100, price: 1152),
        PriceBracket(maxPeople: 150, price: 1296),
        PriceBracket(maxPeople: 250, price: 1584),
        PriceBracket(maxPeople: 500, price: 2112),
        PriceBracket(maxPeople: 750, price: 2688),
        PriceBracket(maxPeople: 1000, price: 3264),
        PriceBracket(maxPeople: 1250, price: 3888),
        PriceBracket(maxPeople: 1500, price: 4560),
        PriceBracket(maxPeople: 1750, price: 5280),
        PriceBracket(maxPeople: 2000, price: 6240),
        PriceBracket(maxPeople: 2500, price: 7200)
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
        
        let url = try await request.stripe.sessions.create(cancelUrl: returnUrl, paymentMethodTypes: [.card], successUrl: returnUrl, customerEmail: user.email, lineItems: lineItems, mode: .subscription).get()

        return try await request.view.render("license-calculation", CommercialContext(price: bracket.price, contact: false, paymentUrl: url.url))

    }

    func nonCommercial(request: Request) throws -> EventLoopFuture<View> {
        return request.view.render("license-non-commercial")
    }

}
