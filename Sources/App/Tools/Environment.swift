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
    
    static var thumborKey: String {
        Environment.get("THUMBOR_KEY")!
    }
    
    static var thumborUrl: String {
        Environment.get("THUMBOR_URL")!
    }

    static var sendInBlueKey: String {
        Environment.get("SEND_IN_BLUE_KEY")!
    }
    
    // Cloudflare
    
    static var cloudflareAccountHash: String {
        Environment.get("CLOUDFLARE_ACCOUNT_HASH")!
    }
    
    static var cloudflareBearerToken: String {
        Environment.get("CLOUDFLARE_BEARER_TOKEN")!
    }
    
    static var cloudflareAccountIdentifier: String {
        Environment.get("CLOUDFLARE_ACCOUNT_IDENTIFIER")!
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
