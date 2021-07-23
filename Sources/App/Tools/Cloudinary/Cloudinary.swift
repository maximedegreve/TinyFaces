//
//  Cloudinary.swift
//  App
//
//  Created by Maxime on 26/06/2020.
//

import Foundation
import Vapor
import Crypto

final public class Cloudinary {
    private let apiKey: String
    private let apiSecret: String
    private let cloudName: String
    private let url: String

    init() throws {

        guard let cloudinaryUrl = Environment.cloudinaryUrl else {
            throw Abort(.badRequest, reason: "Missing `CLOUDINARY_URL` environment variable.")
        }
        
        let url = URL(string: cloudinaryUrl)!

        self.cloudName = url.host!
        self.apiKey = String(url.user!)
        self.apiSecret = String(url.password!)
        self.url = "https://api.cloudinary.com/v1_1/\(cloudName)/image/upload"

    }

    func upload(file: File, eager: String?, publicId: String?, folder: String?, transformation: String?, format: String?, allowedFormats: String = "jpg,png", client: Client) -> EventLoopFuture<CloudinaryResponse> {

        let unixTimestamp = Int(Date().timeIntervalSince1970)

        let queryItems = [
            URLQueryItem(name: "allowed_formats", value: allowedFormats),
            URLQueryItem(name: "eager", value: eager),
            URLQueryItem(name: "folder", value: folder),
            URLQueryItem(name: "format", value: format),
            URLQueryItem(name: "public_id", value: publicId),
            URLQueryItem(name: "timestamp", value: "\(unixTimestamp)"),
            URLQueryItem(name: "transformation", value: transformation)
        ]

        let signature = createSignature(queryItems: queryItems, client: client)

        let body = CloudinaryRequest(apiKey: apiKey, signature: signature, file: file, timestamp: unixTimestamp, folder: folder, eager: eager, publicId: publicId, transformation: transformation, allowedFormats: allowedFormats, format: format)

        let request = client.post("\(self.url)") { req in
            try req.content.encode(body, as: .formData)
        }

        return request.flatMapThrowing { (response) -> CloudinaryResponse in
            return try response.content.decode(CloudinaryResponse.self)
        }

    }

    func upload(file: String, eager: String?, publicId: String?, folder: String?, transformation: String?, format: String?, allowedFormats: String = "jpg,png", client: Client) -> EventLoopFuture<CloudinaryResponse> {

        let unixTimestamp = Int(Date().timeIntervalSince1970)

        let queryItems = [
            URLQueryItem(name: "allowed_formats", value: allowedFormats),
            URLQueryItem(name: "eager", value: eager),
            URLQueryItem(name: "folder", value: folder),
            URLQueryItem(name: "format", value: format),
            URLQueryItem(name: "public_id", value: publicId),
            URLQueryItem(name: "timestamp", value: "\(unixTimestamp)"),
            URLQueryItem(name: "transformation", value: transformation)
        ]

        let signature = createSignature(queryItems: queryItems, client: client)

        let body = CloudinaryURLRequest(apiKey: apiKey, signature: signature, file: file, timestamp: unixTimestamp, folder: folder, eager: eager, publicId: publicId, transformation: transformation, allowedFormats: allowedFormats, format: format)

        let request = client.post("\(self.url)") { req in
            try req.content.encode(body, as: .formData)
        }

        return request.flatMapThrowing { (response) -> CloudinaryResponse in
            return try response.content.decode(CloudinaryResponse.self)
        }

    }

    private func createSignature(queryItems: [URLQueryItem], client: Client) -> String {

        let nonNilQueryItmes = queryItems.filter { (item) -> Bool in
            item.value != nil
        }
        var components = URLComponents()
        components.queryItems = nonNilQueryItmes

        var encrypt = apiSecret

        if let queryString = components.query {
            encrypt = queryString + apiSecret
        }

        let sha1 = Insecure.SHA1.hash(data: Data(encrypt.utf8))
        let sha1Hex = sha1.hexEncodedString()
        return sha1Hex
    }

}
