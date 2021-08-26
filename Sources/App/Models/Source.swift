import Fluent
import Vapor

final class Source: Model, Content {
    static let schema = "sources"

    @ID(custom: .id)
    var id: Int?

    @Field(key: "email")
    var email: String

    @Field(key: "name")
    var name: String

    @Field(key: "external_id")
    var externalId: String

    @Enum(key: "platform")
    var platform: Platform

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    @Timestamp(key: "deleted_at", on: .delete)
    var deletedAt: Date?

    init() { }

    init(email: String, platform: Platform, name: String, externalId: String) {
        self.email = email
        self.platform = platform
        self.name = name
        self.externalId = externalId
    }

}

extension Source {

    static func createIfNotExist(req: Request, name: String, email: String, externalId: String, platform: Platform) -> EventLoopFuture<Source> {

        return Source.query(on: req.db).filter(\.$platform == platform).filter(\.$externalId == externalId).first().flatMap { optionalSource -> EventLoopFuture<Source> in
            
            if let source = optionalSource{
                return req.eventLoop.future(source)
            }
            
            let newSource = Source(email: email, platform: .Facebook, name: name, externalId: externalId)
            return newSource.save(on: req.db).transform(to: newSource)
            
        }

    }

}
