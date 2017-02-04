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
    var width: Int
    var height: Int
    
    init(url: String, size: String, faceId: Node? = nil, userId: Node, width: Int, height: Int) {
        self.userId = userId
        self.url = url
        self.size = size
        self.width = width
        self.height = height
    }

    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        userId = try node.extract("user_id")
        url = try node.extract("url")
        size = try node.extract("size")
        width = try node.extract("width")
        height = try node.extract("height")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "user_id": userId,
            "url": url,
            "size": size,
            "width": width,
            "height": height
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
            "size": size,
            "width": width,
            "height": height
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

struct AvatarAddWidthHeight: Preparation {
    
    static func prepare(_ database: Database) throws {
        try database.modify("avatars", closure: { avatar in
            avatar.int("width", optional: false, unique: false, default: 0)
            avatar.int("height", optional: false, unique: false, default: 0)
        })
    }
    
    static func revert(_ database: Database) throws {
        
    }
    
    static func populate() {
        
        do {
            
            let avatars = try Avatar.query().filter("width", .equals, 0).filter("height", .equals, 0).all()
            
            for avatar in avatars{
                
                guard let localURL = URL(string: "Public/" + avatar.url) else { throw Abort.badRequest }
                let sizeImage = try AdminImageProcessor.getSizeOfImage(url: localURL)
                
                var avatarEdited = avatar
                avatarEdited.width = sizeImage.width
                avatarEdited.height = sizeImage.height
                try avatarEdited.save()
                
            }
            
        } catch let error {
            Swift.print(error)
        }
        
    }
    
}
