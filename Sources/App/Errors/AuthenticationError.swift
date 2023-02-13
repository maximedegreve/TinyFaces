import Vapor

enum AuthenticationError: AppError {
    case sendingAuthEmailFailed
    case noAuthCodeForSession
    case tooManyTries
    case codeExpired
    case incorrectCode
}

extension AuthenticationError: AbortError {
    var status: HTTPResponseStatus {
        switch self {
        case .sendingAuthEmailFailed:
            return .unauthorized
        case .noAuthCodeForSession:
            return .unauthorized
        case .tooManyTries:
            return .unauthorized
        case .codeExpired:
            return .unauthorized
        case .incorrectCode:
            return .unauthorized
        }
    }

    var reason: String {
        switch self {
        case .sendingAuthEmailFailed:
            return "Sending authentication email failed"
        case .noAuthCodeForSession:
            return "Invalid or expired session"
        case .tooManyTries:
            return "Too many failed tries for current session"
        case .codeExpired:
            return "Your code is expired"
        case .incorrectCode:
            return "Incorrect code"
        }
    }

    var identifier: String {
        switch self {
        case .sendingAuthEmailFailed:
            return "auth-1"
        case .noAuthCodeForSession:
            return "auth-2"
        case .tooManyTries:
            return "auth-4"
        case .codeExpired:
            return "auth-5"
        case .incorrectCode:
            return "auth-6"
        }
    }

    var suggestedFixes: [String] {
        switch self {
        case .sendingAuthEmailFailed:
            return ["Try again on reach out to support if the issue persists."]
        case .noAuthCodeForSession:
            return ["Use /authenticate (POST) first to start a session."]
        case .tooManyTries:
            return ["Use /authenticate (POST) to start a new session."]
        case .codeExpired:
            return ["Use /authenticate (POST) to start a new session."]
        case .incorrectCode:
            return ["Make sure you are using the latest and correct code from your authentication email."]
        }
    }

}
