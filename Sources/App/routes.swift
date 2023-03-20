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
    let licenseController = LicenseController()
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

    // MARK: License
    app.on(.GET, "license", "commercial", use: licenseController.commercial)
    app.on(.GET, "license", "non-commercial", use: licenseController.nonCommercial)

    let rateLimited = app.grouped(GatekeeperMiddleware())

    // MARK: Public API
    rateLimited.on(.GET, "api", "pricing", use: pricingController.index)
    rateLimited.on(.GET, "api", "data", use: dataController.index)
    rateLimited.on(.GET, "api", "data-ai", use: dataAIController.index)
    rateLimited.on(.GET, "api", "avatar.jpg", use: avatarController.index)
    rateLimited.on(.POST, "api", "authenticate", use: authController.authenticate)
    rateLimited.on(.POST, "api", "authenticate", "magic", use: authController.magic)

    // MARK: Legacy API
    rateLimited.on(.GET, "users", use: dataController.index)

    // MARK: Private API
    app.on(.GET, "admin", use: adminController.index)
    app.on(.POST, "admin", "upload", body: .collect(maxSize: "10mb"), use: adminController.upload)
    app.on(.PUT, "admin", ":id", use: adminController.put)
    app.on(.DELETE, "admin", ":id", use: adminController.delete)
    app.on(.POST, "stripe", "webhook", use: stripeWebhookController.index)

}
