//
//  File.swift
//
//
//  Created by Maxime De Greve on 10/01/2023.
//

import Foundation
import Fluent

struct CreateUser: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        
        return database.schema("users")
                .field(.id, .int, .identifier(auto: true), .required)
                .field("name", .string, .required)
                .field("email", .string, .required)
                .field("stripe_customer_id", .string)
                .field("created_at", .datetime)
                .field("updated_at", .datetime)
                .field("deleted_at", .datetime)
                .unique(on: "stripe_customer_id")
                .create()

    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("users").delete()
    }
}
