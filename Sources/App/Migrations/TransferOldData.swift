import Fluent

struct TransferOldData: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        
        database.query(OldAvatar.self).filter(\.$size == "original").with(\.$userId).all().flatMap { oldAvatars in
            
            return oldAvatars.map { oldAvatar in
                
                let oldUrl = "https://tinyfac.es/\(oldAvatar.url)"
                
                let newAvatar = Avatar(url: <#T##String#>, sourceId: <#T##Int#>, gender: <#T##Gender#>, quality: <#T##Int#>, approved: <#T##Bool#>)
            }
            
        }

    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.eventLoop.makeSucceededVoidFuture()
    }
}
