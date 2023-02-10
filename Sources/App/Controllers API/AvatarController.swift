import Vapor
import Fluent

final class AvatarController {

    func update(request: Request) async throws -> Response {
        
        let avatars = try await Avatar.query(on: request.db).filter(\.$url, .contains(inverse: false, .anywhere), "storage.googleapis.com").all()
        
        for avatar in avatars {
            let uploaded = try await Cloudflare().upload(url: avatar.url, metaData: ["type": "tiny-avatar", "gender": avatar.gender.rawValue, "approved": avatar.approved, "quality": avatar.quality], client: request.client)
            avatar.url = uploaded.result.id
            try await avatar.save(on: request.db)
        }
        
        
        return Response(status: .ok)
    }
    
    func index(request: Request) async throws -> Response {

        try await Analytic.log(request: request)

        struct RequestData: Content {
            var quality: Int?
            var gender: Gender?
        }
        
        let data = try request.query.decode(RequestData.self)
        
        let optionalAvatar = try await randomAvatar(request: request, gender: data.gender, quality: data.quality ?? 0).get()
        
        guard let avatar = optionalAvatar else {
            throw Abort(.notFound, reason: "Not avatar found for your query.")
        }

        let url = Cloudflare().url(uuid: avatar.url, width: 1024, height: 1024, fit: .cover)
        return request.redirect(to: url)

    }
    
    func randomAvatar(request: Request, gender: Gender?, quality: Int) -> EventLoopFuture<Avatar?> {

        let baseQuery = Avatar.query(on: request.db).with(\.$source).filter(\.$quality >= quality).filter(\.$approved == true)

        if let gender = gender {
            baseQuery.filter(\.$gender == gender)
        }

        return baseQuery.sort(.sql(raw: "rand()")).first()

    }

}
