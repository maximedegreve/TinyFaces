import Fluent
import Vapor

final class OldAvatar: Model, Content {
    static let schema = "old_avatars"

    @ID(custom: .id)
    var id: Int?
    
    @Parent(key: "user_id")
    var userId: Source
    
    @Field(key: "url")
    var url: String
    
    @Field(key: "size")
    var size: String
    
    @Field(key: "width")
    var width: Int
    
    @Field(key: "height")
    var height: Int
    

}
