import Vapor
import Fluent

final class HomeController {

    func index(request: Request) throws -> EventLoopFuture<View> {

        struct HomeContext: Encodable {
            var avatars: [String]
        }

        return Avatar.query(on: request.db).filter(\.$approved == true).sort(\.$quality, .descending).limit(42).all().flatMap { avatars in

            let urls = avatars.map { avatar in
                return Cloudinary().urlWithSize(url: avatar.url, maxSize: 1024, maxHeight: 1024)
            }

            return request.view.render("home", HomeContext(avatars: urls))
        }

    }

}
