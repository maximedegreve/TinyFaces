import Fluent
import Vapor

final class User: Model, Content {
    static let schema = "users"

    @ID(custom: .id)
    var id: Int?

    @Field(key: "name")
    var name: String
    
    @Field(key: "admin")
    var admin: Bool
    
    @Field(key: "email")
    var email: String
    
    @Field(key: "stripe_customer_id")
    var stripeCustomerId: String?

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    @Timestamp(key: "deleted_at", on: .delete)
    var deletedAt: Date?

    init() { }

    init(name: String, email: String, stripeCustomerId: String?, admin: Bool) {
        self.name = name
        self.email = email
        self.admin = admin
        self.stripeCustomerId = stripeCustomerId
    }
    
    static func find(email: String, db: Database) async throws -> User? {
        return try await User.query(on: db).filter(\.$email == email).first()
    }
    
    static func find(stripeCustomerId: String, db: Database) async throws -> User? {
        return try await User.query(on: db).filter(\.$stripeCustomerId == stripeCustomerId).first()
    }

}

extension User {
    
    static func createIfNotExist(db: Database, email: String, stripeCustomerId: String?) async throws -> User {
        
        let optionalUser = try await self.find(email: email, db: db)
        
        if let user = optionalUser {
            return user
        }
        
        let parts = email.components(separatedBy: "@")
        let name = parts.first ?? "Your name"
        
        let newUser = User(name: name, email: email, stripeCustomerId: stripeCustomerId, admin: false)
        try await newUser.save(on: db)
        
        return newUser
        
    }
    
}
