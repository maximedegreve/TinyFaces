import Fluent
import Vapor

func routes(_ app: Application) throws {

    // MARK: Controllers
    let dataController = DataController()


    app.get { _ in
        return "Hello! I'm the API for TinyFac.es"
    }

    // MARK: Slack
    app.get("data", use: dataController.index)
    app.get("user", use: dataController.index) // Legacy Endpoint


}

