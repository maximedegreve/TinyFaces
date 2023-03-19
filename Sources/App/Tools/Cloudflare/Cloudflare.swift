//
//  Cloudinary.swift
//  App
//
//  Created by Maxime on 26/06/2020.
//

import Foundation
import Vapor
import Crypto

final public class Cloudflare {
    private let bearerToken = Environment.cloudflareBearerToken
    private let imageKey = Environment.cloudflareImagesKey
    private let accountIdentifier = Environment.cloudflareAccountIdentifier
    private let apiUrl = "https://api.cloudflare.com/client/v4/accounts/"

    init() {}

    func upload(file: Data, metaData: [String: Any], requireSignedURLs: Bool, client: Client) async throws -> CloudflareResponse {

        let data = try JSONSerialization.data(withJSONObject: metaData, options: .prettyPrinted)
        let jsonString = String(data: data, encoding: .utf8)

        let body = CloudflareRequest(file: file, metadata: jsonString, requireSignedURLs: requireSignedURLs)

        let fileUploadUrl = URI("\(apiUrl)\(accountIdentifier)/images/v1")
        let response = try await client.post(fileUploadUrl) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: bearerToken)
            try req.content.encode(body, as: .formData)
        }

        return try response.content.decode(CloudflareResponse.self)

    }

    func delete(identifier: String, client: Client) async throws -> CloudflareResponse {

        let deleteUrl = URI("\(apiUrl)\(accountIdentifier)/images/v1/\(identifier)")
        let response = try await client.delete(deleteUrl) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: bearerToken)
        }

        return try response.content.decode(CloudflareResponse.self)

    }

    func url(uuid: String, variant: String) -> String {
        return "https://imagedelivery.net/\(Environment.cloudflareAccountHash)/\(uuid)/\(variant)"
    }

    func url(uuid: String, width: Int? = nil, height: Int? = nil, trim: CloudflareTrim? = nil, fit: CloudflareFit? = nil) -> String {

        let url = "https://imagedelivery.net/\(Environment.cloudflareAccountHash)/\(uuid)/"

        var options: [String] = []

        if let width = width {
            options.append("width=\(width)")
        }

        if let height = height {
            options.append("height=\(height)")
        }

        if let fit = fit {
            options.append("fit=\(fit.rawValue)")
        }

        if let trim = trim {
            options.append("trim=\(trim.top);\(trim.right);\(trim.bottom);\(trim.left)")
        }

        let optionsString = options.joined(separator: ",")

        return "\(url)\(optionsString)"
    }

    func generateSignedUrl(url: String) -> String? {

        // `url` is a full imagedelivery.net URL
        // e.g. https://imagedelivery.net/cheeW4oKsx5ljh8e8BoL2A/bc27a117-9509-446b-8c69-c81bfeac0a01/mobile
        guard let uri = URL(string: url) else {
            return nil
        }

        guard var components = URLComponents(url: uri, resolvingAgainstBaseURL: false) else {
            return nil
        }

        // Epoch
        let currentDate = Date()
        let since1970 = currentDate.timeIntervalSince1970
        let epoch = Int(since1970)

        let expiration = 60 * 60 * 24; // 1 day
        let expiry = epoch + expiration

        var queryItems = components.queryItems ?? []
        queryItems.append(URLQueryItem(name: "exp", value: String(expiry)))

        components.queryItems = queryItems

        let removeForSigning = "https://imagedelivery.net"
        guard let stringToSign = components.string?.replacingOccurrences(of: removeForSigning, with: "") else {
            return nil
        }

        guard let data = stringToSign.data(using: .utf8) else {
            return nil
        }

        guard let key: Data = imageKey.data(using: .utf8) else {
            return nil
        }

        let hmacKey = SymmetricKey(data: key)
        let sign = HMAC<SHA256>.authenticationCode(for: data, using: hmacKey)

        let encodedSign = sign.hexEncodedString()

        components.queryItems?.append(URLQueryItem(name: "sig", value: encodedSign))

        return components.string

    }

}
