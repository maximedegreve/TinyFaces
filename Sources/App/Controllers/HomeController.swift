import Vapor
import Fluent

final class HomeController {

    func index(request: Request) throws -> EventLoopFuture<View> {

        struct HomeContext: Encodable {
            var avatars: [Avatar]
        }

        return Avatar.query(on: request.db).filter(\.$approved == true).sort(\.$quality, .descending).all().flatMap { avatars in
            return request.view.render("home", HomeContext(avatars: avatars))
        }

    }

}
