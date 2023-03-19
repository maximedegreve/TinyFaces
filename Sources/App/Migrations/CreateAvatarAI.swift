//
//  File.swift
//  
//
//  Created by Maxime De Greve on 12/02/2023.
//

import Fluent

struct CreateAvatarAI: AsyncMigration {

    func prepare(on database: Database) async throws {

        let genders = try await database.enum("genders").read()

        let ageGroups = try await database.enum("age_groups")
            .case("baby")
            .case("toddler")
            .case("child")
            .case("teenager")
            .case("young_adult")
            .case("middle_adult")
            .case("old_adult")
            .create()

        let styles = try await database.enum("styles")
            .case("colorful")
            .case("neutral")
            .case("urban")
            .create()

        let origins = try await database.enum("origins")
            .case("alaskan")
            .case("balkan")
            .case("german")
            .case("nigerian")
            .case("turkish")
            .case("spanish")
            .case("italian")
            .case("french")
            .case("british")
            .case("polish")
            .case("chinese")
            .case("filipino")
            .case("indonesian")
            .case("japanese")
            .case("korean")
            .case("malaysian")
            .case("vietnamese")
            .case("indian")
            .case("scandinavian")
            .case("brazilian")
            .case("mexican")
            .case("black-american")
            .case("white-american")
            .case("hawaiian")
            .create()

        return try await database.schema("avatars_ai")
            .field(.id, .int, .identifier(auto: true), .required)
            .field("url", .string, .required)
            .field("approved", .bool, .required)
            .field("gender", genders)
            .field("style", styles)
            .field("age_group", ageGroups)
            .field("origin", origins)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .field("deleted_at", .datetime)
            .create()

    }

    func revert(on database: Database) async throws {
        try await database.schema("avatars_ai").delete()
        try await database.enum("origins").delete()
        try await database.enum("styles").delete()
        try await database.enum("age_groups").delete()
        try await database.enum("genders").delete()
    }

}
