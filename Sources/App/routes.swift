import Fluent
import Vapor
import Gatekeeper

func routes(_ app: Application) throws {

    // MARK: Controllers
    let dataController = DataController()
    let homeController = HomeController()
    let avatarController = AvatarController()

    // MARK: Pages
    app.get(use: homeController.index)
    app.get("terms") { req -> EventLoopFuture<View> in
        return req.view.render("terms")
    }
    app.get("privacy") { req -> EventLoopFuture<View> in
        return req.view.render("privacy")
    }

    let rateLimited = app.grouped(GatekeeperMiddleware())

    // MARK: API
    app.get("api", "update", use: avatarController.update)

    rateLimited.get("api", "data", use: dataController.index)
    rateLimited.get("api", "avatar.jpg", use: avatarController.index)
    
    // MARK: API Legacy
    rateLimited.get("api", "users", use: dataController.index)

}
