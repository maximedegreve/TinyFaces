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
		
		let genderSet: FakeGenerator.Gender
		
        if let genderMatch = FakeGenerator.Gender(rawValue: gender) {
            genderSet = genderMatch
		} else {
			genderSet = .other
		}
			
        let avatarOrigin = try Node(node: [
            "id": id,
            "name": name,
            "facebook_profile_link": facebookProfileLink,
            ])
        
        return try JSON(node: [
            "first_name": FakeGenerator.firstName(for: genderSet),
            "last_name": FakeGenerator.lastName(),
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

}

// MARK: Helpers

extension Sequence where Iterator.Element: User {
    func makeJSON(request: Request) throws -> JSON {
        return try JSON(node: self.map {
            try $0.makeJSON(request: request)
        })
    }
}
