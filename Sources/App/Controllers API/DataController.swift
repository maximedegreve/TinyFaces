import Vapor
import Fluent

final class DataController {

    func index(request: Request) throws -> EventLoopFuture<[PublicAvatar]> {

        let defaultAmount = 20;
        let defaultQuality = 10;
        
        struct RequestData: Error, Content {
            var amount: Int?
            var quality: Int?
            var gender: Gender?
        }
        
        let requestData = try request.query.decode(RequestData.self)
        let amount = requestData.amount ?? defaultAmount
        let quality = requestData.quality ?? defaultQuality

        guard amount <= 20 else {
            return request.eventLoop.makeFailedFuture(Abort(.badRequest, reason: "`amount` can't be larger than 20 at a time."))
        }
        
        guard amount > 0 else {
            return request.eventLoop.makeFailedFuture(Abort(.badRequest, reason: "`amount` has to be at least 1."))
        }
        
        guard quality < 11 else {
            return request.eventLoop.makeFailedFuture(Abort(.badRequest, reason: "`quality` can't be larger than 10."))
        }
        
        return Avatar.query(on: request.db).with(\.$source).filter(\.$quality >= quality).limit(amount).all().flatMap { avatars in
            return avatars.map { avatar in
                return request.eventLoop.future(PublicAvatar(avatar: avatar))
            }.flatten(on: request.eventLoop)
        }

    }

}
