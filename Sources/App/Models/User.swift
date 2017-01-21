import Vapor
import Fluent
import FluentMySQL
import Foundation
import HTTP

final class User: Model {
    
    var id: Node?
    var facebookId: String
    var name: String
    var facebookProfileLink: String
    var email: String
    var gender: String
    var verified: Int
    var exists: Bool = false
    var approved: Bool = false
    var quality: Int = 1

    init(facebookId: String, name: String, gender: String, facebookProfileLink: String, email: String, verified: Int) {
        self.name = name
        self.facebookId = facebookId
        self.gender = gender
        self.facebookProfileLink = facebookProfileLink
        self.email = email
        self.verified = verified
    }

    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        name = try node.extract("name")
        facebookId = try node.extract("facebook_id")
        facebookProfileLink = try node.extract("facebook_profile_link")
        email = try node.extract("email")
        gender = try node.extract("gender")
        verified = try node.extract("verified")
        approved = try node.extract("approved")
        quality = try node.extract("quality")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "name": name,
            "facebook_id": facebookId,
            "facebook_profile_link": facebookProfileLink,
            "gender": gender,
            "email": email,
            "approved": approved,
            "verified": verified,
            "quality": quality
        ])
    }
    
    func makeJSON(request: Request) throws -> JSON {
		
        var genderSet: FirstName.Gender = .all
        
        if gender == "male" {
            genderSet = .male
        } else if gender == "female" {
            genderSet = .female
        }
        
        let randomName = try RandomName.generate(gender: genderSet)
        
        let avatarOrigin = try Node(node: [
            "id": id,
            "name": name,
            "facebook_profile_link": facebookProfileLink,
            ])
        
        return try JSON(node: [
            "first_name": randomName?.firstName,
            "last_name": randomName?.lastName,
            "gender": gender,
            "avatars": avatars().all().makeJSON(request: request),
            "avatars_origin": avatarOrigin,
            ])
        
    }

    public static func revert(_ database: Database) throws {
        try database.delete("users")
    }
    
    public static func prepare(_ database: Database) throws {

        try database.create("users") { faces in
            faces.id()
            faces.string("facebook_id", length: 200, optional: false, unique: true)
            faces.string("name", length: 200, optional: false)
            faces.string("facebook_profile_link", length: 200, optional: false)
            faces.string("email", length: 200, optional: false)
            faces.string("gender", length: 250, optional: false)
            faces.int("verified", optional: false)
            faces.int("approved", optional: true, default: 0)
            faces.int("quality", optional: true, default: 1)
        }

    }
    
}

// MARK: Relations

extension User {
    
    func avatars() throws -> Children<Avatar> {
        return children()
    }
    
    func approvedCount() throws -> Int {
        return try User.query().filter("approved", .equals, true).count()
    }
    
    static func random(limit: Limit, minQuality: Int = 10, gender: FirstName.Gender = .all) throws -> [User]{
        
        /* Fluent doesn't support RAND(). So we need to use raw queries for now... */
        
        if let mysql = drop.database?.driver as? MySQLDriver {
            
            let results = try mysql.raw("SELECT * FROM users WHERE approved = 1 AND quality >= \(minQuality) ORDER BY rand() LIMIT \(limit.count)")
            
            guard case .array(let array) = results else {
                return [User]()
            }
            
            let users = try array.map {
                try User(node: $0)
            }
            
            return users
        }
        
        return [User]()
        
    }


}

// MARK: Helpers

extension Sequence where Iterator.Element: User {
    func makeJSON(request: Request) throws -> JSON {
        return try JSON(node: self.map {
            try $0.makeJSON(request: request)
        })
    }
}
