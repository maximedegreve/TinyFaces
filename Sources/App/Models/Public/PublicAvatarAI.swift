import Vapor

final class PublicAvatarAI: Content {

    var id: Int?
    var url: String
    var firstName: String
    var lastName: String
    var gender: Gender?
    var approved: Bool
    var createdAt: Date?
    var updatedAt: Date?

    init(avatarAI: AvatarAI, firstName: String, lastName: String) {
        self.id = avatarAI.id
        self.url = Cloudflare().url(uuid: avatarAI.url, width: 1024, height: 1024, fit: .cover)
        self.firstName = firstName
        self.lastName = lastName
        self.gender = avatarAI.gender
        self.approved = avatarAI.approved
        self.createdAt = avatarAI.createdAt
        self.updatedAt = avatarAI.updatedAt
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
