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
    private let accountIdentifier = Environment.cloudflareAccountIdentifier
    private let apiUrl = "https://api.cloudflare.com/client/v4/accounts/"

    init() {}

    func upload(url: String, metaData: [String: Any], client: Client) async throws -> CloudflareResponse {

        let data = try JSONSerialization.data(withJSONObject: metaData, options: .prettyPrinted)
        let jsonString = String(data: data, encoding: .utf8)
        
        let body = CloudflareRequest(url: url, metadata: jsonString)

        let directUploadUrl = URI("\(apiUrl)\(accountIdentifier)/images/v1")
        let response = try await client.post(directUploadUrl) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: bearerToken)
            try req.content.encode(body, as: .formData)
        }
        
        return try response.content.decode(CloudflareResponse.self)

    }
    
    func upload(file: File, metaData: [String: Any], client: Client) async throws -> CloudflareResponse {

        let data = try JSONSerialization.data(withJSONObject: metaData, options: .prettyPrinted)
        let jsonString = String(data: data, encoding: .utf8)
        
        let body = CloudflareRequest(file: file, metadata: jsonString)

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
    
    func url(uuid: String, width: Int? = nil, height: Int? = nil, trim: CloudflareTrim? = nil, fit: CloudflareFit? = nil) -> String {
        
        let url = "\(Environment.apiUrl)/cdn-cgi/imagedelivery/\(Environment.cloudflareAccountHash)/\(uuid)/"
        
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

    private func generateSignedUrl(url: String) -> String? {
        
        // `url` is a full imagedelivery.net URL
        // e.g. https://imagedelivery.net/cheeW4oKsx5ljh8e8BoL2A/bc27a117-9509-446b-8c69-c81bfeac0a01/mobile
        guard var urlComps = URLComponents(string: url) else {
            return nil
        }
        
        // Epoch
        let currentDate = Date()
        let since1970 = currentDate.timeIntervalSince1970
        let epoch = Int(since1970)
        
        // Attach the expiration value to the `url`
        let expiration = 60 * 60 * 24; // 1 day
        let expiry = epoch + expiration;
        
        urlComps.queryItems?.append(URLQueryItem(name: "exp", value: String(expiry)))
        
        // `url` now looks like
        // https://imagedelivery.net/cheeW4oKsx5ljh8e8BoL2A/bc27a117-9509-446b-8c69-c81bfeac0a01/mobile?exp=1631289275

        // for example, /cheeW4oKsx5ljh8e8BoL2A/bc27a117-9509-446b-8c69-c81bfeac0a01/mobile?exp=1631289275
        var stringToSign = urlComps.path + "?"
        if let query = urlComps.query {
            stringToSign = stringToSign + query
        }

        let key = SymmetricKey(data: Data(bearerToken.utf8))
        let data = Data(stringToSign.utf8)
        let sign = Data(HMAC<Insecure.SHA1>.authenticationCode(for: data, using: key))
        let encodedSign = sign.base64EncodedString().replacingOccurrences(of: "+", with: "-").replacingOccurrences(of: "/", with: "_")
        
        urlComps.queryItems?.append(URLQueryItem(name: "sig", value: String(encodedSign)))

        return urlComps.string

    }
    
}
