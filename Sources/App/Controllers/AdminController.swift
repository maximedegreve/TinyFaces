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
        let mapped: [AvatarAI] = results.compactMap({ avatarAI in
            let url = Cloudflare().url(uuid: avatarAI.url, variant: "small")
            guard let signedUrl = Cloudflare().generateSignedUrl(url: url) else {
                return nil
            }
            avatarAI.url = signedUrl
            return avatarAI
        })
            
        return mapped

    }

    func upload(request: Request) async throws -> AvatarAI {

        struct Response: Error, Content {
            var avatar: Data
        }

        let user = try request.jwt.verify(as: UserToken.self)
        
        guard user.admin else {
            throw GenericError.notAdmin
        }
        
        let response = try request.content.decode(Response.self, using: FormDataDecoder())
        let metaData = ["type": "avatarai"]

        let upload = try await Cloudflare().upload(file: response.avatar, metaData: metaData, requireSignedURLs: true, client: request.client)

        guard let resultId = upload.result?.id else {
            throw AdminError.failedUpload
        }
        
        let avatarAI = AvatarAI(url: resultId, approved: false)
        try await avatarAI.save(on: request.db)

        return avatarAI

    }
    
    func delete(request: Request) async throws -> Response {

        let user = try request.jwt.verify(as: UserToken.self)
        
        guard user.admin else {
            throw GenericError.notAdmin
        }
        
        struct RequestData: Content {
            var id: Int
        }
        
        let data = try request.query.decode(RequestData.self)
        
        guard let avatar = try await AvatarAI.find(data.id, on: request.db) else {
            throw AdminError.avatarNotFound
        }
        
        let result = try await Cloudflare().delete(identifier: avatar.url, client: request.client)
        
        guard result.success else {
            throw AdminError.failedDelete
        }
        
        try await avatar.delete(on: request.db)
        
        return Response(status: .ok)

    }

}
