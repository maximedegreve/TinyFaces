import Vapor
import Fluent

final class AdminController {
    
    struct AdminContext: Content {
        var avatars: [AvatarAI]
        var styles: [AvatarStyle]
        var genders: [Gender]
        var origins: [AvatarOrigin]
        var ageGroups: [AvatarAgeGroup]
        var metadata: PageMetadata
    }
    
    func index(request: Request) async throws -> AdminContext {

        enum AdminResultType: String, Content {
            case unreviewed = "unreviewed"
            case reviewed = "reviewed"
            case all = "all"
        }

        struct AdminResults: Content {
            var type: AdminResultType
        }
 
        let user = try request.jwt.verify(as: UserToken.self)
        
        guard user.admin else {
            throw GenericError.notAdmin
        }

            
        let data = try request.query.decode(AdminResults.self)

        let results = AvatarAI.query(on: request.db)

        switch data.type {
        case .unreviewed:
            results.group(.or) { avatar in
                avatar.filter(\.$style, .equal, nil).filter(\.$ageGroup, .equal, nil).filter(\.$gender, .equal, nil).filter(\.$approved, .equal, false)
            }
            break;
        case .reviewed:
            results.group(.and) { avatar in
                avatar.filter(\.$style, .notEqual, nil).filter(\.$ageGroup, .notEqual, nil).filter(\.$gender, .notEqual, nil).filter(\.$approved, .notEqual, false)
            }
            break;
        default:
            break;
        }
            
        let paginatedResults = try await results.paginate(for: request)
        
        let paginateResultsWithUrls: [AvatarAI] = paginatedResults.items.compactMap({ avatarAI in
            let url = Cloudflare().url(uuid: avatarAI.url, variant: "small")
            guard let signedUrl = Cloudflare().generateSignedUrl(url: url) else {
                return nil
            }
            avatarAI.url = signedUrl
            return avatarAI
        })
        
                    
        return AdminContext(avatars: paginateResultsWithUrls, styles: AvatarStyle.allCases, genders: Gender.allCases, origins: AvatarOrigin.allCases, ageGroups: AvatarAgeGroup.allCases, metadata: paginatedResults.metadata)

    }
    
    func put(request: Request) async throws -> Response {
        
        let user = try request.jwt.verify(as: UserToken.self)
        
        guard user.admin else {
            throw GenericError.notAdmin
        }
        
        let id = request.parameters.get("id")!

        guard let avatar = try await AvatarAI.find(Int(id), on: request.db) else {
            throw AdminError.avatarNotFound
        }
        
        struct UpdateData: Error, Content {
            var gender: Gender?
            var origin: AvatarOrigin?
            var ageGroup: AvatarAgeGroup?
            var style: AvatarStyle?
            var approved: Bool
        }
        
        let data = try request.content.decode(UpdateData.self)
        
        avatar.gender = data.gender
        avatar.origin = data.origin
        avatar.ageGroup = data.ageGroup
        avatar.style = data.style
        avatar.approved = data.approved
        
        try await avatar.save(on: request.db)
        
        return Response(status: .ok)
        
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
        
        let id = request.parameters.get("id")!

        guard let avatar = try await AvatarAI.find(Int(id), on: request.db) else {
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
