import Fluent
import Vapor
import Gatekeeper

func routes(_ app: Application) throws {

    // MARK: Controllers
    let dataController = DataController()
    let homeController = HomeController()
    let avatarController = AvatarController()
    let pricingController = PricingController()
    let stripeWebhookController = StripeWebhookController()

    // MARK: Pages
    app.get(use: homeController.index)
    app.get("pricing", use: pricingController.index)

    app.get("terms") { req -> EventLoopFuture<View> in
        return req.view.render("terms")
    }
    app.get("privacy") { req -> EventLoopFuture<View> in
        return req.view.render("privacy")
    }

    let rateLimited = app.grouped(GatekeeperMiddleware())

    // MARK: Public API
    rateLimited.get("api", "data", use: dataController.index)
    rateLimited.get("api", "avatar.jpg", use: avatarController.index)
    
    // MARK: Legacy API
    rateLimited.get("api", "users", use: dataController.index)
    
    // MARK: Private API
    app.post("stripe", "webhook", use: stripeWebhookController.index)
    
}
