import Fluent

struct TransferOldData: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        
        database.query(OldAvatar.self).filter(\.$size == "original").with(\.$userId).all().flatMap { oldAvatars in
            return migrateOldAvatars(oldAvatars: oldAvatars, database: database)
        }

    }
    
    func migrateOldAvatars(oldAvatars: [OldAvatar], database: Database) -> EventLoopFuture<Void> {
        
        return oldAvatars.map { oldAvatar in
            
            let oldUser = oldAvatar.userId
            let newAvatar = Avatar(url: "https://tinyfac.es/\(oldAvatar.url)", sourceId: 123, gender: .Male, quality: 10, approved: true)
            return newAvatar.save(on: database)
        }.flatten(on: database.eventLoop)
        
        
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.eventLoop.makeSucceededVoidFuture()
    }
}
