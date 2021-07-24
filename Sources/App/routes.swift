import Fluent
import Vapor

func routes(_ app: Application) throws {

    // MARK: Controllers
    let dataController = DataController()
    let homeController = HomeController()

    // MARK: Pages
    app.get(use: homeController.index)

    // MARK: API
    app.get("data", use: dataController.index)
    app.get("user", use: dataController.index) // Legacy Endpoint

}
