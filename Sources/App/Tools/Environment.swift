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
    
    static var signer: String {
        Environment.get("SIGNER") ?? "RznZVJsxNFuOJSM6CBqwolzix4nRFb"
    }

    static var sendInBlueKey: String {
        Environment.get("SEND_IN_BLUE_KEY")!
    }
    
    static var stripePublishableKey: String {
        Environment.get("STRIPE_PUBLISH_KEY")!
    }
    static var stripeSecretKey: String {
        Environment.get("STRIPE_SECRET_KEY")!
    }
    
    static var stripeWebhookSecret: String {
        Environment.get("STRIPE_WEBHOOK_SECRET")!
    }
    
    static var stripePricingTableId: String {
        Environment.get("STRIPE_PRICINGTABLE_ID")!
    }

    // Cloudflare
    
    static var cloudflareAccountHash: String {
        Environment.get("CLOUDFLARE_ACCOUNT_HASH")!
    }
    
    static var cloudflareBearerToken: String {
        Environment.get("CLOUDFLARE_BEARER_TOKEN")!
    }
    
    static var cloudflareImagesKey: String {
        Environment.get("CLOUDFLARE_IMAGES_KEY")!
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
