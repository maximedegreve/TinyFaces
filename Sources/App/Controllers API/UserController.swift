import Vapor
import HTTP
import FluentMySQL
import Fluent

final class UserController: ResourceRepresentable {
    
    func index(request: Request) throws -> ResponseRepresentable {
        
        let face = try User.query().filter("approved", .equals, true).sort("quality", .descending)
        face.limit = Limit(count: 30, offset: 0)
        return try face.all().makeJSON(request: request)
    }

    func makeResource() -> Resource<User> {
        return Resource(
            index: index
        )
    }
    
}

extension Request {
    func user() throws -> User {
        guard let json = json else { throw Abort.badRequest }
        return try User(node: json)
    }
}
