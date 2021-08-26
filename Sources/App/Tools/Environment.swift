//
//  Environment.swift
//  App
//
//  Created by Maxime De Greve on 19/05/2019.
//

import Vapor

extension Environment {
    // Basics

    static var apiUrl: String {
        Environment.get("URL") ?? "https://tinyfac.es"
    }

    static var mysqlUrl: String? {
        Environment.get("MYSQL_URL")
    }

    static var cloudinaryUrl: String {
        Environment.get("CLOUDINARY_URL") ?? "cloudinary://138178815636837:6vkmvxx2lENXR8xev1hvsRunooc@tinyfac-es"
    }

    static var sendInBlueKey: String? {
        Environment.get("SEND_IN_BLUE_KEY")
    }

    static var facebookAppId: String {
        Environment.get("FACEBOOK_APP_ID") ?? "4100774536716138"
    }

    static var facebookSecret: String {
        Environment.get("FACEBOOK_SECRET") ?? "a69c56b5eb5a876197cc1fbb638a45c3"
    }

    // Only for development

    static var localClientURI: String {
        "http://localhost:3000"
    }

    static var developmentMySQLUsername: String {
        "vapor_username"
    }

    static var developmentMySQLPassword: String {
        "vapor_password"
    }

    static var developmentMySQLDatabase: String {
        "vapor_database"
    }

}
