import Vapor

enum GenericError: AppError {
    case userNotFound
}

extension GenericError: AbortError {
    var status: HTTPResponseStatus {
        switch self {
        case .userNotFound:
            return .notFound
        }
    }

    var reason: String {
        switch self {
        case .userNotFound:
            return "No matching user found for the supplied token"
        }
    }

    var identifier: String {
        switch self {
        case .userNotFound:
            return "generic-1"
        }
    }

    var suggestedFixes: [String] {
        switch self {
        case .userNotFound:
            return ["Authenticate again to ensure the correct user is embedded in your token."]
        }
    }

}
