import Vapor
import Fluent

final class AdminController {

    struct AdminContext: Content {
        var avatars: [AvatarAI]
        var metadata: PageMetadata
    }

    func index(request: Request) async throws -> View {

        enum AdminResultType: String, Content {
            case unreviewed = "unreviewed"
            case reviewed = "reviewed"
            case all = "all"
        }

        let user = try request.auth.require(User.self)

        guard user.admin else {
            throw Abort.redirect(to: "/dashboard")
        }

        let typeString = request.parameters.get("type") ?? AdminResultType.all.rawValue
        
        guard let type = AdminResultType(rawValue: typeString) else {
            throw Abort.redirect(to: "/dashboard")
        }
        
        let results = AvatarAI.query(on: request.db)

        switch type {
        case .unreviewed:
            results.group(.or) { avatar in
                avatar.filter(\.$style, .equal, nil).filter(\.$ageGroup, .equal, nil).filter(\.$gender, .equal, nil).filter(\.$approved, .equal, false)
            }
            break
        case .reviewed:
            results.group(.and) { avatar in
                avatar.filter(\.$style, .notEqual, nil).filter(\.$ageGroup, .notEqual, nil).filter(\.$gender, .notEqual, nil).filter(\.$approved, .notEqual, false)
            }
            break
        default:
            break
        }

        let paginatedResults = try await results.sort(\.$approved).sort(\.$createdAt, .descending).paginate(for: request)

        let paginateResultsWithUrls: [AvatarAI] = paginatedResults.items.compactMap({ avatarAI in
            let url = Cloudflare().url(uuid: avatarAI.url, variant: .medium)
            guard let signedUrl = Cloudflare().generateSignedUrl(url: url) else {
                return nil
            }
            avatarAI.url = signedUrl
            return avatarAI
        })

        let context = AdminContext(avatars: paginateResultsWithUrls, metadata: paginatedResults.metadata)

        return try await request.view.render("admin", context)

    }
    
    struct AdminDetailContext: Content {
        var avatar: AvatarAI
        var styles: [AvatarStyle]
        var genders: [Gender]
        var origins: [AvatarOrigin]
        var ageGroups: [AvatarAgeGroup]
    }

    func detail(request: Request) async throws -> View {

        let user = try request.auth.require(User.self)

        guard user.admin else {
            throw Abort.redirect(to: "/dashboard")
        }
                
        let id = request.parameters.get("id")!
        let idInt = Int(id)!
        
        guard let avatar = try await AvatarAI.find(idInt, on: request.db) else {
            throw Abort.redirect(to: "/admin")
        }
        
        let url = Cloudflare().url(uuid: avatar.url, variant: .medium)
        
        guard let signedUrl = Cloudflare().generateSignedUrl(url: url) else {
            throw Abort.redirect(to: "/admin")
        }
        avatar.url = signedUrl
        
        let context = AdminDetailContext(avatar: avatar, styles: AvatarStyle.allCases, genders: Gender.allCases, origins: AvatarOrigin.allCases, ageGroups: AvatarAgeGroup.allCases)
        
        return try await request.view.render("admin-detail", context)

    }

    func post(request: Request) async throws -> View {

        let user = try request.auth.require(User.self)

        guard user.admin else {
            throw Abort.redirect(to: "/dashboard")
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
            var approved: String?
        }

        let data = try request.content.decode(UpdateData.self)

        avatar.gender = data.gender
        avatar.origin = data.origin
        avatar.ageGroup = data.ageGroup
        avatar.style = data.style
        avatar.approved = data.approved == "on"

        try await avatar.save(on: request.db)

        return try await detail(request: request)

    }

    func upload(request: Request) async throws -> Response {

        struct Response: Error, Content {
            var avatar: Data
        }

        let user = try request.auth.require(User.self)

        guard user.admin else {
            throw Abort.redirect(to: "/dashboard")
        }

        let response = try request.content.decode(Response.self, using: FormDataDecoder())
        let metaData = ["type": "avatarai"]

        let upload = try await Cloudflare().upload(file: response.avatar, metaData: metaData, requireSignedURLs: true, client: request.client)

        guard let resultId = upload.result?.id else {
            throw AdminError.failedUpload
        }

        let avatarAI = AvatarAI(url: resultId, approved: false)
        try await avatarAI.save(on: request.db)
        
        let id = try avatarAI.requireID()

        return request.redirect(to: "/admin/\(id)")

    }

    func delete(request: Request) async throws -> Response {

        let user = try request.auth.require(User.self)

        guard user.admin else {
            throw Abort.redirect(to: "/dashboard")
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

        return request.redirect(to: "/admin")

    }

}
