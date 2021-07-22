import Fluent

struct CreateAvatar: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        
        database.enum("genders").read().flatMap { genderType in

            return database.schema("avatars")
                .field(.id, .int, .identifier(auto: true), .required)
                .field("source_id", .int, .required, .references("sources", "id"))
                .field("url", .string, .required)
                .field("quality", .int, .required)
                .field("approved", .bool, .required)
                .field("gender", genderType, .required)
                .field("created_at", .datetime)
                .field("updated_at", .datetime)
                .field("deleted_at", .datetime)
                .create()
            
        }
        
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("avatars").delete()
    }
}
