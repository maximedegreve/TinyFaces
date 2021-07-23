import Fluent

struct CreateFirstName: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        
        database.enum("genders").read().flatMap { genderType in
            return database.schema("first_names")
                .field(.id, .int, .identifier(auto: true), .required)
                .field("name", .string, .required)
                .field("gender", genderType, .required)
                .field("created_at", .datetime)
                .field("updated_at", .datetime)
                .field("deleted_at", .datetime)
                .create()
        }
        
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("last_names").delete()
    }
}
