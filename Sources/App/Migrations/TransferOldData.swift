import Vapor
import Fluent
import FluentMySQLDriver

struct TransferOldData: Migration {
    
   var app: Application

   init(app: Application) {
    self.app = app
   }
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {

        return database.query(OldAvatar.self).filter(\.$size == "original").with(\.$user).all().flatMap { oldAvatars in
            return migrateOldAvatars(oldAvatars: oldAvatars, database: database)
        }

    }
    
    func migrateOldAvatars(oldAvatars: [OldAvatar], database: Database) -> EventLoopFuture<Void> {
        
        return oldAvatars.map { oldAvatar in
            
            guard let oldUser = oldAvatar.user else {
                return database.eventLoop.future()
            }
            
            let source = Source(email: oldUser.email, platform: .Facebook, name: oldUser.name, externalId: oldUser.facebookId)
            
            return source.save(on: database).flatMap { Void in
                
                let gender: Gender = oldUser.gender == "female" ? .Female : .Male
                let url = "https://tinyfac.es/\(oldAvatar.url)"
                
                return Cloudinary().upload(file: url, eager: CloudinaryPresets.avatarMaxSize, publicId: nil, folder: "facebook", transformation: nil, format: "jpg", client: self.app.client).flatMap { response in
                    
                    let newAvatar = Avatar(url: response.secureUrl, sourceId: source.id!, gender: gender, quality: oldUser.quality, approved: oldUser.approved)
                    return newAvatar.save(on: database)

                }
                                
            }
            
        }.flatten(on: database.eventLoop)
        
        
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.eventLoop.makeSucceededVoidFuture()
    }
}
