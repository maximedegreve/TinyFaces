import Vapor
import Fluent

final class AddController {

    func index(request: Request) throws -> EventLoopFuture<View> {

        struct AddContext: Encodable {
            var facebookAppId: String
        }

        return request.view.render("add", AddContext(facebookAppId: Environment.facebookAppId))

    }

}
