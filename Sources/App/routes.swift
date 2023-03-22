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
    let dashboardController = DashboardController()
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

    // MARK: Middleware
    let rateLimited = app.grouped(GatekeeperMiddleware())
    let protected = app.grouped([
        User.redirectMiddleware(path: "/authenticate")
    ])

    // MARK: License
    protected.on(.GET, "dashboard", use: dashboardController.index)
    protected.on(.GET, "license", "commercial", use: licenseController.commercial)
    protected.on(.POST, "license", "commercial", use: licenseController.commercialCalculate)
    rateLimited.on(.GET, "license", "non-commercial", use: licenseController.nonCommercial)

    // MARK: Public API
    rateLimited.on(.GET, "api", "pricing", use: pricingController.index)
    rateLimited.on(.GET, "api", "data", use: dataController.index)
    rateLimited.on(.GET, "api", "data-ai", use: dataAIController.index)
    rateLimited.on(.GET, "api", "avatar.jpg", use: avatarController.index)

    // MARK: Authentication
    rateLimited.on(.GET, "authenticate", use: authController.index)
    rateLimited.on(.POST, "authenticate", "magic", use: authController.sendMagicEmail)
    rateLimited.on(.POST, "authenticate", "confirm", use: authController.confirm)

    // MARK: Legacy API
    rateLimited.on(.GET, "users", use: dataController.index)

    // MARK: Private API
    protected.on(.GET, "admin", use: adminController.index)
    protected.on(.POST, "admin", "upload", body: .collect(maxSize: "10mb"), use: adminController.upload)
    protected.on(.PUT, "admin", ":id", use: adminController.put)
    protected.on(.DELETE, "admin", ":id", use: adminController.delete)
    protected.on(.POST, "stripe", "webhook", use: stripeWebhookController.index)

}
