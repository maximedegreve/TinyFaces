import Fluent
import Vapor
import Gatekeeper

func routes(_ app: Application) throws {

    // MARK: Controllers
    let dataController = DataController()
    let adminController = AdminController()
    let avatarController = AvatarController()
    let pricingController = PricingController()
    let stripeWebhookController = StripeWebhookController()

    // MARK: Pages
    app.get { _ in
        return "TinyFaces API (\(app.environment.name))"
    }
    
    app.get("pricing", use: pricingController.index)

    let rateLimited = app.grouped(GatekeeperMiddleware())

    // MARK: Public API
    rateLimited.get("api", "data", use: dataController.index)
    rateLimited.get("api", "avatar.jpg", use: avatarController.index)
    
    // MARK: Legacy API
    rateLimited.get("api", "users", use: dataController.index)
    
    // MARK: Private API
    app.post("stripe", "webhook", use: stripeWebhookController.index)
    
}
