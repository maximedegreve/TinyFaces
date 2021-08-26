import Vapor
import Fluent

final class StatusController {

    func status(request: Request) throws -> EventLoopFuture<Response> {

        let redirectToHome = request.redirect(to: "/")
        
        guard let avatarId = request.parameters.get("avatarId") else {
            return request.eventLoop.future(redirectToHome)
        }
        
        guard let avatarIdInt = Int(avatarId) else {
            return request.eventLoop.future(redirectToHome)
        }

        return Avatar.find(avatarIdInt, on: request.db).flatMap { optionalAvatar in
            
            guard let avatar = optionalAvatar else {
                return request.eventLoop.future(redirectToHome)
            }
                        
            struct StatusContext: Encodable {
                var approved: Bool
            }
            
            let view = request.view.render("status", StatusContext(approved: avatar.approved))
            return view.encodeResponse(for: request)
            
        }

    }

}

