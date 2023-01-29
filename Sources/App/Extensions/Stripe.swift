import Vapor
import StripeKit

extension Application {
    public var stripe: StripeClient {
        return .init(httpClient: self.http.client.shared,
                     eventLoop: self.eventLoopGroup.next(),
                     apiKey: Environment.stripeSecretKey)
    }
}

extension Request {
    private struct StripeKey: StorageKey {
        typealias Value = StripeClient
    }
    public var stripe: StripeClient {
        if let existing = application.storage[StripeKey.self] {
            return existing.hopped(to: self.eventLoop)
        } else {
            let new = StripeClient(httpClient: self.application.http.client.shared,
                                   eventLoop: self.eventLoop,
                                   apiKey: Environment.stripeSecretKey)
            self.application.storage[StripeKey.self] = new
            return new
        }
    }
}

extension StripeClient {
    /// Verifies a Stripe signature for a given `Request`. This automatically looks for the header in the headers of the request and the body.
    /// - Parameters:
    ///     - req: The `Request` object to check header and body for
    ///     - secret: The webhook secret used to verify the signature
    ///     - tolerance: In seconds the time difference tolerance to prevent replay attacks: Default 300 seconds
    /// - Throws: `StripeSignatureError`
    public static func verifySignature(for req: Request, secret: String, tolerance: Double = 300) throws {
        guard let header = req.headers.first(name: "Stripe-Signature") else {
            throw StripeSignatureError.unableToParseHeader
        }
        
        guard let data = req.body.data else {
            throw StripeSignatureError.noMatchingSignatureFound
        }
        
        try StripeClient.verifySignature(payload: Data(data.readableBytesView), header: header, secret: secret, tolerance: tolerance)
    }
}

extension StripeSignatureError: AbortError {
    public var reason: String {
        switch self {
        case .noMatchingSignatureFound:
            return "No matching signature was found"
        case .timestampNotTolerated:
            return "Timestamp was not tolerated"
        case .unableToParseHeader:
            return "Unable to parse Stripe-Signature header"
        }
    }
    
    public var status: HTTPResponseStatus {
        .badRequest
    }
}
