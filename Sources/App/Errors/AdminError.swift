import Vapor

enum AdminError: AppError {
    case failedUpload
    case avatarNotFound
    case failedDelete
}

extension AdminError: AbortError {
    var status: HTTPResponseStatus {
        switch self {
        case .failedUpload:
            return .badRequest
        case .avatarNotFound:
            return .notFound
        case .failedDelete:
            return .badRequest
        }
    }

    var reason: String {
        switch self {
        case .failedUpload:
            return "Upload failed for some reason"
        case .failedDelete:
            return "Deleting avatar failed"
        case .avatarNotFound:
            return "Avatar not found"
        }
    }

    var identifier: String {
        switch self {
        case .failedUpload:
            return "admin-1"
        case .avatarNotFound:
            return "admin-2"
        case .failedDelete:
            return "admin-3"
        }
    }

    var suggestedFixes: [String] {
        switch self {
        case .failedUpload:
            return ["Try again."]
        case .avatarNotFound:
            return ["Use the correct id for the avatar"]
        case .failedDelete:
            return ["Try again"]
        }
    }

}
