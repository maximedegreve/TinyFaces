import Vapor
import Fluent

final class HomeController {

    func index(request: Request) throws -> EventLoopFuture<View> {

        struct HomeContext: Encodable {
            var avatars: [String]
        }

        return Avatar.query(on: request.db).filter(\.$approved == true).sort(\.$quality, .descending).limit(42).all().flatMap { avatars in

            let urls = avatars.map { avatar in
                return avatar.url.replacingOccurrences(of: "/image/upload/", with: "/image/upload/w_300,h_300,c_fit/", options: .literal, range: nil)
            }

            return request.view.render("home", HomeContext(avatars: urls))
        }

    }

}
