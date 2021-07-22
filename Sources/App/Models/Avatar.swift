import Fluent
import Vapor

final class Avatar: Model, Content {
    static let schema = "avatars"

    @ID(custom: .id)
    var id: Int?
    
    @Parent(key: "source_id")
    var source: Source
    
    @Field(key: "url")
    var url: String
    
    @Enum(key: "gender")
    var gender: Gender
    
    @Field(key: "quality")
    var quality: Int
    
    @Field(key: "approved")
    var approved: Bool
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    @Timestamp(key: "deleted_at", on: .delete)
    var deletedAt: Date?

    init() { }

    init(url: String, sourceId: Source, gender: Gender, quality: Int, approved: Bool) {
        self.$source.id = sourceId
        self.url = url
        self.gender = gender
        self.quality = quality
        self.approved = approved
    }

}
