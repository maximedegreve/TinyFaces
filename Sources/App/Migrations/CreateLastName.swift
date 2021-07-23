import Fluent
import Vapor

struct CreateLastName: Migration {
    
   var app: Application

   init(app: Application) {
    self.app = app
   }
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("last_names")
            .field(.id, .int, .identifier(auto: true), .required)
            .field("name", .string, .required)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .field("deleted_at", .datetime)
            .create().flatMap { () in
                return seed(on: database, filePath: "/Resources/Data/LastNames.csv")
            }
    }
    
    
    func seed(on database: Database, filePath: String) -> EventLoopFuture<Void> {
        
        guard let csvFileContents = try? String(contentsOfFile: app.directory.workingDirectory + filePath, encoding: .utf8) else {
            return database.eventLoop.makeFailedFuture(Abort(.badRequest, reason: "File not found for seeding."))
        }
        
        let csvLines = csvFileContents.components(separatedBy: "\r").filter{!$0.isEmpty}
        return save(names: csvLines, index: 0, on: database)
    }
    
    func save(names: [String], index: Int, on database: Database)  -> EventLoopFuture<Void> {
        
        guard let name = names[safe: index] else {
            return database.eventLoop.future()
        }
        
        let newName = LastName(name: name)
        return newName.save(on: database).flatMap { () in
            return save(names: names, index: index + 1, on: database)
        }
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("last_names").delete()
    }
}
