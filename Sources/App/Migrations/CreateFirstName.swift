import Fluent
import Vapor
struct CreateFirstName: Migration {
    
   var app: Application

   init(app: Application) {
    self.app = app
   }
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        
        database.enum("genders").read().flatMap { genderType in
            return database.schema("first_names")
                .field(.id, .int, .identifier(auto: true), .required)
                .field("name", .string, .required)
                .field("gender", genderType, .required)
                .field("created_at", .datetime)
                .field("updated_at", .datetime)
                .field("deleted_at", .datetime)
                .create().flatMap { () in
                    return seed(on: database, gender: .Female, filePath: "/Data/FirstNamesFemale.txt").flatMap { () in
                        return seed(on: database, gender: .Male, filePath: "/Data/FirstNamesMale.txt").flatMap { () in
                            return seed(on: database, gender: .Male, filePath: "/Data/FirstNamesOther.txt")
                        }
                    }
                }
        }
        
    }
    
    func seed(on database: Database, gender: Gender, filePath: String) -> EventLoopFuture<Void> {
        
        guard let txtFileContents = try? String(contentsOfFile: app.directory.workingDirectory + filePath, encoding: .utf8) else {
            return database.eventLoop.makeFailedFuture(Abort(.badRequest, reason: "File not found for seeding."))
        }
        
        let txtLines = txtFileContents.components(separatedBy: "\r").filter{!$0.isEmpty}
        
        return txtLines.compactMap { name in
            let newName = FirstName(name: name, gender: gender)
            return newName.save(on: database)
        }.flatten(on: database.eventLoop)

    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("last_names").delete()
    }
}
