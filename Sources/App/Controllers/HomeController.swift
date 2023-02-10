import Vapor
import Fluent

final class HomeController {

    func index(request: Request) throws -> EventLoopFuture<View> {

        struct HomeContext: Encodable {
            var avatars: [String]
        }

        return Avatar.query(on: request.db).filter(\.$approved == true).sort(\.$quality, .descending).limit(42).all().flatMap { avatars in

            let urls = avatars.map { avatar in
                return Cloudflare().url(uuid: avatar.url, width: 174, height: 174, fit: .cover)
            }

            return request.view.render("home", HomeContext(avatars: urls))
        }

    }

}
