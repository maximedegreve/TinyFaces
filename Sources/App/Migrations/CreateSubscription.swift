//
//  File.swift
//
//
//  Created by Maxime De Greve on 10/01/2023.
//

import Foundation
import Fluent

struct CreateSubscription: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        
        return database.schema("subscriptions")
                .field(.id, .int, .identifier(auto: true), .required)
                .field("user_id", .int, .required, .references("users", "id"))
                .field("stripe_id", .string, .required)
                .field("stripe_plan_id", .string, .required)
                .field("stripe_status", .string, .required)
                .field("cancel_at_period_end", .bool, .required)
                .field("current_period_end", .datetime, .required)
                .field("canceled_at", .datetime)
                .create()

    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("subscriptions").delete()
    }
}
