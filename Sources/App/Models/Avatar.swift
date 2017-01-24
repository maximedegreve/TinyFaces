import Vapor
import HTTP
import Fluent
import FluentMySQL
import Foundation

final class Avatar: Model {

    var id: Node?
    var userId: Node
    var url: String
    var size: String
    var exists: Bool = false
    
    init(url: String, size: String, faceId: Node? = nil, userId: Node) {
        self.userId = userId
        self.url = url
        self.size = size
    }

    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        userId = try node.extract("user_id")
        url = try node.extract("url")
        size = try node.extract("size")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "user_id": userId,
            "url": url,
            "size": size
        ])
    }
    
    func makeJSON(request: Request) throws -> JSON {
        
        var portString = ""
        if let port = request.uri.port {
            portString = ":" + String(port)
        }
        
        let imageURL = "https://\(request.uri.host)\(portString)/\(url)"
        
        return try JSON(node: [
            "url": imageURL,
            "size": size
            ])
    }

    public static func revert(_ database: Database) throws {
        try database.delete("avatars")
    }
    
    public static func prepare(_ database: Database) throws {
        
        try database.create("avatars") { faces in
            faces.id()
            faces.parent(User.self, optional: false, unique: false)
            faces.string("url", length: 250, optional: false, unique: true)
            faces.string("size", length: 250, optional: false, unique: false)
        }

    }

    
}

extension Sequence where Iterator.Element == Avatar {
    
    func makeJSON(request: Request) throws -> JSON {
        return try JSON(node: self.map {
            try $0.makeJSON(request: request)
        })
    }
    
}

extension Avatar {

    func user() throws -> Parent<User> {
        return try parent(userId)
    }

}
