import Fluent
import Vapor

struct MoveCloudinary: AsyncMigration {
    func prepare(on database: Database) async throws {
        let avatars = try await Avatar.query(on: database).all()
        
        for avatar in avatars {
            
            guard avatar.url.contains("https://res.cloudinary.com/tinyfac-es/image/") else  {
                continue
            }
            
            guard let filename = avatar.url.components(separatedBy: "facebook/").last else {
                continue
            }
            
            let newUrl = "https://storage.googleapis.com/tinyfaces/original-facebook/\(filename)"
            
            avatar.url = newUrl
            try await avatar.save(on: database)
            
        }
        
    }

    func revert(on database: Database) async throws {
        // Undo the change made in `prepare`, if possible.
    }
}
