import Fluent

struct CreateSource: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {

        database.enum("platforms")
            .case("facebook")
            .case("unsplash")
            .create().flatMap({ platformType in
                return database.schema("sources")
                    .field(.id, .int, .identifier(auto: true), .required)
                    .field("email", .string, .required)
                    .field("name", .string, .required)
                    .field("external_id", .string, .required)
                    .field("platform", platformType, .required)
                    .field("created_at", .datetime)
                    .field("updated_at", .datetime)
                    .field("deleted_at", .datetime)
                    .create()
            })

    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("platforms").delete().flatMap {
            database.enum("sources").delete()
        }
    }
}
