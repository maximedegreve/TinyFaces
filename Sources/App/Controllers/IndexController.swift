import Vapor
import HTTP
import Fluent

final class IndexController {
    
    func addRoutes(drop: Droplet){
        drop.get(handler: index)
    }

    func index(request: Request) throws -> ResponseRepresentable{
        
        let userQuery = try User.query()
        userQuery.limit = Limit(count: 24, offset: 0)
        let users = try userQuery.filter("approved", .equals, true).sort("quality", .descending).all()
        
        
        var avatars = [String]()
        
        for user in users {
            for avatar in try user.avatars().all() {
                if avatar.size == "medium" {
                    avatars.append(avatar.url)
                }
            }
        }
        
        return try drop.view.make("index", [
            "message": "home",
            "avatars": avatars.makeNode()
            ])
    }
    
    
    
}
