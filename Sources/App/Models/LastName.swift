import Fluent
import Vapor

final class LastName: Model, Content {
    static let schema = "last_names"

    @ID(custom: .id)
    var id: Int?
    
    @Field(key: "name")
    var name: String

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    @Timestamp(key: "deleted_at", on: .delete)
    var deletedAt: Date?

    init() { }

    init(name: String) {
        self.name = name
    }

}
