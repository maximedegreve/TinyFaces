//
//  CloudinaryResponse.swift
//  App
//
//  Created by Maxime on 28/06/2020.
//

import Vapor

struct CloudinaryResponse: Error, Content {
    var secureUrl: String

    enum CodingKeys: String, CodingKey {
        case secureUrl = "secure_url"
    }
}
