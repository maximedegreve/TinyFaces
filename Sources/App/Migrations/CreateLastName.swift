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
                return seed(on: database, filePath: "/Data/LastNames.txt")
            }
    }
    
    
    func seed(on database: Database, filePath: String) -> EventLoopFuture<Void> {
        
        guard let txtFileContents = try? String(contentsOfFile: app.directory.workingDirectory + filePath, encoding: .utf8) else {
            return database.eventLoop.makeFailedFuture(Abort(.badRequest, reason: "File not found for seeding."))
        }
        
        let txtLines = txtFileContents.components(separatedBy: "\r").filter{!$0.isEmpty}
        
        return txtLines.compactMap { name in
            let newName = LastName(name: name)
            return newName.save(on: database)
        }.flatten(on: database.eventLoop)

    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("last_names").delete()
    }
}
