import Fluent
import Vapor

func routes(_ app: Application) throws {

    // MARK: Controllers
    let dataController = DataController()
    let homeController = HomeController()
    let addController = AddController()
    let facebookController = FacebookController()
    let statusController = StatusController()
    let avatarController = AvatarController()

    // MARK: Pages
    app.get(use: homeController.index)
    app.get("add", use: addController.index)
    app.get("status", ":avatarId", use: statusController.status)
    app.post("facebook", "process", use: facebookController.process)
    app.get("terms") { req -> EventLoopFuture<View> in
        return req.view.render("terms")
    }

    // MARK: API
    app.get("api", "data", use: dataController.index)
    app.get("api", "avatar.jpg", use: avatarController.index)

}
