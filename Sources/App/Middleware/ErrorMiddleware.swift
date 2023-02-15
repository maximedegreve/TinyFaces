import Vapor

struct ErrorResponse: Codable {
    var error: Bool
    var reason: String
    var suggestedFixes: [String]?
    var errorCode: String?

    enum CodingKeys: String, CodingKey {
        case error
        case reason
        case suggestedFixes = "suggested_fixes"
        case errorCode = "error_code"
    }
}

extension ErrorMiddleware {
    static func `custom`(environment: Environment) -> ErrorMiddleware {
        return .init { req, error in
            let status: HTTPResponseStatus
            let reason: String
            let suggestedFixes: [String]?
            let headers: HTTPHeaders
            let errorCode: String?

            switch error {
            case let appError as AppError:
                reason = appError.reason
                status = appError.status
                suggestedFixes = appError.suggestedFixes
                headers = appError.headers
                errorCode = appError.identifier
            case let abort as AbortError:
                reason = abort.reason
                status = abort.status
                suggestedFixes = nil
                headers = abort.headers
                errorCode = nil
            case let error as LocalizedError where !environment.isRelease:
                reason = error.localizedDescription
                status = .internalServerError
                headers = [:]
                suggestedFixes = nil
                errorCode = nil
            default:
                reason = "Something went wrong."
                status = .internalServerError
                headers = [:]
                suggestedFixes = nil
                errorCode = nil
            }

            // Report the error to logger.
            req.logger.report(error: error)

            // create a Response with appropriate status
            let response = Response(status: status, headers: headers)

            // attempt to serialize the error to json
            do {
                let errorResponse = ErrorResponse(error: true, reason: reason, suggestedFixes: suggestedFixes, errorCode: errorCode)
                response.body = try .init(data: JSONEncoder().encode(errorResponse))
                response.headers.replaceOrAdd(name: .contentType, value: "application/json; charset=utf-8")
            } catch {
                response.body = .init(string: "Oops: \(error)")
                response.headers.replaceOrAdd(name: .contentType, value: "text/plain; charset=utf-8")
            }
            return response
        }
    }
}
