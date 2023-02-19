//
//  File.swift
//  
//
//  Created by Maxime De Greve on 07/02/2023.
//

import Vapor

struct CloudflareImage: Content {
    var id: String
    var filename: String?
    var metadata: [String: String]?
    var requireSignedURLs: Bool
    var variants: [String]?
}
