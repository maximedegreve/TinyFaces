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
                var title: String
                var subtitle: String
            }
            
            if(avatar.approved){
                let context = StatusContext(title: "Your avatar was added to the queue to be approved.", subtitle: "We will notify you by email once your avatar got approved. If we reject it we will give more information regarding this.")
                return request.view.render("status", context).encodeResponse(for: request)
            }
            
            let context = StatusContext(title: "Your avatar was approved and added to the API", subtitle: "If at any point you have any questions don't hesitate to contact us.")
            return request.view.render("status", context).encodeResponse(for: request)
            
        }

    }

}

