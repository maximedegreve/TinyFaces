//
//  CloudinaryURLRequest.swift
//  App
//
//  Created by Maxime on 28/06/2020.
//

import Vapor

struct CloudflareRequest: Error, Content {
    var file: Data
    var metadata: String?
    var requireSignedURLs: Bool
}
