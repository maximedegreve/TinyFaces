import Fluent
import Vapor
import StripeKit

final class User: Model, Content, ModelSessionAuthenticatable {

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

    @Children(for: \.$user)
    var subscriptions: [Subscription]

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

    func activeSubscriptions(req: Request) async throws -> [Subscription] {

        let all = try await self.$subscriptions.query(on: req.db).all()

        return all.filter { sub in

            let status = sub.stripeStatus
            guard let status = StripeSubscriptionStatus(rawValue: status) else {
                return false
            }

            switch status {
            case .incomplete:
                return false
            case .incompleteExpired:
                return false
            case .trialing:
                return false
            case .active:
                break
            case .pastDue:
                break
            case .canceled:
                return false
            case .unpaid:
                return false
            }

            guard let currentPeriodEnd = sub.currentPeriodEnd else {
                return false
            }

            return currentPeriodEnd >= Date()

        }

    }

}
