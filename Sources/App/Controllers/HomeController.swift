import Vapor
import Fluent

final class HomeController {

    func index(request: Request) throws -> EventLoopFuture<View> {

        struct HomeContext: Encodable {
            var avatars: [String]
        }

        return AvatarAI.query(on: request.db).limit(42).sort(.sql(raw: "rand()")).all().flatMap { avatars in

            let urls = avatars.compactMap { avatar in
                return PublicAvatarAI(avatar: avatar, avatarSize: 174, firstName: "", lastName: "").url
            }

            return request.view.render("home", HomeContext(avatars: urls))
        }

    }

}
