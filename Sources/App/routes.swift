import Fluent
import Vapor
import Gatekeeper

func routes(_ app: Application) throws {

    // MARK: Controllers
    let dataController = DataController()
    let adminController = AdminController()
    let avatarController = AvatarController()
    let authController = AuthenticationController()

    let pricingController = PricingController()
    let stripeWebhookController = StripeWebhookController()

    // MARK: Pages
    app.get { _ in
        return "TinyFaces API (\(app.environment.name))"
    }
    
    let rateLimited = app.grouped(GatekeeperMiddleware())

    // MARK: Public API
    rateLimited.get("pricing", use: pricingController.index)
    rateLimited.get("data", use: dataController.index)
    rateLimited.get("avatar.jpg", use: avatarController.index)
    rateLimited.post("authenticate", use: authController.authenticate)
    rateLimited.post("authenticate", "magic", use: authController.magic)

    // MARK: Legacy API
    rateLimited.get("users", use: dataController.index)
    
    // MARK: Private API
    rateLimited.get("admin", use: adminController.index)
    app.post("stripe", "webhook", use: stripeWebhookController.index)
    
}
