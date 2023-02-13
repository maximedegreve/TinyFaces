import Vapor

enum GenericError: AppError {
    case userNotFound
    case notAdmin
}

extension GenericError: AbortError {
    var status: HTTPResponseStatus {
        switch self {
        case .userNotFound:
            return .notFound
        case .notAdmin:
            return .forbidden
        }
    }

    var reason: String {
        switch self {
        case .userNotFound:
            return "No matching user found for the supplied token"
        case .notAdmin:
            return "Only admins can access this endpoint"
        }
    }

    var identifier: String {
        switch self {
        case .userNotFound:
            return "generic-1"
        case .notAdmin:
            return "generic-2"
        }
    }

    var suggestedFixes: [String] {
        switch self {
        case .userNotFound:
            return ["Authenticate again to ensure the correct user is embedded in your token."]
        case .notAdmin:
            return ["Sign in with a admin account to access this."]
        }
    }

}
