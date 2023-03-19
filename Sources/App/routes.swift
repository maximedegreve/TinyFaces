import Fluent
import Vapor
import Gatekeeper

func routes(_ app: Application) throws {

    // MARK: Controllers
    let dataController = DataController()
    let dataAIController = DataAIController()
    let adminController = AdminController()
    let avatarController = AvatarController()
    let homeController = HomeController()
    let authController = AuthenticationController()

    let pricingController = PricingController()
    let stripeWebhookController = StripeWebhookController()

    // MARK: Pages

    app.get(use: homeController.index)
    app.get("terms") { req -> EventLoopFuture<View> in
        return req.view.render("terms")
    }
    
    app.get("privacy") { req -> EventLoopFuture<View> in
        return req.view.render("privacy")
    }
    
    let rateLimited = app.grouped(GatekeeperMiddleware())

    // MARK: Public API
    rateLimited.get("pricing", use: pricingController.index)
    rateLimited.get("data", use: dataController.index)
    rateLimited.get("data-ai", use: dataAIController.index)
    rateLimited.get("avatar.jpg", use: avatarController.index)
    rateLimited.post("authenticate", use: authController.authenticate)
    rateLimited.post("authenticate", "magic", use: authController.magic)

    // MARK: Legacy API
    rateLimited.get("users", use: dataController.index)
    
    // MARK: Private API
    app.on(.GET, "admin", use: adminController.index)
    app.on(.POST, "admin", "upload", body: .collect(maxSize: "10mb"), use: adminController.upload)
    app.on(.PUT, "admin", ":id", use: adminController.put)
    app.on(.DELETE, "admin", ":id", use: adminController.delete)
    app.post("stripe", "webhook", use: stripeWebhookController.index)
    
}
