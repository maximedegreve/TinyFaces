import Vapor

final class PublicAvatarAI: Content {

    var id: Int?
    var url: String?
    var gender: Gender?
    var firstName: String
    var lastName: String
    var approved: Bool
    var createdAt: Date?
    var updatedAt: Date?

    init(avatar: AvatarAI, avatarSize: Int, firstName: String, lastName: String) {
        
        let url = Cloudflare().url(uuid: avatar.url, variant: "small")
        let signedUrl = Cloudflare().generateSignedUrl(url: url)
      
        self.id = avatar.id
        self.firstName = firstName
        self.lastName = lastName
        self.url = signedUrl
        self.gender = avatar.gender
        self.approved = avatar.approved
        self.createdAt = avatar.createdAt
        self.updatedAt = avatar.updatedAt
    }

    enum CodingKeys: String, CodingKey {
        case id
        case url = "url"
        case gender = "gender"
        case firstName = "first_name"
        case lastName = "last_name"
        case approved = "approved"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

}
