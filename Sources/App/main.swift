import Vapor
import VaporMySQL
import Sessions
import Foundation
import HTTP

let drop = Droplet()

// Leave uncommented for release
drop.log.enabled = LogLevel.all

let memory = MemorySessions()

try drop.addProvider(VaporMySQL.Provider.self)
drop.preparations.append(User.self)
drop.preparations.append(Avatar.self)

let sessions = SessionsMiddleware(sessions: memory)
drop.middleware.append(sessions)

// Web Side

let index = IndexController()
index.addRoutes(drop: drop)

let authentication = AuthenticationController()
authentication.addRoutes(drop: drop)

let newFace = NewFaceController()
newFace.addRoutes(drop: drop)

let admin = AdminController()
admin.addRoutes(drop: drop)

// API Side

drop.resource("api/users", UserController())


drop.run()
