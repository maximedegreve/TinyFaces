import Vapor
import Fluent
import Crypto

final class AvatarController {

    func index(request: Request) throws -> EventLoopFuture<Response> {

        struct RequestData: Content {
            var quality: Int?
            var gender: Gender?
        }
        
        let data = try request.query.decode(RequestData.self)
        
        return randomAvatar(request: request, gender: data.gender, quality: data.quality ?? 0).flatMap { optionalAvatar in
            
            guard let avatar = optionalAvatar else {
                return request.eventLoop.makeFailedFuture(Abort(.notFound, reason: "Not avatar found for your query."))
            }

            return request.eventLoop.future(request.redirect(to: avatar.url))
        }

    }
    
    func randomAvatar(request: Request, gender: Gender?, quality: Int) -> EventLoopFuture<Avatar?> {

        let baseQuery = Avatar.query(on: request.db).with(\.$source).filter(\.$quality >= quality).filter(\.$approved == true)

        if let gender = gender {
            baseQuery.filter(\.$gender == gender)
        }

        return baseQuery.sort(.sql(raw: "rand()")).first()

    }

}
