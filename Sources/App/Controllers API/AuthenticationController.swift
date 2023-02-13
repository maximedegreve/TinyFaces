import Vapor
import Crypto
import Fluent
import JWT

final class AuthenticationController {

    private let flowLifetime: Int = 5

    // MARK: Endpoints

    func authenticate(request: Request) async throws -> Handshake {

        struct RequestData: Error, Validatable, Content {
            var email: String
            var timezone: String?

            enum CodingKeys: String, CodingKey {
                case email
                case timezone
            }

            static func validations(_ validations: inout Validations) {
                validations.add("email", as: String.self, is: .email)
            }
        }

        let requestData = try request.content.decode(RequestData.self)

        try RequestData.validate(content: request)

        let optionalUser = try await User.query(on: request.db).filter(\.$email, .equal, requestData.email).first()

        // 👩🏻‍🦰 Existing user
        if let user = optionalUser {
            return try await sendMagicEmail(request: request, user: user, isNewUser: false)
        }

        // 🧑🏽‍🦱 New user
        let fullNameArr = self.getEmailUsername(requestData.email) ?? "Jo Doe"
        let user = User(name: fullNameArr, email: requestData.email, stripeCustomerId: nil, admin: false)
        try await user.save(on: request.db)

        return try await sendMagicEmail(request: request, user: user, isNewUser: true)

    }

    func sendMagicEmail(request: Request, user: User, isNewUser: Bool) async throws -> Handshake {

        // 🔄 Generate auth data
        let userId = try user.requireID()
        let code = randomString(length: 6)
        let session = UUID().uuidString
        let expiryDate = Calendar.current.date(byAdding: .minute, value: flowLifetime, to: Date()) ?? Date()
        let magicCode = AuthenticationCode(code: code, userId: userId, expiryDate: expiryDate, tries: 0, isNewUser: isNewUser)

        // 💿 Save to session
        let json = try JSONEncoder().encode(magicCode).base64String()
        request.session.data["magic-code"] = json

        // 📧 Build email
        let sender = SendInBlueContact(name: "Laye.rs", email: "no-reply@laye.rs")
        let contactName = user.name
        let to = SendInBlueContact(name: contactName, email: user.email)

        let codeArray = code.uppercased().compactMap { String($0) }
        let emailContext = EmailContext(name: contactName, code1: codeArray[0], code2: codeArray[1], code3: codeArray[2], code4: codeArray[3], code5: codeArray[4], code6: codeArray[5])
        let emailView = try await request.view.render("authentication", emailContext).get()

        // 👨‍💻 Send email if production otherwise log it
        switch request.application.environment {
        case .production:

            let htmlContent = String(buffer: emailView.data)
            let email = SendInBlueEmail(sender: sender, to: [to], subject: "🪄 Sign in to your layers account", htmlContent: htmlContent)

            let isSuccess = try await SendInBlue().sendEmail(email: email, client: request.client)

            guard isSuccess else {
                throw AuthenticationError.sendingAuthEmailFailed
            }

        default:
            request.logger.log(level: .info, "🪄 Sign in using code: \(code)")
        }

        return Handshake(session: session, email: user.email)

    }

    func magic(request: Request) async throws -> JWTToken {

        struct SettingsRequestData: Error, Content {
            var code: String
            var session: String

            enum CodingKeys: String, CodingKey {
                case code
                case session
            }
        }

        let requestData = try request.content.decode(SettingsRequestData.self)

        // 💿 Fetch authentication code
        guard var authCodeData = request.session.data["magic-code"] else {
            throw AuthenticationError.noAuthCodeForSession
        }
        
        let buffer = ByteBuffer(bytes: authCodeData.base64Bytes())
        var authCode = try JSONDecoder().decode(AuthenticationCode.self, from: buffer)
        
        // 👮‍♂️ Check if code was tries too much
        guard authCode.tries < 3 else {
            request.session.destroy()
            throw AuthenticationError.tooManyTries
        }

        // 🗓️ Check if code expired
        guard authCode.expiryDate > Date() else {
            request.session.destroy()
            throw AuthenticationError.codeExpired
        }

        // ⛔️ Validate code otherwise increment tries on session
        guard authCode.code.uppercased() == requestData.code.uppercased() else {
            authCode.tries+=1
            let json = try JSONEncoder().encode(authCode).base64String()
            request.session.data["magic-code"] = json
            throw AuthenticationError.incorrectCode
        }

        guard let user = try await User.find(authCode.userId, on: request.db) else {
            throw GenericError.userNotFound
        }
        
        // 🎉 Generate JWT token
        let fourtheenDays = Calendar.current.date(byAdding: .day, value: 14, to: Date()) ?? Date()

        let token = UserToken(
                subject: "Layers",
                expiration: .init(value: fourtheenDays),
                userId: authCode.userId,
                email: user.email,
                stripeCustomerId: user.stripeCustomerId
            )

        let signedToken = try request.jwt.sign(token)

        // 🗑️ Delete authentication session
        request.session.destroy()

        return JWTToken(jwt: signedToken)

    }

    // MARK: Helpers

    func getEmailUsername(_ s: String) -> String? {
        let parts = s.components(separatedBy: "@")
        return parts.first
    }

    func randomString(length: Int) -> String {
      let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map { _ in letters.randomElement()! })
    }

   // MARK: Context
    
    struct JWTToken: Content {
        var jwt: String

        enum CodingKeys: String, CodingKey {
            case jwt
        }
    }

    struct Handshake: Content {
        var session: String
        var email: String
    }

    struct EmailContext: Content {
        var name: String
        var code1: String
        var code2: String
        var code3: String
        var code4: String
        var code5: String
        var code6: String
    }

    struct AuthenticationTries: Content {
        var total: Int
    }

    struct AuthenticationCode: Content, Codable {
        var code: String
        var userId: Int
        var expiryDate: Date
        var tries: Int
        var isNewUser: Bool

        enum CodingKeys: String, CodingKey {
            case code
            case userId = "user_id"
            case expiryDate = "expiry_date"
            case tries = "tries"
            case isNewUser = "is_new_user"
        }
    }

}
