import Vapor

final class PublicAvatar: Content {

    var id: Int?
    var source: PublicSource
    var url: String
    var gender: Gender
    var approved: Bool
    var createdAt: Date?
    var updatedAt: Date?

    init(avatar: Avatar) {
        self.id = avatar.id
        self.source = PublicSource(source: avatar.source)
        self.url = avatar.url
        self.gender = avatar.gender
        self.approved = avatar.approved
        self.createdAt = avatar.createdAt
        self.updatedAt = avatar.updatedAt
    }

    enum CodingKeys: String, CodingKey {
        case id
        case source = "source"
        case url = "url"
        case gender = "gender"
        case approved = "approved"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

}
