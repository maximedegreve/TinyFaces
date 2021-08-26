import Vapor
import Fluent

final class DataController {

    func index(request: Request) throws -> EventLoopFuture<[PublicAvatar]> {

        let defaultLimit = 50
        let defaultQuality = 10
        let defaultAvatarMaxSize = 1024

        struct RequestData: Error, Content {
            var limit: Int?
            var quality: Int?
            var gender: Gender?
            var avatarMaxSize: Int?

            enum CodingKeys: String, CodingKey {
                case limit
                case quality
                case gender
                case avatarMaxSize = "avatar_max_size"
            }

        }

        let requestData = try request.query.decode(RequestData.self)
        let limit = requestData.limit ?? defaultLimit
        let quality = requestData.quality ?? defaultQuality
        let avatarSize = requestData.avatarMaxSize ?? defaultAvatarMaxSize

        guard avatarSize <= 1024 else {
            return request.eventLoop.makeFailedFuture(Abort(.badRequest, reason: "`avatar_max_size` can't be larger than 1024."))
        }

        guard limit <= 50 else {
            return request.eventLoop.makeFailedFuture(Abort(.badRequest, reason: "`limit` can't be larger than 50 at a time."))
        }

        guard limit > 0 else {
            return request.eventLoop.makeFailedFuture(Abort(.badRequest, reason: "`limit` has to be at least 1."))
        }

        guard quality <= 10 else {
            return request.eventLoop.makeFailedFuture(Abort(.badRequest, reason: "`quality` can't be larger than 10."))
        }

        let gender = requestData.gender

        return self.randomFirstNames(request: request, gender: gender, limit: limit).flatMap { firstNames in

            return self.randomLastNames(request: request, limit: limit).flatMap { lastNames in

                return self.randomAvatars(request: request, gender: gender, limit: limit, quality: quality).flatMap { avatars in

                    return avatars.enumerated().compactMap { (index, element) in

                        let firstName = firstNames[safe: index]?.name ?? "Jane"
                        let lastName = lastNames[safe: index]?.name ?? "Doe"
                        let avatar = PublicAvatar(avatar: element, avatarSize: avatarSize, firstName: firstName, lastName: lastName)
                        return request.eventLoop.future(avatar)

                    }.flatten(on: request.eventLoop)

                }
            }

        }

    }

    func randomAvatars(request: Request, gender: Gender?, limit: Int, quality: Int) -> EventLoopFuture<[Avatar]> {

        let baseQuery = Avatar.query(on: request.db).with(\.$source).filter(\.$quality >= quality).filter(\.$approved == true)

        if let gender = gender {
            baseQuery.filter(\.$gender == gender)
        }

        return baseQuery.limit(limit).sort(.sql(raw: "rand()")).all()

    }

    func randomFirstNames(request: Request, gender: Gender?, limit: Int) -> EventLoopFuture<[FirstName]> {

        let firstNameQuery = FirstName.query(on: request.db)

        if let gender = gender {
            let genderIsBinary = gender == .Male || gender == .Female
            let genderFilter = genderIsBinary ? gender : .Other
            firstNameQuery.filter(\.$gender == genderFilter)
        }

        return firstNameQuery.limit(limit).sort(.sql(raw: "rand()")).all()

    }

    func randomLastNames(request: Request, limit: Int) -> EventLoopFuture<[LastName]> {
        return LastName.query(on: request.db).limit(limit).sort(.sql(raw: "rand()")).all()
    }

}
