import Vapor
import Fluent

final class AdminController {

    func index(request: Request) async throws -> [AvatarAI] {

        let user = try request.jwt.verify(as: UserToken.self)
        
        guard user.admin else {
            throw GenericError.notAdmin
        }

        struct HomeContext: Encodable {
            var avatars: [AvatarAI]
        }
        
        let results = try await AvatarAI.query(on: request.db).limit(10).all()

        return results

    }

}
