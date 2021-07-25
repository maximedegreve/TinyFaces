import Fluent
import Vapor

final class FirstName: Model, Content {
    static let schema = "first_names"

    @ID(custom: .id)
    var id: Int?

    @Field(key: "name")
    var name: String

    @Enum(key: "gender")
    var gender: Gender

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    @Timestamp(key: "deleted_at", on: .delete)
    var deletedAt: Date?

    init() { }

    init(name: String, gender: Gender) {
        self.name = name
        self.gender = gender
    }

}
