import Fluent
import Vapor

final class OldUser: Model, Content {
    static let schema = "old_users"

    @ID(custom: .id)
    var id: Int?
    
    @Field(key: "facebook_id")
    var facebookId: String
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "email")
    var email: String
    
    @Field(key: "gender")
    var gender: String
    
    @Field(key: "verified")
    var verified: Bool
    
    @Field(key: "approved")
    var approved: Bool
    
    @Field(key: "quality")
    var quality: Bool

}
