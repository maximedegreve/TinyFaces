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
                    return seed(on: database, gender: .Female, filePath: "/Resources/Data/FirstNamesFemale.txt").flatMap { () in
                        return seed(on: database, gender: .Male, filePath: "/Resources//Data/FirstNamesMale.txt").flatMap { () in
                            return seed(on: database, gender: .Other, filePath: "/Resources/Data/FirstNamesOther.txt")
                        }
                    }
                }
        }
        
    }
    
    func seed(on database: Database, gender: Gender, filePath: String) -> EventLoopFuture<Void> {
        
        guard let txtFileContents = try? String(contentsOfFile: app.directory.workingDirectory + filePath, encoding: .utf8) else {
            return database.eventLoop.makeFailedFuture(Abort(.badRequest, reason: "File not found for seeding."))
        }
        
        let txtLines = txtFileContents.components(separatedBy: "\n").filter{!$0.isEmpty}
        return save(names: txtLines, index: 0, gender: gender, on: database)
    }
    
    func save(names: [String], index: Int, gender: Gender, on database: Database)  -> EventLoopFuture<Void> {
        
        guard let name = names[safe: index] else {
            return database.eventLoop.future()
        }
        
        let newName = FirstName(name: name, gender: gender)
        return newName.save(on: database).flatMap { () in
            return save(names: names, index: index + 1, gender: gender, on: database)
        }
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("last_names").delete()
    }
}
