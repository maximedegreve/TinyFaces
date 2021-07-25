import Fluent
import Vapor

func routes(_ app: Application) throws {

    // MARK: Controllers
    let dataController = DataController()
    let homeController = HomeController()

    // MARK: Pages
    app.get(use: homeController.index)
    app.get("terms") { req -> EventLoopFuture<View> in
        return req.view.render("terms")
    }

    // MARK: API
    app.get("api", "data", use: dataController.index)
    app.get("api", "user", use: dataController.index) // Legacy Endpoint

}
