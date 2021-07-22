import Fluent

struct CreatePlatform: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.enum("platforms")
            .case("facebook")
            .case("unsplash")
            .create()
            .transform(to: database.eventLoop.makeSucceededVoidFuture())
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.enum("platforms").delete()
    }
}
