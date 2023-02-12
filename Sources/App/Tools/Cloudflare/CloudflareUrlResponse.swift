//
//  CloudinaryURLRequest.swift
//  App
//
//  Created by Maxime on 28/06/2020.
//

import Vapor

struct CloudflareUrlResponse: Error, Content {
    var result: CloudflareImage
    var success: Bool
    var errors: [CloudflareError]?
    var messages: [CloudflareMessage]?
}
