//
//  File.swift
//  
//
//  Created by Maxime De Greve on 07/02/2023.
//

import Vapor

struct CloudflareError: Content {
    var code: Int
    var message: String
}
