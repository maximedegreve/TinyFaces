//
//  File.swift
//  
//
//  Created by Maxime De Greve on 12/02/2023.
//

import Fluent

struct CreateAvatarAI: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.enum("genders").read().flatMap { genderType in
            database.enum("age_groups")
                         .case("baby")
                         .case("toddler")
                         .case("child")
                         .case("teenager")
                         .case("young_adult")
                         .case("middle_adult")
                         .case("old_adult")
                         .create().flatMap { ageGroup in
                             return database.schema("avatars_ai")
                                 .field(.id, .int, .identifier(auto: true), .required)
                                 .field("url", .string, .required)
                                 .field("approved", .bool, .required)
                                 .field("gender", genderType)
                                 .field("age_group", ageGroup)
                                 .field("created_at", .datetime)
                                 .field("updated_at", .datetime)
                                 .field("deleted_at", .datetime)
                                 .create()
                         }
        }
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("age_groups").delete().flatMap {
            database.enum("avatars_ai").delete()
        }
    }
}
