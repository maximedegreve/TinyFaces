import Vapor
import Fluent

final class DataAIController {

    func index(request: Request) async throws -> [PublicAvatarAI] {

        try await Analytic.log(request: request)

        let defaultLimit = 50

        struct RequestData: Error, Content {
            var limit: Int?
            var gender: Gender?

            enum CodingKeys: String, CodingKey {
                case limit
                case gender
            }

        }

        let requestData = try request.query.decode(RequestData.self)
        let limit = requestData.limit ?? defaultLimit

        guard limit <= 50 else {
            throw Abort(.badRequest, reason: "`limit` can't be larger than 50 at a time.")
        }

        guard limit > 0 else {
            throw Abort(.badRequest, reason: "`limit` has to be at least 1.")
        }

        let gender = requestData.gender

        let firstNames = try await self.randomFirstNames(request: request, gender: gender, limit: limit).get()
        let lastNames = try await self.randomLastNames(request: request, limit: limit).get()
        let avatars = try await self.randomAvatars(request: request, gender: gender, limit: limit).get()

        return avatars.enumerated().compactMap { (index, element) in

            let firstName = firstNames[safe: index]?.name ?? "Jane"
            let lastName = lastNames[safe: index]?.name ?? "Doe"
            let avatar = PublicAvatarAI(avatar: element, firstName: firstName, lastName: lastName)
            return avatar

        }

    }

    func randomAvatars(request: Request, gender: Gender?, limit: Int) -> EventLoopFuture<[AvatarAI]> {

        let baseQuery = AvatarAI.query(on: request.db)

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
