import Vapor

final class PublicSource: Content {

    var id: Int?
    var name: String
    var platform: Platform
    var createdAt: Date?
    var updatedAt: Date?

    init(source: Source) {
        self.id = source.id
        self.name = source.name
        self.platform = source.platform
        self.createdAt = source.createdAt
        self.updatedAt = source.updatedAt
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name = "name"
        case platform = "platform"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

}
