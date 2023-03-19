import JWT

struct UserToken: JWTPayload {

    var subject: SubjectClaim
    var expiration: ExpirationClaim
    var userId: Int
    var email: String
    var admin: Bool
    var stripeCustomerId: String?

    enum CodingKeys: String, CodingKey {
        case subject = "sub"
        case expiration = "exp"
        case userId = "user_id"
        case stripeCustomerId = "stripe_customer_id"
        case email = "email"
        case admin = "admin"
    }

    func verify(using signer: JWTSigner) throws {
        try self.expiration.verifyNotExpired()
    }
}
