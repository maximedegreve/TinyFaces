import Vapor
import Fluent

final class DataController {

    func index(request: Request) throws -> EventLoopFuture<[PublicAvatar]> {

        struct RequestData: Error, Content {
            var amount: Int = 20
            var quality: Int = 10
            var gender: String?
        }

        let requestData = try request.content.decode(RequestData.self)
        
        guard requestData.amount <= 20 else {
            return request.eventLoop.makeFailedFuture(Abort(.badRequest, reason: "`amount` can't be larger than 20 at a time."))
        }
        
        guard requestData.amount > 0 else {
            return request.eventLoop.makeFailedFuture(Abort(.badRequest, reason: "`amount` has to be at least 1."))
        }
        
        guard requestData.quality < 11 else {
            return request.eventLoop.makeFailedFuture(Abort(.badRequest, reason: "`quality` can't be larger than 10."))
        }
        
        return Avatar.query(on: request.db).field(\.$quality >= requestData.quality).with(\.$source).all().flatMap { avatars in
            return avatars.map { avatar in
                return PublicAvatar(avatar: avatar)
            }
        }

    }

}
