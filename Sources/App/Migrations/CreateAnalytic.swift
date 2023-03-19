//
//  File.swift
//  
//
//  Created by Maxime De Greve on 10/01/2023.
//

import Foundation
import Fluent

struct CreateAnalytic: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {

        return database.schema("analytics")
                .field(.id, .int, .identifier(auto: true), .required)
                .field("ip", .string, .required)
                .field("date", .date, .required)
                .field("requests", .int, .required)
                .create()

    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("analytics").delete()
    }
}
