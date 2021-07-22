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
    

    init() { }

    init(email: String, platform: Platform, name: String, externalId: String) {
        self.email = email
        self.platform = platform
        self.name = name
        self.externalId = externalId
    }

}