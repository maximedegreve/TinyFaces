//
//  CloudinaryRequest.swift
//  App
//
//  Created by Maxime on 28/06/2020.
//

import Vapor

struct CloudinaryRequest: Error, Content {
    var apiKey: String
    var signature: String
    var file: File
    var timestamp: Int
    var folder: String?
    var eager: String?
    var publicId: String?
    var transformation: String?
    var allowedFormats: String?
    var format: String?

    enum CodingKeys: String, CodingKey {
        case file = "file"
        case apiKey = "api_key"
        case publicId = "public_id"
        case folder = "folder"
        case signature = "signature"
        case timestamp = "timestamp"
        case eager = "eager"
        case transformation = "transformation"
        case allowedFormats = "allowed_formats"
        case format = "format"
    }
}
