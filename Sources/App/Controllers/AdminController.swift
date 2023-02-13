import Vapor
import Fluent

final class AdminController {

    func index(request: Request) throws -> EventLoopFuture<View> {

        struct HomeContext: Encodable {
            var avatars: [AvatarAI]
        }

        return AvatarAI.query(on: request.db).filter(\.$approved == true).limit(42).all().flatMap { avatars in
            return request.view.render("home", HomeContext(avatars: avatars))
        }

    }

}
