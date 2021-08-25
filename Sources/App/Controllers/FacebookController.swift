import Vapor
import Fluent

final class FacebookController {

    func redirect(request: Request) throws -> EventLoopFuture<View> {
        return request.view.render("add")
    }

}
