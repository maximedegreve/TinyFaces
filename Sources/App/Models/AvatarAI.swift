import Fluent
import Vapor

final class AvatarAI: Model, Content {
    static let schema = "avatars_ai"

    @ID(custom: .id)
    var id: Int?

    @Field(key: "url")
    var url: String

    @OptionalEnum(key: "gender")
    var gender: Gender?
    
    @OptionalEnum(key: "age_group")
    var ageGroup: AgeGroup?

    @Field(key: "approved")
    var approved: Bool

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    @Timestamp(key: "deleted_at", on: .delete)
    var deletedAt: Date?

    init() { }

    init(url: String, approved: Bool) {
        self.url = url
        self.approved = approved
    }

}
